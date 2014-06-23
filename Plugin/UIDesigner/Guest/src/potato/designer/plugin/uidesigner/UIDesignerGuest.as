package potato.designer.plugin.uidesigner
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import core.display.DisplayObject;
	import core.display.Stage;
	
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
			//注册消息
			GuestManagerGuest.addEventListener(DesignerConst.S2C_REQ_DESCRIBE_TYPE, reqDescribeTypeHandler);
			GuestManagerGuest.addEventListener(DesignerConst.S2C_INIT, initDesignerHandler);
			GuestManagerGuest.addEventListener(DesignerConst.S2C_UPDATE, updateHandler);
			
			//初始化UI
			
			
			//注册基础解释器
			BasicInterpreter.init();
			
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
			log("!!!!!!!!!!!updateHandler!!!!!!!!!!!!!")
			_rootTargetProfile = msg.data[0];
			_foldPath = msg.data[1];
			_focusIndex = msg.data[2];
			
			_rootTargetTree = Factory.compileProfile(_rootTargetProfile);
			log("根组件",_rootTargetTree.target);
			if(_rootTargetTree.target is DisplayObject)
			{
				log(_rootTargetTree.target.width, _rootTargetTree.target.height);
			}
			
			_rootSubstitute = makeSubstitute(_rootTargetTree, _foldPath, _focusIndex);
			
			Stage.getStage().addChild(_rootSubstitute);
			Stage.getStage().addChild(_rootTargetTree.target);
			
		}
		
		/**
		 *创建替身树 
		 * @param targetTree 目标树
		 * @param fold 展开路径。如果为null说明不在展开路径上。
		 * @param focus 焦点目标。-2表示当前对象是焦点，-1表示没有选中焦点，0及正数表示子节点是焦点。
		 * 
		 */
		protected static function makeSubstitute(targetTree:TargetTree, fold:Vector.<uint>,
												 focus:int, parent:ComponentSubstitute = null):ComponentSubstitute
		{
			if(!targetTree)
			{
				return null;
			}
			
			var ret:ComponentSubstitute = new ComponentSubstitute(targetTree.target, parent);
			
			ret.selected = -2 == focus;
			ret.unfolded = null != fold;
			
			
			for (var i:int = 0; i < targetTree.children.length; i++) 
			{
				var subFold:Vector.<uint> = null;
				var subFocus:int = -1;
				
				if(fold)//如果处在路径上
				{
					if(fold.length)//如果还有子路径，确定子fold
					{
						if(i == fold[0])
						{
							subFold = fold.slice(1);
							subFocus = focus;
							
						}
					}
					else//没有子路径了，确定focus
					{
						subFocus = i == focus ? -2 : -1;
					}
				}

				makeSubstitute(targetTree.children[i], subFold, subFocus, ret);
			}
			
			
			
			return ret;
		}
	}
}