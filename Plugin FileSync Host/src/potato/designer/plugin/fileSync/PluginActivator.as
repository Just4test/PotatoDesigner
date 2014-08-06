package potato.designer.plugin.fileSync
{
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;

	public class PluginActivator implements IPluginActivator
	{
		public function start(info:PluginInfo):void
		{
			info.started();
			
		}
		
	}
}