/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 12-12-10
 * Time: 下午4:07
 * To change this template use File | Settings | File Templates.
 */
package potato.display
{
import flash.geom.Point;
import flash.geom.Rectangle;

import core.display.Image;
import core.display.SubTexture;
import core.display.SuperTexture;
import core.display.Texture;

import potato.logger.Logger;
import potato.utils.Vertex;

/**
 * 砖块拼接图像
 */
public class TiledImage extends Image
{
	// 原来的父材质
	private var _parentTexture:Texture;

	// 超级材质，性能提升的关键
	private var _superTexture:SuperTexture;

	// 超级材质的宽和高
	private var _w:int;
	private var _h:int;

	// 顶点数组（在调用 commit 函数前，顶点数组可以一直添加有效顶点）
	private var _vertexes:Array;
	// 顶点的总数
	private var _vertexCount:int;

	// 顶点索引数组（在调用 commit 函数前，顶点索引数组可以一直添加有效索引）
	private var _indexes:Array;
	// 索引的总数
	private var _indexCount:int;
	// 当前索引值
	private var _index:int;

	// 顶点数据实体的查询字典，Key = Vertex.toString，Value = Index(int)
	private var _vertexDic:Object;

	private var _logger:Logger;

	// 可重用的四个顶点对象
	private var _vertex0:Vertex;
	private var _vertex1:Vertex;
	private var _vertex2:Vertex;
	private var _vertex3:Vertex;

	/**
	 * 构造一个指定父材质和宽、高的砖块拼接图像
	 * @param parentTexture			父材质。必须为根材质，不能是子材质
	 * @param w						拼接图像的宽度
	 * @param h						拼接图像的高度
	 */
	public function TiledImage(parentTexture:Texture, w:int, h:int):void
	{
		super(null);

		if (w <= 0 || h <= 0 || w > 2048 || h > 2048)
			throw new Error('指定的砖块拼接图宽度和高度应当都为正数值，同时还应当小于 2048');

		_w = w;
		_h = h;

//		_logger = Logger.getLog('TiledImage');

		_vertex0 = new Vertex(0, 0, 0, 0);
		_vertex1 = new Vertex(0, 0, 0, 0);
		_vertex2 = new Vertex(0, 0, 0, 0);
		_vertex3 = new Vertex(0, 0, 0, 0);

		this.parentTexture = parentTexture;
	}

	/**
	 * 指定父材质
	 * @param value				父材质，必须为根材质，不能是子材质
	 */
	public function set parentTexture(value:Texture):void
	{
		if (value is SubTexture || value is SuperTexture)
			throw new Error('不允许使用子级材质来派生出砖块拼接图像！');

		_parentTexture = value;

		_superTexture = new SuperTexture(value);
		_superTexture.setSize(_w, _h);

		this.texture = _superTexture;

		_vertexes = [];
		_vertexCount = 0;

		_indexes = [];
		_indexCount = 0;
		_index = 0;

		_vertexDic = {};
	}

	/**
	 * 从父材质复制一个矩形内的像素到当前实例的目标位置上。
	 * 注：该方法的效果有点象 flash 开发中的 BitmapData.copyPixels
	 *
	 * @param sourceRect		复制源矩形数据
	 * @param destPoint			数据将覆盖的目标位置
	 */
	public function copyRect(sourceRect:Rectangle, destPoint:Point):void
	{
		copyRectByScala(sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height, destPoint.x, destPoint.y);
//		var begin:int = getTimer();
//		
//		var last:int = begin;
		
		/*// StartX and StartY
		const sx:Number = sourceRect.x;
		const sy:Number = sourceRect.y;
		// EndX and EndY
		const ex:Number = sourceRect.x + sourceRect.width;
		const ey:Number = sourceRect.y + sourceRect.height;
		// SourceWidth and SourceHeight
		const sw:Number = sourceRect.width;
		const sh:Number = sourceRect.height;
		// DestX and DestY
		const dx:Number = destPoint.x;
		const dy:Number = destPoint.y;
		
//		var now:int = getTimer();
		
//		_logger.debug('1st', String(now - last));
		
//		last = getTimer();

		// 构造本次四边形涉及到的四个顶点
		_vertex0.x = dx;
		_vertex0.y = dy;
		_vertex0.textureX = sx;
		_vertex0.textureY = sy;

		_vertex1.x = dx + sw;
		_vertex1.y = dy;
		_vertex1.textureX = ex;
		_vertex1.textureY = sy;

		_vertex2.x = dx;
		_vertex2.y = dy + sh;
		_vertex2.textureX = sx;
		_vertex2.textureY = ey;

		_vertex3.x = dx + sw;
		_vertex3.y = dy + sh;
		_vertex3.textureX = ex;
		_vertex3.textureY = ey;
		
//		now = getTimer();
//		
//		_logger.debug('2nd', String(now - last));
//		
//		last = getTimer();

		// 加入顶点
		var key0:String = pushVertexAndGetKey(_vertex0);
		var key1:String = pushVertexAndGetKey(_vertex1);
		var key2:String = pushVertexAndGetKey(_vertex2);
		var key3:String = pushVertexAndGetKey(_vertex3);
//		var index0:int = pushVertexAndGetIndex(dx, dy, sx, sy);
//		var index1:int = pushVertexAndGetIndex(dx + sw, dy, ex, sy);
//		var index2:int = pushVertexAndGetIndex(dx, dy+sh, sx, ey);
//		var index3:int = pushVertexAndGetIndex(dx+sw, dy+sh, ex, ey);
		
//		now = getTimer();
//		
//		_logger.debug('3rd', String(now - last));
//		
//		last = getTimer();

		// 两个三角形顶点声明
//		_indexes[_indexCount] = getIndexOfVertex(key0);
//		_indexes[_indexCount + 1] = getIndexOfVertex(key1);
//		_indexes[_indexCount + 2] = getIndexOfVertex(key2);
//		_indexes[_indexCount + 3] = getIndexOfVertex(key1);
//		_indexes[_indexCount + 4] = getIndexOfVertex(key3);
//		_indexes[_indexCount + 5] = getIndexOfVertex(key2);
		
		_indexes[_indexCount] = _vertexDic[key0];
		_indexes[_indexCount + 1] = _vertexDic[key1];
		_indexes[_indexCount + 2] = _vertexDic[key2];
		_indexes[_indexCount + 3] = _vertexDic[key1];
		_indexes[_indexCount + 4] = _vertexDic[key3];
		_indexes[_indexCount + 5] = _vertexDic[key2];
		
//		_indexes[_indexCount] = index0;
//		_indexes[_indexCount + 1] = index1;
//		_indexes[_indexCount + 2] = index2;
//		_indexes[_indexCount + 3] = index1;
//		_indexes[_indexCount + 4] = index3;
//		_indexes[_indexCount + 5] = index2;

		_indexCount += 6;
		
//		now = getTimer();
//		
//		_logger.debug('4th:', String(now - last));
//		
//		_logger.debug('total', String(now - begin));*/
	}

	public function copyRectByScala(sourceX:int, sourceY:int, sourceW:int, sourceH:int, destX:int, destY:int):void
	{
		var endX:int = sourceX + sourceW;
		var endY:int = sourceY + sourceH;

		var destRight:int = destX + sourceW;
		var destBottom:int = destY + sourceH;

		// 加入顶点
//		var key0:String = pushVertexAndGetKey(_vertex0);
//		var key1:String = pushVertexAndGetKey(_vertex1);
//		var key2:String = pushVertexAndGetKey(_vertex2);
//		var key3:String = pushVertexAndGetKey(_vertex3);
		var index0:int = pushVertexScalaAndGetIndex(destX, destY, sourceX, sourceY);
		var index1:int = pushVertexScalaAndGetIndex(destRight, destY, endX, sourceY);
		var index2:int = pushVertexScalaAndGetIndex(destX, destBottom, sourceX, endY);
		var index3:int = pushVertexScalaAndGetIndex(destRight, destBottom, endX, endY);

//		_indexes[_indexCount] = _vertexDic[index0];
//		_indexes[_indexCount + 1] = _vertexDic[index1];
//		_indexes[_indexCount + 2] = _vertexDic[index2];
//		_indexes[_indexCount + 3] = _vertexDic[index1];
//		_indexes[_indexCount + 4] = _vertexDic[index3];
//		_indexes[_indexCount + 5] = _vertexDic[index2];
		_indexes[_indexCount] = index0;
		_indexes[_indexCount + 1] = index1;
		_indexes[_indexCount + 2] = index2;
		_indexes[_indexCount + 3] = index1;
		_indexes[_indexCount + 4] = index3;
		_indexes[_indexCount + 5] = index2;

		_indexCount += 6;
	}

	/**
	 * 立即执行之前设置的内容
	 */
	public function flush():void
	{
		_superTexture.clear();
		_superTexture.setSize(_w, _h);

		// simulation only fix
//		this.texture = _superTexture;

		var vertexes:Vector.<Number> = Vector.<Number>(_vertexes);
		vertexes.fixed = true;
		var indexes:Vector.<int> = Vector.<int>(_indexes);
		indexes.fixed = true;

		_superTexture.addTriangles(vertexes, indexes);

		_vertexes = [];
		_vertexCount = 0;

		_indexes = [];
		_indexCount = 0;
		_index = 0;

		_vertexDic = {};
	}

	/**
	 * 将顶点压入平坦化后的顶点数组内。
	 * 首先会查询该顶点是否已存在过，
	 * 如果字典内没有顶点的索引，
	 * 则顶点压入，自增索引并添加到字典内。
	 * @param vertex			要压入的顶点实例
	 * @return					该顶点对应的 Key 值
	 */
//	private function pushVertexAndGetKey(vertex:Vertex):String
	private function pushVertexScalaAndGetIndex(v0:int, v1:int, v2:int, v3:int):int
//	private function pushVertexAndGetIndex(v0:int, v1:int, v2:int, v3:int):int
	{
		var key:String = String(v0) + '_' + String(v1) + '_' + String(v2) + '_' + String(v3);
//		var key:String = [v0, v1, v2, v3].join('_');
//		var key:String = '0_0_0_0';
		var index:int = _vertexDic[key];
		if (!index)
		{
			_vertexes[_vertexCount] = v0;
			_vertexes[_vertexCount + 1] = v1;
			_vertexes[_vertexCount + 2] = v2;
			_vertexes[_vertexCount + 3] = v3;

			_vertexCount += 4;

			_vertexDic[key] = _index;

			return _index++;
		}
		else
			return index;
//		var t0:int, t1:int, t2:int, t3:int;
//		for (var i:int = 0, m:int = _vertexes.length, index:int = 0; i<m; i+=4)				// 在现有顶点数据内循环，查找重复项并剔除
//		for (var m:int = _vertexes.length, i:int = m-16, index:int = 0; i<m; i+=4)			// 假设顶点是顺序排列进来，只在前 4 个顶点内查找重复并剔除
//		{
//			t0 = _vertexes[i];
//			t1 = _vertexes[i+1];
//			t2 = _vertexes[i+2];
//			t3 = _vertexes[i+3];
//
//			if (t0 == v0 && t1 == v1 && t2 == v2 && t3 == v3)
//				return index;
//
//			index ++;
//		}
//
//		_vertexes[m] = v0;
//		_vertexes[m+1] = v1;
//		_vertexes[m+2] = v2;
//		_vertexes[m+3] = v3;
//
//		_vertexCount += 4;
//
//		return _index++;
	}

	/**
	 * 取得某个顶点实例的索引值。
	 * @param key				要获取索引值的顶点实例生成的键值
	 * @return					该顶点实例的索引值
	 */
	private function getIndexOfVertex(key:String):int
	{
		var index:int = _vertexDic[key];

		return index;
		/*if (_vertexDic[key] != undefined)
			return _vertexDic[key];
		else
			return -1;			// 此值为非法，正常情况下不应该获得该数据*/
	}

	override public function dispose():void
	{
		super.dispose();

		_superTexture.clear();
		_superTexture = null;

		_vertexes = null;
		_indexes = null;
		_vertexDic = null;
	}
}
}
