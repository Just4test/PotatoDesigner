package potato.events.gesture.events
{
	import core.events.Event;
	import core.events.TimerEvent;
	import core.events.TouchEvent;
	import core.utils.Timer;
	
	import flash.geom.Point;
	
	import potato.events.GestureEvent;
	import potato.events.gesture.Gesture;
	import potato.events.gesture.tools.GesturePoint;
	import potato.ui.UIComponent;
	import potato.ui.UIGlobal;

	/**
	 *手势事件 长按事件 处理实现类 
	 * @author LuXianli
	 * 
	 */	
	public class GestureLongPressEvent extends Gesture
	{
		public function GestureLongPressEvent()
		{
			eventID = "GestureLongPressEvent";
			eventName = GestureEvent.GESTURE_LONG_PRESS;
		}
		
		private var _eventInitFlag:Boolean = false;
		override public function initEvent(uiComponent:UIComponent, listener:Function):void{
			
			_eventInitFlag = true;
			_uiComponent = uiComponent;
			_uiComponent.addEventListener(TouchEvent.TOUCH_BEGIN,listener);
			_uiComponent.addEventListener(TouchEvent.TOUCH_MOVE,listener);
			_uiComponent.addEventListener(TouchEvent.TOUCH_END,listener);
			if(_uiComponent.isMultiTouch){
				_uiComponent.addEventListener(TouchEvent.MULTI_TOUCH_BEGIN,listener);
				_uiComponent.addEventListener(TouchEvent.MULTI_TOUCH_MOVE,listener);
				_uiComponent.addEventListener(TouchEvent.MULTI_TOUCH_END,listener);
			}
		}
		
		private var _downFlag:Boolean = false;
		private var _longPressTimer:Timer;
		private var _startPoint:GesturePoint;
		private var _touchID:int = -1;
		override public function optionEvent(event:Event):void{
			
			if(!(event is TouchEvent) || !_eventInitFlag)return;
			
			var touchEvent:TouchEvent = event as TouchEvent;
			
			switch(touchEvent.type)
			{
				case TouchEvent.TOUCH_BEGIN:
				case TouchEvent.MULTI_TOUCH_BEGIN:
					if(!_downFlag ){
						_downFlag = true;
						_touchID = touchEvent.touchPointID;
						_startPoint = new GesturePoint(touchEvent);
						startTimer();
					}
					break;
				
				case TouchEvent.TOUCH_MOVE:
				case TouchEvent.MULTI_TOUCH_MOVE:
					if(_downFlag && _touchID == touchEvent.touchPointID && Point.distance(new Point(touchEvent.stageX,touchEvent.stageY),_startPoint.stage) > Gesture.TOUCH_OFF_LENGTH)restore();
					break;
				
				case TouchEvent.TOUCH_END:
				case TouchEvent.MULTI_TOUCH_END:
					if(_touchID == touchEvent.touchPointID)restore();
					break;
				
			}
			touchEvent = null;
		}
		
		private function startTimer():void{
			
			if(!_longPressTimer){
				_longPressTimer = new Timer(UIGlobal.LONG_PRESS_TIME,1);
				_longPressTimer.addEventListener(TimerEvent.TIMER_COMPLETE,longPressTimerHandler);
				_longPressTimer.start();
			}
		}
		
		private function longPressTimerHandler(event:TimerEvent):void{
			
			sendEvent();
		}
		
		private function clearTimer():void{
			
			if(_longPressTimer){
				_longPressTimer.stop();
				_longPressTimer.removeEventListeners();
				_longPressTimer = null;
			}
		}
		
		private function sendEvent():void{
			
			var gestureEvent:GestureEvent = new GestureEvent(GestureEvent.GESTURE_LONG_PRESS,false,_startPoint.stage.x,_startPoint.stage.y);
			gestureEvent.localX = _startPoint.local.x;
			gestureEvent.localY = _startPoint.local.y;
			gestureEvent.touchPointID = _touchID;
			dispatchEvent(gestureEvent);
			gestureEvent = null;
			restore();
		}
		
		private function restore():void{
			_downFlag = false;
			_touchID = -1;
			clearTimer();
		}
		override public function clear():void{
			_eventInitFlag = false;
			super.clear();
			restore();
		}
		
	}
}