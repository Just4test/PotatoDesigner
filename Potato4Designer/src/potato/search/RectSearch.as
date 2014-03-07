package potato.search
{
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/**
	 * 快速的矩形区域搜索 
	 * @author floyd
	 */
	public class RectSearch
	{
		/**
		 * 当前矩形数组 
		 */
		private var rect:Array;
		
		private var gw:int;
		
		private var gh:int;
		
		private var items:Dictionary;
		
		private var _width:int;
		
		private var _maxW:int;
		
		private var _maxH:int;
		
		private var scaleX:Dictionary;
		
		private var scaleY:Dictionary;
		/**
		 * 构造一个对象 
		 * @param width		最小查询范围——值越小越查询越，反而性能越低。
		 * @param maxWidth	最大范围
		 * @param maxHeight	最大范围
		 */
		public function RectSearch(width:int, maxWidth:int, maxHeight:int)
		{
			scaleX = new Dictionary();
			scaleY = new Dictionary();
			
			_width = width;
			_maxW = maxWidth;
			_maxH = maxHeight;
			gw = Math.ceil(maxWidth / width);
			gh = Math.ceil(maxHeight / width);
			
			rect = [];
			for (var i:int = 0; i < gh; i++) 
			{
				rect[i] = [];
				for (var j:int = 0; j < gw;j++) 
				{
					rect[i][j] = [];
				}
			}
			
			items = new Dictionary(true);
		}
		
		/**
		 * 添加一个对象到集合 
		 * @param obj
		 */
		public function append(obj:RectObject, scaleX:Number = 1, scaleY:Number = 1):void
		{
			var p:Point = obj.point;
			this.scaleX[obj] = scaleX;
			this.scaleY[obj] = scaleY;
			if (p.x > _maxW || p.y > _maxH) 
			{
				items[obj] = false;
				return;
			}
			_update(obj);
		}
		
		/**
		 * 从集合里面移除一个对象 
		 * @param obj
		 */
		public function remove(obj:RectObject):void
		{
			del(obj);
			delete scaleX[obj];
			delete scaleY[obj];
			delete items[obj];
		}
		
		/**
		 * 查询对象 
		 * @param x	x坐标
		 * @param y	x坐标
		 * @param w	x坐标
		 * @param h	x坐标
		 * @return 当前区域内的所有对象
		 */
		public function find(x:int,y:int,w:int,h:int):Array
		{
			var xx:int = (x / _width);
			var yy:int = (y / _width);
			var ww:int = Math.ceil(w / _width);
			var hh:int = Math.ceil(h / _width);
			
			var arr:Array = [];
			
			for (var i:int = yy; i < yy + hh && i < gh; i++) 
			{
				for (var j:int = xx; j < xx + ww && j < gw; j++) 
				{
					var objs:Array = rect[i][j];
					for (var k:int = 0; k < objs.length; k++) 
					{
						arr.push(objs[k]);
					}
				}
			}
			
			return arr;
		}
		
		/**
		 * 当坐标发生改变后执行全部更新 
		 */
		public function update():void
		{
			for (var obj:* in items) 
			{
				_update(obj);
			}
		}
		
		
		private function _update(obj:RectObject):void
		{
			del(obj);
			obj.update();
			var p:Point = obj.point;
			var xx:int = p.x / _width;
			var yy:int = p.y / _width;
			var ww:int = (obj.width * scaleX[obj] + (p.x % _width)) / _width + 1;
			var hh:int = (obj.height * scaleY[obj] + (p.y % _width)) / _width + 1;
			
			var index:Array = [];
			for (var i:int = yy; i < yy + hh && i < gh && i > -1; i++) 
			{
				for (var j:int = xx; j < xx + ww && j < gw && j > -1; j++) 
				{
					index.push(i); 
					index.push(j);
					rect[i][j].push(obj);
				}
			}
			items[obj] = index;
		}
		
		private function del(obj:RectObject):void
		{
			if(items[obj])
			{
				var index:Array = items[obj];
				for (var i:int = 0; i < index.length; i += 2) 
				{
					var objs:Array = rect[index[i]][index[i+1]];
					var delIndex:int = objs.indexOf(obj);
					if(delIndex != -1)
						objs.splice(delIndex, 1);
				}
			}
		}
		
	}
}