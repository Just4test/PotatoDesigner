package potato.designer.plugin.uidesigner
{
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.registerClassAlias;
	
	import mx.core.UIComponent;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Message;
	import potato.designer.plugin.guestManager.Guest;
	import potato.designer.plugin.guestManager.GuestManagerHost;
	import potato.designer.plugin.uidesigner.basic.ClassTypeEditor;
	import potato.designer.plugin.uidesigner.basic.TypeTransform;
	import potato.designer.plugin.uidesigner.basic.classdescribe.ClassProfile;
	import potato.designer.plugin.uidesigner.basic.classdescribe.Suggest;
	import potato.designer.plugin.uidesigner.construct.BasicClassTypeProfile;
	
	import spark.components.Window;
	import spark.skins.spark.SparkChromeWindowedApplicationSkin;
	import spark.skins.spark.WindowedApplicationSkin;
	
	/**
	 *管理设计器的Host端UI、提供两个Window。
	 * <br>提供两个窗口作为Host端UI。这两个窗口均为纵向布局。习惯上，窗口0显示组件类型视图和大纲视图，窗口1显示属性视图。
	 * <br>提供打包、传输组件描述文件的方式
	 * <br>提供控制组件替身的方式
	 * @author Administrator
	 * 
	 */
	public class UIDesignerHost implements IPluginActivator
	{
		{
			registerClassAlias("BasicClassProfile", BasicClassTypeProfile);
			
			TypeTransform.regType("String", "String");
			TypeTransform.regType("int", "int");
			TypeTransform.regType("Number", "Number");
		}
		
		/**请求指定的类描述*/		
		public static const S2C_REQ_DESCRIBE_TYPE:String = "UID_S2C_REQ_DESCRIBE_TYPE";
		public static const SUGGEST_FILE_PATH:String = "suggest.json";
		
		
		/**事件：生成组件配置文件
		 * <br>这个事件将附带一个Object。各个编辑工具需要响应这个事件，并为Object添加属性。
		 * <be>稍后Object将被传输至客户端以生成组件，或者被存储到文件。因此为其添加的属性必须可以序列化。*/
		public static const EVENT_MAKE_COMPONENT_PROFILE:String = "EVENT_MAKE_COMPONENT_PROFILE";
		
		/**组件和大纲窗口*/
		protected static var window0:Window;
		/**属性窗口*/
		protected static var window1:Window;
		
		/**窗口0的视图列表。默认是组件类型视图和大纲视图*/
		public static const window0Views:Vector.<UIComponent> = new Vector.<UIComponent>;
		/**窗口1的视图列表。默认是属性视图*/
		public static const window1Views:Vector.<UIComponent> = new Vector.<UIComponent>;
		
		/***更改了视图列表后调用此方法，以便应用更改。*/
		public static function updateWindow():void
		{
			//TODO
			if(window0)
			{
				window0.removeAllElements();
				for each(var i:UIComponent in window0Views)
				{
					window0.addElement(i);
				}
			}
			
			if(window1)
			{
				window1.removeAllElements();
				for each(i in window1Views)
				{
					window1.addElement(i);
				}
			}
		}
		
		/**
		 *刷新客户端组件树
		 * <br>当属性更改或者向组件树添加了新组件后调用这个方法。
		 * <br>这个方法将先派发EVENT_MAKE_COMPONENT_PROFILE事件，以创建组件配置文件；
		 * <br>然后将组件配置文件传输至客户端，指示其刷新设计舞台。
		 */
		public static function update():void
		{
			//TODO
			var profile:Object = {};
			EventCenter.dispatchEvent(new DesignerEvent(EVENT_MAKE_COMPONENT_PROFILE, profile));
			
			
			for each(var i:Guest in GuestManagerHost.getGuestsWithPlugin("UIDesigner"))
			{
				i.send(DesignerConst.S2C_UPDATE, profile);
			}
			
		}
		
		/**插件注册方法*/
		public function start(info:PluginInfo):void
		{
			Suggest.loadSuggestFile(info.getAbsolutePath(SUGGEST_FILE_PATH));
			
			EventCenter.addEventListener(GuestManagerHost.EVENT_GUEST_CONNECTED, guestConnectedHandler);
			
			//注册视图并显示窗口
			updateWindow();
			
			info.started();
			
		}
		
		private function guestConnectedHandler(event:DesignerEvent):void
		{
			var newWindow:ClassTypeEditor = new ClassTypeEditor;
			newWindow.open(true);
			
			update();
		}
		
		
	}
}