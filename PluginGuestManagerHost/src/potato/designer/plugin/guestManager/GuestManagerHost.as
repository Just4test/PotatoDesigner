package potato.designer.plugin.guestManager
{
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.File;
	import flash.net.ServerSocket;
	
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Connection;
	import potato.designer.net.Message;
	import potato.designer.net.NetConst;

	public class GuestManagerHost implements IPluginActivator
	{
		/**客户端创建*/
		public static const EVENT_GUEST_CREATED:String = "EVENT_GUEST_CREATED";
		/**客户端连接到宿主*/
		public static const EVENT_GUEST_CONNECTED:String = "EVENT_GUEST_CONNECTED";
		/**客户端从宿主断开*/
		public static const EVENT_GUEST_DISCONNECTED:String = "EVENT_GUEST_DISCONNECTED";
		
		private static var serverSocket:ServerSocket;
		
		/**插件注册方法*/
		public function start(info:PluginInfo):void
		{
			serverSocket = new ServerSocket;
			serverSocket.bind(NetConst.PORT, "0.0.0.0");
			serverSocket.listen();
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, connectHandler);
			log("[GuestManager] 开始监听连接");
			
			info.started();
			startLocalGuest();
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
			
			//创建Guest对象
			var guest:Guest = new Guest();
			guest.connection = connection;
		}
		
		public static const loaclAvmPath:String = "C:/Users/Administrator/Documents/Flash Working Folder/avm/avm.exe";
		public static const loaclProjectPath:String = "C:/Users/Administrator/Documents/GitHub/PotatoDesigner/PotatoDesignerGuest";
		public static const loaclProjectMainSwfPath:String = "bin-debug/Main.swf";
		/**启动一个新的本地客户端实例。*/
		public static function startLocalGuest():Guest
		{
			var ret:Guest = new Guest("local", true);
			var avmFile:File = new File(loaclAvmPath);
			var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			startupInfo.executable = avmFile;
			startupInfo.arguments = new Vector.<String>;
			startupInfo.arguments[0] = loaclProjectPath + "/" + loaclProjectMainSwfPath;
			var process:NativeProcess = new NativeProcess();
			process.start(startupInfo);
			return ret;
		}
		
		public static function get guestList():Array
		{
			return null;
		}
	}
}