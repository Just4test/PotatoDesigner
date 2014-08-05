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
	 *手势 多指移动事件处理实现类 
	 * @author LuXianli
	 * 
	 */	
	public class GestureMultiMoveEvent extends Gesture
	{
		public function GestureMultiMoveEvent()
		{
			eventID = "GestureMultiMoveEvent";
			eventName = GestureEvent.GESTURE_MULTI_MOVE;
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
		private var _touchID:int = -1;
		private var _startPoint:GesturePoint;
		private var _startPointArr:Array = [];
		private var _movePoinrArr:Array = [];
		private var _endPoint:GesturePoint;
		private var _startTime:int = getTimer();
		override public function optionEvent(event:Event):void{
			
			if(!(event is TouchEvent) || !_eventInitFlag)return;
			
			var touchEvent:TouchEvent = event as TouchEvent;
			
			switch(touchEvent.type)
			{
				case TouchEvent.TOUCH_BEGIN:
					_startPointArr.push(new GesturePoint(touchEvent));
					_startTime = getTimer();
					break;
				
				case TouchEvent.MULTI_TOUCH_BEGIN:
					
					if(_startPointArr.length < 1){
						_startPointArr.push(new GesturePoint(touchEvent));
						_startTime = getTimer();
					}
					else if(_startPointArr.length == 1 && getTimer() - _startTime < UIGlobal.MULTI_BEGIN_TIME){
						
						_startPointArr.push(new GesturePoint(touchEvent));
						_movePoinrArr = _startPointArr.concat();
						_startTime = getTimer();
						_downFlag = true;
						_startPoint = getCenterPoint(_startPointArr);
					}else if(_startPointArr.length > 1 && getTimer() - _startTime < UIGlobal.MULTI_BEGIN_TIME){
						_startPointArr.push(new GesturePoint(touchEvent));
						_movePoinrArr = _startPointArr.concat();
						_startTime = getTimer();
						_startPoint = getCenterPoint(_startPointArr);
					}
					
					break;
				
				case TouchEvent.TOUCH_MOVE:
					if(_downFlag && changePoint(touchEvent))sendEvent();
					break;
				
				case TouchEvent.MULTI_TOUCH_MOVE:
					if(_downFlag && changePoint(touchEvent))sendEvent();
					break;
				
				case TouchEvent.TOUCH_END:
					if(contrastTouchID(_startPointArr,touchEvent.touchPointID)){
						restore();
					}
					break;
				
				case TouchEvent.MULTI_TOUCH_END:
					if(contrastTouchID(_startPointArr,touchEvent.touchPointID)){
						restore();
					}
					break;
				
			}
//			touchEvent.stopPropagation();
			touchEvent = null;
		}
		
		private function changePoint(event:TouchEvent):Boolean{
			
			for(var i:int = 0;i < _movePoinrArr.length; i ++){
				if(_movePoinrArr[i].touchPointID == event.touchPointID){
					_movePoinrArr[i] = new GesturePoint(event);
					return true;
				}
			}
			return false;
		}
		
		private function sendEvent():void{
			
			_endPoint = getCenterPoint(_movePoinrArr);
			var gestureEvent:GestureEvent = new GestureEvent(GestureEvent.GESTURE_MOVE,false,_endPoint.stage.x,_endPoint.stage.y);
			gestureEvent.localX = _endPoint.local.x;
			gestureEvent.localY = _endPoint.local.y;
			gestureEvent.distanceX = _endPoint.stage.x - _startPoint.stage.x;
			gestureEvent.distanceY = _endPoint.stage.y - _startPoint.stage.y;
			dispatchEvent(gestureEvent);
			gestureEvent = null;
			
		}
		
		private function contrastTouchID(arr:Array,touchPointID:int):Boolean{
			
			for each(var point:GesturePoint in arr){
				if(point.touchPointID == touchPointID)return true;
			}
			return false;
		}
		
		private function getCenterPoint(arr:Array):GesturePoint{
			
			var point:GesturePoint = new GesturePoint();
			var point1:GesturePoint;
			var point2:GesturePoint;
			var point3:GesturePoint;
			switch(arr.length)
			{
				case 0:
					
					break;
				
				case 1:
					point = arr[0] as GesturePoint;
					break;
				
				case 2:
					point1 = arr[0] as GesturePoint;
					point2 = arr[1] as GesturePoint;
					point.local.x = point1.local.x + (point2.local.x - point1.local.x)/2;
					point.local.y = point1.local.y + (point2.local.y - point1.local.y)/2;
					point.stage.x = point1.stage.x + (point2.stage.x - point1.stage.x)/2;
					point.stage.y = point1.stage.y + (point2.stage.y - point1.stage.y)/2;
					break;
				default:
					point1 = arr[0] as GesturePoint;
					point2 = arr[1] as GesturePoint;
					point3 = arr[2] as GesturePoint;
					point.local.x = getBetweenNum(point1.local.x,point2.local.x,point3.local.x);
					point.local.y = getBetweenNum(point1.local.y,point2.local.y,point3.local.y);
					point.stage.x = getBetweenNum(point1.stage.x,point2.stage.x,point3.stage.x);
					point.stage.y = getBetweenNum(point1.stage.y,point2.stage.y,point3.stage.y);
					break;
			}
			
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
			
			_downFlag = false;
			_startPointArr = [];
			_movePoinrArr = [];
		}
		
		override public function clear():void{
			_eventInitFlag = false;
			restore();
			super.clear();
		}
	}
}