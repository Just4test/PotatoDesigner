package potato.designer.net
{
	CONFIG::HOST{
		import flash.events.Event;
	}
	CONFIG::GUEST{
		import core.events.Event;
	}
	
	/**
	 * 消息类。
	 * @author Just4test
	 * 
	 */
	public class Message extends Event
	{
		protected var _connection:Connection;
		protected var _data:*;
		internal var _index:uint;
		
		public function Message(connection:Connection, type:String, data:*)
		{
			super(type);
			_connection = connection;
			_data = data;
		}
		
		/**
		 *应答此消息
		 * @param type 消息类型
		 * @param data 消息数据体
		 * @param callbackHandle 指定应答回调方法。如果指定此方法，则消息的接收方可以对此消息进行应答，应答消息由回调方法处理。
		 */
		public function answer(type:String, data:* = null, callbackHandle:Function = null):void
		{
			_connection.answer(type, data, callbackHandle, this);
			_index =  0;
		}
		
		public function get data():*
		{
			return _data;
		}
		
		/**
		 *检查这条消息是否可以应答 
		 * @return 
		 * 
		 */
		public function get answerable():Boolean
		{
			return 0 != _index;
		}
		
		public function get index():uint
		{
			return _index;
		}
	}
}