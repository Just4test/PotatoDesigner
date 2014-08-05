package potato.events.gesture.events
{
	import core.events.Event;
	import core.events.TouchEvent;
	
	import potato.events.GestureEvent;
	import potato.events.gesture.Gesture;
	import potato.events.gesture.tools.GesturePoint;
	import potato.ui.UIComponent;
	
	/**
	 *单指移动事件处理实现类 
	 * @author LuXianli
	 * 
	 */	
	public class GestureMoveEvent extends Gesture
	{
		public function GestureMoveEvent()
		{
			eventID = "GestureMoveEvent";
			eventName = GestureEvent.GESTURE_MOVE;
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
		private var _movePoint:GesturePoint;
		override public function optionEvent(event:Event):void{
			
			if(!(event is TouchEvent) || !_eventInitFlag)return;
			
			var touchEvent:TouchEvent = event as TouchEvent;
			
			switch(touchEvent.type)
			{
				case TouchEvent.TOUCH_BEGIN:
				case TouchEvent.MULTI_TOUCH_BEGIN:
					
					if(!_downFlag){
						_downFlag = true;
						_touchID = touchEvent.touchPointID;
						_startPoint = new GesturePoint(touchEvent);
					}
					
					break;
				
				case TouchEvent.TOUCH_MOVE:
				case TouchEvent.MULTI_TOUCH_MOVE:
					if(_downFlag && _touchID == touchEvent.touchPointID){
						sendEvent(touchEvent);
					}
					else{
						if(_uiComponent.touchPointID == touchEvent.touchPointID){
							_downFlag = true;
							_touchID = _uiComponent.touchPointID;
							if(!_startPoint)_startPoint = new GesturePoint(touchEvent);
							sendEvent(touchEvent);
						}
					}
					break;
				
				case TouchEvent.TOUCH_END:
				case TouchEvent.MULTI_TOUCH_END:
					if(_touchID == touchEvent.touchPointID){
						_downFlag = false;
						_touchID = -1;
					}
					break;
				
			}
//			touchEvent.stopPropagation();
			touchEvent = null;
		}
		private function sendEvent(touchEvent:TouchEvent):void{
			
			// TODO: 可考虑用简单的对象池技术将 GestureEvent 对象缓存起来重复使用；具体可参考 Starling 1.2 Event 事件类
			var gestureEvent:GestureEvent = new GestureEvent(GestureEvent.GESTURE_MOVE,false,touchEvent.stageX,touchEvent.stageY);
			gestureEvent.localX = touchEvent.localX;
			gestureEvent.localY = touchEvent.localY;
			gestureEvent.touchPointID = touchEvent.touchPointID;
			if(touchEvent.capturer){
				gestureEvent.setGestureTarget(touchEvent.capturer);
			}else{
				gestureEvent.setGestureTarget(touchEvent.target);
			}
			// 这里为 GestureEvent 添加了 distanceX 和 distanceY 这两个属性，先避免了在此计算 distance 和 rotation 属性的开销
			gestureEvent.distanceY = touchEvent.stageY - _startPoint.stage.y;       // 使用基于 stage 的 Y 值做计算，以避免手指移出目标对象后坐标计算值不正确
			gestureEvent.distanceX = touchEvent.stageX - _startPoint.stage.x;       // 使用基于 stage 的 X 值做计算，以避免手指移出目标对象后坐标计算值不正确
			dispatchEvent(gestureEvent);
			gestureEvent = null;
			touchEvent = null;
		}
		
		override public function clear():void{
			_eventInitFlag = false;
			super.clear();
		}
	}
}