package potato.designer.plugin.uidesigner
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Message;
	import potato.designer.plugin.guestManager.GuestManagerGuest;
	
	public class UIDesignerGuest implements IPluginActivator
	{
		/**请求指定的类描述*/		
		public static const S2C_REQ_DESCRIBE_TYPE:String = "UID_S2C_REQ_DESCRIBE_TYPE";
		
		
		[Suggest(type="String", "int", "Number", value="Hello, World!", null, 0)]
		public function start1(s:String, x:int, y:int):void
		{
			
		}
		public function start(info:PluginInfo):void
		{
			GuestManagerGuest.addEventListener(S2C_REQ_DESCRIBE_TYPE, reqDescribeTypeHandler);
			info.started();
		}
		
		protected function reqDescribeTypeHandler(msg:Message):void
		{
			var xml:XML;
			try
			{
				xml =  describeType(getDefinitionByName(msg.data));
			} 
			catch(error:Error) 
			{
				trace("Error", error);
			}
			trace("解析", msg.data, xml);
			msg.answer("", xml);
		}
	}
}