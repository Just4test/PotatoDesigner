package potato.designer.plugin.guestManager
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.net.Connection;
	import potato.designer.net.Message;
	import potato.designer.net.NetConst;

	/**
	 *客户端的抽象模型 
	 * @author Administrator
	 * 
	 */
	public class Guest extends EventDispatcher
	{
		
		/**到该客户端的连接控制器。在连接完成之前，这个值可能为空。*/
		internal var connection:Connection;
		private var _isLocal:Boolean;
		
		private var _id:int;
		
		internal var _activedPlugins:Vector.<String> = new Vector.<String>;
		
		public function Guest(id:int = 0, isLocal:Boolean = false)
		{
			_id = id || int(Math.random() * 90000 + 10000);
			_isLocal = isLocal;
			
			addEventListener(NetConst.C2S_LOG, logGuest);
			
			EventCenter.dispatchEvent( new DesignerEvent(GuestManagerHost.EVENT_GUEST_CREATED, this));
		}
		
		/**向客户端发送关闭请求*/
		public function close():void
		{
			GuestManagerHost.close(this);
		}
		
		/**向客户端发送重新启动请求
		 * <br/>重新启动时服务端仍保留Guest对象，因而可以再次连接。
		 */
		public function restart():void
		{
			//TODO
		}

		
		
		protected function logGuest(msg:Message):void
		{
			log("[客户端" + _id.toString(16) + "]",msg.data);
		}

		/**客户端id
		 * <br/>这是一长串字符；他唯一的标明了一个客户端。
		 * <br/>在单次服务端运行时，客户端可以重新启动，并以此id重新连接。
		 */
		public function get id():int
		{
			return _id;
		}

		/**标记客户端是否是本地客户端*/
		public function get isLocal():Boolean
		{
			return _isLocal;
		}
		
		public function get connected():Boolean
		{
			return connection && connection.connected;
		}
		
		/**
		 *发送一条消息 
		 * @param type 消息类型
		 * @param data 消息数据体
		 * @param callbackHandle 指定应答回调方法。如果指定此方法，则消息的接收方可以对此消息进行应答，应答消息由回调方法处理。
		 */
		public function send(type:String, data:* = null, callbackHandle:Function = null):void
		{
			connection && connection.send(type, data, callbackHandle);
		}

		/**
		 *返回一个列表，指示客户端上已经激活的插件。 
		 * @return 
		 * 
		 */
		public function get activedPlugins():Vector.<String>
		{
			return _activedPlugins.concat();
		}
		
		public function isPluginActived(id:String):Boolean
		{
			return -1 != _activedPlugins.indexOf(id);
		}

	}
}