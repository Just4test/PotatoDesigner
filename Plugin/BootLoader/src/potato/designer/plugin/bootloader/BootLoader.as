package potato.designer.plugin.bootloader
{
	import core.display.DisplayObject;
	import core.display.Stage;
	import core.filesystem.File;
	import core.system.Domain;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.plugin.guestManager.GuestManagerGuest;
	
	public class BootLoader implements IPluginActivator
	{
		protected var _info:PluginInfo
		public function start(info:PluginInfo):void
		{
			_info = info;
			EventCenter.addEventListener(GuestManagerGuest.EVENT_HOST_DISCOVERED, hostDiscoverdHandler);
			GuestManagerGuest.startHostDiscovery();
			
		}
		
		protected function hostDiscoverdHandler(event:DesignerEvent):void
		{
			if(event.data.length)
			{
				EventCenter.addEventListener(GuestManagerGuest.EVENT_HOST_CONNECTED, connectedHandler);
				GuestManagerGuest.tryConnect(event.data[0]);
				GuestManagerGuest.stopHostDiscovery();
			}
		}
		
		protected function connectedHandler(event:DesignerEvent):void
		{
			log("尝试启动Main.swf");
			if(run("Main.swf", _info.getAbsolutePath("library.swf")))
			{
				log("成功加载Main.swf");
				_info.started();
			}
		}
		
		public function run(mainPath:String, overridePath:String):Boolean
		{
			if(!File.exists(mainPath) || !File.exists(overridePath))
				return false;
			
			var overrideDomain:Domain = new Domain();
			
			overrideDomain.load(overridePath);
			overrideDomain.getClass("potato.logger.Logger").just4Log = bootloaderLog;
			log("这是个啥",overrideDomain.getClass("potato.logger.Logger").just4Log);
			
			var mainDomain:Domain = new Domain(overrideDomain);
			mainDomain.load(mainPath);
			
			var mainClass:Class = mainDomain.getClass("Main");
			var app:DisplayObject = new mainClass() as DisplayObject;
			Stage.getStage().addChild(app);
			
			return true;
		}
		
		protected function bootloaderLog(msg:String):void
		{
			log("[BootLoader] " + msg);
		}
	}
}