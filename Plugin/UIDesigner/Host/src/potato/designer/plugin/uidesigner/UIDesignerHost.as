package potato.designer.plugin.uidesigner
{
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.registerClassAlias;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Message;
	import potato.designer.plugin.guestManager.Guest;
	import potato.designer.plugin.guestManager.GuestManagerHost;
	import potato.designer.plugin.uidesigner.classdescribe.BasicClassProfile;
	import potato.designer.plugin.uidesigner.classdescribe.ClassProfile;
	import potato.designer.plugin.uidesigner.classdescribe.Suggest;
	
	public class UIDesignerHost implements IPluginActivator
	{
		
		
		{
			registerClassAlias("BasicClassProfile", BasicClassProfile);
		}
		
		/**请求指定的类描述*/		
		public static const S2C_REQ_DESCRIBE_TYPE:String = "UID_S2C_REQ_DESCRIBE_TYPE";
		public static const SUGGEST_FILE_PATH:String = "suggest.json";
		
		/**插件注册方法*/
		public function start(info:PluginInfo):void
		{
			//
			Suggest.loadSuggestFile(info.getAbsolutePath(SUGGEST_FILE_PATH));
			
			
			
			
			
			EventCenter.addEventListener(GuestManagerHost.EVENT_GUEST_CONNECTED, guestConnectedHandler);
			info.started();
		}
		
		private function guestConnectedHandler(event:DesignerEvent):void
		{
			var guest:Guest = event.data;
//			guest.send(S2C_REQ_DESCRIBE_TYPE, "potato.designer.framework::DataCenter", describeTypeAnswerHandler);
//			guest.send(S2C_REQ_DESCRIBE_TYPE, "B", describeTypeAnswerHandler);
			guest.send(S2C_REQ_DESCRIBE_TYPE, "core.display::Quad", describeTypeAnswerHandler);
		}
		
		private function describeTypeAnswerHandler(msg:Message):void
		{
			log(msg.data);
			var p:ClassProfile = new ClassProfile(msg.data);
			trace(p.isDisplayObj);
			trace(p.isDisplayObjContainer);
		}
	}
}