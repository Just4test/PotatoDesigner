package potato.events
{
	import core.events.Event;

	public interface IEventDispatcher
	{
		/**
		 * 使用 EventDispatcher 对象注册事件侦听器对象，以使侦听器能够接收事件通知。
		 * @param type 事件的类型。
		 * @param listener 处理事件的侦听器函数。 此函数必须接受 Event 对象作为其唯一的参数，并且不能返回任何结果。
		 */
		function addEventListener(type:String, listener:Function):void;
		
		/**
		 * 从 EventDispatcher 对象中删除侦听器。
		 * @param type 事件的类型。
		 * @param listener 要删除的侦听器对象。
		 */
		function removeEventListener(type:String, listener:Function):void;
		
		/**
		 * 从 EventDispatcher 对象中删除某类型的侦听器。
		 * @param type 事件的类型。如为null，则删除所有侦听器。
		 */
//		function removeEventListeners(type:String=null):void;
//		
//		function dispose():void;
		
		/**
		 * 将事件调度到事件流中。
		 * @param event 调度到事件流中的 Event 对象。
		 * @return 如果成功调度了事件，则值为 true。
		 */
		function dispatchEvent(event:Event):Boolean;
		
		/**
		 * 检查 EventDispatcher 对象是否为特定事件类型注册了任何侦听器。
		 * @param type 事件的类型。
		 * @return 如果指定类型的侦听器已注册，则值为 true；否则，值为 false。
		 */
		function hasEventListener(type:String):Boolean;
	}
}