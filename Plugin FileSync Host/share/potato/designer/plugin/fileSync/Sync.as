package potato.designer.plugin.fileSync 
{
	
	
	import flash.utils.ByteArray;
	
	import potato.designer.framework.DataCenter;
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Message;

	CONFIG::HOST
	{
		import flash.events.Event;
		import flash.filesystem.File;
		import flash.filesystem.FileMode;
		import flash.filesystem.FileStream;
		import flash.utils.Dictionary;
		
		import potato.designer.framework.EventCenter;
		import potato.designer.plugin.guestManager.Guest;
		import potato.designer.plugin.guestManager.GuestManagerHost;
	}
	
	CONFIG::GUEST
	{
		import core.filesystem.File;
		import core.filesystem.FileInfo;
		
		import potato.designer.plugin.guestManager.GuestManagerGuest;
	}
	
	public class Sync
	{
		public static const PLUGIN_NAME:String = "FileSync";
		
		/**创建远程Sync对象*/
		public static const CREATE_REMOTE_SYNC:String = "CREATE_REMOTE_SYNC";
		
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
		
		
		protected static const JOB_SCAN:String = "SCAN";
		protected static const JOB_SYNC:String = "SYNC";
		protected static const JOB_PUSH:String = "SYNC_PUSH";
		protected static const JOB_PULL:String = "SYNC_PULL";
		protected static const JOB_REMOTE_SCAN:String = "SYNC_REMOTE_SCAN";
		protected static const JOB_REMOTE_SYNC:String = "SYNC_REMOTE_SYNC";
		
		
		CONFIG::HOST
			protected var _guest:Guest;
		
		protected var _id:String;
		protected var _localPath:String;
		protected var _remotePath:String;
		protected var _direction:String;
		protected var _syncSubfolder:Boolean;
		protected var _changeLess:String;
		
		
		/**存储文件的上次更改时间*/
		internal const fileMap:Object = {};
		/**存储文件的更改距今时间。如果文件在上次同步之后未曾更改，则值为null。*/
		internal var changedMap:Object = {};
		protected const jobs:Vector.<SyncJob> = new Vector.<SyncJob>;
		protected var working:Boolean;
		
		protected function addJob(job:SyncJob):void
		{
			jobs.push(job);
			work();
		}
		
		protected function jobDone(...args):void
		{
			var job:SyncJob = jobs.shift();
			job.callback && job.callback.apply(null, args);
			working = false;
			work();
		}
		
		CONFIG::HOST
			protected static const guestMap:Dictionary = new Dictionary;
		CONFIG::GUEST
			protected static const syncMap:Object = new Object;
		
		protected var remoteCrated:Boolean;
		
		
		internal static function start(info:PluginInfo):void
		{
			CONFIG::HOST
			{
				for each(var i:Guest in GuestManagerHost.guestList)
				{
					addEventListenerTo(i);
				}
				EventCenter.addEventListener(GuestManagerHost.EVENT_GUEST_CONNECTED,
					function(event:DesignerEvent):void
					{
						addEventListenerTo(event.target);
						
						//
						new Sync(event.data as Guest, "", "", true);
					});
			}
			
			CONFIG::GUEST
			{
				addEventListenerTo(GuestManagerGuest);
			}
			
			info.started();
			
			function addEventListenerTo(eventDispatcher:*):void
			{
				eventDispatcher.addEventListener(CREATE_REMOTE_SYNC, createRemoteSyncHandler);
				eventDispatcher.addEventListener(JOB_PUSH, msgForwardHandler);
				eventDispatcher.addEventListener(JOB_PULL, msgForwardHandler);
				eventDispatcher.addEventListener(JOB_REMOTE_SCAN, msgForwardHandler);
				eventDispatcher.addEventListener(JOB_REMOTE_SYNC, msgForwardHandler);
			}
		}
		
		protected static function createRemoteSyncHandler(msg:Message):void
		{
			log("接收到创建远程Sync对象的请求", msg.data);
			
			CONFIG::HOST
			{
				new Sync(msg.data[0], msg.data[1], msg.data[2], msg.data[3], msg.data[4], msg.data[5], msg.data[6]);
			}
				
			CONFIG::GUEST
			{
				new Sync(msg.data[0], msg.data[1], msg.data[2], msg.data[3], msg.data[4], msg.data[5]);
			}
				
			msg.answer("");
			
		}
		
		/**
		 *将同一个客户端/主机端传递过来的相关消息转发给对应的Sync对象 
		 * @param msg
		 * 
		 */
		protected static function msgForwardHandler(msg:Message):void
		{
			CONFIG::HOST
			{
				const syncMap:Object = guestMap[msg.target];
			}
			
			const sync:Sync = syncMap[msg.data[0]];
			
			switch(msg.type)
			{
				case JOB_PUSH:
					sync.pushRequestHandler(msg);
					break;
				case JOB_PULL:
					sync.pullRequestHandler(msg);
					break;
				case JOB_REMOTE_SCAN:
					sync.scanRemoteRequestHandler(msg);
					break;
				case JOB_REMOTE_SYNC:
					sync.pushRequestHandler(msg);
					break;
				
				default:
					throw "无法理解消息类型";
			}
		}
		
		CONFIG::HOST
		protected function send(type:String, data:* = null, callbackHandle:Function = null):void
		{
			_guest.send(type, data, callbackHandle);
		}
		
		CONFIG::GUEST
		protected function send(type:String, data:* = null, callbackHandle:Function = null):void
		{
			GuestManagerGuest.send(type, data, callbackHandle);
		}
		
		
		
		CONFIG::HOST
		/**
		 *创建一个同步对象 
		 * @param localPath 本地路径
		 * @param remotePath 远程路径
		 * @param syncSubfolder 是否同步子目录
		 * @param channel
		 * @param direction
		 * @param changeLess
		 * @param id
		 * 
		 */
		public function Sync(guest:Guest, localPath:String, remotePath:String, syncSubfolder:Boolean,
							 direction:String = DIRECTION_NONE, changeLess:String = CHANGELESS_NONE, id:String = null)
		{
			_guest = guest;
			
			id ||= Math.random().toString();
			_id = id;
			_localPath = localPath;
			_remotePath = remotePath;
			_syncSubfolder = syncSubfolder;
			_direction = direction;
			_changeLess = changeLess;
			
			scanLocal();
			
			if(guest.isPluginActived(PLUGIN_NAME))
				sendCreateRemoteSync();
			else
				guest.addEventListener(GuestManagerHost.EVENT_GUEST_PLUGIN_ACTIVATED, guestPluginActivatedHandler);
			
			function guestPluginActivatedHandler(event:DesignerEvent):void
			{
				if(PLUGIN_NAME == event.data)
				{
					guest.removeEventListener(GuestManagerHost.EVENT_GUEST_PLUGIN_ACTIVATED, guestPluginActivatedHandler);
					sendCreateRemoteSync();
				}
			}
		}
		
		
		CONFIG::GUEST
		/**
		 *创建一个同步对象 
		 * @param localPath 本地路径
		 * @param remotePath 远程路径
		 * @param syncSubfolder 是否同步子目录
		 * @param channel
		 * @param direction
		 * @param changeLess
		 * @param id
		 * 
		 */
		public function Sync(localPath:String, remotePath:String, syncSubfolder:Boolean,
							 direction:String = DIRECTION_NONE, changeLess:String = CHANGELESS_NONE, id:String = null)
		{
			id ||= Math.random().toString();
			_id = id;
			_localPath = localPath;
			_remotePath = remotePath;
			_syncSubfolder = syncSubfolder;
			_direction = direction;
			_changeLess = changeLess;
			
			log("创建Sync", localPath, remotePath, syncSubfolder, direction, changeLess, id);
			
			sendCreateRemoteSync();
			
			scanLocal();
			
		}
		
		protected function sendCreateRemoteSync():void
		{
			log("[Sync] 请求创建远程Sync", _id);
			send(CREATE_REMOTE_SYNC, [localPath, remotePath, syncSubfolder, direction, changeLess, _id], remoteSyncCreatedHandler);
		}
		
		protected function remoteSyncCreatedHandler(msg:Message):void
		{
			remoteCrated = true;
			log("远程Sync已经创建", _id);
		}
		
		
		
		/**
		 *推送本地文件到远程目录
		 * @param path 目录
		 * @param callback 完成时的回调。参数：ok:Boolean 表示是否推送成功
		 * 
		 */
		public function push(path:String, callback:Function):void
		{
			addJob(new SyncJob(JOB_PUSH, callback, path));
		}
		
		protected function pushNow():void
		{
			var job:SyncJob = jobs[0];
			var bytes:ByteArray = readFile(job.path);
			
			if(!bytes)
				return jobDone(false);
			
			
			send(JOB_PUSH, [_id, job.path, bytes], doneMsgHandler);
			
			function doneMsgHandler(msg:Message):void
			{
				return jobDone(msg.data);
			}
		}
		
		protected function pushRequestHandler(msg:Message):void
		{
			msg.answer("", writeFile(msg.data[1], msg.data[2]));
		}
		
		/**
		 *从远程目录拉取一个文件 
		 * @param path 目录
		 * @param callback 完成时的回调。参数：ok:Boolean 表示是否拉取成功
		 * 
		 */
		public function pull(path:String, callback:Function):void
		{
			addJob(new SyncJob(JOB_PULL, callback, path));
		}
		
		protected function pullNow():void
		{
			var job:SyncJob = jobs[0];
			send(JOB_PULL, [_id, job.path], doneMsgHandler);
			
			function doneMsgHandler(msg:Message):void
			{
				if(!msg.data)
					return jobDone(false);
				
				return jobDone(writeFile(job.path, msg.data));
			}
		}
		
		
		
		protected function pullRequestHandler(msg:Message):void
		{
			msg.answer("", readFile(msg.data[1]));
		}
		
		
		
		/**
		 *扫描远程目录 
		 * @param callback 完成时的回调。参数：fileMap:Object 远程目录的文件表
		 * 
		 */
		public function scanRemote(callback:Function):void
		{
			addJob(new SyncJob(JOB_REMOTE_SCAN, callback, null));
		}
		
		protected function scanRemoteNow():void
		{
			var job:SyncJob = jobs[0];
			send(JOB_REMOTE_SCAN, [_id, job.path], doneMsgHandler);
			
			function doneMsgHandler(msg:Message):void
			{
				if(!msg.data)
				{
					log("[Sync] [Error] 扫描远程目录时发生错误");
				}
				
				return jobDone(msg.data);
			}
		}
		
		protected function scanRemoteRequestHandler(msg:Message):void
		{
			var bytes:ByteArray;
			try
			{
				scanLocal();
				msg.answer("", fileMap);
			} 
			catch(error:Error) 
			{
				msg.answer("", null);
			}
		}
		
		public function sync(callback:Function):void
		{
			addJob(new SyncJob(JOB_SYNC, callback, null));
		}
		
		protected function syncNow():void
		{
			var job:SyncJob = jobs[0];
			
			if(DIRECTION_NONE == _direction)
			{
				return jobDone(true);
			}
			
			
			send(JOB_REMOTE_SCAN, [_id, job.path], doneMsgHandler);
			
			if(_changeLess != CHANGELESS_LOCAL)
			{
				scanLocal();
			}
			
			function doneMsgHandler(msg:Message):void
			{
				if(!msg.data)
				{
					log("[Sync] [Error] 同步远程目录时发生错误");
					return jobDone(false);
				}
				
				
				//展开同步工作为一组pull/push工作。最后一个pull/push工作完成时，同步工作完成
				
				var remoteFileMap:Object = msg.data[0];
				var remoteChangedMap:Object = msg.data[1];
				var subJob:SyncJob;
				var path:String;
				
				switch(_direction)
				{
					case DIRECTION_TO_REMOTE:
						for(path in changedMap)
						{
							subJob = new SyncJob(JOB_PUSH, null, path);
							addJob(subJob);
						}
						subJob.callback = syncDoneCallback;
						break;
					
					case DIRECTION_TO_LOCAL:
						for(path in remoteChangedMap)
						{
							subJob = new SyncJob(JOB_PULL, null, path);
							addJob(subJob);
						}
						subJob.callback = syncDoneCallback;
						break;
					
					case DIRECTION_TWO_WAY:
						for(path in changedMap)
						{
							subJob = new SyncJob(JOB_PUSH, null, path);
							addJob(subJob);
						}
						
						for(path in remoteChangedMap)
						{
							subJob = new SyncJob(JOB_PULL, null, path);
							addJob(subJob);
						}
						subJob.callback = syncDoneCallback;

						break;
					
					default:
						throw new Error("指定的同步方向无法识别");
				}
				
				var callback:Function = job.callback;
				job.callback = null;
				jobDone();
				
				
				
				function syncDoneCallback(result:Boolean):void
				{
					callback && callback(true);
				}
			}
		}
		
		
		protected function syncPrepareRequestHandler(msg:Message):void
		{
			try
			{
				if(!changedMap || _changeLess != CHANGELESS_REMOTE)
					scanLocal();
				msg.answer("", changedMap);
			} 
			catch(error:Error) 
			{
				msg.answer("", null);
			}
			
		}
		
		protected function work():void
		{
			log("[Sync]!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! enter WORK!");
			
			if(working || !remoteCrated || !jobs.length)
				return;
			
			working = true;
			
			var job:SyncJob = jobs[0];
			switch(job.type)
			{
				
				case JOB_SYNC:
					syncNow();
					break;
				
				case JOB_SCAN:
					scanLocal();
					break;
				
				case JOB_PULL:
					pullNow();
					break;
				
				case JOB_PUSH:
					pushNow();
					break;
				
				case JOB_REMOTE_SCAN:
					send(JOB_REMOTE_SCAN, null, remoteScanCallback);
					function remoteScanCallback(msg:Message):void
					{
						log("[Sync] 远程扫描完成！", remotePath);
						jobDone(msg.data);
					}
					break;
				
				case JOB_REMOTE_SYNC:
					send(JOB_REMOTE_SYNC, null, remoteSyncCallback);
					function remoteSyncCallback(msg:Message):void
					{
						log("[Sync] 远程同步完成！", remotePath);
						jobDone(msg.data);
					}
					break;
			}
		}
		
		/////////////////////////Native相关代码//////////////////////////
		
		
		protected function readFile(path:String):ByteArray
		{
			path = localPath + "/" + path;
			var bytes:ByteArray;
			
			
			try
			{
				CONFIG::HOST
				{
					var fileStream:FileStream = new FileStream();
					fileStream.open(new File(path), FileMode.READ);
					bytes = new ByteArray;
					fileStream.readBytes(bytes);
				}
				
				CONFIG::GUEST
				{
					bytes = File.readByteArray(path);
				}
			} 
			catch(error:Error) 
			{
				log("[Sync] [Error] 读取本地文件错误，", path);
			}
			
			CONFIG::HOST
			{
				fileStream.close();
			}
			
			return bytes;
		}
		
		protected function writeFile(path:String, bytes:ByteArray):Boolean
		{
			path = localPath + "/" + path;
			
			try
			{
				CONFIG::HOST
				{
					var fileStream:FileStream = new FileStream();
					fileStream.open(new File(path), FileMode.WRITE);
					fileStream.writeBytes(bytes);
					fileStream.close();
				}
				CONFIG::GUEST
				{
					File.writeByteArray(path, bytes);
				}
			} 
			catch(error:Error) 
			{
				log("[Sync] [Error] 写文件时发生错误", path);
				CONFIG::HOST
				{
					fileStream.close();
				}
				
				return false;
			}
			
			return true;
		}
		
		CONFIG::HOST
		public function scanLocal():void
		{
			var rootFile:File = new File(DataCenter.workSpaceFolderPath + "/" + localPath);
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
						if(!i.isDirectory || syncSubfolder)
							scanThis(i);
					} 
				}
				else
				{
					var path:String = rootFile.getRelativePath(file);
					log("[Sync] 处理了文件", path);
					var newTime:Number = file.modificationDate.time;
					
					if(fileMap[path] != newTime)
					{
						fileMap[path] = newTime;
						changedMap[path] = true;
					}
				}
			}
		}
		
		CONFIG::GUEST
		/**
		 *扫描本地目录，这是一个同步操作。
		 */
		public function scanLocal():void
		{
			var path:String = DataCenter.workSpaceFolderPath + "/" + localPath;
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
			
			
			
			function scanThese(arr:Array, parentPath:String):void
			{
				var currentTime:Number = new Date().time;
				changedMap = {};
				
				for each(var i:FileInfo in arr)
				{
					if("." == i.name || ".." == i.name)
					{
						continue;
					}
					
					var path:String = parentPath + "/" + i.name;
					
					if(i.isDirectory)
					{
						if(syncSubfolder)
							scanThese(File.getDirectoryListing(path), path);
					}
					else
					{
						log("[Sync] 处理了文件", path);
						var newTime:Number = i.lastWriteTime.time;
						
						if(fileMap[path] != newTime)
						{
							fileMap[path] = newTime;
							changedMap[path] = currentTime - newTime;
						}
					}
				}
			}
		}
		
		////////////////////////读写器/////////////////////////////////////

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