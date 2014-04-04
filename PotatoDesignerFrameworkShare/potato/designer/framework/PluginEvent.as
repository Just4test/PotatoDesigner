package potato.designer.framework
{
	CONFIG::HOST
	{
		import flash.events.Event;
	}
	
	CONFIG::GHOST
	{
		import core.events.Event;
	}
	
	public class PluginEvent extends Event
	{
		private var _plugin:PluginInfo;
		
		public function PluginEvent(type:String, plugin:PluginInfo)
		{
			super(type);
			_plugin = plugin;
		}
		
		
		public function get plugin():PluginInfo
		{
			return _plugin;
		}

	}
}