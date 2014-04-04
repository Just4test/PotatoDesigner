package potato.designer.plugin.ghostManager
{
	import flash.system.System;
	
	import potato.designer.net.Connection;

	/**
	 *客户端的抽象模型 
	 * @author Administrator
	 * 
	 */
	public class Ghost
	{
		private var _connection:Connection;
		private var _isLocal:Boolean;
		
		private var _id:String;
		
		public function Ghost(id:String = null, isLocal:Boolean = false)
		{
			_isLocal = isLocal;
			_id = id || int(Math.random() * 90000 + 1000).toString();
		}
		
		/**向客户端发送关闭请求*/
		public function close():void
		{
		}
		
		/**向客户端发送重新启动请求
		 * <br/>重新启动时服务端仍保留Ghost对象，因而可以再次连接。
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
		}

		/**客户端id
		 * <br/>这是一长串字符；他唯一的标明了一个客户端。
		 * <br/>在单次服务端运行时，客户端可以重新启动，并以此id重新连接。
		 */
		public function get id():String
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