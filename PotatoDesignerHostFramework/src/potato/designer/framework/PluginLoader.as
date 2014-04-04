package potato.designer.framework
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import deng.fzip.FZip;
	
	
	[Event(name="complete", type="flash.events.Event")]
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
		
		public function PluginLoader(pluginInfo:PluginInfo, domain:ApplicationDomain)
		{
			_pluginInfo = pluginInfo;
			_domain = domain;
			
			var fZipLoader:FZip = new FZip();
			fZipLoader.load(new URLRequest(_pluginInfo.filePath));
			fZipLoader.addEventListener(Event.COMPLETE, onUnzipCompleteHandler);
		}
		
		private function onUnzipCompleteHandler(e:Event):void
		{
			var swfData:ByteArray = _fZipLoader.getFileByName("library.swf").content;//取swf内容
			_fZipLoader.removeEventListener(Event.COMPLETE, onUnzipCompleteHandler);
			
			_fZipLoader = null;
			//
			_loader = new Loader();
			_loader.loadBytes(swfData,new LoaderContext(false, ApplicationDomain.currentDomain));//加载到域
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderCompleteHandler);
		}
		
		private function onLoaderCompleteHandler(e:Event):void
		{
			_loader.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			_loader = null;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function get pluginInfo():PluginInfo
		{
			return _pluginInfo;
		}

	}
}