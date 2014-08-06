package potato.designer.plugin.fileSync
{
	import flash.filesystem.File;
	
	import potato.designer.framework.DataCenter;
	import potato.designer.net.Connection;
	import potato.designer.plugin.guestManager.Guest;

	public class NativeSyncHost implements INativeSync
	{
		protected var sync:Sync;
		protected var guest:Guest;
				
		
		public function NativeSyncHost(sync:Sync, guest:Guest)
		{
			this.sync = sync;
			this.guest = guest;
		}
		
		public function nativeScanLocal():void
		{
			var rootFile:File = new File(DataCenter.workSpaceFolderPath + "/" + sync.localPath);
			scanThis(rootFile);
			//TODO
			
			function scanThis(file:File):void
			{
				if(!file.exists)
				{
					return;
				}
				
				if(file.isDirectory)
				{
					for each(var i:File in file.getDirectoryListing())
					{
						scanThis(i);
					} 
				}
				else
				{
					var path:String = rootFile.getRelativePath(file);
					var newTime:Number = file.modificationDate.time;
					
					if(sync.fileMap[path] != newTime)
					{
						sync.fileMap[path] = newTime;
						sync.changedMap[path] = true;
					}
				}
			}
		}
		
		public function nativeSync():void
		{
		}
		
		public function send(type:String, data:* = null, callbackHandle:Function = null):void
		{
			guest.send(type, data, callbackHandle);
		}
		
		public function addEventListener(type:String, listener:Function):void
		{
			guest.addEventListener(type, listener);
		}
		
		
	}
}