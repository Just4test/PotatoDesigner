package potato.ui
{
	import core.display.Image;
	import core.events.Event;
	
	import potato.res.Res;
	import potato.utils.Size;

	/**
	 * 3宫格实现，默认为横向
	 * <Grid3 id="aa" source1="" source2="" source3="" height="100" isVertical="true"/>
	 */
	public class Grid3 extends UIComponent
	{
		private var _isVertical:Boolean = false;	//是否是纵向
		
		private var img1:Image;
		private var img2:Image;
		private var img3:Image;
		
//		private var img1Size:Size;
		private var img2Size:Size;
//		private var img3Size:Size;
		
		private var pw:Number = 0;
		private var ph:Number = 0;
		
		/**XML配置图片资源**/
		private var _src1:String;
		private var _src2:String;
		private var _src3:String;
		
		public function Grid3(_img1:String=null, _img2:String=null, _img3:String=null, isVertical:Boolean=false)
		{
			_isContainer = false;
			
			if(!_img1 && !_img2 && !_img3)return;
			if(_img1 && _img2 && _img3)
			{
				img1 = Res.getImage(_img1);
				img2 = Res.getImage(_img2);
				img3 = Res.getImage(_img3);
				this.isVertical = isVertical;
				
				img2Size = new Size(img2.width, img2.height);
				
				if (_isVertical) {
					addChild(img1);
					img2.y = img1.height;
					addChild(img2);
					img3.y = img1.height + img2.height;
					addChild(img3);
				} else {
					addChild(img1);
					img2.x = img1.width;
					addChild(img2);
					img3.x = img1.width + img2.width;
					addChild(img3);
				}
			}else
			{
				throw new Event("parms error");
			}
		}
		
		/**
		 * 设置总体宽度，只在横向时有效
		 * @param w
		 */		
		public function setWidth(w:int):void {
			if (!_isVertical) {
				img2.scaleX = (w - img1.width - img3.width) / img2Size.width;
				img3.x = img1.width + Math.floor(img2.width);
				pw = w;
			}
		}
		
		/**
		 * 设置总体高度，只在纵向时有效
		 * @param h
		 */		
		public function setHeight(h:int):void {
			if (_isVertical) {
				img2.scaleY = (h - img1.height - img3.height) / img2Size.height;
				img3.y = img1.height + Math.floor(img2.height);
				ph = h;
			}
		}
		
		override public function get width():Number {
			if (_isVertical) {
				return img1.width;
			} else {
				return pw;
			}
		}
		
		override public function get height():Number {
			if (!_isVertical) {
				return img1.height;
			} else {
				return ph;
			}
		}
		
		/**
		 * img1图片资源
		 */
		public function set source1(value:String):void
		{
			_src1 = value;
		}
		
		/**
		 * img2图片资源
		 */
		public function set source2(value:String):void
		{
			_src2 = value;
		}
		
		/**
		 * img3图片资源
		 */
		public function set source3(value:String):void
		{
			_src3 = value;
		}
		
		/**
		 * 横纵向平铺
		 */
		public function set isVertical(b:Boolean):void
		{
			_isVertical = b;
		}
		
		public override function render():void
		{
			if(_src1 && _src2 && _src3)
			{
				img1 = Res.getImage(_src1);
				img2 = Res.getImage(_src2);
				img3 = Res.getImage(_src3);
				
				img2Size = new Size(img2.width, img2.height);
				
				if (_isVertical) {
					addChild(img1);
					img2.y = img1.height;
					addChild(img2);
					img3.y = img1.height + img2.height;
					addChild(img3);
				} else {
					addChild(img1);
					img2.x = img1.width;
					addChild(img2);
					img3.x = img1.width + img2.width;
					addChild(img3);
				}
				
				if(expectWidth > 0 && _isVertical)
				{
					setWidth(expectWidth);
				}
				
				if(expectHeight > 0 && !_isVertical)
				{
					setHeight(expectHeight);
				}
			}else
			{
				throw new Event("parms error");
			}
		}
		
		/**
		 * 析构资源
		 */
		public override function dispose():void
		{
			img1 = null;
			img2 = null;
			img3 = null;
			img2Size = null;
			super.dispose();
		}
	}
}