package potato.designer.plugin.uidesigner
{
	import mx.collections.ArrayList;
	import mx.core.UIComponent;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.plugin.uidesigner.view.ComponentView;
	import potato.designer.plugin.uidesigner.view.OutlineView;
	import potato.designer.plugin.window.ViewWindow;
	import potato.designer.plugin.window.WindowManager;
	
	import spark.layouts.VerticalLayout;

	/**
	 *视图控制器
	 * <br>显示编辑器UI等功能。客户端的视图也由该类控制。
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
		
		protected static var _foldPath:Vector.<uint>;
		protected static var _focusIndex:int;
		
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
					_window1 = null;
				}
			}
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
			
			updateWindow();
			
			
			EventCenter.addEventListener(DesignerConst.OUTLINE_ITEM_CLICK, outlineItemClickHandler);
			EventCenter.addEventListener(DesignerConst.OUTLINE_ITEM_DOUBLE_CLICK, outlineItemDoubleClickHandler);
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
		
		protected static function outlineItemClickHandler(event:DesignerEvent):void
		{
			
		}
		
		protected static function outlineItemDoubleClickHandler(event:DesignerEvent):void
		{
			
		}
		
		///////////////////////
		
		internal static function set foldPath(value:Vector.<uint>):void
		{
			_foldPath = value;
			//TODO：向客户端分发更改
		}
		internal static function set focusIndex(value:int):void
		{
			_focusIndex = value;
			//TODO：向客户端分发更改
		}
		internal static function set focusPath(value:Vector.<uint>):void
		{
			_focusIndex = value.pop();
			_foldPath = value;
			//TODO：向客户端分发更改
		}
		
		internal static function addComponent(type:String):void
		{
			_outlineView.add(type, _foldPath);
		}
		
		
	}
}