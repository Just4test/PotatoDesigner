package potato.designer.framework
{
	CONFIG::HOST
	{
		import flash.events.Event;
		import flash.events.EventDispatcher;
	}
	
	CONFIG::GHOST
	{
		import core.events.Event;
		import core.events.EventDispatcher;
	}
	
	/**
	 * 事件中心，所有系统级事件通过这里派发。
	 * @author Just4test
	 * 
	 */
	public class EventCenter
	{
		public static const EVENT_LOG:String = "log";
		
		private static var eventDispatcher:EventDispatcher = new EventDispatcher;
		
		public static function addEventListener(type:String, listener:Function):void
		{
			eventDispatcher.addEventListener(type, listener);
		}
		
		public static function removeEventListener(type:String, listener:Function):void
		{
			eventDispatcher.removeEventListener(type, listener);
		}
		
		public static function dispatchEvent(event:Event):void
		{
			eventDispatcher.dispatchEvent(event);
		}
	}
}