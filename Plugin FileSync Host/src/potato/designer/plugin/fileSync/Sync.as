package potato.designer.plugin.fileSync
{
	import potato.designer.framework.DataCenter;
	import potato.designer.net.Message;

	CONFIG::HOST
	{
		import flash.events.Event;
		import flash.filesystem.File;
		import flash.filesystem.FileMode;
		import flash.filesystem.FileStream;
		
		import potato.designer.plugin.guestManager.Guest;
	}
	CONFIG::GUEST
	{
		import core.filesystem.File;
		import core.filesystem.FileInfo;
	}
	
	public class Sync
	{
		protected var _localPath:String;
		protected var _remotePath:String;
		protected var _direction:String;
		protected var _syncSubfolder:Boolean;
		protected var _changeLess:String;
		
		/**没有文件会被同步。*/
		public static const DIRECTION_NONE:String = "DIRECTION_NONE";
		/**远程目录是源目录，本地目录是目标目录。*/
		public static const DIRECTION_TO_LOCAL:String = "DIRECTION_TO_LOCAL";
		/**本地目录是源目录，远程目录是目标目录。*/
		public static const DIRECTION_TO_REMOTE:String = "DIRECTION_TO_REMOTE";
		/**双向同步*/
		public static const DIRECTION_TWO_WAY:String = "DIRECTION_TWO_WAY";
		
		/**
		 *模式：默认
		 * <br>如果发生冲突，将会跳过。
		 * <br>同步模式为TO_LOCAL和TO_REMOTE时，目标目录的多余文件不会被删除。
		 * <br>同步模式为TWO_WAY时，发生删除操作时，什么也不做
		 */
		public static const MODE_DEFAULT:String = null;
		
		/**
		 * 模式：严格
		 * <br>同步模式为TO_LOCAL和TO_REMOTE时：
		 * <br>当发生文件冲突时，将覆盖目的文件。将删除目的文件夹中存在，而源文件夹中不存在的文件。
		 * <br>同步模式为TWO_WAY时：
		 * <br>将同步删除操作。如果发生文件冲突，则使用“较新的文件”覆盖“较旧的文件”。本次修改时间离上次修改时间较长的文件被认为较新。
		 */
		public static const MODE_STRICT:String = "MODE_STRICT";
		
		
		/**本地及远程目录都是易变目录*/
		public static const CHANGELESS_NONE:String = "CHANGELESS_NONE";
		/**本地目录是非易变目录*/
		public static const CHANGELESS_LOCAL:String = "CHANGELESS_LOCAL";
		/**远程目录是非易变目录*/
		public static const CHANGELESS_REMOTE:String = "CHANGELESS_REMOTE";
		
		
		protected const jobs:Vector.<SyncJob> = new Vector.<SyncJob>;
		protected const fileMap:Object = {};
		protected const changedMap:Object = {};
		
		
		
		CONFIG::HOST
		{
			protected var guest:Guest;
		}
		
		
		public function Sync(localPath:String, remotePath:String, syncSubfolder:Boolean,
							 direction:String, changeLess:String = CHANGELESS_NONE)
		{
			_localPath = localPath;
			_remotePath = remotePath;
			_syncSubfolder = syncSubfolder;
			_direction = direction;
			_changeLess = changeLess;
			
			scanLocal();
		}
		
		
		/**
		 *推送本地文件 
		 * @param path
		 * @param callback
		 * 
		 */
		public function push(path:String, callback:Function):void
		{
			
		}
		
		public function pull(path:String, callback:Function):void
		{
			
		}
		
		/**
		 *扫描本地目录，这是一个同步操作。
		 */
		public function scanLocal():void
		{
			CONFIG::HOST
			{
				var rootFile:File = new File(DataCenter.workSpaceFolderPath + "/" + _localPath);
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
						
						if(fileMap[path] != newTime)
						{
							fileMap[path] = newTime;
							changedMap[path] = true;
						}
					}
				}
			}
		}
		
		public function scanRemote(callback:Function):void
		{
			var job:SyncJob = new SyncJob;
			job.type = SyncJob.TYPE_REMOTE_SCAN;
			job.callback = callback;
			
			jobs.push(job);
		}
		
		public function actualSync(callback:Function):void
		{
			if(CHANGELESS_LOCAL != _changeLess)
			{
				scanLocal();
			}
			
			switch(_direction)
			{
				case DIRECTION_NONE:
					callback();
					return;
					break;
				
				//同步到本地是由对方Sync执行的
				case DIRECTION_TO_LOCAL:
					guest.send(SyncJob.TYPE_REMOTE_SYNC, syncToLocalHandler);
					function syncToLocalHandler(msg:Message):void
					{
						callback && callback();
					}
					break;
				
				case DIRECTION_TO_REMOTE:
					break;
				
				case DIRECTION_TWO_WAY:
					break;
				
				default:
					throw new Error("指定的同步方向无法识别");
			}
		}
		
		protected function work():void
		{
			if(!jobs.length)
				return;
			
			var job:SyncJob = jobs.shift();
			switch(job.type)
			{
				
				case SyncJob.TYPE_SYNC:
					actualSync(job.callback);
					break;
				
				case SyncJob.TYPE_SCAN:
					scanLocal();
					break;
				
				case SyncJob.TYPE_PULL:
					pull(job.path, job.callback);
					break;
				
				case SyncJob.TYPE_PUSH:
					push(job.path, job.callback);
					break;
				
				case SyncJob.TYPE_REMOTE_SCAN:
					guest.send(SyncJob.TYPE_REMOTE_SCAN, remoteScanCallback);
					function remoteScanCallback(msg:Message):void
					{
						log("[Sync] 远程扫描完成！", remotePath);
						job.callback && job.callback();
					}
					break;
				
				case SyncJob.TYPE_REMOTE_SYNC:
					guest.send(SyncJob.TYPE_REMOTE_SYNC, remoteSyncCallback);
					function remoteSyncCallback(msg:Message):void
					{
						log("[Sync] 远程同步完成！", remotePath);
						job.callback && job.callback();
					}
					break;
			}
		}

		/**
		 *同步的本地路径 
		 */
		public function get localPath():String
		{
			return _localPath;
		}

		/**
		 * 同步的远程路径
		 */
		public function get remotePath():String
		{
			return _remotePath;
		}

		/**
		 *同步模式 
		 */
		public function get direction():String
		{
			return _direction;
		}

		
		/**
		 * 非易变目录设定
		 * <br>您可指定本地文件夹或者远程文件夹为非易变。非易变目录在同步之前不会被扫描。
		 * <br>如果您正在从主机端向客户端同步一个很大的资源文件夹，则将客户端目录设置为非易变将有效地提升同步速度。
		 * <br>当使用双向同步时，将任一目录指定为非易变可能会让同步操作不能正常完成。
		 */		
		public function get changeLess():String
		{
			return _changeLess;
		}

		public function set changeLess(value:String):void
		{
			_changeLess = value;
		}

		public function get syncSubfolder():Boolean
		{
			return _syncSubfolder;
		}


	}
}