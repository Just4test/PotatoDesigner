package potato.designer.plugin.fileSync 
{
	public class SyncJob
	{
		public function SyncJob(type:String, callback:Function, path:String)
		{
			this.type = type;
			this.callback = callback;
			this.path = path;
		}
		
		internal var type:String;
		
		internal var path:String;
		
		internal var callback:Function;
	}
}