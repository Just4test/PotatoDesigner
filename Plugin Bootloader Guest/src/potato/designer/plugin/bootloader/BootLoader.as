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
	import potato.designer.plugin.guestManager.ConnectHelper;
	import potato.designer.plugin.guestManager.GuestManagerGuest;
	
	public class BootLoader implements IPluginActivator
	{
		public static const LOG:String = "BOOTLOADER_LOG";
		
		protected static var connected:Boolean;
		
		protected var _info:PluginInfo
		public function start(info:PluginInfo):void
		{
			_info = info;
			ConnectHelper.show();
//			EventCenter.addEventListener(GuestManagerGuest.EVENT_HOST_DISCOVERED, hostDiscoverdHandler);
//			GuestManagerGuest.startHostDiscovery();
			
		}
		
//		protected function hostDiscoverdHandler(event:DesignerEvent):void
//		{
//			if(event.data.length)
//			{
//				EventCenter.addEventListener(GuestManagerGuest.EVENT_HOST_CONNECTED, connectedHandler);
//				GuestManagerGuest.tryConnect(event.data[0]);
//				GuestManagerGuest.stopHostDiscovery();
//			}
//		}
		
		protected function connectedHandler(event:DesignerEvent):void
		{
			log("[BootLoader] 尝试启动Main.swf");
			if(run("Main.swf", _info.getAbsolutePath("library.swf")))
			{
				log("[BootLoader] 成功加载Main.swf");
				_info.started();
			}
		}
		
		public function run(mainPath:String, overridePath:String):Boolean
		{
			if(!File.exists(mainPath) || !File.exists(overridePath))
				return false;
			
			var overrideDomain:Domain = new Domain();
			
			overrideDomain.load(overridePath);
			overrideDomain.getClass("__J4T_BootLoader").log = bootloaderLog;
			
			var mainDomain:Domain = new Domain(overrideDomain);
			mainDomain.load(mainPath);
			
			var mainClass:Class = mainDomain.getClass("Main");
			var app:DisplayObject = new mainClass() as DisplayObject;
			Stage.getStage().addChild(app);
			
			return true;
		}
		
		protected function bootloaderLog(msg:String):void
		{
			if(connected)
			{
				GuestManagerGuest.send(LOG, msg);
			}
			else
			{
				log("[BL Log] " + msg);
			}
		}
	}
}