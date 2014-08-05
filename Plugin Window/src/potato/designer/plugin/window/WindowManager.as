package potato.designer.plugin.window
{
	import mx.core.UIComponent;
	
	import potato.designer.framework.DataCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	
	import spark.layouts.BasicLayout;
	import spark.layouts.supportClasses.LayoutBase;
	
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
		}
		
		public static function openWindow(title:String, components:Vector.<UIComponent>, layout:LayoutBase = null,
								   autoSize:Boolean = true, width:int = 100, height:int = 100):ViewWindow
		{
			log("[Window] 打开窗口:", title);
			var data:WindowData = new WindowData;
			
			data.title = title;
			data.layout = layout || new BasicLayout;
			data.components = components;
			data.autoSize = autoSize;
			data.width = width;
			data.height = height;
			
			var window:ViewWindow = new ViewWindow;
			window.windowData = data;
			
			DataCenter.instance[OPEN_WINDOW] = window;
			
			return window;
		}
	}
}