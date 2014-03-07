package potato.display
{
	import core.display.Image;
	import core.display.Texture;
	
	import flash.geom.Rectangle;
	
	import potato.net.Download;
	import potato.res.ResBean;
	
	
	/**
	 * 异步加载的Image
	 * Jun 7, 2012
	 */
	public class AsyncImage extends Image
	{
		/**当前的bean对象*/
		public var bean:ResBean;
		/**是否已经加载*/
		private var _loaded:Boolean;
		
		public var rect1:Rectangle;
		
		public var rect2:Rectangle;
		
		public function AsyncImage(texture:Texture)
		{
			super(texture);
		}
		
		override public function get width():Number
		{
			if(rect2)
				return rect2.width;
			else if(rect1)
				return rect1.width;
			return super.width;
		}
		
		override public function get height():Number
		{
			if(rect2)
				return rect2.height;
			else if(rect1)
				return rect1.height;
			return super.height;
		}
		
		/**
		 * 加状态 
		 * @return 
		 */		
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		public function set loaded(value:Boolean):void
		{
			_loaded = value;
		}
		
		public function toString():String {
			return "AsyncImage[" + rect1 + "]";
		}
	}
}