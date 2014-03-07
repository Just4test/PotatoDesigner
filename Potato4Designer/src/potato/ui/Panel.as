package potato.ui
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	import core.display.Quad;
	import core.events.Event;
	
	import potato.events.DragEvent;
	import potato.events.GestureEvent;
	import potato.events.UIEvent;
	import potato.tweenlite.TweenLite;
	import potato.tweenlite.easeing.Expo;

	/**
	 * 面板对象
	 * <Panel id="" width="" height=""></Panel>
	 * Apr 25, 2012
	 */
	public class Panel extends DisplayObjectContainer
	{
		/**被滚动对象*/
		private var clip:UIComponent;
		/**滚动层*/
		private var scroll:UIComponent;
		/**显示宽度*/
		private var _width:int;
		/**显示高度*/
		private var _height:int;

		/**当前缓动*/
		private var tween:TweenLite;
		/**当前是否正在移动*/
		private var moving:Boolean;

		/**是否禁用左右拖动*/
		private var _disabledLeftRightDrag:Boolean = false;
		/**是否禁用上下拖动*/
		private var _disabledUpDownDrag:Boolean = false;
		/**上下滚动条*/
		private var _upDownScroll:DisplayObject;
		/**左右滚动条*/
		private var _leftRightScroll:DisplayObject;
		/**是否允许拖出去true 允许，false 不允许 默认是true */
		private var _dragOut:Boolean = true;

		/**物体质量*/
		private var _quality:uint = 5;

		/**
		 * 创建一个面板对象
		 * @param width		面板显示宽度
		 * @param height	面板高度
		 */
		public function Panel(width:int = 0, height:int = 0)
		{
			super();
			if (width > 0 && height > 0)
			{
				_width = width;
				_height = height;
				render();
			}

		}

		public function render():void
		{

			clip = new UIComponent();
			clip.clipRect = new Rectangle(0, 0, _width, _height);
			addChild(clip);

			scroll = new UIComponent();
			clip.addChild(new Quad(_width, _height, 0));
			clip.addChild(scroll);
			clip.addEventListener(GestureEvent.GESTURE_DOWN, begin);
			addEventListener(Event.ENTER_FRAME, flush);
		}
		/**
		 * 重设显示区域
		 * @param valueW
		 * @param valueH
		 * 
		 */		
		public function reSiteClipRect(valueW:Number,valueH:Number):void{
			
			if(valueW > 0 && valueH > 0){
				_width = valueW;
				_height = valueH;
				
				clip.clipRect = new Rectangle(0,0,_width,_height);
				
				if(clip && clip.numChildren > 0){
					var dis:DisplayObject = clip.getChildAt(0);
					if(dis is Quad){
						clip.removeChildAt(0);
						clip.addChildAt(new Quad(_width,_height,0),0);
					}
				}
			}
		}

		public function set isStopEvent(value:Boolean):void
		{
			if (scroll)
				scroll.isStopEvent = value;
		}
		
		public function set isMultiTouch(value:Boolean):void{
			
			clip.isMultiTouch = value;
			clip.removeEventListeners(GestureEvent.GESTURE_DOWN);
			clip.addEventListener(GestureEvent.GESTURE_DOWN,begin);
		}

		/**上下禁用*/
		public function get disabledUpDownDrag():Boolean
		{
			return _disabledUpDownDrag;
		}

		/**
		 * @private
		 */
		public function set disabledUpDownDrag(value:Boolean):void
		{
			_disabledUpDownDrag = value;
		}

		/**左右禁用*/
		public function get disabledLeftRightDrag():Boolean
		{
			return _disabledLeftRightDrag;
		}

		/**
		 * @private
		 */
		public function set disabledLeftRightDrag(value:Boolean):void
		{
			_disabledLeftRightDrag = value;
		}

		private var _disabledSlide:Boolean;

		public function get disabledSlide():Boolean
		{
			return _disabledSlide;
		}

		public function set disabledSlide(v:Boolean):void
		{
			_disabledSlide = v;
		}

		/**
		 * 按下
		 * @param e
		 */
		public function begin(e:GestureEvent = null):void
		{
			if (_disabledSlide)
				return;
			if (tween)
			{
				tween.kill();
				tween = null;
			}
			moving = true;
			var rect:Rectangle = new Rectangle(-(scroll.width + _width), -(scroll.height + _height), (scroll.width + _width), (scroll.height + _height));

			if (!_dragOut)
			{
				rect.x = -scroll.width + _width;
				rect.width = 0;
				rect.y = -scroll.height + _height;
				rect.height = 0;
			}

			if (_disabledLeftRightDrag)
			{
				rect.x = 0;
				rect.width = 0;
			}

			if (_disabledUpDownDrag)
			{
				rect.y = 0;
				rect.height = 0;
			}
			startDrag(rect);
		}

		private static var isDraging:Boolean = false;

		/**
		 * 是否启用拖动
		 */
		public var dragEnable:Boolean = false;
		/**按下之后是否移动过*/
		private var moved:Boolean;
		/**可拖动范围*/
		private var _dragRect:Rectangle;

		/**开始拖拽时的对象坐标x*/
		private var startDragX:int;
		/**开始拖拽时的对象坐标y*/
		private var startDragY:int;

		/**按下开始的舞台x*/
		private var touchX:int;
		/**按下开始的舞台y*/
		private var touchY:int;

		/**当前按下的舞台x*/
		private var curTouchX:int;
		/**当前按下的舞台y*/
		private var curTouchY:int;

		/**移动过程中被采样的点*/
		private var samplePoints:Array = [];
		/**上次移动时间*/
		private var upMoveTime:int;
		/**应该像哪个索引添加*/
		private var index:int;

		/**
		 * 判断力量
		 */
		private function ifPorw():void
		{
			var speedX:Number = 0;
			var speedY:Number = 0;

			if (samplePoints)
			{
				if (samplePoints.length > UIGlobal.SLIDE_SMAPLE_COUNT)
				{
					samplePoints = samplePoints.slice(samplePoints.length - UIGlobal.SLIDE_SMAPLE_COUNT);
				}

				var uptime:int = -1;
				var upx:int = -1;
				var upy:int = -1;

				for (var i:int = 0; i < samplePoints.length; i++)
				{
					if (samplePoints[i] is Point)
					{
						if (upx == -1)
						{
							upx = samplePoints[i].x;
							upy = samplePoints[i].y;
							uptime = i * 30;
							i = samplePoints.length - 2;
							continue;
						}
						//当前移动x距离
						var csx:Number = samplePoints[i].x - upx;
						//当前移动y距离
						var csy:Number = samplePoints[i].y - upy;
						//当前移动时间
						var t:int = i * 30 - uptime;
						//加速度
						speedX = csx / (.5 * t * t) * t;
						speedY = csy / (.5 * t * t) * t;

						speedX *= 30;
						speedY *= 30;
						if (speedX > 100)
							speedX = 100;
						if (speedX < -100)
							speedX = -100;

						if (speedY > 100)
							speedY = 100;
						if (speedY < -100)
							speedY = -100;
					}
				}
			}

			if (hasEventListener(DragEvent.SLIDE_EVENT))
			{
				dispatchEvent(new DragEvent(DragEvent.SLIDE_EVENT, false, NaN, NaN, speedX, speedY));
			}

			slide(new DragEvent(DragEvent.SLIDE_EVENT, false, NaN, NaN, speedX, speedY));
		}


		/**
		 * 在移动中收集过程中的点。用于计算滑动的力量
		 */
		private function samplePoint(e:GestureEvent):void
		{
			if (samplePoints.length > 0)
			{
				var now:int = getTimer();
				var time:int = now - upMoveTime;
				if (time < 30)
					return;

				var stageX:int = e.stageX;
				var stageY:int = e.stageY;
				var x:int = (stageX - samplePoints[index].x);
				var y:int = (stageY - samplePoints[index].y);
				upMoveTime = now;
				index = index + int(time / 30);
				samplePoints[index] = new Point(stageX, stageY);
			}
			else
			{
				samplePoints[index] = new Point(e.stageX, e.stageY);
			}
		}

		/**
		 * 开始拖动.
		 * 该方法必须在手势按下之前调用有效.
		 * @param rect	可拖动的范围。
		 */
		private function startDrag(rect:Rectangle = null):void
		{
			if (isDraging)
			{
				//				trace("Error, an component object is already been draging....");
				//				return;
				stopDrag();
				startDrag(rect);
			}

			samplePoints = [];
			upMoveTime = getTimer();
			index = 0;
			//			samplePoints[0] = new Point(CursorManager.lastTouchX, CursorManager.lastTouchY);
			moved = true;
			isDraging = true;
			UIGlobal.GESTURE_SLIDE_EVENT_FLAG = false;
			clip.addEventListener(GestureEvent.GESTURE_MOVE, dragHandler);
			clip.addEventListener(GestureEvent.GESTURE_UP, dragEndHandler);

			touchX = -1;
			touchY = -1;

			startDragX = scroll.x;
			startDragY = scroll.y;

			_dragRect = rect;
		}

		private function dragHandler(e:GestureEvent):void
		{
			if(!UIGlobal.GESTURE_PANEL_DRAG_FLAG)return;
			if (touchX == -1)
			{
				/// 由于取不到当前鼠标的舞台坐标，头一次用来取坐标，不移动
				touchX = e.stageX;
				touchY = e.stageY;
				return;
			}

			curTouchX = e.stageX;
			curTouchY = e.stageY;

			var dX:int = curTouchX - touchX;
			var dY:int = curTouchY - touchY;

			var newThisX:int = startDragX + dX;
			var newThisY:int = startDragY + dY;

			if (_dragRect)
			{
				if (newThisX < _dragRect.x)
					newThisX = _dragRect.x;
				if (newThisX > _dragRect.width)
					newThisX = _dragRect.width;

				if (newThisY < _dragRect.y)
					newThisY = _dragRect.y;
				if (newThisY > _dragRect.height)
					newThisY = _dragRect.height;
			}
			var cc:int;
			if (newThisY > 0)
			{

				newThisY = Math.pow(newThisY, 1 / 1.3);
			}
			else if (newThisY - _height < -scroll.height && newThisY != 0)
			{
				if(scroll.height >= _height){
					cc = -((newThisY - _height) + scroll.height);
					newThisY = -(scroll.height - _height) - Math.pow(cc, 1 / 1.3);
				}else{
					cc = ((newThisY - _height) + scroll.height);
					newThisY = -(scroll.height - _height) - Math.pow(cc, 1 / 1.3);
				}
			}

			if (newThisX > 0)
			{

				newThisX = Math.pow(newThisX, 1 / 1.3);
			}
			else if (newThisX - _width < -scroll.width && newThisX != 0)
			{
				cc = -((newThisX - _width) + scroll.width);
				newThisX = -(scroll.width - _width) - Math.pow(cc, 1 / 1.3);
			}

			scroll.x = newThisX;
			scroll.y = newThisY;

			samplePoint(e);

			dispatchEvent(new DragEvent(DragEvent.DRAGING_EVENT, false, e.stageX, e.stageY));
		}

		private function dragEndHandler(e:GestureEvent):void
		{
			stopDrag();

			// 拖拽结束事件
			dispatchEvent(new DragEvent(DragEvent.DRAGEND_EVENT, false, e.stageX, e.stageY));
		}

		/**
		 * 停止拖动
		 */
		private function stopDrag():void
		{
			isDraging = false;
			UIGlobal.GESTURE_SLIDE_EVENT_FLAG = true;
			clip.removeEventListener(GestureEvent.GESTURE_MOVE, dragHandler);
			clip.removeEventListener(GestureEvent.GESTURE_UP, dragEndHandler);

			ifPorw();
		}

		/**
		 *停止panel的滑动
		 *
		 */
		public function stopScrollDrag():void
		{

			stopDrag();
		}

		/**
		 * 滑动事件
		 * @param e
		 */
		private function slide(e:DragEvent):void
		{
//			if(_disabledSlide)
//				return;

			if (quality == 0)
				return;

			var toX:int = scroll.x;
			var toY:int = scroll.y;

			if (!_disabledLeftRightDrag)
			{
				toX += e.slideX / quality * Math.abs(e.slideX);
			}

			if (!_disabledUpDownDrag)
			{
				toY += e.slideY / quality * Math.abs(e.slideY);
			}

			if (toX < _width - scroll.width)
			{
				toX = _width - scroll.width;
			}
			if (toX > 0)
			{
				toX = 0;
			}

			if (toY < _height - scroll.height)
			{
				toY = _height - scroll.height;
			}
			if (toY > 0)
			{
				toY = 0;
			}
			tween = TweenLite.to(scroll, 0.4, {x: toX, y: toY, ease: Expo.easeOut, onComplete: onComplete});
			this.dispatchEvent(new UIEvent(UIEvent.CHANGE, false));
		}

		/**
		 * 缓动播放完成
		 */
		private function onComplete():void
		{
//			trace("完成");
			tween = null;
			moving = false;
			this.dispatchEvent(new UIEvent(UIEvent.CHANGE, false));
			this.dispatchEvent(new UIEvent(UIEvent.STOP, false));
		}

		/**
		 * 添加内容
		 * @param obj
		 */
		public function addContent(obj:DisplayObject):void
		{
			scroll.addChild(obj);
		}

		/**
		 * 移除内容
		 * @param obj
		 */
		public function removeContent(obj:DisplayObject):void
		{
			scroll.removeChild(obj);
		}

		/**
		 * 移除多个内容
		 * @param index		从哪里索引开始
		 * @param end		到哪里结束
		 */
		public function removeContents(index:int = 0, end:int = int.MAX_VALUE):void
		{
			scroll.removeChildren(index, end);
		}


		/**
		 *
		 * @param e
		 */
		private function flush(e:Event):void
		{
			if (moving)
			{
				if (_upDownScroll)
				{
					var h:Number = _height / scroll.height;
					_upDownScroll.scaleY = 1;
					_upDownScroll.scaleY = (h * _height) / _upDownScroll.height;

					var numY:Number = scroll.y / (scroll.height - _height);
					_upDownScroll.y = -(_height - _upDownScroll.height) * numY;
					if (!_upDownScroll.parent)
						clip.addChild(_upDownScroll);
				}

				if (_leftRightScroll)
				{
					var w:Number = _width / scroll.width;
					_leftRightScroll.scaleX = 1;
					_leftRightScroll.scaleX = (w * _width) / _leftRightScroll.width;

					var numX:Number = scroll.x / (scroll.width - _width);
					_leftRightScroll.x = -(_width - _leftRightScroll.width) * numY;
					if (!_leftRightScroll.parent)
						clip.addChild(_leftRightScroll);
				}
			}
			else
			{
				if (_upDownScroll && _upDownScroll.parent)
				{
					clip.removeChild(_upDownScroll);
				}

				if (_leftRightScroll && _leftRightScroll.parent)
				{
					clip.removeChild(_leftRightScroll);
				}
			}
		}

		/**
		 * 横向滚动条
		 * @param value
		 */
		public function set hScrollBar(value:DisplayObject):void
		{
			if (_leftRightScroll && _leftRightScroll.parent)
			{
				clip.removeChild(_leftRightScroll);
			}

			_leftRightScroll = value;
		}

		/**
		 * 纵向滚动条
		 * @param value
		 */
		public function set vScrollBar(value:DisplayObject):void
		{
			if (_upDownScroll && _upDownScroll.parent)
			{
				clip.removeChild(_upDownScroll);
			}

			_upDownScroll = value;
//			_upDownScroll.x = _width - _upDownScroll.width;

		}

		/**
		 * 是否允许拖出去true 允许，false 不允许 默认是true
		 * @return
		 *
		 */
		public function get dragOut():Boolean
		{
			return _dragOut;
		}

		/**
		 * 是否允许拖出去true 允许，false 不允许 默认是true
		 * @param v
		 *
		 */
		public function set dragOut(v:Boolean):void
		{
			_dragOut = v;
		}

		/**
		 * 获得滚动内容的Y
		 * @return 返回百分比
		 */
		public function get scrollY():Number
		{
//			trace(scroll.y, scroll.height, _height);
//			(-scroll.y + _height) / scroll.height;
			return (-scroll.y + _height) / scroll.height;
		}

		public function set scrollY(value:Number):void
		{
			scroll.y = -value * (scroll.height - _height);
		}

		/**
		 * 获得滚动内容的X
		 * @return 返回百分比
		 */
		public function get scrollX():Number
		{
			return -scroll.x / (scroll.width - _width);
		}

		public function set scrollX(value:Number):void
		{
			scroll.x = -value * (scroll.width - _width);
		}

		/**
		 * 当前面板质量（影响滑动的距离。质量越大，滑动越慢） .
		 * @default 	50_width
		 * @return
		 */
		public function get quality():uint
		{
			return _quality;
		}

		/**
		 * @private
		 * @param v
		 */
		public function set quality(v:uint):void
		{
			_quality = v;
		}

		/**
		 * 重设滑动面板位置（X,Y坐标）
		 * @valueX	滑动版X坐标
		 * @valueY	滑动版Y坐标
		 * */
		public function reSite(valueX:Number = 0, valueY:Number = 0):void
		{

			if (scroll)
			{
				scroll.x = valueX;
				scroll.y = valueY;
			}
		}

		/**
		 * 获得当前滚动的位置
		 * @return
		 */
		public function get contentYNumber():Number
		{
			return scroll.y;
		}

		/**
		 * 获得panel的真实高度
		 * @return
		 */
		public function get contentHeight():Number
		{
			return scroll.height;
		}

		/**
		 * 移除多个子对象
		 * @param index		开始索引
		 * @param end		结束索引
		 */
		public function removeChildren(index:int = 0, end:int = int.MAX_VALUE):void
		{
			if (numChildren < 1)
				return;
			if (index == end)
			{
				removeChildAt(index);
				return;
			}
			else if (index > end)
			{
				var temp:int = index;
				index = end;
				end = temp;
			}

			index = index > numChildren - 1 ? (numChildren - 1 > 0 ? numChildren - 1 : 0) : index;
			end = end > numChildren - 1 ? (numChildren - 1 > 0 ? numChildren - 1 : 0) : end;

			for (var i:int = end; i >= index; i--)
			{
				removeChildAt(i);
			}
		}
		
		public override function get width():Number{
			return _width;
		}
		public override function get height():Number{
			return _height;
		}
	}
}