package potato.designer.plugin.fileSync
{
	import flash.filesystem.File;

	import potato.designer.framework.DataCenter;

	public class NativeSyncHost implements INativeSync
	{
		protected var sync:Sync;
				
		
		public function NativeSyncHost(sync:Sync)
		{
			this.sync = sync;
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
						if(!i.isDirectory || sync.syncSubfolder)
							scanThis(i);
					} 
				}
				else
				{
					var path:String = rootFile.getRelativePath(file);
					log("[Sync] 处理了文件", path);
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
	}
}