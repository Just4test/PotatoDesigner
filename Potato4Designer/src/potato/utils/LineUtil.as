package potato.utils
{
	import flash.geom.Point;

	public class LineUtil
	{
		public function LineUtil()
		{
		}
		
		/**
		 * 贝塞尔曲线 
		 * @param t			0-1的数（当前百分比）
		 * @param points	锚点
		 * @return 			当前坐标
		 */
		public static function bezierCurves(t:Number, points:Array):Point
		{
			var x:Number = 0;
			var y:Number = 0;
			var n:uint = points.length-1;
			var factn:Number = factoral(n);
			for (var i:uint=0;i<=n;i++)
			{
				var b:Number = factn/(factoral(i)*factoral(n-i));
				var k:Number = Math.pow(1-t, n-i)*Math.pow(t, i);
				x += b*k*points[i].x;
				y += b*k*points[i].y;
			}
			return new Point(x, y);
		}
		
		private static function factoral(value:uint):Number
		{
			if (value==0)
				return 1;
			var total:Number = value;
			while (--value>1)
				total *= value;
			return total;
		}
		
		
		
		
		
	}
}