package potato.events.gesture
{
	import potato.events.gesture.events.GestureClickEvent;
	import potato.events.gesture.events.GestureDownEvent;
	import potato.events.gesture.events.GestureLongPressEvent;
	import potato.events.gesture.events.GestureMoveEvent;
	import potato.events.gesture.events.GestureMultiMoveEvent;
	import potato.events.gesture.events.GestureStageMoveEvent;
	import potato.events.gesture.events.GestureStageUpEvent;
	import potato.events.gesture.events.GestureThreeClickEvent;
	import potato.events.gesture.events.GestureTwoClickEvent;
	import potato.events.gesture.events.GestureUpEvent;
	
	public class GestureClass
	{
		// 在库内部已有的手势事件类字典
		static private const innerGestureClassDic:Object = {
			"gestureDown":potato.events.gesture.events.GestureDownEvent,				//单指按下事件处理类
			"gestureMove":potato.events.gesture.events.GestureMoveEvent,				//单指滑动事件处理类
			"gestureStageMove":potato.events.gesture.events.GestureStageMoveEvent,
			"gestureUp":potato.events.gesture.events.GestureUpEvent,					//单指抬起事件处理类
			"gestureStageUp":potato.events.gesture.events.GestureStageUpEvent,
			"gestureLongPress":potato.events.gesture.events.GestureLongPressEvent,	//单指长按事件处理类
			"gestureMultiMove":potato.events.gesture.events.GestureMultiMoveEvent,	//多指滑动事件处理类
			"gestureClick":potato.events.gesture.events.GestureClickEvent,			//单指点击事件处理类
			"gestureTwoClick":potato.events.gesture.events.GestureTwoClickEvent,		//双指点击事件处理类
			"gestureThreeClick":potato.events.gesture.events.GestureThreeClickEvent	//三指点击事件处理类
		};

		// 通过调用注册函数，注册进来的自定义手势事件类字典
		static private var registedGestureClassDic:Object = new Object();

		/**
		 *通过事件名得到事件处理类的实例 
		 * @param eventName	事件名
		 * @return			对应名称的事件处理类
		 * 
		 */		
		static public function getGestureClass(eventName:String):Gesture
		{
			var eventClass:Class = innerGestureClassDic[eventName];
			if(eventClass)
				return new eventClass() as Gesture;

			eventClass = registedGestureClassDic[eventName];
			if(eventClass)
				return new eventClass() as Gesture;

			return null;
		}
		/**
		 * 注册自定义手势事件
		 * @param eventName		手势事件名字
		 * @param gestureClass	手势事件处理类（单独处理类：必须继承 Gesture 类来实现；）
		 * 
		 */
		static public function registerGestureClass(eventName:String, gestureClass:Class):void
		{
			if(eventName && gestureClass)
				registedGestureClassDic[eventName] = gestureClass;
		}
		
	}
}