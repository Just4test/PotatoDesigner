package potato.ui
{
	import flash.geom.Rectangle;
	
	import core.display.Grid9Texture;
	import core.display.Image;
	import core.display.Texture;
	
	import potato.res.Res;
	
	/**
	 * 九宫格
	 * <Grid9 id="" source="" width="400" height="400"/>
	 */
	public class Grid9 extends UIComponent
	{
		private var _img:Image;
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var _oldWidth:Number = 0;
		private var _oldHeight:Number = 0;
		private var _cutRect:Rectangle;
		private var _texture:Texture;
		
		/**背景资源字符串**/
		private var _source:String;
		/**
		 * 缩放 的 Image对象  内 图片的四角花纹(默认状态) 宽高 不得 大于 原图片 宽高的 1/3
		 * @param	img	缩放image对象
		 * @param	cutRect	九切片 第五格 切片矩阵（x,y,width,height）
		 */
		public function Grid9(img:Image=null,cutRect:Rectangle = null)
		{
			_isContainer = false;
			
			if (!img) return;
			if(!img.texture)return;
			_cutRect = cutRect;
			_texture = img.texture;
			
			init();
		}
		
		/**
		 * 设置图片材质
		 */
		public function set texture(value:Texture):void {
			
			if (!value) return;
			clean();
			_texture = value;
			init();
		}
		
		/**
		 * 获取图片材质
		 */
		public function get texture():Texture {
			return _texture;
		}
		
		private var _rectX:Number = 0;
		private var _rectY:Number = 0;
		private var _rectW:Number = 0;
		private var _rectH:Number = 0; 
		private function init():void {
			
			_width = _texture.width;
			_height = _texture.height;
			_img = new Image(_texture);
			addChild(_img);
			if (_cutRect != null) {
				
				_rectX = _cutRect.x;
				_rectY = _cutRect.y;
				_rectW = _cutRect.width;
				_rectH = _cutRect.height;
			}else {
				
				_rectX = Math.floor(_width / 3);
				_rectW = _rectX;
				_rectY = Math.floor(_height / 3);
				_rectH = _rectY;
			}
			
			if (((_oldWidth > 0 && _oldHeight > 0) && (_oldWidth != _width || _oldHeight != _height))) setSize(_oldWidth, _oldHeight);
		}
		
		/**
		 * 设定 九宫格 的 宽高
		 * @param	valueW  宽度
		 * @param	valueH 高度
		 */
		public function setSize(valueW:Number, valueH:Number):void {
			
			_oldWidth = valueW;
			_oldHeight = valueH;
			if (!_texture) return;
			
			_img.texture = new Grid9Texture(_texture,new Rectangle(_rectX,_rectY,_rectW,_rectH),_oldWidth,_oldHeight);
		}
		

		
		/**
		 * 得到当前九宫格的 宽度
		 */
		override public function get width():Number 
		{
			return _oldWidth;
		}
		/**
		 * 得到当前九宫格的 高度
		 */
		override public function get height():Number 
		{
			return _oldHeight;
		}
		
		private function clean():void {
			
			while (numChildren > 0) {
				
				removeChildAt(0);
			}
			_img = null;
			_texture = null;
		}
		
		/**
		 * 设置九宫格背景
		 */
		public function set source(value:String):void
		{
			_source = value;
		}
		
		public override function render():void
		{
			if(_source)
			{
				_texture = Res.getTexture(_source);
				init();
			}
		}
	}
}