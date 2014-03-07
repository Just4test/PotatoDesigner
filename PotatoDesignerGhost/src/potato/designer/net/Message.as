package potato.designer.net
{
	public class Message
	{
		protected var _connection:Connection;
		protected var _type:uint;
		protected var _index:uint;
		protected var _data:*;
		
		public function Message(connection:Connection, type:String, index:uint, data:*)
		{
			_index = index;
			_data = data;
		}
		
		public function answer(type:String, data:* = null, answerHandle:Function = null):void
		{
			_connection.send(type, data, answerHandle, _index);
		}
		
		public function get data():*
		{
			return _data;
		}
		
		public function get index():uint
		{
			return _index;
		}
	}
}