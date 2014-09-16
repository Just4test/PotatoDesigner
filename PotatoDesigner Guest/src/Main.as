package
{
	
	import core.display.DisplayObjectContainer;
	import core.display.Stage;
	import core.text.TextField;
	
	import potato.designer.framework.DataCenter;
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.PluginManager;
	
	public class Main extends DisplayObjectContainer
	{
		
		static protected var _instance:Main;
		
		public var text:TextField;
		
		public function Main(...args)
		{
			DataCenter.loadWorkSpace("designer");
//			DataCenter.instance[DataCenter.BOOT_PARAMETERS] = args;
			
			text = new TextField("", Stage.getStage().stageWidth, Stage.getStage().stageHeight, DataCenter.DEFAULT_FONT, 20, 0xffffff);
			Stage.getStage().addChild(text);
			
			EventCenter.addEventListener(EventCenter.EVENT_LOG, log2text);
			function log2text(event:DesignerEvent):void
			{
				text.text += event.data + "\n";
			}
			
			EventCenter.addEventListener(PluginManager.EVENT_PLUGIN_INSTALLED, startPluginWhenLoaded);
			PluginManager.scan();
			
			
			EventCenter.addEventListener(PluginManager.EVENT_PLUGIN_ACCTIVATED, startHandler);
		}
		
		protected function startPluginWhenLoaded(e:DesignerEvent):void
		{
			PluginManager.startPlugin(e.data.id);
		}
		
		protected function startHandler(e:DesignerEvent):void
		{
		}
	}
}