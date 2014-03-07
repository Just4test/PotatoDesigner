package potato.events.gesture.events
{
	import core.events.Event;
	import core.events.TouchEvent;
	
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import potato.events.GestureEvent;
	import potato.events.gesture.Gesture;
	import potato.events.gesture.tools.GesturePoint;
	import potato.ui.UIComponent;
	import potato.ui.UIGlobal;

	/**
	 *单指点击事件处理实现类 
	 * @author LuXianli
	 * 
	 */	
	public class GestureClickEvent extends Gesture
	{
		public function GestureClickEvent()
		{
			eventID = "GestureClickEvent";
			eventName = GestureEvent.GESTURE_CLICK;
		}
		
		private var _eventInitFlag:Boolean = false;
		override public function initEvent(uiComponent:UIComponent,listener:Function):void{
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
		private var _isMoved:Boolean = false;
		private var _startTime:Number = 0;
		private var _touchID:int = -1;
		private var _startPoint:GesturePoint;
		private var _nowPoint:Point = new Point();
		override public function optionEvent(event:Event):void{
			
			if(!(event is TouchEvent) || !_eventInitFlag)return;
			
			var touchEvent:TouchEvent = event as TouchEvent;
			var gestureEvent:GestureEvent;
			switch(touchEvent.type)
			{
				case TouchEvent.TOUCH_BEGIN:
				case TouchEvent.MULTI_TOUCH_BEGIN:
					if(!_downFlag && _touchID == -1){
						_downFlag = true;
						_startTime = getTimer();
						_touchID = touchEvent.touchPointID;
						_startPoint = new GesturePoint(touchEvent);
					}
					
					break;
				
				case TouchEvent.TOUCH_MOVE:
				case TouchEvent.MULTI_TOUCH_MOVE:
					if(_downFlag && _touchID == touchEvent.touchPointID){
						_nowPoint.x = touchEvent.stageX;
						_nowPoint.y = touchEvent.stageY;
						if(Point.distance(_nowPoint,_startPoint.stage) > Gesture.TOUCH_OFF_LENGTH)_isMoved = true;
					}
					break;
				
				case TouchEvent.TOUCH_END:
				case TouchEvent.MULTI_TOUCH_END:
					
					if(_touchID == touchEvent.touchPointID ){
						if(!_isMoved && (getTimer() - _startTime < UIGlobal.LONG_PRESS_TIME)){
							
							gestureEvent = new GestureEvent(GestureEvent.GESTURE_CLICK,false,touchEvent.stageX,touchEvent.stageY);
							gestureEvent.localX = touchEvent.localX;
							gestureEvent.localY = touchEvent.localY;
							gestureEvent.touchPointID = _touchID;
							if(touchEvent.capturer){
								gestureEvent.setGestureTarget(touchEvent.capturer);
							}else{
								gestureEvent.setGestureTarget(touchEvent.target);
							}
							dispatchEvent(gestureEvent);
						}
						restore();
					}
					break;
			}
//			touchEvent.stopPropagation();
			touchEvent = null;
			gestureEvent = null;
		}
		
		private function restore():void{
			_downFlag =false;
			_isMoved = false;
			_touchID = -1;
		}
		override public function clear():void{
			_eventInitFlag = false;
			super.clear();
			restore();
		}
	}
}