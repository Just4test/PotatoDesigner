package potato.designer.plugin.uidesigner
{
	import flash.net.registerClassAlias;
	
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.plugin.uidesigner.basic.compiler.BasicCompiler;
	
	/**
	 *管理编译器的Host端
	 * <br>提供两个窗口作为Host端UI。这两个窗口均为纵向布局。习惯上，窗口0显示组件类型视图和大纲视图，窗口1显示属性视图。
	 * <br>提供打包、传输组件描述文件的方式
	 * <br>提供控制组件替身的方式
	 * @author Administrator
	 * 
	 */
	public class UIDesignerHost implements IPluginActivator
	{
		
		/**编译器队列*/
		public static const compilerList:Vector.<ICompiler> = new Vector.<ICompiler>;
		
		/**组件类型映射表副本*/
		protected static const _componentTypeTable:Object = {};

//		public static function get componentTypeTable():Object
//		{
//			function constructor():void{};
//			constructor.prototype = _componentTypeTable;
//			
//			return new constructor();
//		}

		
		protected static var _rootCompilerProfile:CompilerProfile;

		/**编译器配置文件树的根*/
		public static function get rootCompilerProfile():CompilerProfile
		{
			return _rootCompilerProfile;
		}
		
		public static function getCompilerProfileByPath(path:Vector.<uint>):CompilerProfile
		{
			//没有根组件、路径长度为0、路径第一位不是0都直接返回null
			if(!_rootCompilerProfile || !path.length || path.shift())
				return null;

			return _rootCompilerProfile.getCompilerProfileByPath(path);
		}

		
		/**插件注册方法*/
		public function start(info:PluginInfo):void
		{
			registerClassAlias("ITargetProfile", ITargetProfile);
			
			clearStage();
			
			//初始化UI
			ViewController.init();
			
			//初始化基础编译器
			BasicCompiler.init(info);
			
			info.started();
			
		}
	
		
		//////////////////////////////////////////////////////////////////////////////
		
//		protected static var _foldPath:Vector.<uint>;
//		protected static var _focusIndex:int;
		
		
		
		////////////////////////////////////////////////////////////////////////////
		
		/**
		 *清理所有已经存在的组件，并初始化 
		 * 
		 */
		public static function clearStage():void
		{
			_rootCompilerProfile = null;
			ViewController.clearStage();
		}
		
		public static function get exportResult():Object
		{
			return null;
		}
		
		
//		protected static var _multiLock:MultiLock;
//		protected static var _componentProfile:Object;
		/**
		 *检查编译器是否锁定。当导出发布版本未完成时，编译器锁定。此时不应对组件配置有任何修改。
		 */
//		public static function get isLocking():Boolean
//		{
//			return !_multiLock;
//		}
		
		
		
		
		/**
		 *注册组件类型 
		 * @param name 组件名
		 * @param isContainer 组件是否是容器。这决定了组件能否展开并插入子组件
		 * @param icon 为组件指定图标
		 * 
		 */
		public static function regComponentType(name:String, isContainer:Boolean, icon:* = null):void
		{
			_componentTypeTable[name] = new ComponentType(name, isContainer, icon);
			ViewController.regComponentType(_componentTypeTable[name]);
		}
		
		/**
		 *移除组件类型 
		 * @param name 组件名
		 * @return 如果成功移除了组件，返回true。如果本不存在该名称的组件，返回false
		 * 
		 */
		public static function removeComponentType(name:String):Boolean
		{
			if(_componentTypeTable[name])
			{
				ViewController.removeComponentType(_componentTypeTable[name]);
				delete _componentTypeTable[name];
				return true;
			}
			return false;
		}
		
//		protected static function 
		
		
		
		
		/**
		 *更新组件树 
		 * @param profile 仅更新指定的组件树。不提供该值将更新根组件树。
		 * 
		 */
		public static function update(dispatch:Boolean = true, profile:CompilerProfile = null):void
		{
			profile ||= _rootCompilerProfile;
			
			if(profile)
			{
				for (var i:int = 0; i < profile.childrenVector.length; i++) 
				{
					update(false, profile.childrenVector[i]);
				}
				
				for (var j:int = 0; j < compilerList.length; j++) 
				{
					if(compilerList[j].update(profile))
						break;
				}
			}
			
			
			if(dispatch)
				ViewController.update(_rootCompilerProfile ? _rootCompilerProfile.targetProfile : null);
		}
		
		/**
		 *导出发行版
		 * <br>此方法派发 EVENT_EXPORT_RELEASE_BUILD 事件以调用编译器生成发行版组件。
		 * 
		 */
		/*
		public static function exportReleaseBuild():void
		{
			_multiLock = new MultiLock;
			EventCenter.dispatchEvent(new DesignerEvent(DesignerConst.EVENT_EXPORT_OK, [_componentProfile, _multiLock]));
			if(!_multiLock.isFree)
			{
				finishExport();
			}
			else
			{
				_multiLock.addEventListener(MultiLock.EVENT_DEAD, multiLockHandler);
				_multiLock.addEventListener(MultiLock.EVENT_UNLOCKED, multiLockHandler);
			}
		}
		
		protected static function multiLockHandler(event:Event):void
		{
			_multiLock.removeEventListener(MultiLock.EVENT_DEAD, multiLockHandler);
			_multiLock.removeEventListener(MultiLock.EVENT_UNLOCKED, multiLockHandler);
			
			switch(event.type)
			{
				case MultiLock.EVENT_DEAD:
				{
					finishExport();
					break;
				}
				case MultiLock.EVENT_UNLOCKED:
				{
					EventCenter.dispatchEvent(new Event(DesignerConst.EVENT_EXPORT_FAILED));
					break;
				}
					
				default:
				{
					throw new Error("内部错误");
					break;
				}
			}
		}
		
		
		protected static function finishExport():void
		{
			_multiLock = null;
			EventCenter.dispatchEvent(new Event(DesignerConst.EVENT_EXPORT_OK));
		}
		*/
		
		/**
		 *在当前路径下添加组件 
		 * @param type
		 * 
		 */
		public static function addComponent(typeName:String):void
		{
			var parrentCP:CompilerProfile;
			var type:ComponentType = _componentTypeTable[typeName];
			if(_rootCompilerProfile)
			{
				var path:Vector.<uint> = ViewController.foldPath;
				parrentCP = UIDesignerHost.getCompilerProfileByPath(path);
				if(!parrentCP)
				{
					logf("[{0}] 当根组件不为空时，您只能向容器添加子组件。请展开任何容器以添加子组件。", DesignerConst.PLUGIN_NAME);
					return;
				}
				if(!parrentCP.type.isContainer)
				{
					logf("[{0}] 当前展开对象不是容器，因此无法添加子组件。", DesignerConst.PLUGIN_NAME);
					return;
				}
			}
			else
			{
				//如果尝试创建一个不是容器的根组件
				if(!type.isContainer)
				{
					logf("[{0}] 警告：为根组件指定了不是容器的类型。这将导致无法添加任何其他组件。", DesignerConst.PLUGIN_NAME);
				}
			}
			
			var cp:CompilerProfile = new CompilerProfile(type);
			
			for (var i:int = 0; i < compilerList.length; i++) 
			{
				if(compilerList[i].addTarget(cp, parrentCP))
					break;
			}
			if(!cp.targetProfile)
			{
				logf("[{0}] 尝试创建组件[{1}]，但是所有已安装的编译器都没有对此作出反应。", DesignerConst.PLUGIN_NAME, type.name);
			}
			
			if(_rootCompilerProfile)//如果有根组件，就有父组件
			{
				parrentCP.addChildAt(cp, ViewController.focusIndex + 1);
			}
			else
			{
				_rootCompilerProfile = cp;
			}
			
			ViewController.update(_rootCompilerProfile.targetProfile, ViewController.foldPath, ViewController.focusIndex + 1);
		}
		
		/**
		 *获取编译器配置文件树中指定的目标
		 * @param cp 编译器配置文件树
		 * @param foldPath 展开路径。
		 * @param focusIndex 焦点索引。如果指定为-1则说明没有选中任何对象。 
		 * @return 
		 * 
		 */
		protected static function getCompilerProfileAtPath(cp:CompilerProfile, foldPath:Vector.<uint>, focusIndex:int = -1):CompilerProfile
		{
			while(foldPath.length)
			{
				var index:int = foldPath.shift();
				if(cp.childrenVector.length <= index)
					return null;
				cp = cp.childrenVector[index];
				
			}
			
			if(-1 != focusIndex)
			{
				if(cp.childrenVector.length <= focusIndex)
					return null;
				cp = cp.childrenVector[focusIndex];
			}
			
			return cp;
		}

//		/**展开路径
//		 * <br>请不要直接使用foldPath.shift()等方式修改展开路径，而是修改后使用赋值应用更改。
//		 */
//		public static function get foldPath():Vector.<uint>
//		{
//			return _foldPath.concat();
//		}
//		public static function set foldPath(value:Vector.<uint>):void
//		{
//			_foldPath = value;
//			ViewController.foldPath = _foldPath;
//		}
//		
//		/**焦点索引*/
//		public static function get focusIndex():int
//		{
//			return _focusIndex;
//		}
//		
//		public static function set focusIndex(value:int):void
//		{
//			_focusIndex = value;
//			ViewController.focusIndex = _focusIndex;
//		}
		
		
//		/**焦点路径，当直接点击了某个焦点对象时使用此设置方式。
//		 * <br>如果当前没有指定焦点，会返回null。
//		 * <br>请不要直接使用focusPath.shift()等方式修改焦点路径，而是修改后使用赋值应用更改。
//		 */
//		public static function get focusPath():Vector.<uint>
//		{
//			if(-1 == _focusIndex)
//			{
//				return null;
//			}
//			else
//			{
//				return _foldPath.concat(_focusIndex);
//			}
//		}
//		public static function set focusPath(value:Vector.<uint>):void
//		{
//			_focusIndex = value.pop();
//			_foldPath = value;
//			ViewController.focusPath = value;
//		}
		
		
	}
}