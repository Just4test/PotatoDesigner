package potato.designer.plugin.fileSync 
{
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;

	//因为Sync类不能无参实例化，所以用这个类中转下
	public class PluginActivator implements IPluginActivator
	{
		public function start(info:PluginInfo):void
		{
			Sync.start(info);
		}
	}
}