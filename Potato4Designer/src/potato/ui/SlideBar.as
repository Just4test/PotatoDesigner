package potato.ui
{
	import core.display.DisplayObject;
	
	import flash.geom.Rectangle;
	
	import potato.events.DragEvent;
	import potato.events.GestureEvent;
	import potato.events.UIEvent;

	/**
	 * 滑动条刻度改变事件.
	 * 在滑动条拖动，改变后调度.<br/>
	 * @see sf.ui.SlideBar
	 */
	[Event(name="slideBarChange", type="potato.events.UIEvent")]
	
	/**
	 * 滑动控件
	 * @author Floyd
	 * Apr 27, 2012
	 */
	public class SlideBar extends UIComponent
	{
		/**滑动条背景*/
		private var _bg:DisplayObject;
		/**是否是横向*/
		private var _h:Boolean;
		/**滑动条按钮*/
		private var _dragBtn:Button;
		/**拖动最大范围*/
		private var _size:Number;
		/**起始数*/
		private var _startNum:Number;
		/**结束数*/
		private var _endNum:Number;
		/**当前值*/
		private var _num:Number;
		
		/**是否禁用*/
		private var _disabled:Boolean;
		/**
		 *
		 * @param size		最大拖动范围
		 * @param h			横向？
		 */
		public function SlideBar(size:int = 100, h:Boolean = true)
		{
			_size = size;
			_h = h;
		}

		/**
		 * 设置拖动按钮
		 * @param btn			按钮
		 * @param startNum		最小值
		 * @param endNum		最大值
		 * @param defaultNum	默认滑动到哪个位置
		 */
		public function setBtn(btn:Button, startNum:Number = 0, endNum:Number = 0, defaultNum:Number = 0):void
		{
			_dragBtn = btn;
			addChild(btn);

			_startNum = startNum;
			_endNum = endNum;

			var all:Number = endNum - startNum;
			var curr:Number = defaultNum - startNum;

			if(_h)
				_dragBtn.x = _size * (curr / all);
			else
				_dragBtn.y = _size * (curr / all);
			change(null);

			_dragBtn.addEventListener(GestureEvent.GESTURE_DOWN, begin);
			_dragBtn.addEventListener(GestureEvent.GESTURE_UP, end);
		}
		
		override public function set isMultiTouch(value:Boolean):void{
			
			super.isMultiTouch = value;
			
			_dragBtn.removeEventListeners(GestureEvent.GESTURE_DOWN);
			_dragBtn.removeEventListeners(GestureEvent.GESTURE_UP);
			
			_dragBtn.addEventListener(GestureEvent.GESTURE_DOWN, begin);
			_dragBtn.addEventListener(GestureEvent.GESTURE_UP, end);
		}

		private function begin(e:GestureEvent):void
		{
			e.stopPropagation();
			
			if(_disabled)
				return;
			
			if (_h)
				_dragBtn.startDrag(new Rectangle(0, 0, _size, 0));
			else
				_dragBtn.startDrag(new Rectangle(0, 0, 0, _size));
			_dragBtn.addEventListener(DragEvent.DRAGING_EVENT, change);
		}

		private function change(e:DragEvent):void
		{
			if(_h)
				_num = _dragBtn.x / (_size / (_endNum - _startNum)) + _startNum;
			else
				_num = _dragBtn.y / (_size / (_endNum - _startNum)) + _startNum;
			if(e)
				this.dispatchEvent(new UIEvent(UIEvent.SLIDE_BAR_CHANGE, false));
		}

		private function end(e:GestureEvent):void
		{
			e.stopPropagation();
			if(_disabled)
				return;
			_dragBtn.stopDrag();
			_dragBtn.removeEventListener(DragEvent.SLIDE_EVENT, change);
		}

		/**
		 * 背景图片
		 * @param bg
		 */
		public function backgroundImage(bg:DisplayObject, x:int = 0, y:int = 0):void
		{
			if(_bg)
			{
				removeChild(_bg);
			}
			
			_bg = bg;
			
			if (bg)
			{
				bg.x = _bg.x;
				bg.y = _bg.y;
				addChildAt(bg, 0);
				bg.x = x;
				bg.y = y;
			}
		}
		
		/**
		 * 设置背景坐标 
		 * @param x
		 * @param y
		 */	
		public function setBackgroundPoint(x:int, y:int):void
		{
			if(_bg)
			{
				_bg.x = x;
				_bg.y = y;
			}
		}

		/**
		 * 当前刻度
		 * @return
		 */
		public function get value():Number
		{
			return _num;
		}
		
		public function set value(v:Number):void
		{
			_num = v;
			
			
			var all:Number = _endNum - _startNum;
			var curr:Number = _num - _startNum;
			
			if(_h)
				_dragBtn.x = _size * (curr / all);
			else
				_dragBtn.y = _size * (curr / all);
		}
		
		/**
		 * 禁用拖动（true=禁用，false=不禁用） 
		 * @return 
		 */		
		public function get disabled():Boolean
		{
			return _disabled;
		}
		
		public function set disabled(v:Boolean):void
		{
			_disabled = v;
		}
		
	}
}