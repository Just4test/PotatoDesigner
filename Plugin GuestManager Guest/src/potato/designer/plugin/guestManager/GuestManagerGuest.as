package potato.designer.plugin.guestManager
{
	import flash.utils.ByteArray;
	
	import core.display.Stage;
	import core.events.Event;
	import core.events.EventDispatcher;
	import core.events.IOErrorEvent;
	import core.events.TimerEvent;
	import core.net.UdpSocket;
	import core.utils.Timer;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.framework.PluginManager;
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
		
		/**
		 *已发现的主机列表
		 * <br>当发现了主机，以及主机没有响应过期后都将派发
		 * <br>data:[ip0, ip1....] 
		 */
		public static const EVENT_HOST_DISCOVERED:String = "EVENT_HOST_DISCOVERED";
		
		protected static var _connection:Connection;
		
		protected static var _udpSocket:UdpSocket;
		protected static var _hostTable:Object;

		
		/**
		 *标记是否真正连接到了主机。
		 * <br>在connection连接成功后还要进行通讯以确定双方是否能够对接。 
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
		protected static var _id:String;
		
		protected static const _messageTarget:EventDispatcher = new EventDispatcher;
		
		public function start(info:PluginInfo):void
		{
			EventCenter.addEventListener(PluginManager.EVENT_PLUGIN_ACCTIVATED, pluginActiveHandler);
			
			info.started();
			
//			tryConnect("localhost", "local");
//			startHostDiscovery();
		}
		
		protected static function pluginActiveHandler(event:DesignerEvent):void
		{
			if(_connection && _connection.connected)
			{
				send(NetConst.C2S_PLUGIN_ACCTIVATED, event.data.id);
			}
		}
		
		/**
		 *启动主机发现
		 * <br>允许客户端发现位于同一子网的正在进行Host多播的主机。
		 * <br>
		 * 
		 */
		public static function startHostDiscovery():void
		{
			log("[GuestManager] 开始发现主机");
			if(!_udpSocket)
			{
				_udpSocket = new UdpSocket;
				_udpSocket.bind(NetConst.HOST_MULTICAST_PORT);
				_udpSocket.jointGroup(NetConst.HOST_MULTICAST_IP, 1);
				
				_hostTable = {};
			}
			
			Stage.getStage().addEventListener(Event.ENTER_FRAME, hostDiscoveryHandler);
		}
		
		protected static function hostDiscoveryHandler(event:Event):void
		{
			var time:Number = new Date().time;
			var flag:Boolean;
			var bytes:ByteArray = new ByteArray;
			
			while(_udpSocket.receive(bytes) > 0)
			{
				try
				{
					if(NetConst.HOST_MULTICAST_PORT == _udpSocket.remotePort && NetConst.S2C_HELLO == bytes.readUTFBytes(bytes.length))
					{
						if(!_hostTable[_udpSocket.remoteAddress])
							flag = true;
						if(!_hostTable[_udpSocket.remoteAddress])
							log("[GuestManager] 发现主机", _udpSocket.remoteAddress);
						
						_hostTable[_udpSocket.remoteAddress] = time;
					}
				} 
				catch(error:Error) 
				{
					
				}
			}
			
			for (var i:String in _hostTable) 
			{
				if(time - _hostTable[i] > NetConst.HOST_MULTICAST_INTERVAL + 1000)
				{
					flag = true;
					log("[GuestManager] 主机停止响应", i);
					delete _hostTable[i];
				}
			}
			
			if(flag)
			{
				EventCenter.dispatchEvent(new DesignerEvent(EVENT_HOST_DISCOVERED, discoveredHosts));
			}
			
		}
		
		public static function stopHostDiscovery():void
		{
			log("[GuestManager] 停止发现主机");
			Stage.getStage().removeEventListener(Event.ENTER_FRAME, hostDiscoveryHandler);
		}
		
		/**
		 *已经发现的主机列表。该列表进行过排序。
		 * @return 如果没有在进行主机发现，返回null。否则返回已经发现的主机列表。
		 * 
		 */
		public static function get discoveredHosts():Vector.<String>
		{
			if(!_hostTable)
				return null;
			
			var ret:Vector.<String> = new Vector.<String>;
			for(var i:String in _hostTable)
			{
				ret.push(i);
			}
			ret.sort(0);
			return ret;
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
		
		/**
		 *socket成功建立并收到服务器hello消息后，使用此方法完成连接
		 */
		protected static function completeConnect():void
		{	
			_testOnly = false;
			
			_connected = true;
			_connection.messageTarget = _messageTarget;
			_connection.removeEventListeners();
			_connection.addEventListener(Event.CLOSE, onDisconnectHandler);
			_connection.addEventListener(IOErrorEvent.IO_ERROR, onDisconnectHandler);
			_connection.addEventListener(Connection.EVENT_CRASH, onDisconnectHandler);
			var plugins:Vector.<String> = new Vector.<String>;
			for each(var i:PluginInfo in PluginManager.pluginList)
			{
				if(PluginInfo.STATE_RUNNING == i.state)
				{
					plugins.push(i.id);
				}
			}
			_connection.send(NetConst.C2S_HELLO, {id:_id, plugins:plugins});
			
			log("[GuestManager] 与来自", _connection.remoteAddress, "的主机对接成功。已经接管log");
			EventCenter.addEventListener(EventCenter.EVENT_LOG, log2host);
			
			EventCenter.dispatchEvent(new DesignerEvent(EVENT_HOST_CONNECTED,
				{ip:_connection.remoteAddress, id:_id}));
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
		
		public static function addEventListener(type:String, listener:Function):void
		{
			_messageTarget.addEventListener(type, listener);
		}
		
		public static function removeEventListener(type:String, listener:Function):void
		{
			_messageTarget.removeEventListener(type, listener);
		}
		
		public static function dispatchEvent(event:Event):void
		{
			_messageTarget.dispatchEvent(event);
		}
		
		/**
		 *发送一条消息 
		 * @param type 消息类型
		 * @param data 消息数据体
		 * @param callbackHandle 指定应答回调方法。如果指定此方法，则消息的接收方可以对此消息进行应答，应答消息由回调方法处理。
		 */
		public static function send(type:String, data:* = null, callbackHandle:Function = null):void
		{
			if(!_connection)
			{
				throw new Error("在尚未建立连接的情况下尝试发送消息");
			}
			_connection.send(type, data, callbackHandle);
		}
		
		/**
		 *断开连接的诸多操作
		 */
		protected static function completeDisconnect(reason:String):void
		{
			EventCenter.removeEventListener(EventCenter.EVENT_LOG, log2host);
			
			_connected = false;
			_connection.removeEventListeners();
			var ip:String = _connection.remoteAddress;
			_connection = null;
			
			EventCenter.dispatchEvent(new DesignerEvent(EVENT_HOST_DISCONNECTED,
				{ip:ip, id:_id, reason:reason}));
			log("[GuestManager] 从主机端断开", ip, "。原因:", reason);
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
		
		public function toString():String
		{
			return "[Guest " + _id + "]";
		}
		
		//////////////////////////////////////////////////////////////////
		
		protected static function log2host(event:DesignerEvent):void
		{
			_connection.send(NetConst.C2S_LOG, event.data);
			event.preventDefault();
		}
	}
}