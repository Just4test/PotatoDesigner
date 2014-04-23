package potato.movie
{
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import core.display.Texture;
	import core.events.Event;
	
	import potato.movie.IMovie;
	import potato.movie.MovieAsset;
	import potato.movie.MovieBean;
	import potato.res.Res;
	import potato.ui.Grid9;
	import potato.ui.UIComponent;

	/**
	 * 播放动画类
	 * May 25, 2012
	 */
	public class Grid9Movie extends UIComponent implements IMovie
	{
		/**当前显示对象*/
		private var display:Grid9;
		/**当前帧*/
		private var _currentFrame:int = 1;
		/**当前速度*/
		private var speed:int;
		/**总共帧*/
		private var frameNumber:int;
		/**动画名*/
		private var movieName:String;
		/**基准点X*/
		private var footX:int;
		/**基准点Ｙ*/
		private var footY:int;
		/**上次执行时间*/
		private var upTime:int;
		/**当前是否停止*/
		private var stoped:Boolean;
		/**一个动作播放完成*/
		private var actionPlayComplete:Function;

		/**
		 * 构造方法
		 * @param movieName		动画名
		 * @param rect		切割矩阵
		 */
		public function Grid9Movie(movieName:String,rect:Rectangle = null)
		{
			display = new Grid9(null,rect);
			addChild(display);

			var bean:MovieBean = MovieAsset.getConfig(movieName);

			this.movieName = bean.movieName;
			this.speed = bean.speed;
			this.frameNumber = bean.frameNumber;
			if(frameNumber != 1)
				addEventListener(Event.ENTER_FRAME, loop);
			upTime = getTimer();
			
			footX = bean.footX;
			footY = bean.footY;
			_play(0);
		}

		/**
		 * 在当前帧停止（不立即渲染）
		 */
		public function stop():void
		{
			stoped = true;
			removeEventListener(Event.ENTER_FRAME, loop);
			showImg(_currentFrame);
		}

		/**
		 * 开始播放 （不立即渲染）
		 */
		public function play():void
		{
			stoped = false;
			addEventListener(Event.ENTER_FRAME, loop);
		}

		/**
		 * 立即渲染并停止到frame
		 * @param frame
		 */
		public function gotoAndStop(frame:int):void
		{
			removeEventListener(Event.ENTER_FRAME, loop);
			
			_currentFrame = frame;
			_currentFrame %= frameNumber + 1;
			if (_currentFrame == 0)
				_currentFrame = frameNumber;
			showImg(_currentFrame);
			stoped = true;
		}

		/**
		 * 立即渲染并继续播放
		 * @param frame
		 */
		public function gotoAndPlay(frame:int):void
		{
			addEventListener(Event.ENTER_FRAME, loop);
			
			_currentFrame = frame;
			_currentFrame %= frameNumber + 1;
			if (_currentFrame == 0)
				_currentFrame = frameNumber;
			showImg(_currentFrame);
			stoped = false;
			upTime = getTimer();
		}

		public function get currentFrame():int
		{
			return _currentFrame;
		}

		public function get currentAction():String
		{
			return movieName;
		}
		
		public function set playComplete(value:Function):void
		{
			actionPlayComplete = value;
		}

		private function loop(e:Event):void
		{
			if (stoped)
				return;

			var currentTime:int = getTimer();
			var cha:int = currentTime - upTime;
			if (cha >= speed)
			{
				var f:int = cha / speed;
				upTime += f * speed;
				_play(f);
			}
		}

		private function _play(addFrame:int):void
		{
			if (_currentFrame + addFrame >= frameNumber)
			{
				_currentFrame = ((_currentFrame + addFrame) % frameNumber);
				if (_currentFrame == 0)
					_currentFrame = frameNumber;
				if(actionPlayComplete != null)
				{
					actionPlayComplete();
					return;
				}
			}
			else
			{
				_currentFrame += addFrame;
			}
			showImg(_currentFrame);
		}
		
		private function showImg(frame:int):void
		{
			var texture:Texture = Res.getImage(movieName+ "_" + frame).texture;
			if(texture)
			{
				display.texture = texture;
				display.x = -footX;
				display.y = -footY;
			}
			else
			{
				removeChild(display);
				display = new Grid9(Res.getImage(movieName+ "_" + frame));
				display.setSize(_width, _height);
				addChild(display);
				display.x = -footX;
				display.y = -footY;
			}
			display.exactHitTest = _exact;
		}
		
		public function setSize(valueW:Number, valueH:Number):void {
			
			display.setSize(valueW, valueH);
			_width = valueW;
			_height = valueH;
		}
		
		private var _width:Number;
		override public function get width():Number 
		{
			return _width;
		}
		
		private var _height:Number;
		override public function get height():Number 
		{
			return _height;
		}
		
		override public function dispose():void
		{
			removeEventListener(Event.ENTER_FRAME, loop);
			super.dispose();
		}
		
		private var _exact:Boolean;
		
		override public function set exactHitTest(value:Boolean):void
		{
			_exact = value;
		}
		
		override public function get exactHitTest():Boolean
		{
			return _exact;
		}
		
		public function get totalFrames():int
		{
			return frameNumber;
		}
	}
}