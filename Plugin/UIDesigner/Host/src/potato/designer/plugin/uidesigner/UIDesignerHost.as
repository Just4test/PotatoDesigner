package potato.designer.plugin.uidesigner
{
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.registerClassAlias;
	
	import mx.core.Window;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Message;
	import potato.designer.plugin.guestManager.Guest;
	import potato.designer.plugin.guestManager.GuestManagerHost;
	import potato.designer.plugin.uidesigner.classdescribe.ClassProfile;
	import potato.designer.plugin.uidesigner.classdescribe.Suggest;
	import potato.designer.plugin.uidesigner.construct.BasicClassTypeProfile;
	
	import spark.skins.spark.SparkChromeWindowedApplicationSkin;
	import spark.skins.spark.WindowedApplicationSkin;
	
	public class UIDesignerHost implements IPluginActivator
	{
		
		
		{
			registerClassAlias("BasicClassProfile", BasicClassTypeProfile);
			
			TypeTransform.regType("String", "String");
			TypeTransform.regType("int", "int");
			TypeTransform.regType("Number", "Number");
		}
		
		/**请求指定的类描述*/		
		public static const S2C_REQ_DESCRIBE_TYPE:String = "UID_S2C_REQ_DESCRIBE_TYPE";
		public static const SUGGEST_FILE_PATH:String = "suggest.json";
		
		/**插件注册方法*/
		public function start(info:PluginInfo):void
		{
			Suggest.loadSuggestFile(info.getAbsolutePath(SUGGEST_FILE_PATH));
			
			EventCenter.addEventListener(GuestManagerHost.EVENT_GUEST_CONNECTED, guestConnectedHandler);
			
			info.started();
			
		}
		
		private function guestConnectedHandler(event:DesignerEvent):void
		{
			var newWindow:ClassTypeEditor = new ClassTypeEditor;
			newWindow.open(true);
		}
		
		public static function regClass(classProfile:ClassProfile):void
		{
			
		}
		
		
	}
}