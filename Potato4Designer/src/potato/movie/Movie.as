package potato.movie
{
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import core.display.Image;
	import core.display.Texture;
	import core.events.Event;
	
	import potato.res.Res;

	/**
	 * 播放动画类
	 * May 25, 2012
	 */
	public class Movie extends Image implements IMovie
	{
		/** 当前帧 */
		protected var _currentFrame:int = 0;
		/** 帧速度，单位：毫秒 */
		protected var _speed:int;
		/** 总共帧 */
		protected var _frameNumber:int;
		/** 动画资源名 */
		protected var _movieName:String;
		/**基准点X*/
		protected var _footX:int;
		/** 基准点Ｙ */
		protected var _footY:int;
		/** 每一帧速度的数组，例如一个匀速5帧的动画，此值为：[1,1,1,1,1] */
		protected var _frameArr:Array;
		/** 上次重绘的执行时间，单位：毫秒 */
		protected var _upTime:int;
		/** 当前是否停止 */
		protected var _isStoped:Boolean;
		/** 一个动作播放完成时的回调函数 */
		protected var _actionPlayCompleteCallback:Function;
		/** 每一帧的材质资源向量数组 */
		protected var _frames:Vector.<Texture>;

		/**自动播放*/
		protected var _autoPlay:Boolean;
		
		private var _from:int;
		
		private var _to:int;
		/** 图集缩放系数，表示图集中的元素被缩小到多少。1 表示未被缩放 */
		protected var _scaleFactor:Number;
		private var _scaleX:Number = 1;

		override public function set scaleX(value:Number):void
		{
			if (value != _scaleX)
			{
				_scaleX = value;
				super.scaleX = _scaleX / _scaleFactor;
			}
		}

		private var _scaleY:Number = 1;

		override public function set scaleY(value:Number):void
		{
			if (value != _scaleY)
			{
				_scaleY = value;
				super.scaleY = _scaleY / _scaleFactor;
			}
		}

		/**
		 * 构造方法
		 * @param movieName		动画名
		 * @param action		播放动作
		 */
		public function Movie(movieName:String, autoPlay:Boolean = true,from:int = 0,to:int = 0)
		{
			super(null);
			_from = from;
			_to = to;
			_autoPlay = autoPlay;
			this.movieName = movieName;
		}

		public function set movieName(value:String):void
		{
			if (_movieName != value && value)
			{
				var bean:MovieBean = MovieAsset.getConfig(value);
				
				if(bean==null){
					trace('::movieName(),no bean ,returned');
					return;
				}
				_movieName = bean.movieName;
				_speed = bean.speed;
				_frameNumber = bean.frameNumber;

				_scaleFactor = bean.scale ? bean.scale : 1;		// 缩放要在脚点之前设置
				super.scaleX = _scaleX / _scaleFactor;
				super.scaleY = _scaleY / _scaleFactor;

				_footX = bean.footX * _scaleFactor;
				_footY = bean.footY * _scaleFactor;
				_frameArr = bean.frameArr;

				if (_frameNumber != 1 && _autoPlay)
					addEventListener(Event.ENTER_FRAME, loopHandler);
				else
					removeEventListener(Event.ENTER_FRAME, loopHandler);

				_upTime = getTimer();

				_frames = new Vector.<Texture>(_frameNumber, true);
				for (var i:int = 0; i < _frameNumber; i++)
				{
					if (_frameArr[i] > 0) {
						_frames[i] = Res.getTexture(value + "_" + String(i));
					} else {
						_frames[i] = null;
						_frameArr[i] = -_frameArr[i];
					}
				}
				

				if(_from != 0){
					_currentFrame = _from;
					showImg(_currentFrame);
				}else{
					_play(0);
				}
			}
		}
		
		/**
		 * 从指定帧间循环播放
		 * @param from	起始帧
		 * @param to	结束帧（to = 0 :最大帧）
		 */		
		public function setFromTo(from:int,to:int = 0):void{
			
			_from = from;
			_to = to == 0 ? _frameNumber : to;
			_currentFrame = _from;
			showImg(_currentFrame);
		}
		
		public function get movieName():String
		{
			return _movieName;
		}

		/**
		 * 在当前帧停止（不立即渲染）
		 */
		public function stop():void
		{
			_isStoped = true;
			removeEventListener(Event.ENTER_FRAME, loopHandler);
		}

		/**
		 * 开始播放
		 */
		public function play():void
		{
			_isStoped = false;
			addEventListener(Event.ENTER_FRAME, loopHandler);
			showImg(_currentFrame);
		}

		/**
		 * 立即渲染并停止到frame
		 * @param frame
		 */
		public function gotoAndStop(frame:int):void
		{
			removeEventListener(Event.ENTER_FRAME, loopHandler);

			_currentFrame = frame;
			_currentFrame %= _frameNumber;
//			if (_currentFrame == 0)
//				_currentFrame = _frameNumber;
			showImg(_currentFrame);
			_isStoped = true;
		}

		/**
		 * 立即渲染并继续播放
		 * @param frame
		 */
		public function gotoAndPlay(frame:int):void
		{
			addEventListener(Event.ENTER_FRAME, loopHandler);

			_currentFrame = frame;
			_currentFrame %= _frameNumber;
//			if (_currentFrame == 0)
//				_currentFrame = _frameNumber;
			showImg(_currentFrame);
			_isStoped = false;
			_upTime = getTimer();
		}

		public function get currentFrame():int
		{
			return _currentFrame;
		}
		
		public function get totalFrames():int{
			return _frameNumber;
		}

		public function get currentAction():String
		{
			return _movieName;
		}

		public function set playComplete(value:Function):void
		{
			_actionPlayCompleteCallback = value;
		}

		protected function loopHandler(e:Event):void
		{
			if (_isStoped)
				return;

			var currentTime:int = getTimer();
			var cha:int = currentTime - _upTime;
			var speed:int = _frameArr[_currentFrame]
			if (cha >= speed)
			{
				var f:int = cha / speed;
				_upTime += f * speed;
				_play(f);
			}
		}

		protected function _play(addFrame:int):void
		{
			if (_currentFrame + addFrame >= _frameNumber)
			{
				_currentFrame = ((_currentFrame + addFrame) % _frameNumber);
//				if (_currentFrame == 0)
//					_currentFrame = _frameNumber;
				if (_actionPlayCompleteCallback != null)
				{
					showImg(_currentFrame);
					_actionPlayCompleteCallback();
					return;
				}
			}
			else
			{
				_currentFrame += addFrame;
			}
			if(_from >= 0 && _to >= _from){
				if(_currentFrame < _from && _currentFrame > _to)_currentFrame = _from;
			}
			showImg(_currentFrame);
		}

		protected function showImg(frame:int):void
		{
			var texture:Texture = _frames[frame];
//			if (texture)
//			{
				this.texture = texture;
				pivotX = -_footX;
				pivotY = -_footY;
//			}

		}

		public function setSize(valueX:Number, valueY:Number):void
		{
			if (width > 0 && height > 0)
			{
				var _w:Number = valueX / width;
				var _h:Number = valueY / height;
				scaleX = _w;
				scaleY = _h;
			}
		}
		
		public function get footPoint():Point{
			return new Point(_footX,_footY);
		}

		override public function dispose():void
		{
			removeEventListener(Event.ENTER_FRAME, loopHandler);
			super.dispose();
		}
		
	}
}