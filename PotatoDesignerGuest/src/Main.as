package
{
	
	import core.display.DisplayObjectContainer;
	import core.display.Stage;
	import core.text.TextField;
	
	import potato.designer.framework.DataCenter;
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.PluginManager;
	import potato.ui.UIGlobal;
	
	public class Main extends DisplayObjectContainer
	{
		
		static protected var _instance:Main;
		
		public var text:TextField;
		
		public function Main(arg:String = null)
		{
			DataCenter.loadWorkSpace("designer");
			
			text = new TextField("", Stage.getStage().stageWidth, Stage.getStage().stageHeight, UIGlobal.defaultFont, 32, 0xffffffff);
			Stage.getStage().addChild(text);
			
			EventCenter.addEventListener(EventCenter.EVENT_LOG, log2text);
			function log2text(event:DesignerEvent):void
			{
				text.text += event.data + "\n";
			}
			
			EventCenter.addEventListener(PluginManager.EVENT_PLUGIN_INSTALLED, loadPluginWhenLoaded);
			PluginManager.scan();
			
			
			EventCenter.addEventListener(PluginManager.EVENT_PLUGIN_ACCTIVATED, startHandler);
			
			
			EventCenter.addEventListener("show", showSomeThing);
		}
		
		protected function loadPluginWhenLoaded(e:DesignerEvent):void
		{
			PluginManager.startPlugin(e.data.id);
		}
		
		protected function startHandler(e:DesignerEvent):void
		{
		}
		
		public function showSomeThing(e:DesignerEvent):void
		{
			var t:* = e.data;
			trace(t);
		}
	}
}