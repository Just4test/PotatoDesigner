package potato.designer.plugin.guestManager
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
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
		private var _connection:Connection;
		private var _isLocal:Boolean;
		
		private var _id:int;
		
		public function Guest(id:int = 0, isLocal:Boolean = false)
		{
			_id = id || int(Math.random() * 90000 + 10000);
			_isLocal = isLocal;
			
			addEventListener(NetConst.C2S_LOG, logGuest);
		}
		
		/**向客户端发送关闭请求*/
		public function close():void
		{
			_connection.close()
		}
		
		/**向客户端发送重新启动请求
		 * <br/>重新启动时服务端仍保留Guest对象，因而可以再次连接。
		 */
		public function restart():void
		{
			
		}

		/**到该客户端的连接控制器。在连接完成之前，这个值可能为空。*/
		public function get connection():Connection
		{
			return _connection;
		}

		/**
		 * @private
		 */
		public function set connection(value:Connection):void
		{
			_connection = value;
			_connection.messageTarget = this;
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
	}
}