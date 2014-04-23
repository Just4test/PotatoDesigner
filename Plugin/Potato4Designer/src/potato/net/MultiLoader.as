package potato.net
{
	import core.events.Event;
	import core.events.EventDispatcher;
	import core.events.IOErrorEvent;
	import core.events.ProgressEvent;
	import core.system.Domain;
	
	import potato.events.HttpEvent;
	import potato.logger.Logger;

	[Event(name="allLoadComplete", type="potato.events.HttpEvent")]
	[Event(name="resLoadComplete", type="potato.events.HttpEvent")]
	[Event(name="resLoadField", type="potato.events.HttpEvent")]
	[Event(name="resLoadProgress", type="potato.events.HttpEvent")]
	
	/**
	 * 多线队列下载器
	 */
	public class MultiLoader extends EventDispatcher
	{
		private static var log:Logger = Logger.getLog("MultiLoader");
		
		/**最大同事下载数量*/
		private const MAX:int = 2;
		/**最大重试次数*/
		private const MAXRETRY:int = 3;
		
		
		/**正在下载的加载器*/
		private var ingLoader:Array;
		
		/**全部下载任务*/
		private var allReqLoad:Vector.<String>;
		/**全部下载文件的md5*/
		private var allReqMd5:Object;
		
		/**
		 * 下载文件的下载次数
		 */		
		private var retryMap:Object;
		
		/**
		 * 资源根路径
		 */		
		private var resRoot:String;
		
		/**
		 * 资源版本，所有资源是统一的
		 */		
		private var _ver:int = 0;
		
		/**
		 * 构造方法	单例模式，请用getInstance 
		 * @param ver 资源的版本
		 */		
		public function MultiLoader(ver:int)
		{
			allReqLoad = new Vector.<String>();
			allReqMd5 = new Object();
			ingLoader = [];
			retryMap = new Object();
			
			resRoot = HttpConst.urlHead;
			
			_ver = ver;
		}
		
		/**
		 * 添加一个下载。只用于资源更新下载，没有排除重复处理。
		 * @param url	下载路径
		 * @return 		当前下载的唯一标识
		 */
		public function push(url:String, md5:String=null):void
		{
			log.debug("**** pushpushpush", url);
			allReqLoad.push(url);
			allReqMd5[url] = md5;
			load();
		}
		
		/**
		 * lqs
		 *向前添加一个下载资源， 
		 * @param url
		 * @param md5
		 * 
		 */		
		public function unShift(url:String, md5:String=null):void
		{
			log.debug("**** unShift", url);
			allReqLoad.unshift(url);
			allReqMd5[url] = md5;
			load();
		}
		/**
		 * 开始下载 
		 */		
		private function load():void
		{
			trace("开始下载",ingLoader.length,MAX);
			if(ingLoader.length < MAX)
			{
				addLoader();
			}
			//			print("当前", ing.length, " 全部 ", all.length);
		}
		
		/**
		 * 添加一个下载 
		 */
		private function addLoader():void
		{
			if (allReqLoad.length > 0)
			{
				var url:String = allReqLoad.shift();
				var verStr:String;
				
				if (retryMap[url]) {
					retryMap[url] += 1;
					verStr = "?v=" + Math.random(); //防止系统缓存，重试时使用随机数
				} else {
					retryMap[url] = 1;
					verStr = "?v=" + _ver;
				}
				
				var ld:Download = new Download();
				ld.addEventListener(IOErrorEvent.IO_ERROR, ioerror);
				ld.addEventListener(ProgressEvent.PROGRESS, progress);
				ld.addEventListener(Event.COMPLETE, complete);
				ld.load(resRoot, url, verStr, allReqMd5[url]);
				ingLoader.push(ld);
			} else {	//已经全部下载完
				if (ingLoader.length == 0) {
					var loadedNum:int = 0;	//下载正确完成的文件数（出错次数没超过MAXRETRY）
					var totalNum:int = 0;	//本次总共下载的文件数
					for (var s:String in retryMap) {
						totalNum++;
						if (retryMap[s] <= MAXRETRY) {
							loadedNum++;
						}
					}
					// 全部下载完成
					log.debug("全部下载完: 总数 / 成功下载 / 出错忽略", totalNum, loadedNum, totalNum-loadedNum);
					trace("全部下载完: 总数 / 成功下载 / 出错忽略", totalNum, loadedNum, totalNum-loadedNum);
					dispatchEvent(new HttpEvent(HttpEvent.ALL_LOAD_COMPLETE, "", loadedNum, totalNum));
				}
			}
		}
		
		/**
		 * 下载错误. 
		 */		
		private function ioerror(e:IOErrorEvent):void
		{
			var ld:Download = e.target as Download;
			stopLoad(e.target as Download);
			
			//			Log.debug("ioerror", e.toString(), retryMap[ld.fileUrl], MAXRETRY);
			
			// 出错重试 
			if (retryMap[ld.fileUrl] < MAXRETRY) {
				push(ld.fileUrl, allReqMd5[ld.fileUrl]);
			} else {
				retryMap[ld.fileUrl]++;
				dispatchEvent(new HttpEvent(HttpEvent.RES_LOAD_FAILED, ld.fileUrl));
			}
			
			load();
		}
		
		/**
		 * 下载进度.
		 */
		private function progress(e:ProgressEvent):void
		{
			var ld:Download = e.target as Download;
			dispatchEvent(new HttpEvent(HttpEvent.RES_LOAD_PROGRESS, ld.fileUrl, ld.bytesLoaded, ld.bytesTotal));
		}
		
		/**
		 * 下载完成.
		 */		
		private function complete(e:Event):void
		{
			//			print("下载完成的 ", e.target.fileUrl);
			var ld:Download = e.target as Download;
			dispatchEvent(new HttpEvent(HttpEvent.RES_LOAD_COMPLETE, ld.fileUrl));
			stopLoad(ld);
			load();
		}
		
		private function stopLoad(loader:Download):void
		{
			var index:int = ingLoader.indexOf(loader);
			ingLoader.splice(index, 1);
			
			loader.removeEventListener(IOErrorEvent.IO_ERROR, ioerror);
			loader.removeEventListener(ProgressEvent.PROGRESS, progress);
			loader.removeEventListener(Event.COMPLETE, complete);
		}
		
		/**
		 * 正在下载的文件数 
		 * @return 
		 */		
		public function loadingCnt():int {
			return ingLoader.length;
		}
		
		/**
		 *停止当前加载 @lqs 
		 */		
		public function stop():void
		{
			for each(var ld:Download in ingLoader)
			{
				stopLoad(ld);
				allReqLoad.unshift(ld.fileUrl);
			}
		}
	}
}