package potato.events
{
	import core.events.Event;
	
	
	/**
	 * http请求事件
	 * Jun 17, 2012
	 */
	public class HttpEvent extends Event
	{
		/**
		 * 资源全部下载完成
		 * 该事件中的loaded和total表示已下载的文件数和总文件数，两个值的差即是出错忽略掉的文件数
		 */
		public static const ALL_LOAD_COMPLETE:String = "allLoadComplete";
		/**资源下载完成*/
		public static const RES_LOAD_COMPLETE:String = "resLoadComplete";
		/**资源下载失败*/
		public static const RES_LOAD_FAILED:String = "resLoadFailed";
		/**资源下载进度*/
		public static const RES_LOAD_PROGRESS:String = "resLoadProgress";
		
		private var _url:String;
		
		private var _loaded:int;
		private var _total:int;
		
		/**
		 * 下载事件 
		 * @param type		类型
		 * @param t			token
		 * @param loaded	下载字节数
		 * @param total		总共字节数
		 */		
		public function HttpEvent(type:String, url:String, loaded:int = 0, total:int = 0)
		{
			_url = url;
			
			_loaded = loaded;
			_total = total;
			super(type, false);
		}
		
		override public function clone():Event
		{
			return new HttpEvent(type, _url, _loaded, _total);
		}
		
		public function get url():String
		{
			return _url;
		}
	}
}