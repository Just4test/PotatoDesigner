package potato.designer.plugin.guestManager
{
	import core.events.Event;
	import core.events.IOErrorEvent;
	import core.events.TimerEvent;
	import core.utils.Timer;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.net.Connection;
	import potato.designer.net.Message;
	import potato.designer.net.NetConst;

	public class GuestManagerGuest implements IPluginActivator
	{
		/**
		 * 客户端连接到宿主
		 * <br>data: {ip:"127.0.0.1", id:null}
		 */
		public static const EVENT_HOST_CONNECTED:String = "EVENT_HOST_CONNECTED";
		/**
		 * 尝试连接失败
		 * <br>data: {ip:"127.0.0.1", id:null, reason:"timeout", error:null}
		 */
		public static const EVENT_CONNECT_FAILED:String = "EVENT_CONNECT_FAILED";
		/**
		 * 连接已经准备好。当tryConnect时指定testOnly为true，则会派发此消息。
		 * <br>data: {ip:"127.0.0.1", id:null, hostInfo:null}
		 */
		public static const EVENT_CONNECT_AVAILABLE:String = "EVENT_CONNECT_AVAILABLE";
		/**
		 * 客户端从宿主断开
		 * <br>data: {ip:"127.0.0.1", id:null}
		 */
		public static const EVENT_HOST_DISCONNECTED:String = "EVENT_HOST_DISCONNECTED";
		
		protected static var _connection:Connection;
		
		/**
		 *标记是否真正连接到了主机。
		 * <br>在socket连接成功后还要进行通讯以确定双方是否能够对接。 
		 */		
		protected static var _connected:Boolean;
		protected static var _testOnly:Boolean;
		protected static var _timer:Timer;
		
		/**
		 *连接超时的时间 
		 */
		protected static const TIME_OUT:int = 5000;
		
		/**
		 *客户端id。执此id可以重新连接 
		 */
		private static var _id:String
		
		public function start(info:PluginInfo):void
		{
			
			info.started();
			tryConnect("127.0.0.1");
			
		}
		
		/**
		 * 显示连接助手
		 * <br>连接助手是一个用于连接到主机端的UI
		 * <br>当连接成功之后连接助手会自动关闭
		 */
		public static function showConnectHelper(defaultIp:String):void
		{
			
		}
		
		/**
		 *尝试连接到指定ip的主机。仅能于未连接时使用。
		 * <br>
		 * @param ip 指定的ip。输入格式错误的IP会导致客户端崩溃
		 * @param id [可选]指定连接id。这是为了恢复一个连接
		 * @param testOnly [可选]仅仅测试连接。将暂时不回应主机端的hello消息。
		 * <br>如果指定了测试连接，则需要再次连接相同IP、id并指定非测试以便完成连接。
		 */
		public static function tryConnect(ip:String, id:String = null, testOnly:Boolean = false):void
		{
			if(_connected)
			{
				throw new Error("客户端已经连接");
			}
			
			//如果上一次为了测试保持了连接，这次连接到相同地址但没有指定为测试模式，则立即连接成功
			if(!testOnly && _testOnly && _connection && _connection.remoteAddress == ip && _id == id)
			{
				completeConnect();
				return;
			}
			
			_testOnly = testOnly;
			
			
			
			if(_connection)
			{
				_connection.removeEventListeners();
				_connection.close();
			}
			
			if(!_timer)
			{
				_timer = new Timer(TIME_OUT, 1);
			}
			
			_timer.removeEventListeners();
			_timer.addEventListener(TimerEvent.TIMER, tryFailHandler);
			_timer.reset();
			_timer.start();
			
			_connection = new Connection;
			_connection.addEventListener(Event.CLOSE, tryFailHandler);
			_connection.addEventListener(IOErrorEvent.IO_ERROR, tryFailHandler);
			_connection.addEventListener(Connection.EVENT_CRASH, tryFailHandler);
			_connection.addEventListener(NetConst.S2C_HELLO, tryHelloHandler);
			
			_connection.connect(ip, NetConst.PORT);
		}
		
//		protected static function tryConnectedHandler(event:Event):void
//		{
//			_timer.removeEventListeners();
//			_timer.addEventListener(TimerEvent.TIMER, timeoutHandler);
//			_timer.reset();
//			_timer.start();
//		}
		protected static function tryFailHandler(event:Event):void
		{
			_timer.removeEventListeners();
			_timer.stop();
			
			_connection.removeEventListeners();
			_connection.close();
			var ip:String = _connection.remoteAddress;
			_connection = null;
			
			_testOnly = false;
			
			var reason:String;
			switch(event.type)
			{
				case TimerEvent.TIMER:
					reason = "没有在限定时间内完成连接";//连接超时或者连接后主机端无响应
					break;
				case Event.CLOSE:
					reason = "连接被远程端口关闭"
					break;
				case IOErrorEvent.IO_ERROR:
					reason = "连接IO错误"
					break;
				case Connection.EVENT_CRASH:
					reason = "连接协议崩溃"
					break;
			}
			
			EventCenter.dispatchEvent(
				new DesignerEvent(EVENT_CONNECT_FAILED,
					{ip:ip, id:_id, reason:reason}));
			log("[GuestManager] 尝试对接", ip, "不成功。原因:", reason);
		}
		
//		protected static function timeoutHandler(e:Event):void
//		{
//			failed();
//		}
		
		/**
		 *接收到了服务器Hello事件，说明正确的连接到了服务器。
		 * @param event
		 * 
		 */
		protected static function tryHelloHandler(event:Message):void
		{
			_timer.stop();
			_timer.removeEventListeners();
			
			if(_testOnly)
			{
				EventCenter.dispatchEvent(new DesignerEvent(EVENT_CONNECT_AVAILABLE,
					{ip:_connection.remoteAddress, id:_id, hostInfo:event.data}));
			}
			else
			{
				completeConnect();
			}
		}
//		protected function errorHandler(event:IOErrorEvent):void
//		{
//			failed();
//		}
		
		/**
		 *socket成功建立并收到服务器hello消息后，使用此方法完成连接
		 */
		protected static function completeConnect():void
		{	
			_testOnly = false;
			
			_connected = true;
			_connection.removeEventListeners();
			_connection.addEventListener(Event.CLOSE, onDisconnectHandler);
			_connection.addEventListener(IOErrorEvent.IO_ERROR, onDisconnectHandler);
			_connection.addEventListener(Connection.EVENT_CRASH, onDisconnectHandler);
			
			_connection.send(NetConst.C2S_HELLO);
			EventCenter.dispatchEvent(new DesignerEvent(EVENT_HOST_CONNECTED,
				{ip:_connection.remoteAddress, id:_id}));
			log("[GuestManager] 对接成功，来自", _connection.remoteAddress);
		}
		
		protected static function onDisconnectHandler(event:Event):void
		{
			var reason:String;
			switch(event.type)
			{
				case Event.CLOSE:
					reason = "连接被远程端口关闭"
					break;
				case IOErrorEvent.IO_ERROR:
					reason = "连接IO错误"
					break;
				case Connection.EVENT_CRASH:
					reason = "连接协议崩溃"
					break;
			}
			completeDisconnect(reason);
		}
		
		/**
		 *断开连接的诸多操作
		 */
		protected static function completeDisconnect(reason:String):void
		{	
			_connected = false;
			_connection.removeEventListeners();
			var ip:String = _connection.remoteAddress;
			_connection = null;
			EventCenter.dispatchEvent(new DesignerEvent(EVENT_HOST_DISCONNECTED,
				{ip:ip, id:_id, reason:reason}));
			log("[GuestManager] 从主机端断开", ip, "。原因:", reason);
		}
		
		protected function testIP(text:String):Boolean
		{
			if(!/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/.test(text))
			{
				return false;
			}
			
			
			for each (var s:String in text.split(".")) 
			{
				if(int(s) > 255)
				{
					return false;
				}
			}
			
			return true;
		}
		
		public static function close():void
		{
			_connection && _connection.close();
			if(_connected)
			{
				completeDisconnect("本地断开连接");
			}
				
		}
		
		public static function get connected():Boolean
		{
			return _connected;
		}

		public static function get connection():Connection
		{
			return _connection;
		}

//		public static function set connection(value:Connection):void
//		{
//			_connection = value;
//			if()
//			{
//				
//			}
//			else
//			{
//				
//			}
//			_connection.addEventListener(Event.Connect, onConnect);
//		}
		
		
		
		
		
	}
}