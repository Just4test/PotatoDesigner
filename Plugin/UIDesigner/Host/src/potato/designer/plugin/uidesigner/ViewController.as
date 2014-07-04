package potato.designer.plugin.uidesigner
{
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	import mx.core.UIComponent;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.plugin.guestManager.Guest;
	import potato.designer.plugin.guestManager.GuestManagerHost;
	import potato.designer.plugin.uidesigner.view.ComponentView;
	import potato.designer.plugin.uidesigner.view.LaunchLocalHostView;
	import potato.designer.plugin.uidesigner.view.OutlineView;
	import potato.designer.plugin.window.ViewWindow;
	import potato.designer.plugin.window.WindowManager;
	import potato.designer.utils.MultiLock;
	
	import spark.layouts.VerticalLayout;

	/**
	 *视图控制器
	 * <br>控制编辑器UI与客户端视图。
	 * @author Administrator
	 * 
	 */
	public class ViewController
	{
		
		/**窗口0的视图列表。默认是组件类型视图和大纲视图*/
		public static const window0Views:Vector.<UIComponent> = new Vector.<UIComponent>;
		/**窗口0*/
		protected static var _window0:ViewWindow;
		
		/**窗口1的视图列表。默认是属性视图*/
		public static const window1Views:Vector.<UIComponent> = new Vector.<UIComponent>;
		/**窗口1*/
		protected static var _window1:ViewWindow;
		
		/**组件视图*/
		protected static var _componentTypeView:ComponentView;
		/**组件视图数据提供程序*/
		protected static var _componentTypeViewDataProvider:ArrayList;
		/**添加组件菜单数据提供程序*/
		protected static var _componentTypeCreaterDataProvider:ArrayList;
		
		/**大纲视图*/
		protected static var _outlineView:OutlineView;
		
		protected static var _foldPath:Vector.<uint> = new <uint>[];
		protected static var _focusIndex:int = -1;
		protected static var _targetProfile:ITargetProfile;
		
		/***更改了视图列表后调用此方法，以便应用更改。*/
		public static function updateWindow():void
		{
			if(window0Views.length)
			{
				if(!_window0)
				{
					_window0 = WindowManager.openWindow("", window0Views, new VerticalLayout);
				}
				
				_window0.refresh();
			}
			else
			{
				if(_window0)
				{
					_window0.refresh();
					_window0.close();
					_window0 = null;
				}
			}
			
			if(window1Views.length)
			{
				if(!_window1)
				{
					_window1 = WindowManager.openWindow("", window1Views, new VerticalLayout);
				}
				
				_window1.refresh();
			}
			else
			{
				if(_window1)
				{
					_window1.refresh();
					_window1.close();
					_window1 = null;
				}
			}
		}
		
		internal static function clearStage():void
		{
			_foldPath.length = 0;
			_focusIndex = -1;
			//TODO
		}
		
		internal static function init():void
		{
			
			
			//注册视图并显示窗口
			_componentTypeViewDataProvider = new ArrayList;
			_componentTypeCreaterDataProvider = new ArrayList;
			_componentTypeView = new ComponentView;
			_componentTypeView.list.dataProvider = _componentTypeViewDataProvider;
			_componentTypeView.add_drop.dataProvider = _componentTypeCreaterDataProvider;
			window0Views.push(_componentTypeView);
			
			_outlineView = new OutlineView;
			window0Views.push(_outlineView);
			
			window0Views.push(new LaunchLocalHostView);
			
			updateWindow();
			
			EventCenter.addEventListener(GuestManagerHost.EVENT_GUEST_PLUGIN_ACTIVATED, guestPluginActivatedHandler);
			EventCenter.addEventListener(GuestManagerHost.EVENT_GUEST_CONNECTED, guestConnectedHandler);
			for each(var guest:Guest in GuestManagerHost.getGuestsWithPlugin(DesignerConst.PLUGIN_NAME))
			{
				initGuest(guest);
			}
		}
		
		protected static function guestPluginActivatedHandler(event:DesignerEvent):void
		{
			if(DesignerConst.PLUGIN_NAME == event.data[1])
			{
				initGuest(event.data[0]);
			}
		}
		
		protected static function guestConnectedHandler(event:DesignerEvent):void
		{
			if(Guest(event.data).isPluginActived(DesignerConst.PLUGIN_NAME))
			{
				initGuest(event.data);
			}
		}
		
		protected static function initGuest(guest:Guest):void
		{
			var lock:MultiLock = new MultiLock;
			lock.addEventListener(MultiLock.EVENT_DEAD, lockHandler);
			
			for (var i:int = 0; i < UIDesignerHost.compilerList.length; i++) 
			{
				if(UIDesignerHost.compilerList[i].initGuest(guest, lock))
					break;
			}
			
			if(lock.isFree)
			{
				finishInit();
			}
			else
			{
				lock.addEventListener(MultiLock.EVENT_UNLOCKED, lockHandler);
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
				guest.send(DesignerConst.S2C_UPDATE, [_targetProfile, _foldPath, _focusIndex]);
			}
		}
		
		
		/**
		 *注册组件类型到视图 
		 * @param name 组件名
		 * @param isContainer 组件是否是容器。这决定了组件能否展开并插入子组件
		 * @param icon 为组件指定图标
		 * 
		 */
		internal static function regComponentType(type:ComponentType):void
		{
			_componentTypeViewDataProvider.addItem(type);
			//TODO：向客户端分发更改
			
		}
		
		/**
		 *从视图移除组件类型
		 * @param name 组件名
		 * 
		 */
		internal static function removeComponentType(type:ComponentType):void
		{
			_componentTypeViewDataProvider.removeItem(type);
			//TODO：向客户端分发更改
		}
		
		/**
		 *注册组件类型创建器菜单项
		 * <br>在设计器UI中，组件视图的左上角有一个添加组件下拉菜单。使用此方法注册新的菜单项
		 * @param label 菜单项的标签
		 * @param func 点击菜单项后调用的方法
		 * 
		 */
		public static function regComponentTypeCreater(label:String, func:Function):void
		{
			_componentTypeCreaterDataProvider.addItem({label:label, func:func, toString:function():String{return label}});
		}
		
		/**
		 * 移除组件类型创建器菜单项
		 * @param label 菜单项的标签
		 * 
		 */
		public static function removeComponentTypeCreater(label:String):void
		{
			for(var i:int = 0; i < _componentTypeCreaterDataProvider.length; i++)
			{
				var obj:Object = _componentTypeCreaterDataProvider.getItemAt(i);
				if(obj.label == label)
				{
					delete _componentTypeCreaterDataProvider.removeItem(obj)
				}
			}
		}

//		/**大纲视图*/
//		public static function get outlineView():OutlineView
//		{
//			return _outlineView;
//		}
		
		///////////////////////
		
//		public static function set foldPath(value:Vector.<uint>):void
//		{
//			setFoldAndFocus(value, _focusIndex);
//		}
//		public static function set focusIndex(value:int):void
//		{
//			setFoldAndFocus(_foldPath, value);
//		}
		
//		internal static function addComponent(type:String):void
//		{
//			var path:Vector.<uint> = _foldPath;
//			path.push(_focusIndex + 1);
////			path = _foldPath.concat(_focusIndex + 1);//这句话报错，强转失败
//			_outlineView.add(type, path);
//		}

		/**
		 *展开路径
		 * <br>展开路径是展开组件的路径。当展开一个组件时，可以编辑其子组件，或创建新的子组件。
		 * <br>容器组件才可以展开。
		 * <br>特别的，foldPath[0]只可能为0。
		 */
		public static function get foldPath():Vector.<uint>
		{
			return _foldPath.concat();
		}

		/**
		 *焦点索引
		 * <br>指示展开组件中，正在编辑的组件的索引。
		 * <br>如果没有在编辑任何组件，此值为-1。
		 */
		public static function get focusIndex():int
		{
			return _focusIndex;
		}
		
		/**派发焦点更改事件*/
		public static function setFoldAndFocus(foldPath:Vector.<uint>, focusIndex:int):void
		{
			if(_focusIndex == focusIndex && _foldPath.length == foldPath.length)
			{
				var flug:Boolean;
				for(var i:int = 0; i < _foldPath.length; i++)
				{
					if(_foldPath[i] != foldPath[i])
					{
						flug = true;
						break;
					}
				}
				
				if(!flug)
					return;
			}
			
			_foldPath = foldPath;
			_focusIndex = focusIndex;
			
			EventCenter.dispatchEvent(new DesignerEvent(DesignerConst.FOCUS_CHANGED, [_foldPath, _focusIndex]));
			
			for each(var j:Guest in GuestManagerHost.getGuestsWithPlugin(DesignerConst.PLUGIN_NAME))
			{
				j.send(DesignerConst.S2C_FOCUS_CHANGED, [_foldPath, _focusIndex]);
			}
		}
		
		/**
		 *派发组件树更新事件 
		 * @param tp 组件树
		 * 
		 */
		public static function update(rootTarget:ITargetProfile, foldPath:Vector.<uint> = null, focusIndex:int = -1):void
		{
			_targetProfile = rootTarget;
			if(foldPath)
			{
				_foldPath = foldPath;
				_focusIndex = focusIndex;
			}
			
			EventCenter.dispatchEvent(new DesignerEvent(DesignerConst.UPDATE, [rootTarget, _foldPath, _focusIndex]));
			
			for each(var i:Guest in GuestManagerHost.getGuestsWithPlugin(DesignerConst.PLUGIN_NAME))
			{
				i.send(DesignerConst.S2C_UPDATE, [rootTarget, _foldPath, _focusIndex]);
			}
		}
		
		
	}
}