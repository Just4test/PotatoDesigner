package potato.designer.plugin.uidesigner.basic.compiler
{
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Message;
	import potato.designer.plugin.guestManager.Guest;
	import potato.designer.plugin.uidesigner.CompilerProfile;
	import potato.designer.plugin.uidesigner.ICompiler;
	import potato.designer.plugin.uidesigner.UIDesignerHost;
	import potato.designer.plugin.uidesigner.basic.BasicConst;
	import potato.designer.plugin.uidesigner.basic.compiler.classdescribe.ClassProfile;
	import potato.designer.plugin.uidesigner.basic.compiler.classdescribe.Suggest;
	import potato.designer.plugin.uidesigner.basic.interpreter.BasicTargetProfile;
	import potato.designer.utils.MultiLock;
	import potato.designer.utils.SubLock;

	public class BasicCompiler implements ICompiler
	{
		/**
		 *由guest端提供的type表 
		 * <br>_typeTable[typeName] = className
		 */
		protected static var _paramTypeTable:Object;
		
		/**
		 *注册的组件表 
		 */
		protected static var _classTypeTable:Object
		
		
		public static const instance:BasicCompiler = new BasicCompiler;
		
		
		public static function init(info:PluginInfo):void
		{
			Suggest.loadSuggestFile(info.getAbsolutePath(BasicConst.SUGGEST_FILE_PATH));
		}
		
		public function addTarget(targetType:String, profile:CompilerProfile):Boolean
		{
			var cp:ClassProfile = _classTypeTable[targetType];
			if(!cp)
			{
				return false;
			}
			
			var tp:BasicTargetProfile;
			if(profile.targetProfile)
			{
				tp = profile.targetProfile as BasicTargetProfile;
				if(!tp)
				{
					return false;
				}
			}
			else
			{
				tp = new BasicTargetProfile();
				profile.targetProfile = tp;
			}
			
			tp.className = cp.className;
			
			
			
			
			
			
			
			
			
			
			
			// TODO Auto Generated method stub
			return false;
		}
		
		public function export(lock:MultiLock):Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
//		protected var initLock:SubLock;
		public function initGuest(guest:Guest, lock:MultiLock):Boolean
		{
			//请求type
			var typeLock:SubLock = lock.getLock("从Guest端获取type表");
			guest.send(BasicConst.S2C_REQ_TYPE_TABLE, null,
				function(msg:Message):void
				{
					_paramTypeTable = msg.data;
					typeLock.unLock();
				}
			);
			
			return false;
		}
		
		public function refresh(profile:CompilerProfile):Boolean
		{
			//因为属性修改是实时的所以不需要refresh，直接return
			return false;
		}
		
		/**
		 * 注册类配置文件
		 * @param nickName 类昵称。将注册该名称的组件
		 * @param classProfile 类配置文件
		 */
		public function addClass(nickName:String, classProfile:ClassProfile):void
		{
			for each (var i:String in _classTypeTable) 
			{
				if(classProfile.className == _classTypeTable[i].className)
				{
					delete _classTypeTable[i];
					UIDesignerHost.removeComponentType(i);
				}
			}
			
			_classTypeTable[nickName] = classProfile;
			UIDesignerHost.regComponentType(nickName, classProfile.isDisplayObjContainer);
			
		}
		
		
	}
}