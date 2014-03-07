package potato.designer.net
{
	import core.events.Event;
	
	public class MessageEvent extends Event
	{
		protected var _message:Message;
		
		public function MessageEvent(connection:Connection, type:String, index:uint, data:*)
		{
			super(type);
			_message = new Message(connection, type, index, data);
		}
		
		public function answer(type:String, data:* = null, answerHandle:Function = null):void
		{
			_message.answer(type, data, answerHandle);
		}

		public function get data():*
		{
			return _message.data;
		}

		public function get index():uint
		{
			return _message.index;
		}

		public function get message():Message
		{
			return _message;
		}


	}
}