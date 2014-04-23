package potato.events.gesture.events
{
	import core.display.Stage;
	import core.events.Event;
	import core.events.TouchEvent;
	
	import potato.events.GestureEvent;
	import potato.events.gesture.Gesture;
	import potato.ui.UIComponent;
	
	/**
	 *单指抬起事件处理实现类 
	 * @author LuXianli
	 * 
	 */	
	public class GestureStageUpEvent extends Gesture
	{
		public function GestureStageUpEvent()
		{
			eventID = "gestureStageUp";
			eventName = GestureEvent.GESTURE_STAGE_UP;
		}
		private var _eventInitFlag:Boolean = false;
		private var _stage:Stage;
		private var _stageFun:Function;
		override public function initEvent(uiComponent:UIComponent, listener:Function):void{
			
			_eventInitFlag = true;
			_uiComponent = uiComponent;
			_stage = Stage.getStage();
			_stageFun = listener;
			_stage.addEventListener(TouchEvent.TOUCH_BEGIN,listener);
			_stage.addEventListener(TouchEvent.MULTI_TOUCH_BEGIN,listener);
			_stage.addEventListener(TouchEvent.TOUCH_END,listener);
			_stage.addEventListener(TouchEvent.MULTI_TOUCH_END,listener);
		}
		
		private var _downFlag:Boolean = false;
		private var _touchID:int = -1;
		override public function optionEvent(event:Event):void{
			
			if(!(event is TouchEvent) && !_eventInitFlag)return;
			
			var touchEvent:TouchEvent = event as TouchEvent;
			
			switch(touchEvent.type)
			{
				case TouchEvent.TOUCH_BEGIN:
				case TouchEvent.MULTI_TOUCH_BEGIN:
					if (!_uiComponent.hasEventListener(GestureEvent.GESTURE_DOWN)){
						if(!_downFlag){
							_downFlag = true;
							_touchID = touchEvent.touchPointID;
						}
					}
					
					break;
				
				case TouchEvent.TOUCH_END:
				case TouchEvent.MULTI_TOUCH_END:
					if(_downFlag){
						
						if(_touchID == touchEvent.touchPointID)sendEvent(touchEvent);
					}else{
						
						if(touchEvent.touchPointID == _uiComponent.touchPointID){
							sendEvent(touchEvent);
						}
					}
					break;
				
			}
			//			touchEvent.stopPropagation();
			touchEvent = null;
			
		}
		
		private function sendEvent(touchEvent:TouchEvent):void{
			
			var gestureEvent:GestureEvent = new GestureEvent(GestureEvent.GESTURE_STAGE_UP,false,touchEvent.stageX,touchEvent.stageY);
			gestureEvent.localX = touchEvent.localX;
			gestureEvent.localY = touchEvent.localY;
			gestureEvent.touchPointID = touchEvent.touchPointID;
			if(touchEvent.capturer){
				gestureEvent.setGestureTarget(touchEvent.capturer);
			}else{
				gestureEvent.setGestureTarget(touchEvent.target);
			}
			dispatchEvent(gestureEvent);
			_downFlag = false;
			_touchID = -1;
			gestureEvent = null;
		}
		
		override public function clear():void{
			
			_stage.removeEventListener(TouchEvent.TOUCH_BEGIN,_stageFun);
			_stage.removeEventListener(TouchEvent.MULTI_TOUCH_BEGIN,_stageFun);
			_stage.removeEventListener(TouchEvent.TOUCH_END,_stageFun);
			_stage.removeEventListener(TouchEvent.MULTI_TOUCH_END,_stageFun);
			_stage = null;
			_stageFun = null;
			super.clear();
		}
		
		public function dispose():void{
			
			if(_stage && _stageFun != null)clear();
		}
	}
}