/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 12-12-11
 * Time: 下午2:42
 * To change this template use File | Settings | File Templates.
 */
package potato.utils
{
/**
 * 顶点数据，目前仅用于 SuperTexture 内
 *
 * 它是两组坐标的数据载体，分别是顶点坐标和材质坐标。
 * 顶点坐标，表示顶点在 OpenGL 体系内绘制的坐标；
 * 材质坐标，表示顶点对应父材质上的坐标。
 */
public class Vertex
{
	public var x:int;			// 顶点坐标 x
	public var y:int;			// 顶点坐标 y
	public var textureX:int;	// 材质坐标 x
	public var textureY:int;	// 材质坐标 y

	/**
	 * 构造一个顶点数据
	 * @param v1			顶点坐标 x
	 * @param v2			顶点坐标 y
	 * @param v3			材质坐标 x
	 * @param v4			材质坐标 y
	 */
	public function Vertex(v1:int, v2:int, v3:int, v4:int) {
		this.x = v1;
		this.y = v2;
		this.textureX = v3;
		this.textureY = v4;
	}

	/**
	 * 检查当前顶点是否等于另外一个顶点对象
	 * @param other			用来比较的另外一个顶点对象
	 * @return				两个顶点对象的值是否相等
	 */
	public function equals(other:Vertex):Boolean
	{
		if (!other)
			return false;
		else if (this === other)
			return true;
		else
			return (x == other.x && y == other.y && textureX == other.textureX && textureY == other.textureY);
	}

	/**
	 * 返回顶点的字符串表示
	 * @return				顶点的字符串表示
	 */
	public function toString():String {
//		return "Vertex {x: " + String(x) + ", y: " + String(y) + ", textureX: " + String(textureX) + ", textureY: " + String(textureY) + "}";
		return 'v_' + String(x) + '_' + String(y) + '_' + String(textureX) + '_' + String(textureY);
	}
}
}
