package potato.movie.dragon
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	import core.display.DisplayObjectContainer;
	import core.display.Image;
	import core.events.Event;
	import core.filesystem.File;
	import core.filters.ColorMatrixFilter;
	
	import potato.logger.Logger;
	import potato.movie.FrameBean;
	import potato.movie.MovieAsset;
	import potato.movie.dragon.events.DragonEvent;
	import potato.res.Res;
	import potato.res.ResBean;
	
	/**
	 * 龙骨动画 
	 * @author floyd
	 */
	public class DragonMovie extends DisplayObjectContainer
	{
		/**
		 * 龙骨数据
		 */
		private var dragonData:Object;
		
		/**
		 * 动画名
		 */
		private var _movieName:String;
		
		private var _action:String;
		
		/**
		 * 当前动作帧数据数组
		 */
		private var fds:Array;
		
		/**
		 * 当前播放索引
		 */
		private var _currentFrame:int;
		
		/**
		 * 是否已经停止 
		 */		
		private var stoped:Boolean;

		/**
		 * 当前是否在播放 
		 */
		private var _isPlay:Boolean;
		
		/**
		 * 总工帧 
		 */
		private var _totalFrames:int;
		
		private static var _isRegistClass:Boolean = false;
		
		private static var log:Logger = Logger.getLog("DragonMovie");
		
		public function DragonMovie()
		{
			if(!_isRegistClass)
			{
				trace("注册龙骨类");
				_isRegistClass = true;
				registerClassAlias("data.FrameData", FrameData);
			}
			
		}
		
		public function set movieName(value:String):void
		{
			removeChildren();
			var bean:ResBean = Res.getResBean("dragon_data_" + value);
			if (bean)
			{
				if(File.exists(bean.path))
				{
					var bytes:ByteArray = File.readByteArray(bean.path);
					bytes.uncompress();
					dragonData = bytes.readObject();
				}
			}
			if (!dragonData)
			{
				log.error(value, "龙骨数据为空");
				return;
			}
			_movieName = value;
		}
		
		public function get movieName():String
		{
			return _movieName;
		}
		
		/**
		 * 播放影片 
		 * @param action action = null， 播放上一个影片  
		 */		
		public function play(action:String = null):void
		{
			if (!action)
			{
				action = _action;
			}
			fds = dragonData[action];
			if (!fds)
			{
				dispatchEvent(new Event("noAction"));
				log.error(action, "没有找到动作");
				trace(action, "没有找到动作");
				return;
			}
			
			_action = action;
			_totalFrames = fds.length-1;
			_currentFrame = 0;
			_isPlay = true;
			showImg(_currentFrame);
			if(_totalFrames!=1)
				addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function showImg(frame:int):void
		{
			if(!fds ||fds.length<frame)
			{
				trace("动作为空",frame);
			}
			var arr:Array = fds[frame];
			var tempName:Array = [];
			var tempImage:Array = [];
			var update:Boolean = false;
			if(arr.length != numChildren)
			{
				update = true;
			}
			for (var i:int = 0,l:int = arr.length; i < l; i++) 
			{
				var fd:FrameData = arr[i];
				var img:Image;
				if(cacheName[i] == fd.texName && !update)
				{
					img = cacheImage[i];
				}
				else
				{
					if(cacheImage[i])
						removeChildAt(i);
					img = Res.getImage(fd.texName);
					addChildAt(img, i);
				}
				
				tempName[i] = fd.texName;
				tempImage[i] = img;
				
				img.x = fd.x;
				img.y = fd.y;
				img.scaleX = fd.scaleX;
				img.scaleY = fd.scaleY;
				img.rotation = fd.rotation;
				img.pivotX = fd.px;
				img.pivotY = fd.py;
				if(fd.changeTransframe)
				{
					if(fd.transframe == null)
						img.filter = null;
					else
						img.filter = new ColorMatrixFilter(fd.transframe);
				}
			}
			cacheName = tempName;
			cacheImage = tempImage;
			removeChildren(i);
		}
		
		public function stop():void
		{
			removeEventListener(Event.ENTER_FRAME, loop);
			_isPlay = false;
		}
		
		public function gotoAndStop(frame:int):void
		{
			removeEventListener(Event.ENTER_FRAME, loop);
			_isPlay = false;
			if (fds)
			{
				_currentFrame = frame;
				_currentFrame %= _totalFrames;
				showImg(_currentFrame);
			}
		}
		
		public function gotoAndPlay(frame:int):void
		{
			addEventListener(Event.ENTER_FRAME, loop);
			_isPlay = true;
			if (fds)
			{
				_currentFrame = frame;
				_currentFrame %= _totalFrames;
				showImg(_currentFrame);
			}
		}

		
		private var color:ColorMatrixFilter;
		
		private var cacheName:Array = [];
		private var cacheImage:Array = [];
		private function loop(e:Event):void
		{
			if(fds && _isPlay)
			{
				nextFrame();
			}
		}
		
		public function nextFrame():void
		{
			_currentFrame ++;
			if(_currentFrame>_totalFrames)
			{
				dispatchEvent(new DragonEvent(DragonEvent.ACTION_COMPLETE, _action));
				_currentFrame%=_totalFrames;
			}
			showImg(_currentFrame);
		}
		
		private function removeChildren(startIndex:int = 0):void
		{
			cacheImage.splice(startIndex, numChildren - startIndex);
			cacheName.splice(startIndex, numChildren - startIndex);
			
			for (var i:int = 0, l:int = numChildren - startIndex; i < l; i++)
			{
				removeChildAt(startIndex);
			}
		}
		
		override public function dispose():void
		{
			fds = null;
			cacheName = null;
			cacheImage = null;
			dragonData = null;
			removeEventListeners();
			stop();
			super.dispose();
		}

		/**
		 * 总共帧 
		 */
		public function get total():int
		{
			return _totalFrames;
		}

		/**
		 * 当前帧 
		 */
		public function get curIndex():int
		{
			return _currentFrame;
		}

		/**
		 * 当前播放动作
		 */
		public function get action():String
		{
			return _action;
		}
	}
}