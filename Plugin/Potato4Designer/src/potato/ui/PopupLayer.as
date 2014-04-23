package potato.ui
{
	import core.display.DisplayObject;
	import core.display.Stage;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import potato.events.GestureEvent;

	/**
	 * 弹出层
	 * Jun 24, 2012
	 */
	public class PopupLayer extends UIComponent
	{
		
		private var _currentDisplay:UIComponent;
		
		private var _callback:Function;
		
		private var _disabledTouch:Boolean = false;
		
		private var _st:UIComponent;
		
		public function PopupLayer(st:UIComponent)
		{
			super();
			_st = st;
			st.addEventListener(GestureEvent.GESTURE_DOWN, touch);
		}
		
		override public function set isMultiTouch(value:Boolean):void{
			
			super.isMultiTouch = value;
			_st.isMultiTouch = value;
			_st.removeEventListeners(GestureEvent.GESTURE_DOWN);
			_st.addEventListener(GestureEvent.GESTURE_DOWN, touch);
		}
		
		/**
		 * 添加显示对象
		 */
		public function addItem(item:UIComponent, callback:Function = null, autoLayout:Boolean=true):void
		{
			touch(null);
			
			_callback = callback;
			_currentDisplay = item;
			addChild(_currentDisplay);
			_currentDisplay.isMultiTouch = true;
			_currentDisplay.addEventListener(GestureEvent.GESTURE_DOWN, touchItem);
			_currentDisplay.isStopEvent = true;
//			trace("addItem _currentDisplay");
			
			// 调整到显示区域内
			if (autoLayout) {
				var gp:Point = item.localToGlobal(new Point());
				
				var stage:Stage = Stage.getStage();
				var globalBounds:Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
				if(gp.x + item.width > globalBounds.x + globalBounds.width){
					gp.x = gp.x - item.width;
				}
				if(gp.x < globalBounds.x) {
					gp.x = globalBounds.x;
				}
				if(gp.y + item.height > globalBounds.y + globalBounds.height){
					gp.y = gp.y - item.height;
				}
				if(gp.y < globalBounds.y){
					gp.y = globalBounds.y;
				}
				
				item.x = gp.x;
				item.y = gp.y;
			}
		}
		
		public function removeItem():void
		{
			touch(null);
		}
		
		/**
		 * 按下显示对象 
		 * @param e
		 */
		private function touchItem(e:GestureEvent):void
		{
//			e.stopPropagation();
//			touch(null);
		}
		
		/**
		 * 点击舞台
		 * @param e
		 */
		private function touch(e:GestureEvent):void
		{
			if(_disabledTouch) return;
			if (_currentDisplay)
			{
				removeChild(_currentDisplay);
				_currentDisplay.removeEventListener(GestureEvent.GESTURE_DOWN, touchItem);
				_currentDisplay = null;
//				trace("remove _currentDisplay");
				
				if(_callback != null)
				{
					_callback();
					_callback = null;
				}
			}
		}
		
		public function get disabledTouch():Boolean
		{
			return _disabledTouch;
		}
		
		/**
		 * 暂停 TOUCH_BEGIN 关闭
		 * @param value
		 */
		public function set disabledTouch(value:Boolean):void
		{
			_disabledTouch = value;
		}

	}
}