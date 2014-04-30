package potato.designer.framework
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name=EVENT_FAIL, type="potato.designer.framework.PluginLoader")]
	/**
	 *载入宿主端插件。包含解压缩swc提取swf，载入swf到domain的操作。 
	 * @author Administrator
	 * 
	 */
	public class PluginLoader extends EventDispatcher
	{
		private var _loader:Loader;
		private var _pluginInfo:PluginInfo;
		private var _domain:ApplicationDomain;
		
		public static const EVENT_FAIL:String = "EVENT_FAIL";
		
		public function load(pluginInfo:PluginInfo, domain:ApplicationDomain):void
		{
			if(_loader)
			{
				throw new Error("上一次的载入过程还没有完成");
			}
			
			_pluginInfo = pluginInfo;
			_domain = domain;
			
			
			var pluginFile:File = new File(pluginInfo.filePath);
			var fileStream:FileStream = new FileStream();
			fileStream.open(pluginFile, FileMode.READ);
			
			var bytes:ByteArray = new ByteArray;
			fileStream.readBytes(bytes);
			
			
			if("swc" == pluginFile.extension)
			{
				bytes = Utils.unzipSWC(bytes);
				if(!bytes)
				{
					dispatchEvent(new DesignerEvent(EVENT_FAIL, "解压缩错误"));
				}
			}
			
			_loader = new Loader();
			var context:LoaderContext = new LoaderContext(false, _domain);
			context.allowCodeImport = true;
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFailHandler);
			_loader.loadBytes(bytes, context);//加载到域
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
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onFailHandler);
			_loader = null;
			
			var reason:String;
			switch(e.type)
			{
				case IOErrorEvent.IO_ERROR:
					reason = "IO错误";
					break
				default:
					reason = e.toString();
			}
			dispatchEvent(new DesignerEvent(EVENT_FAIL, reason));
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