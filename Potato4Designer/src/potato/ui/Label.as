/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 12-11-9
 * Time: 下午2:36
 * To change this template use File | Settings | File Templates.
 */
package potato.ui
{
import flash.geom.Point;
import flash.geom.Rectangle;

import core.display.DisplayObject;
import core.display.DisplayObjectContainer;
import core.display.Image;
import core.filters.Filter;
import core.text.TextField;

import potato.events.GestureEvent;
import potato.res.Res;
import potato.tweenlite.TweenLite;
import potato.utils.Size;
import potato.utils.Utils;

/**
 * 文字标签类
 *
 * XML 配置示例：
 *     &lt;Label id="label_z" x="150" y="150" text="未来式波音747不知道哪里去鸟" width="291" height="100" multiline="false" fontSize="30" textColor="0xFFFF00" background="assets/yaopuBg3" /&gt;
 * 其中，text 属性也可以改用 htmlText，就像 &lt;Label htmlText="&lt;b&gt;黑体&lt;/b&gt;" ... /&gt;
 * multiline 属性是布尔值，可以写 true 或 false。
 */
public class Label extends BaseBatchRenderableUIComponent
{

	private var _bg:DisplayObject;

	private var _tf:TextField;
	private var _text:String;
	private var _isHtmlText:Boolean;

	private var _icon:Image;
	private var _iconTextCap:int;
	private var _iconOffset:Point;

	private var _bgOrgW:int;     // 背景原始宽度
	private var _bgOrgH:int;     // 背景原始高度
	private var _bgScaleMode:int;

//	private var _expectWidth:int;      // 强制宽度
//	private var _expectHeight:int;      // 强制高度

	/**
	 * 通知 UI 编辑器，Label 并非容器类控件
	 */
	override public function get isContainer():Boolean
	{
		return false;
	}

	/**
	 * constructor.
	 *
	 * 构造一个 Label 对象实例
	 *
	 * @param text      该 Label 内要显示的文字
	 * @param color     该 Label 文字的颜色
	 * @param icon      图标，为 Image 实例类型
	 * @param hAlign    文字在行方向的对方方式，默认为水平居中
	 */
	public function Label(text:String = '', color:uint = 0, icon:Image = null, hAlign:uint = TextField.ALIGN_CENTER):void
	{
		var textSize:Size = getTextSize(text);

		_text = text;

		var fontName:String = UIGlobal.defaultFont;
		var fontSize:int = UIGlobal.FONTSIZE;

		_tf = new TextField(text, textSize.width, textSize.height, fontName, fontSize, color);
		_tf.hAlign = hAlign;
		_tf.vAlign = TextField.ALIGN_CENTER;

		_iconTextCap = 4;
		_expectWidth = _expectHeight = -1;

		_icon = icon;

		render();
	}

	/**
	 * 获取指定文本在指定字体和字号情况下的文字尺寸
	 *
	 * @param text      用于计算尺寸的文本对象
	 * @param fontName  文本使用的字体
	 * @param fontSize  文本使用的字号
	 * @return          文本对象在指定字体和字号情况下的文字尺寸
	 */
	private function getTextSize(text:String, fontName:String = 'yh'/*UIGlobal.defaultFont*/, fontSize:int = 20 /*UIGlobal.FONTSIZE*/):Size
	{
		return (text) ?
				Utils.getTextSize(text, fontName, fontSize, _isHtmlText) :
				new Size(0, 0);
	}

	/**
	 * 清除现有内容并重新构造其内容
	 */
	override public function renderImmediately():void
	{
		super.renderImmediately();

		// removeChildren();
		while(numChildren > 0)
		{
			var child:DisplayObject = removeChildAt(0);
			child.removeEventListeners();
		}

		addChild(_tf);

		var textSize:Size = getTextSize(_text, _tf.fontName, _tf.fontSize);
		var iconH:int = getDisplayObjectHeight(_icon);
//		var bgH:int = getDisplayObjectHeight(_bg);

//		var textH:int = Math.max(textSize.height, iconH, bgH);

		if (_icon)
		{
			var iconX:int = 0;
			var iconY:int;

			if (-1 == _expectHeight)
			{
				// 防止当文本被清空时 icon 突然跳动
				// textSize.height - _icon.height >> 1 等同于 (textSize.height - _icon.height) / 2
				iconY = _tf.text ? textSize.height - _icon.height >> 1 : 0;
			}
			else
			{
				// _sizeH - _icon.height >> 1 等同于 (_sizeH - _icon.height) / 2
				iconY = _expectHeight - _icon.height >> 1;
			}

			if (_iconOffset)
			{
				iconX = _iconOffset.x;
				iconY += _iconOffset.y;
			}

			_icon.x = iconX;
			_icon.y = iconY;
			addChild(_icon);
		}

		_tf.x = _icon ? _icon.x + _icon.width + _iconTextCap : _iconTextCap;
		_tf.y = 0;

		var tfWidth:int =
				_expectWidth == -1 ?
				textSize.width :
						_expectWidth > _tf.x ?
						_expectWidth - _tf.x :
						0;
		var tfHeight:int =
				_expectHeight == -1 ?
				textSize.height :
				_expectHeight;

//		_tf.text = _text;
		// _tf 的文本内容将在 setTFSize 函数内被设置
		// tfWidth + 3 是为了适当放大文字宽度，以避免因字体宽度计算上的误差
		// 导致文本被误认为超宽而截断
		setTFSize(tfWidth + 3, tfHeight);

		if (_bg)
		{
			var w:int = _tf.x + tfWidth;
			var h:int = Math.max(tfHeight, iconH);

			switch (_bgScaleMode)
			{
				case 0:
					break;

				case 1:
					_bg.scaleX = w / _bgOrgW;
					_bg.scaleY = h / _bgOrgH;
					break;

				case 2:
					(_bg as DisplayObjectContainer).clipRect = new Rectangle(0, 0, w,  h);
					break;

				case 3:
					(_bg as Object).width = w;
					(_bg as Object).height = h;
					break;
			}

			/*if (_bgOrgW != textSize.width)
				_bg.scaleX = textSize.width / _bgOrgW;

			if (_bgOrgH <= textH)
				_bg.scaleY = textH / _bgOrgH;*/


			addChildAt(_bg,  0);
		}

	}

	/**
	 * 设置文本对象的滤镜？？
	 * @param filter        将应用到文本对象上的滤镜？？
	 */
	public function setTextFilter(filter:Filter):void
	{
		_tf.filter = filter;
	}

	/**
	 * 设置 Label 的背景资源 ID
	 * @param value
	 */
	public function set background(value:String):void
	{
		var bg:Image = Res.getImage(value);
		setBackground(bg);
	}

	/**
	 * 设置 Label 背景的缩放模式，这代表当背景大小和 Label 大小不合时如何处理
	 * @param value
	 */
	/*public function backgroundScaleMode(value:int):void
	{

	}*/

	/**
	 * 为Label添加背景。背景无法添加偏移。 （真的需要这么复杂吗？我真蛋疼 wangyu
	 * @param bg        将被指定的背景显示对象
	 * @param keepWH    保持当前宽度和高度（该参数似乎多余了？）
	 * @param scaleMode 当背景大小和Label大小不合时如何处理。
	 * <br> 0: 忽略。此设置可能导致显示问题。
	 * <br> 1: 缩放（以scaleX  和 scaleY）
	 * <br> 2: 将背景置入DisplayObjectContainer并以clipRect剪切显示区域。
	 * <br> 3: 直接设置bg的宽高值。必须确认该对象的宽高可以被写入否则将发生错误。
	 */
	public function setBackground(bg:DisplayObject, keepWH:Boolean = true, scaleMode:int = 1):void
	{
		_bgOrgW = bg.width;
		_bgOrgH = bg.height;
		_bgScaleMode = scaleMode;

		if (2 == scaleMode)
		{
			var doc:DisplayObjectContainer = new DisplayObjectContainer();
			doc.addChild(bg);

			_bg = doc;
		}
		else
			_bg = bg;

		render();
	}

	/**
	 * 设置前景文本内容的颜色（等同于 set textColor）
	 * @param color     文本内容的颜色
	 */
	public function setForeground(color:uint):void
	{
		textColor = color;
	}

	/**
	 * 设置文本对象的文本颜色
	 * @param color     文本对象的文本颜色
	 */
	public function set textColor(color:uint):void
	{
		_tf.textColor = color;
	}

	/**
	 * 返回文本对象的文本颜色
	 */
	public function get textColor():uint
	{
		return _tf.textColor;
	}

	/**
	 * 重新指定 Label 的文本内容
	 */
	public function set text(value:String):void
	{
		if (_text != value)
		{
			_text = value;
			_isHtmlText = false;

			render();
		}
	}

	/**
	 * 返回文本对象的文本内容
	 */
	public function get text():String
	{
		return _text;
	}

	/**
	 * 重新指定 Label 的 html 文本内容
	 * @param value
	 */
	public function set htmlText(value:String):void
	{
		if (_text != value)
		{
			_text = value;
			_isHtmlText = true;

			render();
		}
	}

	/**
	 * 工具函数，根据 _isHtmlText 的选项来设置内部文本的 htmlText 或 text
	 * @param content           要设置的文本内容
	 */
	private function setTFContent(content:String):void
	{
		if (_isHtmlText)
			_tf.htmlText = content;
		else
			_tf.text = content;
	}

	/**
	 * 重新指定 Label 的文本字号
	 * @param value      文本字号
	 */
	public function set fontSize(value:int):void
	{
		if (_tf.fontSize != value)
		{
			_tf.fontSize = value;

			// 高度不够整行文本在 AVM 上都不会被显示
			if (!expectHeight || expectHeight < value + 3)
				expectHeight = value + 3;

			render();
		}
	}

	/**
	 * 提供修改 Label 控件期望宽度的方法
	 * <br/>在底层来说，实际上它是为了其后调用 setSizeWH 做准备
	 * @param value         要设置的宽度
	 */
	override public function set expectWidth(value:Number):void
	{
		if (_expectWidth != value)
		{
			_expectWidth = value;

			checkSizeWHAndSet();
		}
	}
	/**
	 * 提供修改 Label 控件期望高度的方法
	 * <br/>在底层来说，实际上它是为了其后调用 setSizeWH 做准备
	 * @param value         要设置的高度
	 */
	override public function set expectHeight(value:Number):void
	{
		if (_expectHeight != value)
		{
			_expectHeight = value;

			checkSizeWHAndSet();
		}
	}

	override public function get width():Number
	{
		renderImmediately();

		var bgW:int = getDisplayObjectWidth(_bg);
		var textW:int = Math.max(_tf.x + _tf.textWidth, bgW);

		return textW;
	}

	override public function get height():Number
	{
		renderImmediately();

		var iconH:int = getDisplayObjectHeight(_icon);
		var bgH:int = getDisplayObjectHeight(_bg);

		var textH:int = Math.max(_tf.y + _tf.textHeight,  iconH, bgH);
		return textH;
	}

	/**
	 * 检查当前期望的宽度和高度是否已经有合理数值（大于等于 0，而不是默认值 -1），
	 * <br/>如果都有合理数值，则自动调用 setSizeWH 函数。
	 */
	private function checkSizeWHAndSet():void
	{
		if (_expectWidth >= 0 && _expectHeight >= 0)
		{
			setSizeWH(_expectWidth, _expectHeight);
		}
	}

	/**
	 * 强制设置label宽高。该设置会同时导致背景缩放。参数值为-1则表示在该方向上不强制。<br>
	 * @param w label宽度。强制设置过小的宽度会导致文本显示不全，但icon则总是可以完全显示。<br>
	 * 另外，如果设置了iconOffset，则iconOffset.x的负值不计算在宽度内。<br>
	 * 即，当w = 30; iconOffset.x = -10 时，label的实际宽度为40。
	 * @param h 高度。强制设置高度会导致icon以此高度为中心对齐。若h为-1则icon以文本实际高度为中心对齐。<br>
	 * 强制设置过小的高度会导致文本显示不全，但icon总是可以完全显示而且不会被缩放。
	 *
	 * label宽高策略：
	 * 1. 如果设置了强制宽高，则总是使用强制宽高；
	 * 2. 否则，如果设置了背景且设置为保持宽高，则使用背景宽高；
	 * 3. 否则，label不限制宽度，而以文本高度为其高度。
	 *
	 */
	public function setSizeWH(w:int, h:int):void
	{

		if (_expectWidth != w && _expectHeight != h)
		{
			_expectWidth = w;
			_expectHeight = h;

			var iconH:int = getDisplayObjectHeight(_icon);
			var bgH:int = getDisplayObjectHeight(_bg);

			var textH:int = Math.max(h,  iconH, bgH);

			if (_bg)
			{
				if (_bgOrgW != w)
					_bg.scaleX = w / _bgOrgW;

				if (_bgOrgH <= textH)
					_bg.scaleY = textH / _bgOrgH;
			}

			if (_icon)
			{
				// h - _icon.height >> 1 等同于 (h - _icon.height) / 2
				_icon.y = h - _icon.height >> 1;
			}

			w -= _tf.x;
			setTFSize(w, h);

		}
	}

	/**
	 * 设置内部文本对象的宽度和高度
	 * @param w         将设置的宽度
	 * @param h         将设置的高度
	 */
	private function setTFSize(w:int, h:int):void
	{
		if (_multiline)
		{
			setTFContent(_text);
			_tf.setSize(w, calculateStringHeight(_text, w, _tf.fontName, _tf.fontSize));

			if (_tf.textHeight > _expectHeight)
			{
				clipRect = new Rectangle(0, 0, w + _tf.x, h);
				addEventListener(GestureEvent.GESTURE_MOVE, onGestureMoveHandler);
				addEventListener(GestureEvent.GESTURE_UP, onGestureUpHandler);
			}
			else
			{
				clipRect = null;
				removeEventListener(GestureEvent.GESTURE_UP, onGestureUpHandler);
				removeEventListener(GestureEvent.GESTURE_MOVE, onGestureMoveHandler);
			}
		}
		else
		{

			setTFContent(
					_text.length > 0 ? cutoutStringByWidth(_text, w, _tf.fontName, _tf.fontSize, _isHtmlText) : _text
			);
			_tf.setSize(w, h);

			clipRect = null;
			removeEventListener(GestureEvent.GESTURE_MOVE, onGestureMoveHandler);
		}
	}

	/**
	 * 获取指定显示对象的宽度
	 * @param displayObject		要检测宽度的显示对象实例
	 * @return					显示对象的宽度。如果显示对象为空，则返回 0
	 */
	private function getDisplayObjectWidth(displayObject:DisplayObject):Number
	{
		return (displayObject) ? displayObject.width : 0;
	}

	/**
	 * 获取指定显示对象的高度
	 * @param displayObject     要检测高度的显示对象实例
	 * @return                  显示对象的高度。如果显示对象为空，则返回 0
	 */
	private function getDisplayObjectHeight(displayObject:DisplayObject):Number
	{
		return (displayObject) ? displayObject.height : 0;
	}

	/**
	 * 获取文本期望的宽度
	 * @return          文本期望宽度
	 */
	public function getPreferredWidth():int
	{
		return getFullTextedField().textWidth;
	}

	/**
	 * 获取文本期望的高度
	 * @return          文本期望高度
	 */
	public function getPreferredHeight():int
	{
		return getFullTextedField().textHeight;
	}

	/**
	 * 获取拥有完整文字内容的文本框对象
	 * @return      拥有完整文字内容的文本框对象
	 */
	private function getFullTextedField():TextField
	{
		return new TextField(_text, 1, 1, _tf.fontName, _tf.fontSize);
	}

	/**
	 * 设置图标与文本之间的间距（单位：像素）
	 * @param iconTextCap           图标与文本之间的间距
	 */
	public function setIconTextCap(iconTextCap:Number):void
	{
		if (_iconTextCap != iconTextCap)
		{
			_iconTextCap = iconTextCap;

			render();
		}
	}

	/**
	 * 允许重设图标
	 * <br>图标将以一下逻辑对齐：如果设置了强制高度，则以强制高度的一半为中心对齐。
	 * <br>否则，如果设置了背景且背景图标对齐开关为开，则以背景的一半为中心对齐。
	 * <br>否则，
	 * @param icon 图标
	 * @param offset 偏移。图标的x为offset.x，图标的y为自动对齐后的y + offset.y
	 *
	 */
	public function setIcon(icon:Image, offset:Point = null):void
	{
		var isDisplayDirty:Boolean = false;

		if (_icon != icon)
		{
			_icon = icon;
			isDisplayDirty = true;
		}

		if (_iconOffset != offset)
		{
			_iconOffset = offset;
			isDisplayDirty = true;
		}

		if (isDisplayDirty)
			render();
	}

	/**
	 * hAlign 代表当前 Label 对象文本水平方向上的对齐方式，
	 * 其有效值请参考 core.text.TextField 内几种对齐方式。
	 */
	public function get hAlign():uint
	{
		return _tf.hAlign;
	}
	public function set hAlign(value:uint):void
	{
		if (_tf.hAlign != value)
		{
			_tf.hAlign = value;
		}
	}

	private var _multiline:Boolean = false;
	/**
	 * 获取或设置一个值，指示文本字段是否支持自动换行。
	 * true 值指示支持自动换行；false 值指示不支持自动换行。
	 * 默认值为 false.
	 */
	public function get multiline():Boolean
	{
		return _multiline;
	}
	public function set multiline(value:Boolean):void
	{

		if (_multiline != value)
		{
			_multiline = value;

			render();
		}
	}

	private var _isFirstMove:Boolean = true;
	private var _tfOrginalY:int;

	private function onGestureMoveHandler(e:GestureEvent):void
	{
		if (_isFirstMove)
			_tfOrginalY = _tf.y;

		var scrollHeight:int = _tf.textHeight - expectHeight;
		_tf.y = _tfOrginalY + e.distanceY;

		_isFirstMove = false;
	}

	private function onGestureUpHandler(e:GestureEvent):void
	{
		const maxY:int = 0;
		const minY:int = expectHeight - calculateStringHeight(_text, _tf.textWidth, _tf.fontName, _tf.fontSize); //_tf.textHeight;
		if (_tf.y > maxY)
			TweenLite.to(_tf, 0.5, {y: maxY});
		else if (_tf.y < minY)
			TweenLite.to(_tf, 0.5, {y: minY});

		_isFirstMove = true;
	}


	/**
	 * 计算给定字符串在指定字号下的宽度（单位：像素）
	 * @param string            用于计算宽度的字符串
	 * @param fontSize          对应的字号
	 * @param isHtmlText        是否为 Html 文本
	 * @return                  字符串在指定字号下的宽度
	 */
	private function calculateStringWidth(string:String, fontName:String, fontSize:uint, isHtmlText:Boolean):uint
	{
//		var plainString:String = (isHtmlText) ? string.replace(/<\/?\w+>/g, '') : string;
//		var plainString:String = (isHtmlText) ? string.replace(/<\/?\w+(\s+[\w|=|"]*)*>/g, '') : string;
//
//		var stringWidth:uint = 0;
//		for (var i:uint = 0, m:uint = plainString.length; i<m; i++)
//		{
//			stringWidth += Utils.calculateCharWidth(plainString.charCodeAt(i), fontName, fontSize);
//		}
//
//		return stringWidth;
		var s:Size = Utils.getTextSize(string, fontName, fontSize, isHtmlText);
		return s.width;
	}

	/**
	 * 计算字符串在指定宽度下的高度（近似值）
	 * @param string
	 * @param w
	 * @param fontSize
	 * @param isHtmlText
	 * @return
	 */
	private function calculateStringHeight(string:String, w:uint, fontName:String, fontSize:uint, isHtmlText:Boolean = false):uint
	{
		var totalStringWidth:Number = calculateStringWidth(string, fontName, fontSize, isHtmlText);
		// 行数使用 ceil 后还 +1 是为了得到能全部容纳文字的近似高度
		var lineCount:uint = Math.ceil(totalStringWidth / w) + 1;

		return lineCount * fontSize;
	}

	/**
	 * 截取给定的字符串，返回一个接近指定宽度（单位：像素）的字符串
	 * @param string                将被截取的字符串
	 * @param widthLimit            宽度的限制（单位：像素）
	 * @param fontName              字体
	 * @param fontSize              字号尺寸
	 * @param isHtmlText            是否为 Html 文本
	 * @return                      截取后的字符串
	 */
	private function cutoutStringByWidth(string:String, widthLimit:uint, fontName:String, fontSize:uint, isHtmlText:Boolean):String
	{
		if (calculateStringWidth(string, fontName, fontSize, isHtmlText) <= widthLimit)
		{
			return string;
		}

		// 将宽度减去一文字宽度，以便在末尾加入 … 符号
		widthLimit -= fontSize;

		var stringWidth:uint = 0, charWidth:uint, nextWidth:uint;

		// 表示当前步进到 html tag 内，比如进入了 <b> 这样的标签内
		var isInTag:Boolean;
		// 表示当前步进到 html close tag 内，比如进入了 </b> 这样的标签内
		var isInCloseTag:Boolean;

		var charCode:uint;

		// 在循环里处理 tag 的记录变量；
		var gtPos:int;     // 最后找到的 > 符号位置
		var tag:String,  tags:Vector.<String> = new <String>[];

		var result:String = '';

		for (var i:uint = 0, m:uint = string.length; i<m; i++)
		{
			charCode = string.charCodeAt(i);

			// 如果当前为 htmlText 模式，则进行进入 Html Tag 的检查
			// 如果当前为 < 字符，并且后面还有字符，则做 Html Tag 进一步检查
			if (isHtmlText && charCode == 60 && i < m-1)
			{
				gtPos = string.indexOf('>', i);

				// 如果存在符号 >，则判定为进入了 html tag
				// 注：这不是绝对精确，但我觉得在公司项目中应该够用
				// @author: Bob Jiang
				isInTag = gtPos > 0;

				// 如果紧随当前字符的是符号 /，则判定为当前是 html close tag
				// 注：精确度问题同上
				isInCloseTag = (isInTag) ? string.charCodeAt(i+1) == 47 : false;

				if (isInTag)
				{
					tag = string.substring(
							isInCloseTag ? i+2 : i+1,
							gtPos
					);

					if (isInCloseTag)
						tags.pop();     // 这里假设录入的 XML 标签是严格正确嵌套
					else
						tags.push(tag);

					i = gtPos;

					if (i<m-1)
						continue;
					else
						return string;
				}
			}

			charWidth = Utils.calculateCharWidth(charCode, fontName, fontSize);
			nextWidth = charWidth + stringWidth;

			if (nextWidth > widthLimit)
			{
				result = string.substr(0, i);
				break;
			}
			else if (nextWidth == widthLimit)
			{
				result = string.substr(0, i + 1);
				break;
			}

			stringWidth = nextWidth;
		}

		// 如果是 htmlText 而且存在未关闭的 tag，则主动为它们添加上 tag 关闭标签
		while (isHtmlText && tags.length > 0)
		{
			result += '</' + tags.pop() + '>';
		}

		return result + '…';
	}

	/**
	 * 计算一个字符的宽度（单位：像素），
	 * <br/>主要用于区分英文数字与汉字的宽度计算。
	 * @param charCode          用于计算的字符代码
	 * @param fontSize          字体的大小
	 * @return                  该字符在使用该字体大小时的宽度（单位：像素）
	 */
	/*private function calculateCharWidth(charCode:uint, fontName:String, fontSize:uint):uint
	{
//		return charCode > 192 ? fontSize : fontSize >> 1;
//		return charCode > 192 ? fontSize : fontSize * 0.35;     // 非中文字符采用 0.35 的宽度系数来计算
		return Utils.calculateCharWidth(charCode, fontName, fontSize);
//		var char:String = String.fromCharCode(charCode);
//		return getTextSize(char, _tf.fontName, fontSize).width;
	}*/

}
}
