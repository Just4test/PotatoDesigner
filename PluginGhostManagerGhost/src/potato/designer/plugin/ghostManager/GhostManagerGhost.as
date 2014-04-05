package potato.designer.plugin.ghostManager
{
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;

	public class GhostManagerGhost implements IPluginActivator
	{
		/**客户端连接到宿主*/
		public static const EVENT_HOST_CONNECTED:String = "EVENT_HOST_CONNECTED";
		/**客户端从宿主断开*/
		public static const EVENT_HOST_DISCONNECTED:String = "EVENT_HOST_DISCONNECTED";
		
		public function start(info:PluginInfo):void
		{
			
			info.started();
			
		}
		
		
	}
}