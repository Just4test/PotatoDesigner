package potato.designer.plugin.uidesigner
{
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.registerClassAlias;
	
	import mx.collections.ArrayList;
	import mx.core.UIComponent;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Message;
	import potato.designer.plugin.guestManager.Guest;
	import potato.designer.plugin.guestManager.GuestManagerHost;
	import potato.designer.plugin.uidesigner.basic.compiler.BasicCompiler;
	import potato.designer.plugin.uidesigner.basic.compiler.ClassTypeEditor;
	import potato.designer.plugin.uidesigner.basic.compiler.classdescribe.ClassProfile;
	import potato.designer.plugin.uidesigner.basic.compiler.classdescribe.Suggest;
	import potato.designer.plugin.uidesigner.ui.ComponentView;
	import potato.designer.plugin.uidesigner.ui.OutlineView;
	import potato.designer.plugin.uidesigner.ui.ViewWindow;
	import potato.designer.utils.MultiLock;
	
	import spark.components.Window;
	import spark.layouts.VerticalLayout;
	import spark.skins.spark.SparkChromeWindowedApplicationSkin;
	import spark.skins.spark.WindowedApplicationSkin;
	
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
		
		
		/**
		 * 事件：生成组件配置文件
		 * <br>这是一个同步事件。由于每次添加/删除/修改组件（比如拖动组件位置）都会重新生成组件配置文件并重新构建组件树，因此生成组件配置文件的过程需要非常快。
		 * <br>这个事件将附带一个Object，即目标配置文件。各个编译器需要监听这个事件，并为Object添加属性。添加的属性必须可以序列化。
		 */
		public static const EVENT_MAKE_COMPONENT_PROFILE:String = "UID_EVENT_MAKE_COMPONENT_PROFILE";
		
		
		/**
		 *事件：导出发布版本
		 * <br>生成一个为发布优化的组件配置文件版本。此版本可能为运行时优化了效率，或者针对特定环境进行导出。
		 * 如果某个编译器不涉及为发布优化的功能，以 EVENT_MAKE_COMPONENT_PROFILE 方式响应此事件即可。
		 * <br>这是一个异步事件。允许编译器异步执行（比如与Guest端通讯）甚至导出失败。
		 * <br>data:[target:Object, multiLock:MultiLock]
		 */
		public static const EVENT_EXPORT_RELEASE_BUILD:String = "UID_EVENT_EXPORT_RELEASE_BUILD";
		/**
		 *导出发行版成功 
		 */
		public static const EVENT_EXPORT_OK:String = "UID_EVENT_EXPORT_OK";
		/**
		 * 导出发行版失败
		 */
		public static const EVENT_EXPORT_FAILED:String = "UID_EVENT_EXPORT_FAILED";
		
		//////////////////////////////////////////////////////////////////////////////
		
		public static const compilerList:Vector.<ICompiler> = new Vector.<ICompiler>;
		
		
		protected static var _rootCompilerProfile:CompilerProfile;
		
		
		protected static var _multiLock:MultiLock;
		protected static var _componentProfile:Object;
		
		
		protected static var _componentTypeTable:Object;
		
		
		/////////////////////////////UI/////////////////////////////////////////////////
		
		/**窗口0的视图列表。默认是组件类型视图和大纲视图*/
		public static const window0Views:Vector.<UIComponent> = new Vector.<UIComponent>;
		/**窗口1的视图列表。默认是属性视图*/
		public static const window1Views:Vector.<UIComponent> = new Vector.<UIComponent>;
		
		/**组件和大纲窗口*/
		protected static var _window0:ViewWindow;
		/**属性窗口*/
		protected static var _window1:ViewWindow;
		
		/**组件视图*/
		protected static var _componentTypeView:ComponentView;
		protected static var _componentTypeViewDataProvider:ArrayList;
		
		/**大纲视图*/
		protected static var _outlineView:OutlineView;
		protected static var _outlineTree:XML;
		
		
		////////////////////////////////////////////////////////////////////////////
		
		public static function get exportResult():Object
		{
			return null;
		}
		
		/**
		 *检查编译器是否锁定。当导出发布版本未完成时，编译器锁定。此时不应对组件配置有任何修改。
		 */
		public static function get isLocking():Boolean
		{
			return !_multiLock;
		}
		
		/***更改了视图列表后调用此方法，以便应用更改。*/
		public static function updateWindow():void
		{
			if(window0Views.length)
			{
				if(!_window0)
				{
					_window0 = new ViewWindow;
					_window0.open();
				}
				
				_window0.removeAllElements();
				for each(var i:UIComponent in window0Views)
				{
					_window0.addElement(i);
				}
			}
			else
			{
				if(_window0)
				{
					_window0.removeAllElements();
					_window0.close();
					_window0 = null;
				}
			}
			
			if(window1Views.length)
			{
				if(!_window1)
				{
					_window1 = new ViewWindow;
					_window1.open();
				}
				
				_window1.removeAllElements();
				for each(i in window1Views)
				{
					_window1.addElement(i);
				}
			}
			else
			{
				if(_window1)
				{
					_window1.removeAllElements();
					_window1.close();
					_window1 = null;
				}
			}
			
			
			if(_window1)
			{
				_window1.removeAllElements();
				for each(i in window1Views)
				{
					_window1.addElement(i);
				}
			}
			spark.components.FormHeading
		}
		
		
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
			_componentTypeViewDataProvider.addItem(_componentTypeTable[name]);
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
				_componentTypeViewDataProvider.removeItem(_componentTypeTable[name]);
				delete _componentTypeTable[name];
				return true;
			}
			return false;
		}
		
		
		
		
		
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
			
			for each(var i:Guest in GuestManagerHost.getGuestsWithPlugin("UIDesigner"))
			{
				i.send(DesignerConst.S2C_UPDATE, _rootCompilerProfile && _rootCompilerProfile.targetProfile);
			}
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
		public static function exportReleaseBuild():void
		{
			_multiLock = new MultiLock;
			EventCenter.dispatchEvent(new DesignerEvent(EVENT_EXPORT_OK, [_componentProfile, _multiLock]));
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
		
		private static function multiLockHandler(event:Event):void
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
					EventCenter.dispatchEvent(new Event(EVENT_EXPORT_FAILED));
					break;
				}
					
				default:
				{
					throw new Error("内部错误");
					break;
				}
			}
		}
		
		
		public static function finishExport():void
		{
			_multiLock = null;
			EventCenter.dispatchEvent(new Event(EVENT_EXPORT_OK));
		}
		
		
		
		/**插件注册方法*/
		public function start(info:PluginInfo):void
		{
			_componentTypeTable = {};
			_componentTypeViewDataProvider = new ArrayList;
			
			EventCenter.addEventListener(GuestManagerHost.EVENT_GUEST_CONNECTED, guestConnectedHandler);
			
			//初始化基础编译器
			BasicCompiler.init(info);
			
			//注册视图并显示窗口
			_componentTypeView = new ComponentView;
			_componentTypeView.list.dataProvider = _componentTypeViewDataProvider;
			window0Views.push(_componentTypeView);
			
			_outlineView = new OutlineView;
			_outlineTree = 
				<root>
					<target label="走你"/>
				</root>
				
			_outlineView.tree.dataProvider = _outlineTree
			window0Views.push(_outlineView);
			
			
			updateWindow();
			
			
			info.started();
			
		}
		
		private function guestConnectedHandler(event:DesignerEvent):void
		{
			var newWindow:ClassTypeEditor = new ClassTypeEditor;
			newWindow.open(true);
			
		}
		
		
	}
}

class ComponentType
{
	public var name:String;
	public var isContainer:Boolean;
	public var icon:*;
	
	function ComponentType(name:String, isContainer:Boolean, icon:* = null)
	{
		this.name = name;
		this.isContainer = isContainer;
		this.icon = icon;
	}
}