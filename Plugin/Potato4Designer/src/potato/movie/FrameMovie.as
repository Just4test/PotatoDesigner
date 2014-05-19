package potato.movie
{
	import core.display.Image;
	import core.display.Texture;
	import core.events.Event;
	
	import potato.res.Res;
	
	public class FrameMovie extends Image
	{
		private var _movieName:String;
		
		private var textures:Array = [];
		
		private var frames:Array;
		
		private var _currentFrame:uint;
		/**
		 * 当前是否在播放 
		 */
		private var _isPlay:Boolean;
		
		/**
		 * 当前播放索引
		 */
		private var index:int = 1;
		private var _actionPlayCompleteCallback:Function;
		
		public function FrameMovie()
		{
			super(null);
		}
		
		public function get movieName():String
		{
			return _movieName;
		}

		public function set movieName(value:String):void
		{
			frames = MovieAsset.getFrameMovieConfig(value);
			textures.length = 0;
			if(frames.length==0)
			{
				dispatchEvent(new Event("noAction"));
			}
			for (var i:int = 1, l:int = frames.length; i < l; i++) 
			{
				var bean:FrameBean = frames[i];
				if(bean.texName)
				{
					textures[i] = Res.getTexture(bean.texName);
				}
			}
			
			_movieName = value;
		}

		public function play():void
		{
			isPlay = true;
		}
		
		private function set isPlay(value:Boolean):void
		{
			if(value)
			{
				if (!_isPlay)
				{
					addEventListener(Event.ENTER_FRAME, loop);
				}
			}
			else
			{
				if (_isPlay)
				{
					removeEventListener(Event.ENTER_FRAME, loop);
				}
			}
			_isPlay = value;
		}
		
		private function loop(e:Event):void
		{
			if(index < frames.length)
			{
				var t:Texture = textures[index];
				texture = t;
				var fd:FrameBean = frames[index];
				pivotX = fd.px;
				pivotY = fd.py;
				index ++;
			}else
			{
				if(null != _actionPlayCompleteCallback)
				{
					_actionPlayCompleteCallback();
				}
			}
		}
		
		public function set playComplete(value:Function):void
		{
			_actionPlayCompleteCallback = value;
		}
		
		public function stop():void
		{
			isPlay = false;
		}
		public function gotoAndStop(frame:uint):void
		{
			setIndex(frame);
			loop(null);
			isPlay = false;
		}
		
		public function gotoAndPlay(frame:int):void
		{
			setIndex(frame);
			isPlay = true;
		}

		private function setIndex(frame:int):void
		{
			if(frame<1)
			{
				index =1;
			}else if(frame>frames.length-1)
			{
				index = frames.length-1;
			}else
			{
				index = frame;
			}
		}
		public function get currentFrame():uint
		{
			return index;
		}

		public function get totalFrames():int{
			return frames.length;
		}
		
		public function get currentAction():String
		{
			return _movieName;
		}
		
		override public function dispose():void
		{
			super.dispose();
			removeEventListeners();
			textures = null;
			frames = null;
			_actionPlayCompleteCallback = null;
		}
	}
}