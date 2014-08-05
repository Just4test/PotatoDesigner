package potato.events.gesture.events
{
	import potato.events.GestureEvent;
	import potato.events.gesture.Gesture;

	/**
	 *手势  结束事件处理实现类 
	 * @author LuXianli
	 * 
	 */	
	public class GestureMultiEndEvent extends Gesture
	{
		public function GestureMultiEndEvent()
		{
			eventID = "GestureMultiEndEvent";
			eventName = GestureEvent.GESTURE_MULTI_END;
		}
	}
}