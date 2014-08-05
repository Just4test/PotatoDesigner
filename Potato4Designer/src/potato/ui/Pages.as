package potato.ui
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import core.display.DisplayObject;
	import core.display.Quad;
	
	import potato.events.GestureEvent;
	import potato.events.UIEvent;
	import potato.transitions.ITransition;
	import potato.transitions.PageTransition;
	
	/**
	 * 当翻页后派发事件 
	 */	
	[Event(name="pageChange", type="potato.events.UIEvent")]
	/**
	 *  翻页控件，不支持XML配置
	 */
	public class Pages extends UIComponent
	{
		/**所有页*/
		protected var _pages:Array;
		protected var _content:UIComponent;
		
		/**当前页*/
		protected var _curPage:int = -1;
		/**显示宽度*/
		protected var _width:int;
		/**显示高度*/
		protected var _height:int;
		/**跳到哪一页*/
		protected var _toPage:int;
		/**当前过场*/
		protected var _transition:ITransition;
		/**是否支持拖动翻页*/
		protected var _dragPage:Boolean = true;
		
		protected var _isHorizontal:Boolean;
		/**标志是否为向右或下翻页*/
		protected var isSlideRightorDown:Boolean;
		/**如果为真，则第一页不允许右滑，最后一页不许左滑*/
		public var isTrim:Boolean;
		private var isTrimed:Boolean;
		/**阻尼系数，该值越大滑动越缓慢,取值范围为0-1，若为1则第一页不允许右滑，最后一页不许左滑*/
		public  var  ZUZI_FACTOR:Number = 0.5;
		
		/**
		 * 
		 * @param width 页宽度
		 * @param height 页高度
		 * @param direction 是否为横向翻页
		 * 
		 */
		public function Pages(width:int, height:int, isHorizontal:Boolean = true)
		{
			_pages = [];
			_width = width;
			_height = height;
			_isHorizontal = isHorizontal;
			this.clipRect = new Rectangle(0, 0, width, height);
			var q:Quad = new Quad(width, height,0);
			addChild(q);
			
			_content = new UIComponent();
			_content.isStopEvent = true;
			addChild(_content);
			_transition = new PageTransition();
			
			_content.addEventListener(GestureEvent.GESTURE_DOWN, down);
			_content.addEventListener(GestureEvent.GESTURE_UP, end);
		}
		
		override public function set isMultiTouch(value:Boolean):void{
			
			super.isMultiTouch = value;
			_content.isMultiTouch = value;
			
			_content.removeEventListeners(GestureEvent.GESTURE_DOWN);
			_content.removeEventListeners(GestureEvent.GESTURE_UP);
			
			_content.addEventListener(GestureEvent.GESTURE_DOWN, down);
			_content.addEventListener(GestureEvent.GESTURE_UP, end);
		}
		
		public function get isHorizontal():Boolean
		{
			return _isHorizontal;
		}
		
		private var startX:int;
		private var touchX:int;
		private var startY:int;
		private var touchY:int;
		
		private function down(e:GestureEvent):void
		{
			//			e.stopPropagation();
			if(!_dragPage)
				return;
			UIGlobal.hDrag = true;
			UIGlobal.vDrag = true;
			
			_transition.stopTransition();
			
			touchX = e.stageX;
			startX = _content.x;
			touchY = e.stageY;
			startY = _content.y;
			
			samplePoints = [];
			upMoveTime = getTimer();
			index = 0;
			samplePoints[0] = new Point(touchX, touchY);
			
			_content.touchPointID = e.touchPointID;
			_content.addEventListener(GestureEvent.GESTURE_MOVE, move);
		}
		
		private function end(e:GestureEvent):void
		{
//			e.stopPropagation();
			if(!_dragPage)
				return;
			if(!samplePoints)
				return;
			if(isTrimed)
				return;
			
			move(e);
			_content.removeEventListener(GestureEvent.GESTURE_MOVE, move);
			
			if (samplePoints.length > maxSample)
			{
				samplePoints = samplePoints.slice(samplePoints.length - maxSample);
			}
			
			var uptime:int = -1;
			var upx:int = -1;
			var upy:int = -1;
			
			//x速度
			var speedx:Number;
			var speedy:Number;
			
			var i:int;
			var index:int;
			var t:int;
			
			if(_isHorizontal)
			{
				for ( i = 0; i < samplePoints.length; i++)
				{
					if (samplePoints[i] is Point)
					{
						if (upx == -1)
						{
							upx = samplePoints[i].x;
							uptime = i * 30;
							i = samplePoints.length - 2;
							continue;
						}
						/*当前移动x距离*/
						var csx:Number = samplePoints[i].x - upx;
						
						/*当前移动时间*/
						t = i * 30 - uptime;
						
						/*加速度*/
						speedx = csx / (.5 * t * t) * t;
						uptime = i * 30;
					}
				}
				samplePoints = null;
				if (!isNaN(speedx))
				{
					if(speedx != Infinity && speedx != -Infinity)
					{
						if(Math.abs(speedx) > 1)
						{
							if(speedx < 0)
								gotoPage(_curPage + 1);
							else
								gotoPage(_curPage - 1);
							return;
						}
					}
				}
				
				index = Math.round(_content.x / _width);
			}
			else
			{
				for ( i = 0; i < samplePoints.length; i++)
				{
					if (samplePoints[i] is Point)
					{
						if (upy == -1)
						{
							upy = samplePoints[i].y;
							uptime = i * 30;
							i = samplePoints.length - 2;
							continue;
						}
						/*当前移动y距离*/
						var csy:Number = samplePoints[i].y - upy;
						
						/*当前移动时间*/
						t = i * 30 - uptime;
						
						/*加速度*/
						speedy = csy / (.5 * t * t) * t;
						uptime = i * 30;
					}
				}
				samplePoints = null;
				if (!isNaN(speedy))
				{
					if(speedy != Infinity && speedy != -Infinity)
					{
						if(Math.abs(speedy) > 1)
						{
							if(speedy < 0)
								gotoPage(_curPage + 1);
							else
								gotoPage(_curPage - 1);
							return;
						}
					}
				}
				
				index = Math.round(_content.y / _width);
			}
			
			gotoPage(-index);
		}
		
		/**移动过程中被采样的点*/
		private var samplePoints:Array;
		/**最大采样数量*/
		private const maxSample:int = 5;
		/**上次移动时间*/
		private var upMoveTime:int;
		/**应该像哪个索引添加*/
		private var index:int;
		
		private function move(e:GestureEvent):void
		{
			if(!UIGlobal.GESTURE_PANEL_DRAG_FLAG)return;
			if(!_dragPage)
				return;
			
			var now:int = getTimer();
			var time:int = now - upMoveTime;
			if (time < 30)
				return;
			var minMoveLength:int = 50;
			if(_isHorizontal)
			{
				var offetX:Number = e.stageX - touchX;
				var direction:int = offetX;
				if(isTrim){
					isTrimed = false;
					if((_curPage == 0 && offetX>=0) || (_curPage == _pages.length-1 && offetX <=0 )){
						_content.removeEventListener(GestureEvent.GESTURE_MOVE, move);
						isTrimed = true;
						return;
					}
				}
				
				if(Math.abs(offetX)<minMoveLength)return;
//				if((_curPage == 0 && direction>=0) || (_curPage == _pages.length-1 && direction <= 0 )){
//					var _dis:Number = Math.abs(_content.x - _width*(_pages.length-1));
//					var factor:Number = Math.sin(Math.PI/2*(1-_dis/_width))*(1-ZUZI_FACTOR);
//					offetX *= factor;
//				}
				if(_content.x>0 && offetX>0)
				{
					offetX = Math.pow(offetX, 1 / 1.3);
				}else if(_content.width - Math.abs(_content.x) <= this.clipRect.width)
				{
					if(offetX<0)
						offetX = Math.pow(Math.abs(offetX), 1 / 1.3) *-1;
					else
						offetX = Math.pow(Math.abs(offetX), 1 / 1.3);
				}
				
				_content.x = offetX + startX;
			}
			else
			{
				var offetY:Number = e.stageY - touchY;
				if(Math.abs(offetY)<minMoveLength)return;
				if(_content.y>0 && offetY>0)
				{
					offetY = Math.pow(offetY, 1 / 1.3);
				}else if(_content.height - Math.abs(_content.y) <= this.clipRect.height)
				{
					if(offetY<0)
						offetY = Math.pow(Math.abs(offetY), 1 / 1.3)*-1;
					else
						offetY = Math.pow(Math.abs(offetY), 1 / 1.3);
				}
				_content.y = offetY + startY;
			}
			
			upMoveTime = now;
			index = index + int(time / 30);
			
			samplePoints[index] = new Point(e.stageX, e.stageY);
		}
		
		/**
		 * 添加页
		 * @param page
		 */
		public function addPage(page:DisplayObject):void
		{
			
			if(_isHorizontal)
			{
				page.y = 0;
				page.x = _pages.length * _width;
			}
			else
			{
				page.x = 0;
				page.y = _pages.length * _height;
			}
			_pages.push(page);
			_content.addChild(page);
			this.dispatchEvent(new UIEvent(UIEvent.PAGE_NUM_CHANGE));
			if(_curPage == -1)
				gotoPage(0, false);
			
		}
		
		/**
		 * 添加页，到指定索引
		 * @param page
		 */
		public function addPageAt(page:DisplayObject,pageIndex:int):void
		{
			if(pageIndex<0 || pageIndex>_pages.length)return;
			var i:int;
			_pages.splice(pageIndex,0,page);
			_content.addChildAt(page,pageIndex);
			
			if(_isHorizontal){
				for(i=0;i<_pages.length;i++){
					_pages[i].x = _width*i;
					_pages[i].y = 0;
				}
				
				if(_curPage>pageIndex){
					_curPage++;
					_content.x -= _width;
				}
			}else{
				for(i=0;i<_pages.length;i++){
					_pages[i].x = 0;
					_pages[i].y = _height*i;
				}
				
				if(_curPage>pageIndex){
					_curPage++;
					_content.y -= _height;
				}
			}
			

			_transition.stopTransition();
			checkTransition();
			
			this.dispatchEvent(new UIEvent(UIEvent.PAGE_NUM_CHANGE));
			
		}
		
		/**
		 *需要模拟滑动效果 
		 **/
		private function checkTransition():void
		{
			if(_content.x % _width != 0){
				_transition.stopTransition();
				_toPage = _curPage;
				_transition.doTransition(this);
			}	
		}
		
		/**
		 * 删除页,返回删除的Page
		 * @param page
		 */
		public function removePage(pageIndex:int):UIComponent
		{
			if(pageIndex<0 || pageIndex>=_pages.length || pageIndex== _curPage)return null;
			var i:int;
			var page:UIComponent = _pages[pageIndex];
			_pages.splice(pageIndex,1);
			_content.removeChild(page);
			
			if(_isHorizontal)
			{
				for(i=0;i<_pages.length;i++){
					_pages[i].x = _width*i;
					_pages[i].y = 0;
				}
				//更新当前页
				if(_curPage>pageIndex){        
					_curPage --;
					_content.x  += _width;
				}
			}
			else
			{
				for(i=0;i<_pages.length;i++){
					_pages[i].x = 0;
					_pages[i].y = _height*i;
				}
				//更新当前页
				if(_curPage>pageIndex){        
					_curPage --;
					_content.y  += _height;
				}
			}
			
			_transition.stopTransition();
			checkTransition();
			this.dispatchEvent(new UIEvent(UIEvent.PAGE_NUM_CHANGE));

			return page;
			
		}
		
		
		/**
		 * 跳转到哪一页
		 * @param index
		 */
		public function gotoPage(index:int, dispatchEvent:Boolean = true):void
		{
			if(index < 0)
				index = 0;
			if(index > _pages.length-1)
				index = _pages.length-1;
			
			_transition.stopTransition();
			_toPage = index;
			_transition.doTransition(this);
			_curPage = index;
			if(dispatchEvent)
				this.dispatchEvent(new UIEvent(UIEvent.PAGE_CHANGE));
		}
		
		/**
		 * 页数
		 */
		public function get numPages():int
		{
			return _pages.length;
		}
		
		/**
		 * 下一页
		 */
		public function next():void
		{
			gotoPage(_curPage + 1);
		}
		
		/**
		 * 上一页
		 */
		public function previou():void
		{
			gotoPage(_curPage - 1);
		}
		
		/**缓动对象*/
		public function get transition():ITransition
		{
			return _transition;
		}
		
		/**
		 * @private
		 */
		public function set transition(value:ITransition):void
		{
			_transition = value;
		}
		
		/**
		 * 所有显示页 
		 * @return 
		 */		
		public function get pages():Array
		{
			return _pages;
		}
		
		public function get toPage():int
		{
			return _toPage;
		}
		
		public function get currentPage():int
		{
			return _curPage;
		}
		
		public function get content():UIComponent
		{
			return _content;
		}
		
		public function get dragPage():Boolean
		{
			return _dragPage;
		}
		
		public function set dragPage(v:Boolean):void
		{
			_dragPage = v;
		}
		
		public function get displayWidth():int
		{
			return _width;
		}
		
		public function get displayHeight():int
		{
			return _height;
		}
	}
}