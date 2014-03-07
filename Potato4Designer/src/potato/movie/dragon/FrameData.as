package potato.movie.dragon
{
	public class FrameData
	{
		public function FrameData()
		{
		}
		
		public var x:Number;
		public var y:Number;
		public var scaleX:Number;
		public var scaleY:Number;
		public var rotation:Number;
		
		public var px:Number;
		public var py:Number;
		
		public var transframe:Vector.<Number>;
		
		public var changeTransframe:Boolean;
		
		public var texName:String;
		
		public function toString():String {
			return "FrameData: " + x + ","+ y + ","+ scaleX + ","+ scaleY + ","+ rotation + ","+ texName;
		}
	}
}