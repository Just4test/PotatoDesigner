package potato.events.gesture.events
{
	import core.events.Event;
	import core.events.TouchEvent;
	
	import potato.events.GestureEvent;
	import potato.events.gesture.Gesture;
	import potato.ui.UIComponent;

	/**
	 *单指按下事件处理实现类 
	 * @author LuXianli
	 * 
	 */	
	public class GestureDownEvent extends Gesture
	{
		public function GestureDownEvent()
		{
			eventID = "GestureDownEvent";
			eventName = GestureEvent.GESTURE_DOWN;
		}
		
		private var _eventInitFlag:Boolean = false;
		override public function initEvent(uiComponent:UIComponent, listener:Function):void{
			
			_eventInitFlag = true;
			_uiComponent = uiComponent;
			_uiComponent.addEventListener(TouchEvent.TOUCH_BEGIN,listener);
			_uiComponent.addEventListener(TouchEvent.TOUCH_END,listener);
			if(_uiComponent.isMultiTouch){
				_uiComponent.addEventListener(TouchEvent.MULTI_TOUCH_BEGIN,listener);
				_uiComponent.addEventListener(TouchEvent.MULTI_TOUCH_END,listener);
			}
		}
		
		private var _sendFlag:Boolean = false;
		private var _touchID:int = -1;
		override public function optionEvent(event:Event):void{
			
			if(!(event is TouchEvent) || !_eventInitFlag)return;
			
			var touchEvent:TouchEvent = event as TouchEvent;
			var gestureEvent:GestureEvent;
			switch(touchEvent.type)
			{
				case TouchEvent.TOUCH_BEGIN:
				case TouchEvent.MULTI_TOUCH_BEGIN:
					if(!_sendFlag && _touchID == -1){
						gestureEvent = new GestureEvent(GestureEvent.GESTURE_DOWN,false,touchEvent.stageX,touchEvent.stageY);
						gestureEvent.localX = touchEvent.localX;
						gestureEvent.localY = touchEvent.localY;
						gestureEvent.touchPointID = touchEvent.touchPointID;
						if(touchEvent.capturer){
							gestureEvent.setGestureTarget(touchEvent.capturer);
						}else{
							gestureEvent.setGestureTarget(touchEvent.target);
						}
						dispatchEvent(gestureEvent);
						_sendFlag = true;
						_touchID = touchEvent.touchPointID;
						_uiComponent.touchPointID = _touchID;
					}
					
					break;
				
				case TouchEvent.TOUCH_END:
				case TouchEvent.MULTI_TOUCH_END:
					if(_touchID == touchEvent.touchPointID){
						_sendFlag = false;
						_touchID = -1;
					}
					break;
				
			}
//			touchEvent.stopPropagation();
			touchEvent = null;
			gestureEvent = null;
		}
		
		override public function clear():void{
			_eventInitFlag = false;
			super.clear();
		}
	}
}