package potato.movie.dragon.events
{
	import core.events.Event;
	
	public class DragonEvent extends Event
	{
		public static const ACTION_COMPLETE:String = "actionComplete";
		
		private var _data:Object;
		
		public function DragonEvent(type:String, data:Object)
		{
			_data = data;
			super(type, false);
		}
		
		override public function clone():Event
		{
			return new DragonEvent(type, _data);
		}

		public function get data():Object
		{
			return _data;
		}
	}
}