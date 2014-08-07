package potato.designer.plugin.fileSync
{
	import core.filesystem.File;
	import core.filesystem.FileInfo;
	
	import potato.designer.framework.DataCenter;
	import potato.designer.plugin.guestManager.GuestManagerGuest;

	public class NativeSyncGuest implements INativeSync
	{
		protected var sync:Sync;
				
		
		public function NativeSyncGuest(sync:Sync)
		{
			this.sync = sync;
		}
		
		public function nativeScanLocal():void
		{
			var path:String = DataCenter.workSpaceFolderPath + "/" + sync.localPath;
			if("/" == path.charAt(path.length - 1))
			{
				path = path.substring(0, path.length - 1);
			}
			
			if(File.exists(path))
			{
				//目标是单个文件
				var temp:Array = path.split("/");
				var fileName:String = temp.pop();
				var parentPath:String = temp.join("/");
				
				for each(var i:FileInfo in File.getDirectoryListing(parentPath))
				{
					if(i.name == fileName)
					{
						scanThese([i], parentPath);
						break;
							
					}
				}
			}
			else
			{
				scanThese(File.getDirectoryListing(path), path)
			}
		}
		
		protected function scanThese(arr:Array, parentPath:String):void
		{
			for each(var i:FileInfo in arr)
			{
				if("." == i.name || ".." == i.name)
				{
					continue;
				}
				
				var path:String = parentPath + "/" + i.name;
				
				if(i.isDirectory)
				{
					if(sync.syncSubfolder)
						scanThese(File.getDirectoryListing(path), path);
				}
				else
				{
					log("[Sync] 处理了文件", path);
					var newTime:Number = i.lastWriteTime.time;
					
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
			GuestManagerGuest.send(type, data, callbackHandle);
		}
		
		public function addEventListener(type:String, listener:Function):void
		{
			trace("~~~~~~~~~~~~~~~~", GuestManagerGuest)
			GuestManagerGuest.addEventListener(type, listener);
			trace("~~~~~~~~~~~~~~~~", GuestManagerGuest)
		}
		
		
	}
}