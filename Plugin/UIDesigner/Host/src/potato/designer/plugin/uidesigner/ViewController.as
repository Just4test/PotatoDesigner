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
		protected static var _outlineView:OutlineView;
		
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
		
		internal static function init(componentTypeViewDataProvider:ArrayList, componentTypeCreaterDataProvider:ArrayList):void
		{
			
			//注册视图并显示窗口
			_componentTypeView = new ComponentView;
			
			_componentTypeView.list.dataProvider = componentTypeViewDataProvider;
			
			_componentTypeView.add_drop.dataProvider = componentTypeCreaterDataProvider;
			
			window0Views.push(_componentTypeView);
			
			_outlineView = new OutlineView;

			window0Views.push(_outlineView);
			
			updateWindow();
		}

		/**大纲视图*/
		public static function get outlineView():OutlineView
		{
			return _outlineView;
		}
		
		
		
	}
}