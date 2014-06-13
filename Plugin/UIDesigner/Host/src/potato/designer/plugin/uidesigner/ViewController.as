package potato.designer.plugin.uidesigner
{
	import mx.collections.ArrayList;
	import mx.core.UIComponent;
	
	import potato.designer.plugin.window.ViewWindow;
	import potato.designer.plugin.window.WindowManager;
	
	import spark.layouts.VerticalLayout;
	import potato.designer.plugin.uidesigner.view.ComponentView;
	import potato.designer.plugin.uidesigner.view.OutlineView;

	/**
	 *视图控制器
	 * <br>显示编辑器UI等功能 
	 * @author Administrator
	 * 
	 */
	public class ViewController
	{
		
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
		internal static var _componentTypeViewDataProvider:ArrayList;
		
		/**大纲视图*/
		protected static var _outlineView:OutlineView;
		protected static var _outlineTree:XML;
		
		/**添加组件类型菜单*/
		internal static var _componentTypeCreaterDataProvider:ArrayList;
		
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
			_componentTypeView = new ComponentView;
			
			_componentTypeViewDataProvider = new ArrayList;
			_componentTypeView.list.dataProvider = _componentTypeViewDataProvider;
			
			_componentTypeCreaterDataProvider = new ArrayList;
			_componentTypeView.add_drop.dataProvider = _componentTypeCreaterDataProvider;
			
			window0Views.push(_componentTypeView);
			
			_outlineView = new OutlineView;
			_outlineTree = 
				<root>
					<target label="走你"/>
				</root>
			
			_outlineView.tree.dataProvider = _outlineTree
			window0Views.push(_outlineView);
			
			updateWindow();
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
	}
}