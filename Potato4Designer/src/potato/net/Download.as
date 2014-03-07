package potato.net
{
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import core.events.Event;
	import core.events.EventDispatcher;
	import core.events.HTTPStatusEvent;
	import core.events.IOErrorEvent;
	import core.events.ProgressEvent;
	import core.filesystem.File;
	import core.net.URLRequest;
	import core.net.URLStream;
	import core.system.System;
	import core.utils.MD5;
	
	import potato.logger.Logger;

	/**
	 * 在出现输入/输出错误并导致发送或加载操作失败时调度。
	 * @eventType core.events.IOErrorEvent.IO_ERROR
	 */
	[Event(name="ioError", type = "core.events.IOErrorEvent")]
	
	/**
	 * 在下载操作过程中收到数据时调度。 可以使用 URLStream 类方法立即读取已接收的数据。
	 * @eventType core.events.ProgressEvent.PROGRESS
	 */
	[Event(name="progress", type = "core.events.ProgressEvent")]
	
	/**
	 * 成功加载数据后调度。
	 * @eventType core.events.Event.COMPLETE
	 */
	[Event(name="complete", type = "core.events.Event")]
	
	/**
	 * 下载器
	 * @author Floyd
	 * May 22, 2012
	 */
	public class Download extends EventDispatcher
	{
		private static var log:Logger = Logger.getLog("Download");
		
		private var _urlStream:URLStream;
		
		private var _urlHead:String;
		/**配置文件中的路径*/
//		private var _filePath:String;
		/**文件的md5*/
		private var _md5:String;
		/**资源版本*/
		private var _verStr:String;
		/**文件的完整路径*/
		private var _url:String;
		
		/**当前已经下载的字节*/
		private var _bytesLoaded:int;
		/**总共需要下载字节*/
		private var _bytesTotal:int;
		/**是否下载完成*/
		private var _loaded:Boolean;
		
		private var status:int = -1;
		
//		private static var writeFileWorker:Worker;
		
		public function Download()
		{
//			if ( !writeFileWorker)
//			{
//				writeFileWorker = WorkerDomain.current.createWorkerFromPrimordial();
//				writeFileWorker.setSharedProperty("count", 1);
//				writeFileWorker.setSharedProperty("fn", "asdfasdf");
//				
//				writeFileWorker.start();
//				log.debug("启动线程");
//				Stage.getStage().addEventListener(Event.ENTER_FRAME, workerCmd);
//			}
			_urlStream = new URLStream();
			_urlStream.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
			_urlStream.addEventListener(IOErrorEvent.IO_ERROR, ioerror);
			_urlStream.addEventListener(ProgressEvent.PROGRESS, progress);
			_urlStream.addEventListener(Event.COMPLETE, complete);
		}
		
//		private static function workerCmd(e:Event):void
//		{
//			var c:int = writeFileWorker.getSharedProperty("count");
//			log.debug(c, count, writeFileWorker.getSharedProperty("write"));
//			if(c > count)
//			{
//				if(callback != null)//写入完成一个
//				{
//					callback();
//					callback = null;
//				}
//				
//				if (files.length > 0)
//				{
//					count ++;
//					
//					var fn:String = files.shift();
//					var data:ByteArray = datas.shift();
//					callback = callBacks.shift();
//					writeFileWorker.setSharedProperty("fn", fn);
//					writeFileWorker.setSharedProperty("data", data);
//					writeFileWorker.setSharedProperty("write", true);
//				}
//			}
//		}
//		
//		private static var files:Array = [];
//		private static var datas:Array = [];
//		private static var callBacks:Array = [];
//		private static var callback:Function;
//		private static var count:int = 0;
//		
//		private static function push(fn:String, data:ByteArray, callback:Function):void
//		{
//			files.push(fn);
//			datas.push(data);
//			callBacks.push(callback);
//		}
//		
		
		/**
		 * 开始下载
		 * @param urlHead		加载路径头
		 * @param path			相对路径
		 */
		public function load(urlHead:String, path:String, verStr:String, md5:String=null):void
		{
			_urlHead = urlHead;
//			_filePath = path;
			_verStr = verStr;
			_md5 = md5;
			_url = path;
			
			var request:URLRequest = new URLRequest(urlHead + _url + verStr);
			_urlStream.load(request);
		}
		
		
		private function httpStatus(e:HTTPStatusEvent):void
		{
			status = e.status;
			
			if (status != 200 && status != 0) {
				ioerror(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, "Status is not 200."));
			}
		}
		
		private function ioerror(e:IOErrorEvent):void
		{
			log.debug("下载错误 ", _urlHead, _url, status, e.text, "[", getTimer(), " ]");
			_urlStream.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
			_urlStream.removeEventListener(IOErrorEvent.IO_ERROR, ioerror);
			_urlStream.removeEventListener(ProgressEvent.PROGRESS, progress);
			_urlStream.removeEventListener(Event.COMPLETE, complete);
			
			this.dispatchEvent(e);
		}
		
		
		private function progress(e:ProgressEvent):void
		{
			// 没考虑个别情况下，服务器不返回 bytesTotal
			if(_bytesLoaded > _urlStream.bytesAvailable)
				_bytesLoaded = _urlStream.bytesAvailable;
			if(_bytesTotal > e.bytesTotal)
				_bytesTotal = e.bytesTotal;
			this.dispatchEvent(e);
		}
		
		private function complete(e:Event):void
		{
			//			print("下载完成", _url + _filePath);
			if (status == 200 || status == 0)
			{
				var bytes:ByteArray = new ByteArray();
				_urlStream.readBytes(bytes, 0, _urlStream.bytesAvailable);
				
				if (_md5) {
					//先验证md5
					var md5Util:MD5 = new MD5();
					md5Util.hash(bytes);
					if (md5Util.toString() != _md5) { //下载的文件有错误
						System.nativeCall("MobiFunUMevent", ["FILE_MD5_ERROR"]);		//umeng统计
						ioerror(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, "MD5 is not matching."));
						return;
					}
				}
//				bytes.shareable = true;
//				push(_url, bytes, dispatchEventComplete);
				
				// 扩展名为 .m3z 的为zlib压缩文件
				var extIndex:int = _url.indexOf(".m3z"); 		// zlib 压缩文件
				if (extIndex > 0 && extIndex == _url.length - 4) {
					bytes.uncompress();
					_url = _url.substring(0, extIndex);
				}
				
				createPathForder(_url);
				File.writeByteArray(_url, bytes);
				dispatchEventComplete();
			}
		}
		
		private function dispatchEventComplete():void
		{
			_urlStream.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
			_urlStream.removeEventListener(IOErrorEvent.IO_ERROR, ioerror);
			_urlStream.removeEventListener(ProgressEvent.PROGRESS, progress);
			_urlStream.removeEventListener(Event.COMPLETE, complete);
			_loaded = true;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function get bytesLoaded():int
		{
			return _bytesLoaded;
		}
		
		public function get bytesTotal():int
		{
			return _bytesTotal;
		}
		
		public function get fileUrl():String
		{
			return _url;
		}
		
		/**
		 * 根据路径创建文件夹
		 * @param path
		 */
		public function createPathForder(path:String):void
		{
			var forders:Array = path.split("/");
			var len:int = forders.length - 1;	// 最后一个一定是文件名
			var forderPath:String = "";
			for (var i:int = 0; i < len; i++)
			{
				forderPath += forders[i] + "/";
				File.createDirectory(forderPath);
			}
		}
		
		public function stop():void
		{
			_urlStream.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
			_urlStream.removeEventListener(IOErrorEvent.IO_ERROR, ioerror);
			_urlStream.removeEventListener(ProgressEvent.PROGRESS, progress);
			_urlStream.removeEventListener(Event.COMPLETE, complete);
			_urlStream.close();
		}
	}
}