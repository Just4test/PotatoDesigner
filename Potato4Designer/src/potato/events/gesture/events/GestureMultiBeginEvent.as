package potato.events.gesture.events
{
	import potato.events.GestureEvent;
	import potato.events.gesture.Gesture;

	/**
	 *手势开始事件处理实现类 
	 * @author LuXianli
	 * 
	 */	
	public class GestureMultiBeginEvent extends Gesture
	{
		public function GestureMultiBeginEvent()
		{
			eventID = "GestureMultiBeginEvent";
			eventName = GestureEvent.GESTURE_MULTI_BEGIN;
		}
		
		
	}
}