package potato.designer.framework
{
	CONFIG::HOST
	{
		import flash.events.Event;
		import flash.events.EventDispatcher;
	}
	
	CONFIG::GUEST
	{
		import core.events.Event;
		import core.events.EventDispatcher;
	}
	
	/**
	 * 事件中心
	 * <br/>所有系统级事件通过这里派发。
	 * <br/>请注意即使插件间没有依赖关系，他们也共享事件。请多加注意避免命名冲突。
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