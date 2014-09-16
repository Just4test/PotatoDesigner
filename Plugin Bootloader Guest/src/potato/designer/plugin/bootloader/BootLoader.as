package potato.designer.plugin.bootloader
{
	import flash.utils.ByteArray;
	
	import core.display.DisplayObject;
	import core.display.Stage;
	import core.filesystem.File;
	import core.system.Domain;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.framework.Utils;
	import potato.designer.plugin.guestManager.ConnectHelper;
	import potato.designer.plugin.guestManager.GuestManagerGuest;
	
	public class BootLoader implements IPluginActivator
	{
		public static const LOG:String = "BOOTLOADER_LOG";
		
		protected static var connected:Boolean;
		
		protected var mainPath:String, mainClassName:String, overridePath:String;
		
		protected var _info:PluginInfo
		public function start(info:PluginInfo):void
		{
			_info = info;
			
			if(File.exists(info.getAbsolutePath("config.json")))
			{
				try
				{
					var obj:Object = JSON.parse(File.read(info.getAbsolutePath("config.json")));
				} 
				catch(error:Error) 
				{
					log("[BootLoader] 读取配置文件 config.json 时发生错误", error);
				}
			}
			obj ||= {};
			mainPath = obj.mainPath || "Main.swf";
			mainClassName = obj.mainClassName || "Main";
			overridePath = info.getAbsolutePath(obj.overridePath || "PotatoOverride.swc");
			
			EventCenter.addEventListener(GuestManagerGuest.EVENT_HOST_CONNECTED, connectedHandler);
			ConnectHelper.show();
			
		}
		
		protected function connectedHandler(event:DesignerEvent):void
		{
			log("[BootLoader] 尝试启动", mainPath);
			if(run())
			{
				log("[BootLoader] 成功加载", mainPath);
				_info.started();
			}
		}
		
		public function run():Boolean
		{
			try
			{
				var overrideDomain:Domain = new Domain();
				
				var bytes:ByteArray = File.readByteArray(overridePath);
				if(overridePath.indexOf(".swc") == overridePath.length - 4)
				{
					bytes = Utils.unzipSWC(bytes);
				}
				overrideDomain.loadBytes(bytes);
				overrideDomain.getClass("__J4T_BootLoader").log = bootloaderLog;
				
				var mainDomain:Domain = new Domain(overrideDomain);
				mainDomain.load(mainPath);
				
				var mainClass:Class = mainDomain.getClass(mainClassName);
				var app:DisplayObject = new mainClass() as DisplayObject;
				Stage.getStage().addChild(app);
				
				return true;
			} 
			catch(error:Error) 
			{
				log("[BootLoader] 启动时发生错误", error);
			}
			
			return false;
			
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