package potato.ui
{
	import core.display.Image;
	
	import potato.res.Res;
	
	/**
	 * Image序列，是在MXW项目的开放过程中应用而生；
	 * 注意：该类继承Image。。。（轻量级） 
	 * 
	 * @author	zw
	 * @createTime	2013-02-19
	 * 
	 */
	public class ImageSequence extends Image
	{
		
		/**
		 *自定义 ，尽量用该变量来保存简单数据类型。
		 * 比如可以保存id，name等
		 */
		public var customObject:Object;
		
		protected var _textureSequence:Array;
		protected var _currentTextureIndex:uint=0;
		
		public function set textureSequence(value:Array):void
		{
			_textureSequence = value;
		}
		
		public function get textureSequence():Array{
			return _textureSequence;
		}

		/**
		 *[read-only] 当前材质id 。
		 * @return 
		 * 
		 */
		public function get currentTextureId():String{
			return _textureSequence[_currentTextureIndex];
		}
		
		/**
		 *[read-only] 当前材质在材质序列中的index 。
		 * @return 
		 * 
		 */
		public function get currentTextureIndex():uint{
			return _currentTextureIndex;
		}
		
		/**
		 *[read-only] 实例中材质的总数。 
		 * @return 
		 * 
		 */
		public function get totalTextures():int{
			return _textureSequence.length;
		}
		
		/**
		 *只是对MovieClip的精简模拟；
		 * 当显示具体的某一帧的时候，其他帧中的材质将被清除，不保留缓存；
		 * 注意：该类继承Image（轻量级）  ,不能添加子对象，只显示材质；
		 * 
		 * @param	textureArr	传入初始化时候的材质id，e.g.'ty_btn_0','by_btn_1',...
		 * 材质一旦构造输入，就不能更改；（暂行）
		 * 
		 */
		public function ImageSequence(textureArr:Array = null)
		{
			_textureSequence=textureArr;
			
			//构造函数里面不显示材质；
			super(null);
		}
		
		/**
		 *转向材质 ，注意：第一张材质index=0；
		 * 如果没有传入任何材质序列，那么直接返回；
		 * 如果传入的数据大于材质序列长度，那么显示最后一张材质；
		 * 如果传入的数据小于材质序列长度，那么显示第一张材质；
		 * @param frame	材质在材质序列中的index
		 * 
		 */
		public function showTextureAt(index:int):void{
			if(_textureSequence==null)return;
			_currentTextureIndex=index>=totalTextures?totalTextures-1:index<0?0:index;
			texture=Res.getTexture(_textureSequence[_currentTextureIndex]);
		}
		
		/**
		 *显示下一张材质，如果当前已经是最后一张，那么将没有变化； 
		 * 
		 */
		public function nextTexture():void{
			showTextureAt(_currentTextureIndex+1);
		}

		/**
		 *显示上一张材质，如果当前已经是第一张材质，那么将没有变化； 
		 * 
		 */
		public function prevTexture():void{
			showTextureAt(_currentTextureIndex-1);
		}
		
		override public function dispose():void{
			_textureSequence=null;
			super.dispose();
		}

	}
}