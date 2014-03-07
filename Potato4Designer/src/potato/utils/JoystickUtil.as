/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 12-12-6
 * Time: 下午4:21
 * To change this template use File | Settings | File Templates.
 */
package potato.utils
{
import potato.ui.joystick.IJoystick;

/**
 * 摇杆接口数据的转换工具类，它负责将摇杆返回的 axisX 和 axisY 值转换成真正的方向
 */
public class JoystickUtil
{
	// 摇杆为 8 向模式
	public static const ST_8WAY:uint = 0;
	// 摇杆为 4 向模式
	public static const ST_4WAY:uint = 1;

	// 9 个方向状态的标记
	public static const ST_RIGHT:uint = 0;
	public static const ST_RIGHT_DOWN:uint = 1;
	public static const ST_DOWN:uint = 2;
	public static const ST_LEFT_DOWN:uint = 3;
	public static const ST_LEFT:uint = 4;
	public static const ST_LEFT_UP:uint = 5;
	public static const ST_UP:uint = 6;
	public static const ST_RIGHT_UP:uint = 7;
	public static const ST_CENTER:uint = 8;

	// 8 个角度限制门
	private static const R_SEGMENT:Number = Math.PI / 8;
	private static const R_RIGHT_0:Number = -R_SEGMENT;
	private static const R_RIGHT_1:Number = R_SEGMENT;
	private static const R_DOWN_0:Number = R_SEGMENT * 3;
	private static const R_DOWN_1:Number = R_SEGMENT * 5;
	private static const R_LEFT_0:Number = R_SEGMENT * 7;
	private static const R_LEFT_1:Number = -R_SEGMENT * 7;
	private static const R_UP_0:Number = -R_SEGMENT * 5;
	private static const R_UP_1:Number = -R_SEGMENT * 3;

	/**
	 * 根据指定的摇杆双向轴和摇杆模式（4向/8向），计算并返回方向值
	 * @param axisX					摇杆的 X 轴向偏移值
	 * @param axisY					摇杆的 Y 轴向偏移值
	 * @param joystickMode			摇杆模式：4向或 8向
	 * @return						方向值
	 */
	public static function getDirection(axisX:int, axisY:int, joystickMode:uint = 0):uint
	{
		switch (joystickMode)
		{
			case ST_4WAY:

				if (Math.abs(axisX) >= Math.abs(axisY))
				{
					if (axisX == 0)
						return ST_CENTER;
					else
						return axisX > 0 ? ST_RIGHT : ST_LEFT;
				}
				else
				{
					if (axisY == 0)
						return ST_CENTER;
					else
						return axisY > 0 ? ST_DOWN : ST_UP;
				}

				break;

			case ST_8WAY:

				if (axisX == 0 && axisY == 0)
					return ST_CENTER;
				else
				{
					// 计算该 X Y 轴向参数的弧度
					const radian:Number = Math.atan2(axisY, axisX);

					if (radian > R_RIGHT_0 && radian <= R_RIGHT_1)
						return ST_RIGHT;
					else if (radian > R_RIGHT_1 && radian <= R_DOWN_0)
						return ST_RIGHT_DOWN;
					else if (radian > R_DOWN_0 && radian <= R_DOWN_1)
						return ST_DOWN;
					else if (radian > R_DOWN_1 && radian <= R_LEFT_0)
						return ST_LEFT_DOWN;
					else if ((radian > R_LEFT_0 && radian <= Math.PI) || (radian > -Math.PI && radian <= R_LEFT_1))
						return ST_LEFT;
					else if (radian > R_LEFT_1 && radian <= R_UP_0)
						return ST_LEFT_UP;
					else if (radian > R_UP_0 && radian <= R_UP_1)
						return ST_UP;
					else // if (radian > R_UP_1 && radian <= R_RIGHT_0)
						return ST_RIGHT_UP;
				}

				break;
		}

		return ST_CENTER;
	}

	/**
	 * 根据指定的摇杆实例和摇杆模式，计算并返回方向值
	 * @param joystick				摇杆的实例
	 * @param joystickMode			摇杆的械：4向或 8向
	 * @return						方向值
	 */
	public static function getDirectionByJoystick(joystick:IJoystick, joystickMode:uint = 0):uint
	{
		return getDirection(joystick.axisX, joystick.axisY, joystickMode);
	}
}
}
