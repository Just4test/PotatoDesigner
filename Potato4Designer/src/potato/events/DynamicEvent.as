package potato.events
{
	import core.events.Event;

	public class DynamicEvent extends Event
	{
		private var _paramObject:Object;
		/**
		 *携带对象事件 
		 * @param type	事件名
		 * @param paramObject	事件携带对象
		 * 
		 */		
		public function DynamicEvent(type:String, paramObject:Object=null)
		{
			_paramObject = paramObject;
			super(type, false);
		}
		
		public override function clone():Event
        {
            return new DynamicEvent(type, _paramObject);
        }

        public function get getParamObject():Object
        {
            return _paramObject;
        }
		
	}
}