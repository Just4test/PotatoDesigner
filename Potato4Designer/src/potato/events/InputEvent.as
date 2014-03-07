package potato.events
{
	import core.events.Event;
	
	/**
	 * 输入事件
	 */
	public class InputEvent extends Event
	{
		public static const INPUT_COMPLETE:String = "inputComplete";
		
		public static const INPUT_CHANGE:String = "inputChange";
		
		public function InputEvent(type:String, bubbles:Boolean=false)
		{
			super(type, bubbles);
		}
	}
}