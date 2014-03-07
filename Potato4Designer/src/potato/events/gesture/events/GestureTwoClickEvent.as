package potato.events.gesture.events
{
	import core.events.Event;
	import core.events.TouchEvent;
	
	import flash.utils.getTimer;
	
	import potato.events.GestureEvent;
	import potato.events.gesture.Gesture;
	import potato.events.gesture.tools.GesturePoint;
	import potato.ui.UIComponent;
	import potato.ui.UIGlobal;
	/**
	 *双指点击事件处理类 
	 * @author LuXianli
	 * 
	 */	
	public class GestureTwoClickEvent extends Gesture
	{
		public function GestureTwoClickEvent()
		{
			eventID = "GestureTwoClickEvent";
			eventName = GestureEvent.GESTURE_TWO_CLICK;
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
		
		private var _isMoved:Boolean = false;
		private var _isMultiMoved:Boolean = false;
		private var _startTime:Number = 0;
		private var _endTime:Number = 0;
		private var _beginArr:Array = [];
		private var _endArr:Array = [];
		private var _beginFlag:Boolean = true;
		private var _endFlag:Boolean = true;
		private var _flag:Boolean = false;
		private var _multiFlag:Boolean = false;
		override public function optionEvent(event:Event):void{
			
			if(!(event is TouchEvent) || !_eventInitFlag)return;
			
			var touchEvent:TouchEvent = event as TouchEvent;
			
			switch(touchEvent.type)
			{
				case TouchEvent.TOUCH_BEGIN:
					_startTime = getTimer();
					_beginArr.push(new GesturePoint(touchEvent));
					_flag = true;
					break;
				
				case TouchEvent.MULTI_TOUCH_BEGIN:
					if(_beginArr.length > 0){
						if(_beginFlag && _beginArr.length < 2 && (getTimer() - _startTime < UIGlobal.MULTI_BEGIN_TIME)){
							_startTime = getTimer();
							_beginArr.push(new GesturePoint(touchEvent));
						}else{
							_beginFlag = false;
							if(_beginArr.length < 2){
								restore();
							}
						}
					}else{
						_startTime = getTimer();
						_beginArr.push(new GesturePoint(touchEvent));
					}
					_multiFlag = true;
					break;
				
				case TouchEvent.TOUCH_MOVE:
					if(_flag)_isMoved = true;
					break;
				
				case TouchEvent.MULTI_TOUCH_MOVE:
					if(_multiFlag)_isMultiMoved = true;
					break;
				
				case TouchEvent.TOUCH_END:
					
					if(!_beginFlag && _beginArr.length == 2){
						
						_endTime = getTimer();
						_endArr.push(new GesturePoint(touchEvent));
						sendEvent();
					}else{
						restore();
					}
					break;
				
				case TouchEvent.MULTI_TOUCH_END:
					
					if(!_beginFlag && _beginArr.length == 2){
						
						if(_endArr.length > 0){
							
							if(_endFlag && _beginArr.length < 2 && (getTimer() - _endTime < UIGlobal.MULTI_END_TIME)){
								_endTime = getTimer();
								_beginArr.push(new GesturePoint(touchEvent));
								sendEvent();
							}else{
								_endFlag = false;
								if(_beginArr.length < 2){
									restore();
								}
							}
							
						}else{
							_endTime = getTimer();
							_endArr.push(new GesturePoint(touchEvent));
						}
					}else{
						restore();
					}
					
					break;
			}
//			touchEvent.stopPropagation();
			touchEvent = null;
		}
		
		private function contrastTouchID(arr:Array,touchPointID:int):Boolean{
			
			for each(var point:GesturePoint in arr){
				if(point.touchPointID == touchPointID)return true;
			}
			return false;
		}
		
		private function sendEvent():void{
			
			if(!_isMultiMoved && !_isMoved ){
				if(_endArr.length == 2){
					var point:GesturePoint = getCenterPoint();
					var gestureEvent:GestureEvent = new GestureEvent(GestureEvent.GESTURE_TWO_CLICK,false,point.stage.x,point.stage.y);
					gestureEvent.localX = point.local.x;
					gestureEvent.localY = point.local.y;
					dispatchEvent(gestureEvent);
					point = null;
					restore();
				}
			}else{
				restore();
			}
		}
		
		private function getCenterPoint():GesturePoint{
			
			var point:GesturePoint = new GesturePoint();
			var point1:GesturePoint = _beginArr[0] as GesturePoint;
			var point2:GesturePoint = _beginArr[1] as GesturePoint;
			
			point.local.x = point1.local.x + (point2.local.x - point1.local.x)/2;
			point.local.y = point1.local.y + (point2.local.y - point1.local.y)/2;
			point.stage.x = point1.stage.x + (point2.stage.x - point1.stage.x)/2;
			point.stage.y = point1.stage.y + (point2.stage.y - point1.stage.y)/2;
			
			return point;
		}
		
		private function restore():void{
			
			_isMoved = false;
			_isMultiMoved = false;
			_beginArr = [];
			_endArr = [];
			_beginFlag = true;
			_endFlag = true;
			_flag = false;
			_multiFlag = false;
		}
		
		override public function clear():void{
			_eventInitFlag = false;
			restore();
			super.clear();
		}
	}
}