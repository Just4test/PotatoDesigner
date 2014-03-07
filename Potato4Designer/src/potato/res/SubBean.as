package potato.res
{
	import flash.geom.Rectangle;

	/**
	 * 子纹理配置 
	 */	
	public class SubBean
	{
		/**SubTexture构造方法 第一个显示区域——表示当前要截取的显示区域*/
		public var rect1:Rectangle;
		/**SubTexture构造方法 第二个显示区域——表示当前图片切掉透明区域之前的实际大小*/
		public var rect2:Rectangle;
		/**当前对象在哪个父材质里面 ResBean.id*/
		public var parent:String;
		
		
		public var x1:int;
		public var y1:int;
		public var w1:int;
		public var h1:int;
		
		public var x2:int;
		public var y2:int;
		public var w2:int;
		public var h2:int;
		
		public var parentBean:ResBean;
		//////////没有在配置文件中/////////
		public var name:String;
		public function SubBean()
		{
		}
		
		public function toString():String {
			return "SubBean[" + rect1 + "," + parent + "]";
				
		}
	}
}