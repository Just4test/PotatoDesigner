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
		
		[Suggest(type="String", "int", "Number", value="Hello, World!", null, 0)]
		public function start1(s:String, x:int, y:int):void
		{
			
		}
		public function start(info:PluginInfo):void
		{
			//注册消息
			GuestManagerGuest.addEventListener(DesignerConst.S2C_REQ_DESCRIBE_TYPE, reqDescribeTypeHandler);
			GuestManagerGuest.addEventListener(DesignerConst.S2C_INIT, initDesignerHandler);
			GuestManagerGuest.addEventListener(DesignerConst.S2C_UPDATE, updateHandler);
			
			//初始化UI
			
			
			info.started();
		}
		
		
		/////////////////////////////////////////////////////////////////
		
		/**Host请求类描述*/
		protected function reqDescribeTypeHandler(msg:Message):void
		{
			var xml:XML;
			try
			{
				xml =  describeType(getDefinitionByName(msg.data));
			} 
			catch(error:Error) 
			{
			}
			msg.answer("", xml);
		}
		
		/**
		 *初始化UIDesigner。 
		 * @param msg
		 * 
		 */
		protected function initDesignerHandler(msg:Message):void
		{
			
		}
		
		/**
		 *组件更新 
		 * @param msg 附件为组件构建文件
		 * 
		 */
		protected function updateHandler(msg:Message):void
		{
			
		}
	}
}