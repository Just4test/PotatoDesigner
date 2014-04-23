package potato.designer.framework
{
	import flash.events.Event;
	
	import spark.components.Window;
	
	public class DesignerEvent extends Event
	{
		protected var _data:*;
		
		public function DesignerEvent(type:String, data:*, bubbles:Boolean=false)
		{
			super(type, bubbles, true);
			_data = data;
		}
		
		public function get data():*
		{
			return _data;
		}
		
		override public function clone():Event
		{
			var ret:DesignerEvent = new DesignerEvent(type, data, bubbles);
			return ret;
		}
	}
}