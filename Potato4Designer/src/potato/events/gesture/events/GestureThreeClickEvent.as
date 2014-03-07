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
	 *三指点击事件处理实现类 
	 * @author LuXianli
	 * 
	 */	
	public class GestureThreeClickEvent extends Gesture
	{
		public function GestureThreeClickEvent()
		{
			eventID = "GestureThreeClickEvent";
			eventName = GestureEvent.GESTURE_THREE_CLICK;
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
						if(_beginFlag && _beginArr.length < 3 && (getTimer() - _startTime < UIGlobal.MULTI_BEGIN_TIME)){
							_startTime = getTimer();
							_beginArr.push(new GesturePoint(touchEvent));
						}else{
							_beginFlag = false;
							if(_beginArr.length < 3){
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
					
					if(!_beginFlag && _beginArr.length == 3){
						
						_endTime = getTimer();
						_endArr.push(new GesturePoint(touchEvent));
						sendEvent();
					}else{
						restore();
					}
					break;
				
				case TouchEvent.MULTI_TOUCH_END:
					
					if(!_beginFlag && _beginArr.length == 3){
						
						if(_endArr.length > 0){
							
							if(_endFlag && _beginArr.length < 3 && (getTimer() - _endTime < UIGlobal.MULTI_END_TIME)){
								_endTime = getTimer();
								_beginArr.push(new GesturePoint(touchEvent));
								sendEvent();
							}else{
								_endFlag = false;
								if(_beginArr.length < 3){
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
				if(_endArr.length == 3){
					var point:GesturePoint = getCenterPoint();
					var gestureEvent:GestureEvent = new GestureEvent(GestureEvent.GESTURE_THREE_CLICK,false,point.stage.x,point.stage.y);
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
			var point3:GesturePoint = _beginArr[2] as GesturePoint;
			
			point.local.x = getBetweenNum(point1.local.x,point2.local.x,point3.local.x);
			point.local.y = getBetweenNum(point1.local.y,point2.local.y,point3.local.y);
			point.stage.x = getBetweenNum(point1.stage.x,point2.stage.x,point3.stage.x);
			point.stage.y = getBetweenNum(point1.stage.y,point2.stage.y,point3.stage.y);
			
			return point;
		}
		
		/**
		 * 得到三个值中的的中间值
		 * @param	value1
		 * @param	value2
		 * @param	value3
		 * @return
		 */
		private function getBetweenNum(value1:Number, value2:Number, value3:Number):Number {
			
			var arr:Array = [value1, value2, value3];
			var mNum:Number;
			for (var i:int = 0; i < arr.length; i ++ ) {
				
				for (var j:int = i; j < arr.length; j ++ ) {
					
					if (arr[i] > arr[j]) {
						
						var tmp:Number = arr[i];
						arr[i] = arr[j];
						arr[j] = tmp;
					}
				}
			}
			
			mNum = arr[1];
			arr = null;
			return mNum;
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