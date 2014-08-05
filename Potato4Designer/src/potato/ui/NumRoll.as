/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 12-11-16
 * Time: 上午11:33
 * To change this template use File | Settings | File Templates.
 */
package potato.ui
{
import core.display.DisplayObjectContainer;
import core.display.Image;
import core.events.Event;

import flash.utils.getTimer;

import potato.events.GestureEvent;
import potato.events.UIEvent;
import potato.res.Res;

[Event(name="numChange", type="potato.events.UIEvent")]

/**
 * 加减数字组件
 * @author Floyd
 * May 18, 2012
 *
 * XML 配置示例：
 * <Button id="subBtn" x="0" y="0" downSkin="assets/sub_2.png" upSkin="assets/sub_1.png" disableSkin="assets/sub_3.png" />
 * <Button id="addBtn" x="200" y="0" downSkin="assets/add_2.png" upSkin="assets/add_1.png" disableSkin="assets/add_3.png" />
 * <NumRoll id="nr1" x="100" y="100" width="300" height="100" numberImageTemplate="assets/nr_demo_%d.png"
 *   minNumber="0" maxNumber="10" defaultNumber="5" step="3" isHorizontalArrange="true"
 *   subButton="*subBtn" addButton="*addBtn" />
 *
 * 该示例中，先配置了用于 NumRoll 的两个按钮组件，最后通过 NumRoll 内的 subButton 和 addButton 属性注入
 */
public class NumRoll extends BaseBatchRenderableUIComponent
{
	/**减按钮*/
	protected var _subButton:Button;
	/**加按钮*/
	protected var _addButton:Button;
	/**当前文本*/
	protected var _currentText:DisplayObjectContainer;
	/** 是否按水平方式排列（该属性影响 _currentText 的坐标定位） */
	protected var _isHorizontalArrange:Boolean = true;
	/**文本显示对象*/
	protected var _numberImages:Vector.<Image>;
	// 取得文本图像的路径模板
	// 例如：nr_demo_%d.png 表示取出 nr_demo_0.png, nr_demo_1.png, ... nr_demo_9.png
	private var _numberImageTemplate:String;
	/**最小值*/
	protected var _minNumber:int;
	/**最大值*/
	protected var _maxNumber:int;
	/**滚动速度（毫秒/次）*/
	protected var _scrollingSpeed:int;
	/**当前速度*/
	private var _currentSpeed:int;

	/**0=没按，1=加，-1=减*/
	protected var _addOrSub:int = 0;
	/**当前数字*/
	protected var _num:int;

	/**按下时间*/
	protected var _startTime:int;
	/**上次时间*/
	protected var _upTime:int;

	/**当前加速次数*/
	protected var _addedCount:int;

	/**
	 * 构造方法
	 * @param subBtn		减按钮
	 * @param addBtn		加按钮
	 * @param numberImageTemplate			文本图片资源 ID 的模板，例如：nr_demo_%d.png
	 * @param minNum		最小滚动数字
	 * @param maxNum		最大滚动数字
	 * @param speed			间隔毫秒
	 */
	public function NumRoll(
			subBtn:Button = null,
			addBtn:Button = null,
			numberImageTemplate:String = '',
			minNum:int = 0,
			maxNum:int = 100,
			defaultNum:int = 50,
			speed:int = 100
		):void
	{
		subButton = subBtn;
		addButton = addBtn;
		this.numberImageTemplate = numberImageTemplate;
		minNumber = minNum;
		maxNumber = maxNum;
		scrollingSpeed = speed;

		_currentText = new DisplayObjectContainer();

		value = defaultNum;
	}

	public function set subButton(value:Button):void
	{
		if (_subButton != value)
		{
			if (_subButton)
			{
				removeChild(_subButton);
				_subButton.removeEventListeners();
			}

			_subButton = value;
			_subButton.addEventListener(GestureEvent.GESTURE_DOWN, beginSub);
			_subButton.addEventListener(GestureEvent.GESTURE_UP, endSub);

			render();
		}
	}

	public function set addButton(value:Button):void
	{
		if (_addButton != value)
		{
			if (_addButton)
			{
				removeChild(_addButton);
				_addButton.removeEventListeners();
			}

			_addButton = value;
			_addButton.addEventListener(GestureEvent.GESTURE_DOWN, beginAdd);
			_addButton.addEventListener(GestureEvent.GESTURE_UP, endAdd);

			render();
		}
	}

	public function set numberImageTemplate(value:String):void
	{
		if (value && _numberImageTemplate != value && value.indexOf('%d') > 0)
		{
			const arr:Array = value.split('%d');
			const prefix:String = arr[0];
			const suffix:String = arr.length > 1 ? arr[1] : '';

			if (!_numberImages)
				_numberImages = new Vector.<Image>(10, true);

			for (var i:uint=0,m:uint=_numberImages.length; i<m; i++)
			{
				_numberImages[i] = Res.getImage(prefix + String(i) + suffix);
			}
		}
	}

	public function set minNumber(value:int):void
	{
		if (_minNumber != value)
		{
			_minNumber = value;
		}
	}

	public function set maxNumber(value:int):void
	{
		if (_maxNumber != value)
		{
			_maxNumber = value;
		}
	}

	public function set scrollingSpeed(value:int):void
	{
		if (_scrollingSpeed != value)
		{
			_scrollingSpeed = value;
		}
	}

	public function set defaultNumber(value:int):void
	{
		this.value = value;
	}

	public function get isHorizontalArrange():Boolean
	{
		return _isHorizontalArrange;
	}
	public function set isHorizontalArrange(value:Boolean):void
	{
		_isHorizontalArrange = value;
	}



	override public function renderImmediately():void
	{
		super.renderImmediately();

		if (_subButton && (numChildren < 1 ||  _subButton != getChildAt(0)))
			addChildAt(_subButton, 0);

		if (_addButton && (numChildren < 2 || _addButton != getChildAt(1)))
			addChildAt(_addButton, 1);

		if (_currentText && numChildren < 3)
			addChild(_currentText);

		if (isHorizontalArrange)
			_currentText.x = width - _currentText.width >> 1;
		else
			_currentText.y = height - _currentText.height >> 1;
	}

	/**
	 * 按下减按钮
	 * @param e
	 */
	private function beginSub(e:GestureEvent):void
	{
		addEventListener(Event.ENTER_FRAME, reflush);
		_startTime = getTimer();
		_upTime = _startTime;
		_addedCount = step;
		_addOrSub = -step;
		_currentSpeed = _scrollingSpeed;
		updateNum(-step);
	}

	/**
	 * 停止减
	 * @param e
	 */
	private function endSub(e:GestureEvent):void
	{
		removeEventListener(Event.ENTER_FRAME, reflush);
		_addOrSub = 0;
	}

	/**
	 * 按下加
	 * @param e
	 */
	private function beginAdd(e:GestureEvent):void
	{
		addEventListener(Event.ENTER_FRAME, reflush);
		_startTime = getTimer();
		_upTime = _startTime;
		_addOrSub = step;
		_addedCount = step;
		_currentSpeed = _scrollingSpeed;
		updateNum(step);
	}

	/**
	 * 停止加
	 * @param e
	 */
	private function endAdd(e:GestureEvent):void
	{
		removeEventListener(Event.ENTER_FRAME, reflush);
		_addOrSub = 0;
	}

	/**
	 * 刷新
	 * @param e
	 */
	private function reflush(e:Event):void
	{
		// TODO: 现在有一个 BUG，当点住一个按钮随后手指移离那个按钮，则 reflush 会一直执行
		if (_addOrSub == 0)
		{
			removeEventListener(Event.ENTER_FRAME, reflush);
			return;
		}
		var now:int = getTimer();

		if (now - _upTime > _currentSpeed)
		{
			updateNum(_addOrSub);
			_upTime += _scrollingSpeed;

			if (_currentSpeed > 30)
				_currentSpeed-=4*step;
		}
		if (now - _startTime > _scrollingSpeed * 10 * _addedCount)
		{
			_addedCount++;
			if (_addOrSub > 0)
				_addOrSub += step;
			else
				_addOrSub -= step;
		}
//		trace(_addOrSub);
	}

	/**
	 * 跟新数字显示
	 * @param num		加减多少
	 */
	private function updateNum(num:int):void
	{
		var n:int = num + _num;
		value = n;
	}


	/**
	 * 显示这个数字
	 * @param num
	 */
	private function showNum(num:int):void
	{
		var s:String = num.toString();
		while(_currentText.numChildren > 0)
			_currentText.removeChildAt(0);
		for (var i:int = 0; i < s.length; i++)
		{
			var n:int = int(s.charAt(i));
			var img:Image = new Image(_numberImages[n].texture);
			img.x = i * img.width;
			_currentText.addChild(img);
		}
//		_currentText.x = -_currentText.width / 2 + tx;
		_currentText.x = width - _currentText.width >> 1;
	}

	/**
	 * 当前显示的数值
	 * @return
	 */
	public function get value():int
	{
		return _num;
	}

	public function set value(n:int):void
	{
		if (n > _maxNumber)
			n = _maxNumber;
		if (n < _minNumber)
			n = _minNumber;

		if (_num != n)
		{
			_num = n;

			if (_numberImages)
				showNum(n);

			this.dispatchEvent(new UIEvent(UIEvent.NUM_CHANGE));
		}
	}

	private var tx:int;

	public function setTextPoint(x:int, y:int):void
	{
		tx = x;
		_currentText.x = -_currentText.width / 2 + tx;
		_currentText.y = y;
	}


	private var _step:int = 1;

	public function set step(v:int):void
	{
		_step = v;
	}

	public function get step():int
	{
		return _step;
	}
}
}
