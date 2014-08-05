package potato.ui.drag
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import core.display.DisplayObject;
	import core.display.Stage;
	
	import potato.logger.Logger;
	import potato.search.RectObject;
	import potato.search.RectSearch;
	
	/**
	 * 热区
	 */
	public class HotZone implements RectObject
	{
		private static var log:Logger = Logger.getLog("HotZone");
		
		private static var hots:Vector.<HotZone> = new Vector.<HotZone>();

		private var dis:DisplayObject;

		public static var tools:RectSearch = new RectSearch(100, Stage.getStage().stageWidth, Stage.getStage().stageHeight);
		
		
		private static var scaleX:Dictionary = new Dictionary();
		
		private static var scaleY:Dictionary = new Dictionary();
		
		public function HotZone()
		{
			hots.push(this);
		}

		public function create(dis:DisplayObject, scaleX:Number = 1, scaleY:Number = 1):void
		{
			if(!this.dis)
			{
				this.dis = dis;
				HotZone.scaleX[dis] = scaleX;
				HotZone.scaleY[dis] = scaleY;
				tools.append(this, scaleX, scaleY);
			}
		}

		public function getDisplayObject():DisplayObject
		{
			return dis;
		}

		public function get width():Number
		{
			return dis.width;
		}

		public function get height():Number
		{
			return dis.height;
		}
		
		private var _point:Point;
		
		public function get point():Point
		{
			if (!_point)
				_point = dis.localToGlobal(new Point(0, 0));
//				_point = Utils.getGlobalPoint(dis);
			return _point;
		}
		
		public function update():void
		{
			_point = dis.localToGlobal(new Point(0, 0));
//			_point = Utils.getGlobalPoint(dis);
//			log.debug("全局坐标", dis["name_1"], _point.x, _point.y);
		}

		public function clean():void
		{
			var index:int = hots.indexOf(this);
			if (index != -1)
				hots.splice(index, 1);
			delete scaleX[dis];
			delete scaleY[dis];
			dis = null;
			tools.remove(this);
		}

		/**
		 *
		 * @param px 舞台上的坐标
		 * @param py 舞台上的坐标
		 * @return
		 */
		public static function getOverHot(px:int, py:int):HotZone
		{
			var arr:Array = tools.find(px,py,1,1);
			for (var i:int = 0; i < arr.length; i++) 
			{
				var hot:HotZone = arr[i];
				var p:Point = hot.point;
				if (p)
					if (p.x < px && p.x + hot.width * HotZone.scaleX[hot.dis] > px)//判断x坐标是否在hots[i]对象内部
						if (p.y < py && p.y + hot.height * HotZone.scaleY[hot.dis] > py)//判断y坐标是否在hots[i]对象内部
//							h.push(hots[i]);//加入通过列表
							return hot;
			}
			
			return null;
//			
//				var t:Number = System.getNanosecondTimer();
//				var h:Array = [];//简单判断通过对象
//				for (var i:int = 0; i < hots.length; i++)//先简单进行筛选
//				{
//					var p:Point = hots[i].dis.localToGlobal(new Point(0, 0)); //Utils.getGlobalPoint(hots[i].dis);
//					if (p)
//						if (p.x < px && p.x + hots[i].width > px)//判断x坐标是否在hots[i]对象内部
//							if (p.y < py && p.y + hots[i].height > py)//判断y坐标是否在hots[i]对象内部
//	//							h.push(hots[i]);//加入通过列表
//								return hots[i];
//				}
//				log.debug("getOverHotTime", (System.getNanosecondTimer() - t ) / 1000000);
//				return null;
//
//			for (var j:int = 0; j < h.length; j++)//判断这些通过的对象是否可见（包含clipRect、visible）
//			{
//				if (!Utils.isSee(h[j].dis))
//				{
//					h.splice(j, 1);
//					j--;
//				}
//			}
//
//			if (h.length > 1)
//			{
//				for (var k:int = 0; k < h.length - 1; )
//				{
//					var one:HotZone = h[k];
//					var two:HotZone = h[k + 1];
//					var o:Boolean = Utils.getDisplayIndex(h[k].getDisplayObject(), h[k + 1].getDisplayObject());
//					if (o)
//						h.splice(k, 2, one);
//					else
//						h.splice(k, 2, two);
//				}
//			}
//			return h[0];
		}
	}
}