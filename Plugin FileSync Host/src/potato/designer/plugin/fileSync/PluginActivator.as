package potato.designer.plugin.fileSync
{
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Message;
	import potato.designer.plugin.guestManager.Guest;
	import potato.designer.plugin.guestManager.GuestManagerHost;

	public class PluginActivator implements IPluginActivator
	{
		public function start(info:PluginInfo):void
		{
			
			
			CONFIG::HOST
			{
				for each(var i:Guest in GuestManagerHost.guestList)
				{
					i.addEventListener(Sync.CREATE_REMOTE_SYNC, createRemoteSync);
				}
				EventCenter.addEventListener(GuestManagerHost.EVENT_GUEST_CREATED,
					function(msg:Message):void
					{
						(msg.target as Guest).addEventListener(Sync.CREATE_REMOTE_SYNC, createRemoteSync);
					});
				
				
				
			}
			CONFIG::GUEST
			{
				import core.filesystem.File;
				import core.filesystem.FileInfo;
			}
			info.started();
			
		}
		
		protected function createRemoteSync(msg:Message):void
		{
			CONFIG::HOST
			{
				new Sync(msg.target as Guest, msg.data[0], msg.data[1], msg.data[2], msg.data[3], msg.data[4], msg.data[5]);
			}
		}
		
	}
}