package potato.designer.framework
{
	import core.events.Event;
	import potato.designer.events.CancelableEvent;

	/**
	 *设计器建议使用的事件。可以附带数据，并且可以撤销
	 * @author Just4test Administrator
	 * 
	 */
	public class DesignerEvent extends CancelableEvent
	{
		protected var _data:*;
		
		public function DesignerEvent(type:String, data:*, bubbles:Boolean=false)
		{
			super(type, bubbles);
			_data = data;
		}

		public function get data():*
		{
			return _data;
		}

		override public function clone():Event
		{
			var ret:DesignerEvent = new DesignerEvent(type, data, bubbles);
			ret._root = _root;
			return ret;
		}
		
	}
}