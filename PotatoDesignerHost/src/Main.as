package
{
	import flash.display.Sprite;
	
	import potato.designer.framework.DataCenter;
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.PluginManager;
	
	public class Main extends Sprite
	{
		protected var avmPath:String = "C:\\Users\\Administrator\\Documents\\Flash Working Folder\\avm\\avm.exe";
		protected var ghostPath:String = "C:\\Users\\Administrator\\Documents\\GitHub\\PotatoDesigner\\PotatoDesignerGhost\\bin-debug\\Main.swf";
		
		protected var workSpaceFolder:String = "C:\\Users\\Administrator\\Documents\\GitHub\\PotatoDesigner\\DesignerWorkSpace";
		
		public function Main()
		{
			super();
			
			DataCenter.loadWorkSpace(workSpaceFolder);
			
			EventCenter.addEventListener(PluginManager.EVENT_PLUGIN_INSTALLED, loadPluginWhenLoaded);
			PluginManager.scan();
		}
		
		
		protected function loadPluginWhenLoaded(e:DesignerEvent):void
		{
			PluginManager.startPlugin(e.data.id);
		}
	}
}