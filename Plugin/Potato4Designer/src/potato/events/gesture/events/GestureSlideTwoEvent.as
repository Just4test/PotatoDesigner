package potato.events.gesture.events
{
	import core.display.Stage;
	import core.events.EventDispatcher;
	import core.events.TouchEvent;
	
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import potato.events.GestureEvent;
	import potato.ui.UIGlobal;
	
	[Event(name="gestureSlideIn", type="potato.events.GestureEvent")]
	[Event(name="gestureSlideOut", type="potato.events.GestureEvent")]
	
	/**
	 *单指 上下滑动事件实现类 
	 * @author LuXianli
	 * var gestureSlide:GestureSlideTwoEvent = new GestureSlideTwoEvent(new Rectangle(10,10,100,100),80,80,3000);
	 *     gestureSlide.addEventListener(GestureEvent.GESTURE_SLIDE_UP,onFunctionHandler);
	 */	
	public class GestureSlideTwoEvent extends EventDispatcher
	{
		private var _rect:Rectangle;
		private var _stage:Stage;
		private var _stageWidth:int;
		private var _stageHeight:int;
		private var _touchID1:int = -1;
		private var _touchID2:int = -1;
		private var _start1X:int = -1;
		private var _start1Y:int = -1;
		private var _start2X:int = -1;
		private var _start2Y:int = -1;
		private var _end1X:int = -1;
		private var _end1Y:int = -1;
		private var _end2X:int = -1;
		private var _end2Y:int = -1;
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
		public function GestureSlideTwoEvent(rect:Rectangle = null,touchXLength:int = 40,touchYLength:int = 40,touchTime:int = 3000)
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
				case TouchEvent.MULTI_TOUCH_BEGIN:
					if(_touchID1 < 0 && _rect.contains(event.stageX,event.stageY)){
						_touchID1 = event.touchPointID;
						_start1X = event.stageX;
						_start1Y = event.stageY;
						_startTime = getTimer();
					}else if(_touchID2 < 0 && _rect.contains(event.stageX,event.stageY)){
						_touchID2 = event.touchPointID;
						_start2X = event.stageX;
						_start2Y = event.stageY;
					}
					break;
				
				case TouchEvent.TOUCH_MOVE:
				case TouchEvent.MULTI_TOUCH_MOVE:
					if(event.touchPointID == _touchID1 && getTimer() - _startTime < _touchTime){
						_end1X = event.stageX;
						_end1Y = event.stageY;
						if(Math.abs(event.stageX - _start1X) > _touchXLength){
							if(event.stageX - _start1X > 0){
								sendEvent(_touchID1,GestureEvent.GESTURE_SLIDE_RIGHT);
							}else{
								sendEvent(_touchID1,GestureEvent.GESTURE_SLIDE_LEFT);
							}
						}
					}else if(event.touchPointID == _touchID2 && getTimer() - _startTime < _touchTime){
						_end2X = event.stageX;
						_end2Y = event.stageY;
						if(Math.abs(event.stageX - _start2X) > _touchXLength){
							if(event.stageX - _start2X > 0){
								sendEvent(_touchID2,GestureEvent.GESTURE_SLIDE_RIGHT);
							}else{
								sendEvent(_touchID2,GestureEvent.GESTURE_SLIDE_LEFT);
							}
						}
					}
					
					break;
				
				case TouchEvent.TOUCH_END:
				case TouchEvent.MULTI_TOUCH_END:
					if(_touchID1 == event.touchPointID || _touchID2 == event.touchPointID){
						restore();
					}
					break;
			}
		}
		
		private var _touchObj:Object = new Object();
		private function sendEvent(touchID:int,eventType:String):void{
			
			if(!_sendFlag){
				
				if(!_touchObj[touchID]){
					_touchObj[touchID] = eventType;
				}else{
					if(_touchObj[touchID] != eventType){
						restore();
						return;
					}else{
						if(_touchObj[_touchID1] && _touchObj[_touchID2]){
							
							if(!(_start1X > -1 && _start2X > -1 && _end1X > -1 && _end2X > -1)){
								restore();
								return;
							}
							
							if(Math.abs(_end1X - _end2X) - Math.abs(_start1X - _start2X) < 0){
								dispatchEvent(new GestureEvent(GestureEvent.GESTURE_SLIDE_IN,false,(_start1X + _start2X)/2,(_start1Y + _start2Y)/2));
							}else{
								dispatchEvent(new GestureEvent(GestureEvent.GESTURE_SLIDE_OUT,false,(_start1X + _start2X)/2,(_start1Y + _start2Y)/2));
							}
							_sendFlag = true;
							restore();
						}
					}
				}
				
			}
		}
		
		private function restore():void{
			_sendFlag = false;
			_touchID1 = -1;
			_touchID2 = -1;
			_start1X = -1;
			_start1Y = -1;
			_start2X = -1;
			_start2Y = -1;
			_end1X = -1;
			_end1Y = -1;
			_end2X = -1;
			_end2Y = -1;
			_touchObj = new Object();
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
