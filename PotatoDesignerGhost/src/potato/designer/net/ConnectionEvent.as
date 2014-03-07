package potato.designer.net
{
	import core.events.Event;
	
	public class ConnectionEvent extends Event
	{
		protected var _data:*;
		protected var _answerIndex:uint;
		public function ConnectionEvent(type:String, data:*, answerIndex:uint)
		{
			super(type);
			_data = data;
			_answerIndex = answerIndex;
		}

		public function get data():*
		{
			return _data;
		}

		public function get answerIndex():uint
		{
			return _answerIndex;
		}


	}
}