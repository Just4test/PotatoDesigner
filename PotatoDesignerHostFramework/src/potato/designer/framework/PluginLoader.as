package potato.designer.framework
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import deng.fzip.FZip;
	import deng.fzip.FZipErrorEvent;
	import deng.fzip.FZipEvent;
	
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name=EVENT_FAIL, type="potato.designer.framework.PluginLoader")]
	/**
	 *载入宿主端插件。包含解压缩swc提取swf，载入swf到domain的操作。 
	 * @author Administrator
	 * 
	 */
	public class PluginLoader extends EventDispatcher
	{
		private var _fZipLoader:FZip;
		private var _loader:Loader;
		private var _pluginInfo:PluginInfo;
		private var _domain:ApplicationDomain;
		
		public static const EVENT_FAIL:String = "EVENT_FAIL"
		
		public function PluginLoader(pluginInfo:PluginInfo, domain:ApplicationDomain)
		{
			_pluginInfo = pluginInfo;
			_domain = domain;
			
			_fZipLoader = new FZip();
			_fZipLoader.load(new URLRequest(_pluginInfo.filePath));
			_fZipLoader.addEventListener(Event.COMPLETE, onUnzipCompleteHandler);
//			_fZipLoader.addEventListener(FZipEvent.FILE_LOADED, onFailHandler);
			_fZipLoader.addEventListener(FZipErrorEvent.PARSE_ERROR, onFailHandler);
			_fZipLoader.addEventListener(IOErrorEvent.IO_ERROR, onFailHandler);
			_fZipLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onFailHandler);
		}
		
		private function onUnzipCompleteHandler(e:Event):void
		{
			var swfData:ByteArray = _fZipLoader.getFileByName("library.swf").content;//取swf内容
			_fZipLoader.removeEventListener(Event.COMPLETE, onUnzipCompleteHandler);
//			_fZipLoader.removeEventListener(FZipEvent.FILE_LOADED, onFailHandler);
			_fZipLoader.removeEventListener(FZipErrorEvent.PARSE_ERROR, onFailHandler);
			_fZipLoader.removeEventListener(IOErrorEvent.IO_ERROR, onFailHandler);
			_fZipLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onFailHandler);
			_fZipLoader = null;
			//
			_loader = new Loader();
			var context:LoaderContext = new LoaderContext(false, _domain);
			context.allowCodeImport = true;
			_loader.loadBytes(swfData, context);//加载到域
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFailHandler);
		}
		
		private function onLoaderCompleteHandler(e:Event):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onFailHandler);
			_loader = null;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onFailHandler(e:Event):void
		{	
			if(_fZipLoader)
			{
				_fZipLoader.removeEventListener(Event.COMPLETE, onUnzipCompleteHandler);
//				_fZipLoader.removeEventListener(FZipEvent.FILE_LOADED, onFailHandler);
				_fZipLoader.removeEventListener(FZipErrorEvent.PARSE_ERROR, onFailHandler);
				_fZipLoader.removeEventListener(IOErrorEvent.IO_ERROR, onFailHandler);
				_fZipLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onFailHandler);
				_fZipLoader = null;
			}
			if(_loader)
			{
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onFailHandler);
				_loader = null;
			}
			dispatchEvent(new Event(EVENT_FAIL));
		}

		public function get pluginInfo():PluginInfo
		{
			return _pluginInfo;
		}

		public function get domain():ApplicationDomain
		{
			return _domain;
		}


	}
}