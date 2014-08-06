package potato.designer.plugin.fileSync
{
	public class SyncJob
	{
		public static const TYPE_SCAN:String = "SCAN";
		public static const TYPE_SYNC:String = "SYNC";
		public static const TYPE_PUSH:String = "PUSH";
		public static const TYPE_PULL:String = "PULL";
		public static const TYPE_REMOTE_SCAN:String = "SYNC_REMOTE_SCAN";
		public static const TYPE_REMOTE_SYNC:String = "SYNC_REMOTE_SYNC";
		
		internal var type:String;
		
		internal var path:String;
		
		internal var callback:Function;
	}
}