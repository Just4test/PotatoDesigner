/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 12-12-13
 * Time: 上午10:52
 * To change this template use File | Settings | File Templates.
 */
package potato.display
{
import core.display.DisplayObjectContainer;
import core.display.SubTexture;
import core.display.SuperTexture;
import core.display.Texture;

import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * 多个砖块拼接层显示对象
 */
public class TiledMultiLayers extends DisplayObjectContainer
{
	private var _tiledImagesDic:Object;

	private var _w:int;
	private var _h:int;

	/**
	 * 构造由砖块拼接图像组成的多层显示对象
	 * @param w				该多层对象的宽度
	 * @param h				该多层对象的高度
	 */
	public function TiledMultiLayers(w:int, h:int):void
	{
		if (w <= 0 || h <= 0 || w > 2048 || h > 2048)
			throw new Error('指定的砖块拼接图宽度和高度应当都为正数值，同时还应当小于 2048');

		_w = w;
		_h = h;

		_tiledImagesDic = {};
	}

	/**
	 * 附加一个父级材质
	 * @param textureKey			父级材质在字典中检索用 Key
	 * @param parentTexture			父级材质引用
	 */
	public function appendTexture(textureKey:String,  parentTexture:Texture):void
	{

		if (!textureKey || !parentTexture)
			return;

		if (parentTexture is SubTexture || parentTexture is SuperTexture)
			throw new Error('不允许使用子级材质来派生出砖块拼接图像！');

		var image:TiledImage = _tiledImagesDic[textureKey];

		if (!image)
		{
			image = new TiledImage(parentTexture, _w, _h);
			addChild(image);

			_tiledImagesDic[textureKey] = image;
		}
		else
			image.parentTexture = parentTexture;

	}

	/**
	 * 从父材质复制一个矩形内的像素到当前实例的目标位置上。
	 * 注：该方法的效果有点象 flash 开发中的 BitmapData.copyPixels
	 *
	 * @param textureKey		要复制源父材质的 Key
	 * @param sourceRect		复制源矩形数据
	 * @param destPoint			数据将覆盖的目标位置
	 */
	public function copyRect(textureKey:String, sourceRect:Rectangle, destPoint:Point):void
	{
		if (!textureKey)
			return;

		var image:TiledImage = _tiledImagesDic[textureKey];
		if (image)
		{
			image.copyRect(sourceRect, destPoint);
		}
	}

	/**
	 * 立即执行之前设置的三角形填充等数据
	 * @param	textureKey		要执行的材质 Key。如果未指定，则将所有 TiledImage 内容都提交执行
	 */
	public function flush(textureKey:String = ''):void
	{
		var image:TiledImage;

		if (!textureKey)
		{
			for each (image in _tiledImagesDic)
				image.flush();
		}
		else
		{
			image = _tiledImagesDic[textureKey]
			if (image)
				image.flush();
		}
	}

	override public function dispose():void
	{
		super.dispose();

		var image:TiledImage;
		for each (image in _tiledImagesDic)
			image.dispose();

		_tiledImagesDic = null;
	}
}
}
