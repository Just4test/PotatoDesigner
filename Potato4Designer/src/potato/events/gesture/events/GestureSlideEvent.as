package potato.events.gesture.events
{
	import core.display.Stage;
	import core.events.EventDispatcher;
	import core.events.TouchEvent;
	
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import potato.events.GestureEvent;
	import potato.ui.UIGlobal;
	
	[Event(name="gestureSlideUp", type="potato.events.GestureEvent")]
	[Event(name="gestureSlideDown", type="potato.events.GestureEvent")]
	[Event(name="gestureSlideLeft", type="potato.events.GestureEvent")]
	[Event(name="gestureSlideRight", type="potato.events.GestureEvent")]
	
	/**
	 *单指 上下滑动事件实现类 
	 * @author LuXianli
	 * var gestureSlide:GestureSlideEvent = new GestureSlideEvent(new Rectangle(10,10,100,100),80,80,3000);
	 *     gestureSlide.addEventListener(GestureEvent.GESTURE_SLIDE_UP,onFunctionHandler);
	 *     gestureSlide.addEventListener(GestureEvent.GESTURE_SLIDE_DOWN,onFunctionHandler);
	 */	
	public class GestureSlideEvent extends EventDispatcher
	{
		private var _rect:Rectangle;
		private var _stage:Stage;
		private var _stageWidth:int;
		private var _stageHeight:int;
		private var _touchPiontID:int = -1;
		private var _startX:int;
		private var _startY:int;
		private var _startTime:int;
		private var _slideLength:int;
		private var _touchYLength:int;
		private var _touchXLength:int;
		private var _touchTime:int;
		private var _sendFlag:Boolean = false;
		private var _isPassPanelEvent:Boolean = false;
		/**
		 * 
		 * @param rect	滑动事件触发区域（默认全屏幕）
		 * @param touchXLength	滑动事件触发 滑动长度
		 * @param touchYLength	滑动事件触发 滑动长度
		 * @param touchTime	滑动事件触发 滑动时间段
		 * 
		 */			
		public function GestureSlideEvent(rect:Rectangle = null,touchXLength:int = 80,touchYLength:int = 80,touchTime:int = 3000)
		{
			_stage = Stage.getStage();
			_stageWidth = _stage.stageWidth;
			_stageHeight = _stage.stageHeight;
			if(rect){
				_rect = rect;
			}else{
				_rect = new Rectangle(0,0,_stageWidth,_stageHeight);
			}
			_touchXLength = touchXLength;
			_touchYLength = touchYLength;
			_touchTime = touchTime;
			_stage.addEventListener(TouchEvent.TOUCH_BEGIN,onTouchEventHandler);
			_stage.addEventListener(TouchEvent.TOUCH_MOVE,onTouchEventHandler);
			_stage.addEventListener(TouchEvent.TOUCH_END,onTouchEventHandler);
			_stage.addEventListener(TouchEvent.MULTI_TOUCH_BEGIN,onTouchEventHandler);
			_stage.addEventListener(TouchEvent.MULTI_TOUCH_END,onTouchEventHandler);
			_stage.addEventListener(TouchEvent.MULTI_TOUCH_MOVE,onTouchEventHandler);
		}
		
		private function onTouchEventHandler(event:TouchEvent):void{
			
			if(!_isPassPanelEvent && !UIGlobal.GESTURE_SLIDE_EVENT_FLAG)return;
			switch(event.type)
			{
				case TouchEvent.TOUCH_BEGIN:
					if(_touchPiontID < 0 && _rect.contains(event.stageX,event.stageY)){
						_touchPiontID = event.touchPointID;
						_startY = event.stageY;
						_startX = event.stageX;
						_startTime = getTimer();
					}
					break;
				
				case TouchEvent.MULTI_TOUCH_BEGIN:
					if(_touchPiontID < 0 && _rect.contains(event.stageX,event.stageY)){
						_touchPiontID = event.touchPointID;
						_startY = event.stageY;
						_startX = event.stageX;
						_startTime = getTimer();
					}
					break;
				
				case TouchEvent.TOUCH_MOVE:
					if(event.touchPointID == _touchPiontID && getTimer() - _startTime < _touchTime){
						if(Math.abs(event.stageY - _startY) > _touchYLength){
							if(event.stageY - _startY > 0){
								sendEvent(event,GestureEvent.GESTURE_SLIDE_DOWN);
							}else{
								sendEvent(event,GestureEvent.GESTURE_SLIDE_UP);
							}
						}
						if(Math.abs(event.stageX - _startX) > _touchXLength){
							if(event.stageX - _startX > 0){
								sendEvent(event,GestureEvent.GESTURE_SLIDE_RIGHT);
							}else{
								sendEvent(event,GestureEvent.GESTURE_SLIDE_LEFT);
							}
						}
					}
					break;
				
				case TouchEvent.MULTI_TOUCH_MOVE:
					if(event.touchPointID == _touchPiontID && getTimer() - _startTime < _touchTime){
						if(Math.abs(event.stageY - _startY) > _touchYLength){
							if(event.stageY - _startY > 0){
								sendEvent(event,GestureEvent.GESTURE_SLIDE_DOWN);
							}else{
								sendEvent(event,GestureEvent.GESTURE_SLIDE_UP);
							}
						}
						if(Math.abs(event.stageX - _startX) > _touchXLength){
							if(event.stageX - _startX > 0){
								sendEvent(event,GestureEvent.GESTURE_SLIDE_RIGHT);
							}else{
								sendEvent(event,GestureEvent.GESTURE_SLIDE_LEFT);
							}
						}
					}
					break;
				
				case TouchEvent.TOUCH_END:
					if(_touchPiontID == event.touchPointID){
						_sendFlag = false;
						_touchPiontID = -1;
					}
					break;
				
				case TouchEvent.MULTI_TOUCH_END:
					if(_touchPiontID == event.touchPointID){
						_sendFlag = false;
						_touchPiontID = -1;
					}
					break;
			}
		}
		
		private function sendEvent(event:TouchEvent,eventType:String):void{
			
			if(!_sendFlag){
				dispatchEvent(new GestureEvent(eventType,false,event.stageX,event.stageY));
				_sendFlag = true;
			}
			_startY = event.stageY;
		}
		
		override public function dispose():void{
			
			if(_stage){
				_stage.removeEventListener(TouchEvent.TOUCH_BEGIN,onTouchEventHandler);
				_stage.removeEventListener(TouchEvent.TOUCH_MOVE,onTouchEventHandler);
				_stage.removeEventListener(TouchEvent.TOUCH_END,onTouchEventHandler);
				_stage.removeEventListener(TouchEvent.MULTI_TOUCH_BEGIN,onTouchEventHandler);
				_stage.removeEventListener(TouchEvent.MULTI_TOUCH_END,onTouchEventHandler);
				_stage.removeEventListener(TouchEvent.MULTI_TOUCH_MOVE,onTouchEventHandler);
				_stage = null;
			}
			_rect = null;
			super.dispose();
		}
		/**
		 *事件类 是否工作 
		 * @param value
		 * 
		 */		
		public function enabled(value:Boolean):void{
			
			if(_stage){
				if(value){
					_stage.addEventListener(TouchEvent.TOUCH_BEGIN,onTouchEventHandler);
					_stage.addEventListener(TouchEvent.TOUCH_MOVE,onTouchEventHandler);
					_stage.addEventListener(TouchEvent.TOUCH_END,onTouchEventHandler);
					_stage.addEventListener(TouchEvent.MULTI_TOUCH_BEGIN,onTouchEventHandler);
					_stage.addEventListener(TouchEvent.MULTI_TOUCH_END,onTouchEventHandler);
					_stage.addEventListener(TouchEvent.MULTI_TOUCH_MOVE,onTouchEventHandler);
				}else{
					_stage.removeEventListener(TouchEvent.TOUCH_BEGIN,onTouchEventHandler);
					_stage.removeEventListener(TouchEvent.TOUCH_MOVE,onTouchEventHandler);
					_stage.removeEventListener(TouchEvent.TOUCH_END,onTouchEventHandler);
					_stage.removeEventListener(TouchEvent.MULTI_TOUCH_BEGIN,onTouchEventHandler);
					_stage.removeEventListener(TouchEvent.MULTI_TOUCH_END,onTouchEventHandler);
					_stage.removeEventListener(TouchEvent.MULTI_TOUCH_MOVE,onTouchEventHandler);
				}
			}
		}
		/**
		 *底层事件是否击穿panel 
		 * @param value
		 * 
		 */		
		public function set isPassPanelEvent(value:Boolean):void{
			_isPassPanelEvent = value;
		}
	}
}