package potato.ui
{
	import core.display.Image;
	import core.display.Texture;
	import core.filters.Filter;
	
	import potato.res.Res;

	/**
	 * 位图显示对象
	 * <Bitmap id="aa" source="" exactHitTest="false" />
	 */
	public class Bitmap extends UIComponent
	{
		/**位图对象**/
		private var _img:Image;
		/**资源字符串**/
		private var _source:String;
		
		private var _exactHitTest:Boolean = false;
		
		public function Bitmap(src:String="")
		{
			_isContainer = false;
			if(src)
			{
				_source = src;
				_img = Res.getImage(src);
				addChild(_img);
				_img.filter = _filter;
			}
		}
		
		/**
		 * 设置资源字符串
		 */
		public function set source(value:String):void
		{
			_source = value;
		}
		
		/**
		 * 获取该对象资源字符串
		 */
		public function get source():String
		{
			return _source;
		}
		
		/**
		 * 设置是否开启精确点击
		 */
		public override function set exactHitTest(b:Boolean):void
		{
			if(_img)_img.exactHitTest = b;
			_exactHitTest = b;
		}
		
		public override function render():void
		{
			if(_source)
			{
				if(_img){
					removeChild(_img);
					_img = null;
				}
				_img = Res.getImage(_source);
				_img.exactHitTest = _exactHitTest;
				addChild(_img);
			}
		}
		/**
		 *得到当前显示对象的纹理 
		 * @return 
		 * 
		 */		
		public function get texture():Texture{
			
			if(_img)return _img.texture;
			else return null;
		}
		/**
		 *更换当前显示对象的纹理 
		 * @param value	Texture对象
		 * 
		 */		
		public function set texture(value:Texture):void{
			
			if(_img)_img.texture = value;
		}
		
		private var _filter:Filter;
		/**
		 *应用滤镜 
		 * @param value
		 * 
		 */		
		override public function set filter(value:Filter):void{
			
			if(_img)_img.filter = value;
			_filter = value;
		}
		override public function get filter():Filter{
			return _filter;
		}
		
		public function clearImg():void{
			
			if(_img){
				removeChild(_img);
				_img = null;
			}
		}
		
		/**
		 * 析构对象
		 */
		public override function dispose():void
		{
			if(_img)
			{
				removeChild(_img);
			}
			_img = null;
			_source = null;
			super.dispose();
		}
	}
}