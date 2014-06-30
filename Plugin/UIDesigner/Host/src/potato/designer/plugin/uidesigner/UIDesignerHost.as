package potato.designer.plugin.uidesigner
{
	
	import flash.events.Event;
	import flash.net.registerClassAlias;
	
	import mx.collections.ArrayList;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.plugin.guestManager.Guest;
	import potato.designer.plugin.guestManager.GuestManagerHost;
	import potato.designer.plugin.uidesigner.basic.compiler.BasicCompiler;
	import potato.designer.utils.MultiLock;
	
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
		
		/**组件类型映射表*/
		protected static const _componentTypeTable:Object = {};
		
		/**编译器配置文件树的根*/
		protected static var _rootCompilerProfile:CompilerProfile;
		
		/**插件注册方法*/
		public function start(info:PluginInfo):void
		{
			registerClassAlias("ITargetProfile", ITargetProfile);
			
			clearStage();
			
			//初始化UI
			ViewController.init();
			
			//初始化基础编译器
			BasicCompiler.init(info);
			
			//初始化客户端
			EventCenter.addEventListener(GuestManagerHost.EVENT_GUEST_PLUGIN_ACTIVATED, guestPluginActivatedHandler);
			EventCenter.addEventListener(GuestManagerHost.EVENT_GUEST_CONNECTED, guestConnectedHandler);
			for each(var guest:Guest in GuestManagerHost.getGuestsWithPlugin(DesignerConst.PLUGIN_NAME))
			{
				initGuest(guest);
			}
			
			info.started();
			
		}
		
		protected function guestPluginActivatedHandler(event:DesignerEvent):void
		{
			if(DesignerConst.PLUGIN_NAME == event.data[1])
			{
				initGuest(event.data[0]);
			}
		}
		
		protected function guestConnectedHandler(event:DesignerEvent):void
		{
			if(Guest(event.data).isPluginActived(DesignerConst.PLUGIN_NAME))
			{
				initGuest(event.data);
			}
		}
		
		protected function initGuest(guest:Guest):void
		{
			var lock:MultiLock = new MultiLock;
			lock.addEventListener(MultiLock.EVENT_UNLOCKED, lockHandler);
			lock.addEventListener(MultiLock.EVENT_DEAD, lockHandler);
			
			for (var i:int = 0; i < compilerList.length; i++) 
			{
				if(compilerList[i].initGuest(guest, lock))
					break;
			}
			
			if(lock.isFree)
			{
				finishInit();
			}
			
			function lockHandler(event:Event):void
			{
				lock.removeEventListener(MultiLock.EVENT_UNLOCKED, lockHandler);
				lock.removeEventListener(MultiLock.EVENT_DEAD, lockHandler);
				
				if(MultiLock.EVENT_UNLOCKED == event.type)
				{
					finishInit();
				}
				else
				{
					logf("[{0}] 客户端[{1}]初始化失败：{2}", DesignerConst.PLUGIN_NAME, guest.id, MultiLock(event.target).locks);
				}
			}
			
			function finishInit():void
			{
				logf("[{0}] 客户端[{1}]初始化完毕。", DesignerConst.PLUGIN_NAME, guest.id);
				
				
				ViewController.refreshGuest(_rootCompilerProfile ? _rootCompilerProfile.targetProfile : null, guest);
			}
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
		 *刷新客户端组件树
		 * <br>当属性更改或者向组件树添加了新组件后调用这个方法。
		 * <br>这个方法将先派发EVENT_MAKE_COMPONENT_PROFILE事件，以创建组件配置文件；
		 * <br>然后将组件配置文件传输至客户端，指示其刷新设计舞台。
		 */
		public static function updateGuest():void
		{
			if(_rootCompilerProfile)
				update(_rootCompilerProfile);
			
			ViewController.refreshGuest(_rootCompilerProfile ? _rootCompilerProfile.targetProfile : null);
		}
		
		
		public static function update(profile:CompilerProfile):void
		{
			for (var i:int = 0; i < profile.children.length; i++) 
			{
				update(profile.children[i]);
			}
			
			
			for (var j:int = 0; j < compilerList.length; j++) 
			{
				if(compilerList[j].update(profile))
					break;
			}
			
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
		public static function addComponent(type:String):void
		{
			if(_rootCompilerProfile && !_componentTypeTable[_rootCompilerProfile.type].isContainer)
			{
				logf("[{0}] 根组件不是容器，因此无法添加组件。", DesignerConst.PLUGIN_NAME);
				return;
			}
			//如果尝试创建一个不是容器的根组件
			if(!_rootCompilerProfile && !_componentTypeTable[type].isContainer)
			{
				logf("[{0}] 警告：为根组件指定了不是容器的类型。这将导致无法添加任何其他组件。", DesignerConst.PLUGIN_NAME);
			}
			
			var cp:CompilerProfile = new CompilerProfile(type);
			
			for (var i:int = 0; i < compilerList.length; i++) 
			{
				if(compilerList[i].addTarget(cp))
					break;
			}
			
			ViewController.addComponent(type);
			
			var folder:CompilerProfile = getCompilerProfileAtPath(_rootCompilerProfile, ViewController.foldPath);
			if(folder)
			{
				folder.addChildAt(cp, ViewController.focusIndex + 1);
			}
			else
			{
				//正在创建根组件
				_rootCompilerProfile = cp;
				if(_componentTypeTable[type].isContainer)//如果刚刚创建的根组件是容器，则展开该容器
				{
					ViewController.foldPath = new <uint>[0];
				}
			}
			
			updateGuest();
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
				if(cp.children.length <= index)
					return null;
				cp = cp.children[index];
				
			}
			
			if(-1 != focusIndex)
			{
				if(cp.children.length <= focusIndex)
					return null;
				cp = cp.children[focusIndex];
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