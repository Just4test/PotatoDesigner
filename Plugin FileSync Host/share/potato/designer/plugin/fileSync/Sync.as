package potato.designer.plugin.fileSync 
{
	
	import flash.utils.ByteArray;
	
	import core.filesystem.File;
	
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Message;

	CONFIG::HOST
	{
		import flash.events.Event;
		import flash.utils.Dictionary;
		
		import potato.designer.framework.EventCenter;
		import potato.designer.plugin.guestManager.Guest;
		import potato.designer.plugin.guestManager.GuestManagerHost;
	}
	
	CONFIG::GUEST
	{
		import potato.designer.plugin.guestManager.GuestManagerGuest;
	}
	
	public class Sync
	{
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
		protected static const JOB_PUSH:String = "PUSH";
		protected static const JOB_PULL:String = "PULL";
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
		
		
		
		internal const fileMap:Object = {};
		internal const changedMap:Object = {};
		protected const jobs:Vector.<SyncJob> = new Vector.<SyncJob>;
		
		CONFIG::HOST
			protected static const guestMap:Dictionary = new Dictionary;
		CONFIG::GUEST
			protected static const syncMap:Object = new Object;
		
		protected var native:INativeSync;
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
					function(msg:Message):void
					{
						addEventListenerTo(msg.target);
					});
			}
			
			CONFIG::GUEST
			{
				addEventListenerTo(GuestManagerGuest)
			}
			
			info.started();
			
			
			function addEventListenerTo(eventDispatcher:*):void
			{
				eventDispatcher.addEventListener(Sync.CREATE_REMOTE_SYNC, createRemoteSyncHandler);
				eventDispatcher.addEventListener(JOB_REMOTE_SCAN, msgForwardHandler);
				eventDispatcher.addEventListener(JOB_REMOTE_SYNC, msgForwardHandler);
			}
		}
		
		protected static function createRemoteSyncHandler(msg:Message):void
		{
			CONFIG::HOST
				new Sync(msg.data[0], msg.data[1], msg.data[2], msg.data[3], msg.data[4], msg.data[5], msg.data[6]);
				
			CONFIG::GUEST
				new Sync(msg.data[0], msg.data[1], msg.data[2], msg.data[3], msg.data[4], msg.data[5]);
			
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
			
			id ||= Math.random().toString();
			_id = id;
			_localPath = localPath;
			_remotePath = remotePath;
			_syncSubfolder = syncSubfolder;
			_direction = direction;
			_changeLess = changeLess;
			
			
			CONFIG::HOST
			{
				native = new NativeSyncHost(this);
			}
			CONFIG::GUEST
			{
				native = new NativeSyncGuest(this);
				initRemote();
			}
			
			scanLocal();
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
			
			
			CONFIG::HOST
			{
				native = new NativeSyncHost(this);
			}
			CONFIG::GUEST
			{
				native = new NativeSyncGuest(this);
			}
			
			scanLocal();
		}
		
		
		/**
		 *将同一个客户端/主机端传递过来的相关消息转发给对应的Sync对象 
		 * @param msg
		 * 
		 */
		protected static function msgForwardHandler(msg:Message):void
		{
			CONFIG::HOST
				const syncMap:Object = guestMap[msg.target];
				
			const sync:Sync = syncMap[msg.data[0]];
			sync.msgHandler(msg);
		}
		
		/**
		 *统一的消息处理 
		 * @param msg
		 * 
		 */
		protected function msgHandler(msg:Message):void
		{
			
		}
		
		protected function remoteCreatedHandler(msg:Message):void
		{
			remoteCrated = true;
			work();
		}
		
		protected function remoteScanHandler(msg:Message):void
		{
			scanLocal();
			
			msg.answer("");
		}
		
		protected function remoteSyncHandler(msg:Message):void
		{
			actualSync(okHandler);
			
			function okHandler():void
			{
				msg.answer("");
			}
		}
		
		
		/**
		 *推送本地文件到远程目录
		 * @param path 目录
		 * @param callback 完成时的回调。参数：ok:Boolean 表示是否推送成功
		 * 
		 */
		public function push(path:String, callback:Function):void
		{
			jobs.push(new SyncJob(JOB_PUSH, callback, path));
		}
		
		protected function jobDone(...args):void
		{
			var job:SyncJob = jobs.shift();
			job.callback && job.callback.apply(null, args);
		}
		
		protected function pushNow():void
		{
			var job:SyncJob = jobs[0];
			var bytes:ByteArray;
			
			try
			{
				CONFIG::GUEST
					bytes = File.readByteArray(job.path);
			} 
			catch(error:Error) 
			{
				log("[Sync] [Error] 推送文件时读取本地文件错误，", localPath + "/" + job.path);
				
				return jobDone(false);
			}
			
			
			send(JOB_PUSH, [_id, job.path, bytes], doneMsgHandler);
			
			function doneMsgHandler(msg:Message):void
			{
				return jobDone(msg.data);
			}
		}
		
		protected function pushRequestHandler(msg:Message):void
		{
			try
			{
				File.write(localPath + "/" + msg.data[1], msg.data[2]);
			} 
			catch(error:Error) 
			{
				log("[Sync] [Error] 收到远程Sync发来的推送请求，但是写文件时发生错误", localPath + "/" + msg.data[1]);
				msg.answer("", false);
			}
				
			msg.answer("", true);
		}
		
		/**
		 *从远程目录拉取一个文件 
		 * @param path 目录
		 * @param callback 完成时的回调。参数：ok:Boolean 表示是否拉取成功
		 * 
		 */
		public function pull(path:String, callback:Function):void
		{
			jobs.push(new SyncJob(JOB_PULL, callback, path));
		}
		
		protected function pullNow():void
		{
			var job:SyncJob = jobs[0];
			send(JOB_PULL, [_id, job.path], doneMsgHandler);
			
			function doneMsgHandler(msg:Message):void
			{
				if(msg.data)
				{
					try
					{
						CONFIG::GUEST
							File.write(localPath + "/" + job.path, msg.data);
					} 
					catch(error:Error) 
					{
						log("[Sync] [Error] 拉取文件时写文件发生错误", localPath + "/" + job.path);
						return jobDone(false);
					}
				}
				
				return jobDone(msg.data);
			}
		}
		
		protected function pullRequestHandler(msg:Message):void
		{
			var bytes:ByteArray;
			try
			{
				CONFIG::GUEST
					bytes = File.readByteArray(localPath + "/" + msg.data[1]);
			} 
			catch(error:Error) 
			{
				log("[Sync] [Error] 收到远程Sync发来的拉取请求，但是读文件时发生错误", localPath + "/" + msg.data[1]);
			}
			
			msg.answer("", bytes);
		}
		
		/**
		 *扫描本地目录，这是一个同步操作。
		 */
		public function scanLocal():void
		{
			native.nativeScanLocal();
		}
		
		/**
		 *扫描远程目录 
		 * @param callback 完成时的回调。参数：fileMap:Object 远程目录的文件表
		 * 
		 */
		public function scanRemote(callback:Function):void
		{
			jobs.push(new SyncJob(JOB_REMOTE_SCAN, callback, null));
		}
		
		protected function scanRemoteNow():void
		{
			var job:SyncJob = jobs[0];
			send(JOB_PULL, [_id, job.path], doneMsgHandler);
			
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
					send(JOB_REMOTE_SYNC, null, syncToLocalHandler);
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
		
		protected function addJob(job:SyncJob):void
		{
			jobs.push(job);
			if(1 == jobs.length)
			{
				work();
			}
		}
		
		protected function work():void
		{
			if(!remoteCrated || !jobs.length)
				return;
			
			var job:SyncJob = jobs[0];
			switch(job.type)
			{
				
				case JOB_SYNC:
					actualSync(job.callback);
					break;
				
				case JOB_SCAN:
					scanLocal();
					break;
				
				case JOB_PULL:
					pull(job.path, job.callback);
					break;
				
				case JOB_PUSH:
					push(job.path, job.callback);
					break;
				
				case JOB_REMOTE_SCAN:
					send(JOB_REMOTE_SCAN, null, remoteScanCallback);
					function remoteScanCallback(msg:Message):void
					{
						log("[Sync] 远程扫描完成！", remotePath);
						job.callback && job.callback();
						jobs.shift();
						work();
					}
					break;
				
				case JOB_REMOTE_SYNC:
					send(JOB_REMOTE_SYNC, null, remoteSyncCallback);
					function remoteSyncCallback(msg:Message):void
					{
						log("[Sync] 远程同步完成！", remotePath);
						job.callback && job.callback();
						jobs.shift();
						work();
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