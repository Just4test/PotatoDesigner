package potato.designer.plugin.guestManager
{
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.ServerSocket;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Connection;
	import potato.designer.net.Message;
	import potato.designer.net.NetConst;

	public class GuestManagerHost implements IPluginActivator
	{
		/**客户端创建*/
		public static const EVENT_GUEST_CREATED:String = "EVENT_GUEST_CREATED";
		/**客户端连接到宿主<br>连接起始于管理器将连接设置到Guest对象之时*/
		public static const EVENT_GUEST_CONNECTED:String = "EVENT_GUEST_CONNECTED";
		/**客户端从宿主断开<br>连接终止于连接关闭或者主动断开*/
		public static const EVENT_GUEST_DISCONNECTED:String = "EVENT_GUEST_DISCONNECTED";
		/**客户端激活*/
		public static const EVENT_GUEST_ACTIVATED:String = "EVENT_GUEST_ACTIVATED";
		
		private static var serverSocket:ServerSocket;
		
		private static const _guestList:Vector.<Guest> = new Vector.<Guest>;
		
		private static var _activatedGuest:Guest;
		
		/**插件注册方法*/
		public function start(info:PluginInfo):void
		{
			serverSocket = new ServerSocket;
			serverSocket.bind(NetConst.PORT, "0.0.0.0");
			serverSocket.listen();
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, connectHandler);
			log("[GuestManager] 开始监听连接");
			
			info.started();
			startLocalGuest(960,640);
		}
		
		/**
		 *检测到连接。
		 * <br/>连接后发送服务端问候语
		 * <br/>等待客户端问候语
		 */
		private static function connectHandler(e:ServerSocketConnectEvent):void
		{
			var connection:Connection = new Connection(e.socket);
			log("[GuestManager] 检测到连接，来自 ", connection.remoteAddress);
			connection.send(NetConst.S2C_HELLO, "hello world!");
			
			connection.addEventListener(NetConst.C2S_HELLO, clientInitHandler);
			connection.addEventListener(Event.CLOSE, connectFailHandler);
			connection.addEventListener(IOErrorEvent.IO_ERROR, connectFailHandler);
			connection.addEventListener(Connection.EVENT_CRASH, connectFailHandler);
		}
		
		private static function connectFailHandler(e:Event):void
		{
			var connection:Connection = e.target as Connection;
			
			log("[GuestManager] 连接在对接前失败，来自 ", connection.remoteAddress);
			
			connection.removeEventListener(NetConst.C2S_HELLO, clientInitHandler);
			connection.removeEventListener(Event.CLOSE, connectFailHandler);
			connection.removeEventListener(IOErrorEvent.IO_ERROR, connectFailHandler);
			connection.removeEventListener(Connection.EVENT_CRASH, connectFailHandler);
		}
		
		private static function clientInitHandler(e:Message):void
		{
			var connection:Connection = e.target as Connection;
			
			log("[GuestManager] 客户端对接成功，来自 ", connection.remoteAddress);
			
			connection.removeEventListener(NetConst.C2S_HELLO, clientInitHandler);
			connection.removeEventListener(Event.CLOSE, connectFailHandler);
			connection.removeEventListener(IOErrorEvent.IO_ERROR, connectFailHandler);
			connection.removeEventListener(Connection.EVENT_CRASH, connectFailHandler);
			
			
			connection.addEventListener(Event.CLOSE, GuestManagerHost.closeHandler);
			connection.addEventListener(Connection.EVENT_CRASH, GuestManagerHost.closeHandler);
			connection.addEventListener(IOErrorEvent.IO_ERROR, GuestManagerHost.closeHandler);
			
			
			//创建Guest对象
			var guest:Guest = new Guest();
			guest.connection = connection;
			connection.messageTarget = guest;
			
			EventCenter.dispatchEvent( new DesignerEvent(EVENT_GUEST_CONNECTED, guest));
			
			if(!_activatedGuest)
			{
				activate(guest);
			}
		}
		
		public static const loaclAvmPath:String = "C:/Users/Administrator/Documents/Flash Working Folder/avm/avm.exe";
		public static const loaclProjectPath:String = "C:/Users/Administrator/Documents/GitHub/PotatoDesigner/PotatoDesignerGuest";
		public static const loaclProjectMainSwfPath:String = "bin-debug/Main.swf";
		/**
		 * 启动本地客户端实例
		 * @param width [可选]指定客户端的舞台宽度
		 * @param height [可选]指定客户端的舞台高度
		 * @return 客户端实例
		 * 
		 */
		public static function startLocalGuest(width:int = 0, height:int = 0):Guest
		{
			var ret:Guest = new Guest(8888, true);
			var avmFile:File = new File(loaclAvmPath);
			
			if(!NativeProcess.isSupported)
			{
				log("[GuestManager] 当前客户端的安装不支持启动本地客户端。");
				return null;
			}
			if(width > 0 && height > 0)
			{
				var str:String = "[config]\r\n" +
					"width=" + width + "\r\n" +
					"height=" + height;
				var file:File = new File(loaclProjectPath + "/" + loaclProjectMainSwfPath + "/../config.ini");
				var fileStream:FileStream = new FileStream;
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeMultiByte(str, File.systemCharset);
				fileStream.close();
			}

			
			var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			startupInfo.executable = avmFile;
			startupInfo.arguments = new Vector.<String>;
			startupInfo.arguments[0] = loaclProjectPath + "/" + loaclProjectMainSwfPath;
			
			var process:NativeProcess = new NativeProcess();
			process.addEventListener(NativeProcessExitEvent.EXIT, onExit);
			//目前avm不支持标准输出流和标准错误流。
//			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, localStdErrHandler);
//			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, localStdOutHandler);
//			process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
//			process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError);
			process.start(startupInfo);
			
			return ret;
			
//			function localStdErrHandler(event:ProgressEvent):void
//			{
//				log("[localError]", process.standardError.readMultiByte(process.standardError.bytesAvailable, File.systemCharset));
//			}
//			
//			function localStdOutHandler(event:ProgressEvent):void
//			{
//				log("[localOut]", process.standardOutput.readMultiByte(process.standardOutput.bytesAvailable, File.systemCharset));
//			}
			
			function onExit(event:NativeProcessExitEvent):void
			{
				log("[GuestManager] 本地客户端退出，退出代码：", event.exitCode);
			}
			
//			function onIOError(event:IOErrorEvent):void
//			{
//				log(event.toString());
//			}
		}
		
		
		
		/**
		 *获取已连接的客户端列表的副本。
		 */
		public static function get guestList():Vector.<Guest>
		{
			return _guestList.concat();
		}
		
		/**
		 *获取活跃客户端
		 * <br>主机端允许同时连接多个客户端。但是某些插件不支持同时由多个客户端进行操作。
		 * <br>此值尽可能的返回一个拥有有效连接的Guest实例。如果不存在这样的实例，将返回null。
		 * <br>某些原因将导致活跃客户端变更。比如当前活跃客户端断开了连接，或者另外的客户端被主动激活。
		 */
		public static function get activatedGuest():Guest
		{
			return _activatedGuest;
		}
		
		/**
		 * 
		 * @param guest
		 * @return 成功激活返回true，否则返回false
		 * 
		 */
		public static function activate(guest:Guest):Boolean
		{
			if(!guest.connected || -1 == _guestList.indexOf(guest))
			{
				return false;
			}
			
			_activatedGuest = guest;
			
			EventCenter.dispatchEvent(new DesignerEvent(EVENT_GUEST_ACTIVATED, guest));
			return _activatedGuest == guest;//万一有个贱B侦听这个消息然后激活一个其他的guest
		}
		
		public static function close(guest:Guest):void
		{
			guest.connection.close();
			completeConnect(guest, "服务端断开连接");
		}
		
		private static function completeConnect(guest:Guest, reason:String):void
		{
			if(_activatedGuest == guest)
			{
				for each(var i:Guest in _guestList)
				{
					if(activate(i))
						break;
				}
			}
			guest.connection.messageTarget = null;
			guest.connection = null;
			
			log("[GuestManager] 客户端" + guest.id.toString(16) + "关闭。", reason);
			
			EventCenter.dispatchEvent(new DesignerEvent(GuestManagerHost.EVENT_GUEST_DISCONNECTED, guest));
		}
		
		/////////////////////////////////////////
		
		internal static function closeHandler(event:DesignerEvent):void
		{
			var reason:String;
			switch(event.type)
			{
				case Event.CLOSE:
					reason = "客户端断开连接";
					break;
				case Connection.EVENT_CRASH:
					reason = "连接崩溃";
					break;
				case IOErrorEvent.IO_ERROR:
					reason = "IO错误";
					break;
				default:
					reason = "断开原因:" + event.type;
			}
			completeConnect(event.target as Guest, reason);
			
		}
	}
}