package UIAdjuster
{
	import flash.geom.Point;
	
	import core.display.DisplayObject;

	/**
	 * 单个编辑对象的操作记录 
	 * @author sheep
	 * 
	 */
	public class UIAdjusterItemLog
	{
		/**
		 *  操作步骤
		 */
		protected var operPoint:Vector.<Point> = new Vector.<Point>;
		/**
		 * 当前所在的操作索引 
		 */
		protected var curIndex:int;
		public function UIAdjusterItemLog()
		{
		}
		
		/**
		 * 添加对象坐标 到记录中 + 当前索引到最后
		 * @param p
		 * 
		 */
		public function pushOperPont(res:DisplayObject):Boolean{
			if(operPoint.length != 0){
				// 相同取消
				if(operPoint[operPoint.length-1].equals(new Point(res.x,res.y))){
					return false;
				}
			}
			operPoint.push(new Point(res.x,res.y));
			curIndex = operPoint.length-1;
			return true;
		}
		
		/**
		 * 取当前索引 对应的坐标
		 * @param step 增量
		 * @return 
		 * 
		 */
		public function goOperPoint(step:int):Point{
			var p:Point;
			var goIndex:int = curIndex + step;
			if(goIndex<0){
				p = operPoint[0];
				curIndex = 0;
			}
			else if(goIndex>operPoint.length-1){
				p = operPoint[operPoint.length-1];
				curIndex = operPoint.length-1;
			}
			else{
				p = operPoint[goIndex];
				curIndex = goIndex;
			}
			return p
		}
		
		/**
		 * 清除操作记录,保留第一条的原始点
		 * @return 
		 * 
		 */
		public function clear():Point{
			operPoint.length = 1;
			return operPoint[0];
		}
	}
}