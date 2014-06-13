package potato.designer.plugin.uidesigner.basic.compiler
{
	import flash.net.registerClassAlias;
	
	import mx.core.UIComponent;
	
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Message;
	import potato.designer.plugin.guestManager.Guest;
	import potato.designer.plugin.uidesigner.CompilerProfile;
	import potato.designer.plugin.uidesigner.ICompiler;
	import potato.designer.plugin.uidesigner.UIDesignerHost;
	import potato.designer.plugin.uidesigner.ViewController;
	import potato.designer.plugin.uidesigner.basic.BasicConst;
	import potato.designer.plugin.uidesigner.basic.compiler.classdescribe.ClassProfile;
	import potato.designer.plugin.uidesigner.basic.compiler.classdescribe.Suggest;
	import potato.designer.plugin.uidesigner.basic.interpreter.BasicClassProfile;
	import potato.designer.plugin.uidesigner.basic.interpreter.BasicTargetMemberProfile;
	import potato.designer.plugin.uidesigner.basic.interpreter.BasicTargetProfile;
	import potato.designer.plugin.window.WindowManager;
	import potato.designer.utils.MultiLock;
	import potato.designer.utils.SubLock;
	
	import spark.layouts.BasicLayout;

	public class BasicCompiler implements ICompiler
	{
		/**
		 *由guest端提供的type表 
		 * <br>_typeTable[typeName] = className
		 */
		protected static var _paramTypeTable:Object;
		
		/**类昵称到类描述文件映射表*/
		protected static var _classProfileNickTable:Object = {};
		/**类昵称到类名映射表*/
		protected static var _classProfileNameTable:Object = {};
		
		
		public static const instance:BasicCompiler = new BasicCompiler;
		
		public static function init(info:PluginInfo):void
		{
			registerClassAlias("BasicTargetProfile", BasicTargetProfile);
			registerClassAlias("BasicTargetMemberProfile", BasicTargetMemberProfile);
			registerClassAlias("BasicClassProfile", BasicClassProfile);
			
			Suggest.loadSuggestFile(info.getAbsolutePath(BasicConst.SUGGEST_FILE_PATH));
			
			UIDesignerHost.compilerList.push(instance);
			ViewController.regComponentTypeCreater("添加类", addClassType);
		}
		
		
		
		protected static function addClassType():void
		{
			var editor:ClassTypeEditor = new ClassTypeEditor;
			editor.window = WindowManager.openWindow("类组件编辑器", Vector.<UIComponent>([editor]));
			
		}
		
		public function addTarget(profile:CompilerProfile):Boolean
		{
			var cp:ClassProfile = _classProfileNickTable[profile.type];
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
			if(cp.constructor.hasDefaultValue)
			{
				tp.constructorParam = Vector.<*>(cp.constructor.defaultValue);
			}
			
			return false;
		}
		
		public function export(lock:MultiLock):Boolean
		{
			// TODO 未实现
			return false;
		}
		
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
		
		public function update(profile:CompilerProfile):Boolean
		{
			//因为属性修改是实时的所以不需要refresh，直接return
			return false;
		}
		
		/**
		 * 注册类配置文件
		 * @param nickName 类昵称。将注册该名称的组件
		 * @param classProfile 类配置文件
		 */
		public static function regClass(nickName:String, classProfile:ClassProfile):void
		{
			for(var i:String in _classProfileNickTable) 
			{
				if(classProfile.className == _classProfileNickTable[i].className)
				{
					delete _classProfileNickTable[i];
					UIDesignerHost.removeComponentType(i);
				}
			}
			
			_classProfileNickTable[nickName] = classProfile;
			_classProfileNameTable[classProfile.className] = classProfile;
			UIDesignerHost.regComponentType(nickName, classProfile.isDisplayObjContainer);
		}
		
		/**
		 *根据类昵称获取类配置文件 
		 */
		public static function getClassProfileByNickName(name:String):ClassProfile
		{
			return _classProfileNickTable[name];
		}
		
		/**
		 *根据类全名获取类配置文件 
		 */
		public static function getClassProfileByClassName(name:String):ClassProfile
		{
			return _classProfileNameTable[name];
		}
		
		/**
		 *根据类型获取类全名 
		 */
		public static function getClassNameByType(type:String):ClassProfile
		{
			return _paramTypeTable[type];
		}
		
		/**
		 *获取类全名所对应的类型 
		 * @param name
		 * @return 
		 * 
		 */
		public static function getTypesByClassName(name:String):Vector.<String>
		{
			var ret:Vector.<String> = new Vector.<String>;
			for(var i:String in _paramTypeTable)
			{
				if(name == _paramTypeTable[i])
				{
					ret.push(i);
				}
			}
			return ret;
		}
		
		
		
		
	}
}