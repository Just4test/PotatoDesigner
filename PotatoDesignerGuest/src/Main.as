package
{
	
	import core.display.DisplayObjectContainer;
	import core.display.Stage;
	
	import potato.designer.framework.DataCenter;
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.PluginManager;
	import potato.ui.TextInput;
	import potato.ui.UIGlobal;
	
	public class Main extends DisplayObjectContainer
	{
//		protected var _domain:Domain;
//		protected var _connection:Connection;
		
		static protected var _instance:Main;
		
		public var textHost:TextInput;
		
		public function Main(arg:String = null)
		{
//			_instance = this;
//			
//			var res:Res = new Res();
//			//			res.addEventListener(HttpEvent.RES_LOAD_COMPLETE, onLoaded);
//			res.appendCfg("rcfg.txt", true);
//			
//			var connectHelper:ConnectHelper = new ConnectHelper;
//			addChild(connectHelper);
			DataCenter.loadWorkSpace("designer");
			
			textHost = new TextInput("", Stage.getStage().stageWidth, Stage.getStage().stageHeight, UIGlobal.defaultFont, 32, 0xffffffff);
			Stage.getStage().addChild(textHost);
			
			EventCenter.addEventListener(EventCenter.EVENT_LOG, log2textHost);
			function log2textHost(event:DesignerEvent):void
			{
				textHost.text += event.data + "\n";
			}
			
			EventCenter.addEventListener(PluginManager.EVENT_PLUGIN_INSTALLED, loadPluginWhenLoaded);
			PluginManager.scan();
			
			
			EventCenter.addEventListener(PluginManager.EVENT_PLUGIN_ACCTIVATED, startHandler);
		}
		
		protected function loadPluginWhenLoaded(e:DesignerEvent):void
		{
			PluginManager.startPlugin(e.data.id);
		}
		
		protected function startHandler(e:DesignerEvent):void
		{
		}
	}
}