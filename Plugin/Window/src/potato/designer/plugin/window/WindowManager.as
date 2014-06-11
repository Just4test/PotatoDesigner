package potato.designer.plugin.window
{
	import mx.core.UIComponent;
	
	import potato.designer.framework.DataCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	
	import spark.layouts.BasicLayout;
	
	/**
	 *窗口管理器
	 * <br>一个方便的插件，用于显示窗口。
	 * <br>插件自身创建的窗口有诸多问题，比如不能继承样式。此核心插件由主程序直接驱动，因而可以正确的显示窗口。
	 * @author Just4test
	 * 
	 */
	public class WindowManager implements IPluginActivator
	{
		public static const OPEN_WINDOW:String = "OPEN_WINDOW";
		
		public function start(info:PluginInfo):void
		{
			DataCenter.instance.regProperty(OPEN_WINDOW, ViewWindow, false, OPEN_WINDOW);
			info.started();
			
			openWindow("走你", null, null);
		}
		
		public function openWindow(title:String, layout:BasicLayout, components:Vector.<UIComponent>,
								   width:int = 100, height:int = 100):ViewWindow
		{
			var data:WindowData = new WindowData;
			
			data.title = title;
			data.layout = layout;
			data.components = components;
			data.width = width;
			data.height = height;
			
			var window:ViewWindow = new ViewWindow;
			window.windowData = data;
			
			DataCenter.instance[OPEN_WINDOW] = window;
			
			return window;
		}
	}
}