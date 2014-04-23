/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 12-12-3
 * Time: 下午5:34
 * To change this template use File | Settings | File Templates.
 */
package potato.ui.joystick
{
	import core.display.DisplayObject;
	import core.display.Image;
	import core.events.EventDispatcher;
	
	import flash.geom.Point;
	
	import potato.events.GestureEvent;
	import potato.events.JoystickEvent;
	import potato.res.Res;
	import potato.tweenlite.TweenLite;
	import potato.tweenlite.easeing.Back;
	import potato.ui.UIComponent;
	import potato.utils.JoystickUtil;
	
	/**
	 * 虚拟摇杆，用于手机等触屏界面。
	 * 目前不支持通过 XML 进行配置
	 */
	public class VirtualJoystick extends UIComponent implements IJoystick
	{
		private var _ballImage:DisplayObject;		// 摇杆球头图
		private var _ballPivotX:Number = 0;		// 摇杆球头 pivotX 值
		private var _ballPivotY:Number = 0;		// 摇杆球头 pivotY 值
		
		private var _dockImage:Image;		// 摇杆底座图
		private var _dockPivotX:Number = 0;		// 摇杆底座 pivotX 值
		private var _dockPivotY:Number = 0;		// 摇杆底座 pivotY 值
		
		private var _expectRadius:uint;		// 组件有效显示半径，它会影响 expectWidth 和 expectHeight
		private var _dockAreaRadius:Number;	// 底座半径
		private var _moveRadius:Number;		// 杆头在底座中的有效移动半径
		private var _movePatchRadius:int = 0;	// 杆头可以超出底座半径的移动范围（单位：像素）
		private var _patchedRadius:Number;	// 将 X Y 轴向坐标转换成 -128 ~ 128 之间有效值的中间计算量
		
		private var _axisX:int;				// X 轴向偏移值
		private var _axisY:int;				// Y 轴向偏移值
		
		private var _originalBallX:int		// ballImage 初始坐标 x
		private var _originalBallY:int		// ballImage 初始坐标 y
		
		/**
		 * 摇杆在 X 轴向上的模拟量
		 * 值在 -127 ~ 127 之间
		 * 负数表示向左，正数表示向右
		 */
		public function get axisX():int
		{
			return _axisX;
		}
		
		/**
		 * 摇杆在 Y 轴向上的模拟量
		 * 值在 -127 ~ 127 之间
		 * 负数表示向左，正数表示向右
		 */
		public function get axisY():int
		{
			return _axisY;
		}
		
		/**
		 * 构造一个虚拟摇杆
		 * @param ballImageId		代表摇杆杆头的图像 Id
		 * @param dockImageId		代表摇杆底座的图像 Id
		 * @param expectRadius		当前虚拟摇杆本身尺寸的期望半径（期望半径 * 2 等于期望宽度和期望高度值）
		 * @param ballPivotX		杆头图像中心点坐标 x（如果使用默认值 0，则设置杆头图像宽度的一半为中心点坐标 x）
		 * @param ballPivotY		杆头图像中心点坐标 y（如果使用默认值 0，则设置杆头图像高度的一半为中心点坐标 y）
		 * @param dockPivotX		底座图像中心点坐标 x（如果使用默认值 0，则设置底座图像宽度的一半为中心点坐标 x）
		 * @param dockPivotY		底座图像中心点坐标 y（如果使用默认值 0，则设置底座图像高度的一半为中心点坐标 y）
		 * 
		 */	
		public function VirtualJoystick(ballImageId:* = '', dockImageId:String = '', expectRadius:uint = 70,
										ballPivotX:Number = 0, ballPivotY:Number = 0,
										dockPivotX:Number = 0, dockPivotY:Number = 0, dir:String = '', dirPx:int = 0, dirPy:int = 0):void
		{
			_isContainer = false;
			isMultiTouch = true;
			_expectRadius = expectRadius;
			_expectWidth = _expectHeight = (expectRadius << 1);
			
			_axisX = 0;
			_axisY = 0;
			
			mouseChildren = false;
			
			_ballPivotX = ballPivotX;
			_ballPivotY = ballPivotY;
			_dockPivotX = dockPivotX;
			_dockPivotY = dockPivotY;
			
			this.ballImageId = ballImageId;
			this.dockImageId = dockImageId;
			this.expectRadius = expectRadius;
			this.setDir(dir, dirPx, dirPy);
			addEventListener(GestureEvent.GESTURE_DOWN, onGestureDownHandler);
			addEventListener(GestureEvent.GESTURE_UP, onGestureUpHandler);
		}
		
		public function get eventDispatcher():EventDispatcher
		{
			return this;
		}
		
		private var _dir:Image;
		public function setDir(d:String, px:int, py:int):void
		{
			if(_dir)
				removeChild(_dir);
			if(!d)
				return;
			_dir = Res.getImage(d);
			_dir.mouseEnabled = false;
			_dir.x = _dockImage.width / 2;
			_dir.y = _dockImage.height / 2;
			_dir.pivotX = px;
			_dir.pivotY = py;
			addChild(_dir);
			_dir.mouseEnabled = false;
		}
		
		/**
		 * 指定摇杆球头的图像 Id
		 * @param imageId		摇杆球头使用的图像的 Id
		 */
		public function set ballImageId(imageId:*):void
		{
			var image:DisplayObject;
			if(imageId is DisplayObject)
			{
				image = imageId;
			}
			else
			{
				image = Res.getImage(imageId);
			}
			
			if (image && _ballImage != image)
			{
				if (_ballImage)
				{
					removeChild(_ballImage);
					_ballImage.removeEventListeners();
				}
				
				_ballImage = image;
				//			_ballImage.mouseEnabled = false;
				
				if (!_ballPivotX) _ballPivotX = _ballImage.width >> 1;
				_ballImage.pivotX = _ballPivotX;
				if (!_ballPivotY) _ballPivotY = _ballImage.height >> 1;
				_ballImage.pivotY = _ballPivotY;
				
				_ballImage.x = _expectWidth >> 1;
				_ballImage.y = _expectHeight >> 1;
				
				_originalBallX = _ballImage.x;
				_originalBallY = _ballImage.y;
				
				if (numChildren > 0)
					addChildAt(_ballImage, 1);
				else
					addChild(_ballImage);
			}
			if(_ballImage)_ballImage.mouseEnabled = false;
		}
		
		/**
		 * 指定推杆底座的图像 Id
		 * @param imageId		推杆底座使用的图像的 Id
		 */
		public function set dockImageId(imageId:String):void
		{
			var image:Image = Res.getImage(imageId);
			if (image && _dockImage != image)
			{
				if (_dockImage)
				{
					removeChild(_dockImage)
					_dockImage.removeEventListeners();
				}
				
				_dockImage = image;
				//			_dockImage.mouseEnabled = false;			// 在 avm 中模拟发现，组件内必须有一个 mouseEnabled 子对象，才能接收手势移动事件
				
				if (!_dockPivotX) _dockPivotX = _dockImage.width >> 1;
				_dockImage.pivotX = _dockPivotX;
				if (!_dockPivotY) _dockPivotY = _dockImage.height >> 1;
				_dockImage.pivotY = _dockPivotY;
				
				_dockAreaRadius = _dockPivotX - _ballPivotX;
				_patchedRadius = _dockAreaRadius / 128;
				
				_moveRadius = _dockAreaRadius + _movePatchRadius;
				
				_dockImage.x = _expectWidth >> 1;
				_dockImage.y = _expectHeight >> 1;
				
				addChildAt(_dockImage, 0);
			}
		}
		
		/**
		 * 设置杆头移动时可以超出底座图像多少像素
		 * @param value
		 */
		public function set movePatchRadius(value:int):void
		{
			if (_movePatchRadius != value)
			{
				_movePatchRadius = value;
				
				if (_dockAreaRadius)
					_moveRadius = _dockAreaRadius + value;
			}
		}
		
		/**
		 * 指定组件期望半径
		 * @param value			组件期望半径。
		 */
		public function set expectRadius(value:uint):void
		{
			if (_dockImage && value < _dockImage.width >> 1)
				value = _dockImage.width >> 1;
			
			if (_expectRadius != value)
				_expectRadius = value;
		}
		
		
		private function onGestureDownHandler(e:GestureEvent):void
		{
			if (isReady())
			{
				dispatchEvent(new JoystickEvent(JoystickEvent.JOYSTICK_PRESS));
				
				touchPointID = e.touchPointID;
				addEventListener(GestureEvent.GESTURE_MOVE, onGestureMoveHandler);
				
				//			onGestureMoveHandler(e);
			}
		}
		
		private function onGestureUpHandler(e:GestureEvent):void
		{
			removeEventListener(GestureEvent.GESTURE_MOVE, onGestureMoveHandler);
			
			TweenLite.to(_ballImage, 0.35, {x: _originalBallX, y:_originalBallY, ease: Back.easeOut});
			
			dispatchEvent(new JoystickEvent(JoystickEvent.JOYSTICK_RELEASE));
			
			setAxisXY(0, 0);
		}
		
		private function onGestureMoveHandler(e:GestureEvent):void
		{
			// localX 和 localY 似乎在光标移出显示对象时变成 stageX 或 stageY
			// 所以只能直接用 stageX 和 stageY 来操作坐标
			
			var bx:Number, by:Number;
			var distance:Number;
			
			const localPoint:Point = globalToLocal(new Point(e.stageX, e.stageY));
			
			bx = localPoint.x - _expectRadius;
			by = localPoint.y - _expectRadius;
			
			distance = Math.sqrt(bx * bx + by * by);
			if (distance > _moveRadius)
			{
				const scale:Number = _moveRadius / distance;
				bx *= scale;
				by *= scale;
			}
			
			_ballImage.x = _originalBallX + bx;
			_ballImage.y = _originalBallY + by;
			
			// bx 与 by 与 _patchedRadius 相除，是为了将 bx 和 by 转换到 -127 ~ 127 范围内
			setAxisXY(bx / _patchedRadius, by / _patchedRadius);
		}
		
		/**
		 * 设置摇杆的 X 轴向及 Y 轴向偏移值
		 * @param axisX			X 轴向偏移值，范围在 -127 ~ 127
		 * @param axisY			Y 轴向偏移值，范围在 -127 ~ 127
		 */
		private function setAxisXY(axisX:int, axisY:int):void
		{
			const originalAxisX:int = _axisX;
			const originalAxisY:int = _axisY;
			
			_axisX = axisX;
			_axisY = axisY;
			
			if(_dir)
			{
				var d:int = JoystickUtil.getDirection(axisX, axisY, JoystickUtil.ST_8WAY);
				_dir.rotation = d * 45;
			}
			if (originalAxisX != _axisX || originalAxisY != _axisY)
			{
				dispatchEvent(new JoystickEvent(JoystickEvent.JOYSTICK_UPDATE, _axisX, _axisY));
			}
		}
		
		/**
		 * 检查当前虚拟摇杆是否已经就绪，能够进行操作和计算了。
		 * @return			是否就绪
		 */
		private function isReady():Boolean
		{
			return _ballImage && _dockImage && _expectRadius;
		}
	}
}
