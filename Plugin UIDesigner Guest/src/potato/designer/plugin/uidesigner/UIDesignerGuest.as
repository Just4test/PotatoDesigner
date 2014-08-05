package potato.designer.plugin.uidesigner
{
	import flash.net.registerClassAlias;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Message;
	import potato.designer.plugin.guestManager.GuestManagerGuest;
	import potato.designer.plugin.uidesigner.basic.interpreter.BasicInterpreter;
	import potato.designer.plugin.uidesigner.factory.Factory;
	import potato.designer.plugin.uidesigner.factory.TargetTree;
	
	public class UIDesignerGuest implements IPluginActivator
	{	
		public function start(info:PluginInfo):void
		{
			registerClassAlias("ITargetProfile", ITargetProfile);
			
			//注册消息
			GuestManagerGuest.addEventListener(DesignerConst.S2C_REQ_DESCRIBE_TYPE, reqDescribeTypeHandler);
			GuestManagerGuest.addEventListener(DesignerConst.S2C_INIT, initDesignerHandler);
			GuestManagerGuest.addEventListener(DesignerConst.S2C_REFRESH, refreshHandler);
			GuestManagerGuest.addEventListener(DesignerConst.S2C_UPDATE, updateHandler);
			GuestManagerGuest.addEventListener(DesignerConst.S2C_FOLD_FOCUS_CHANGED, focusChangedHandler);
			
			//注册基础解释器
			BasicInterpreter.init();
			
			//初始化UI
			UI.init();
			
			info.started();	
			
			EventCenter.addEventListener(GuestManagerGuest.EVENT_HOST_DISCOVERED, hostDiscoverdHandler);
			GuestManagerGuest.startHostDiscovery();
			
		}
		
		protected function hostDiscoverdHandler(event:DesignerEvent):void
		{
			if(event.data.length)
			{
				GuestManagerGuest.tryConnect(event.data[0]);
				GuestManagerGuest.stopHostDiscovery();
			}
		}
		
		/**根组件描述文件*/
		protected static var _rootTargetProfile:ITargetProfile;
		
		/**根目标树*/
		protected static var _rootTargetTree:TargetTree;
		
		/**根替身*/
		protected static var _rootSubstitute:ComponentSubstitute;
		
		/**展开路径*/
		protected static var _foldPath:Vector.<uint>;
		/**焦点索引*/
		protected static var _focusIndex:int;
		
		
		
		
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
			logf("更新组件树{0}，展开路径{1}，焦点索引{2}", msg.data[0], msg.data[1], msg.data[2]);
			_rootTargetProfile = msg.data[0];
			_foldPath = msg.data[1];
			_focusIndex = msg.data[2];
			
			_rootTargetTree = Factory.compileProfile(_rootTargetProfile);
			
			UI.update(_rootTargetTree, _foldPath, _focusIndex);
			
			EventCenter.dispatchEvent(new DesignerEvent(DesignerConst.UPDATE, [_rootTargetProfile, _foldPath, _focusIndex]));
		}
		
		/**
		 * 选中另一个组件
		 */
		protected function focusChangedHandler(msg:Message):void
		{
			logf("展开路径{0}，焦点索引{1}", msg.data[0], msg.data[1]);
			_foldPath = msg.data[0];
			_focusIndex = msg.data[1];
			
			UI.update(_rootTargetTree, _foldPath, _focusIndex);
			
			EventCenter.dispatchEvent(new DesignerEvent(DesignerConst.FOLD_FOCUS_CHANGED, [_foldPath, _focusIndex]));
			
		}
		
		protected function refreshHandler(msg:Message):void
		{
			logf("刷新");
			
			UI.update(_rootTargetTree, _foldPath, _focusIndex);
		}
	}
}