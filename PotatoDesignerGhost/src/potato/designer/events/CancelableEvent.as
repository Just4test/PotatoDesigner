package potato.designer.events
{
	import flash.utils.Dictionary;
	
	import core.events.Event;
	
	/**
	 *支持取消默认行为的事件。仅能够正确运行在立即事件模式下。 
	 * @author Just4test
	 */
	public class CancelableEvent extends Event
	{
		protected const canceledMap:Dictionary = new Dictionary;
		
		protected var _root:CancelableEvent;
		
		public function CancelableEvent(type:String, bubbles:Boolean=false)
		{
			super(type, bubbles);
		}
		
		public override function clone():Event
		{
			var ret:CancelableEvent = new CancelableEvent(type, bubbles);
			ret._root = _root;
			return ret;
		}
		
		/**
		 *判定该默认行为是否已经被取消。 
		 * @return 如果为true，说明已经取消默认行为
		 */
		public function isDefaultPrevented():Boolean
		{
			return canceledMap[_root || this];
		}
		
		/**请求取消默认行为*/		
		public function preventDefault():void
		{
			canceledMap[_root || this] = true;
		}
	}
	
}