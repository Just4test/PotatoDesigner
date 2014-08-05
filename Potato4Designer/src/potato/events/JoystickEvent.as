/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 12-12-3
 * Time: 下午5:12
 * To change this template use File | Settings | File Templates.
 */
package potato.events
{
import core.events.Event;

/**
 * 由摇杆对象派发的事件，它返回摇杆在 X 和 Y 轴向上的原始数值。
 * 原始数值的范围都在 -128 ~ 127 之间，
 * 这样的设计是为了和硬件摇杆兼容。
 */
public class JoystickEvent extends Event
{
	public static const JOYSTICK_PRESS:String = 'joystick_press';
	public static const JOYSTICK_UPDATE:String = 'joystick_update';
	public static const JOYSTICK_RELEASE:String = 'joystick_release';

	public var axisX:int;
	public var axisY:int;

	public function JoystickEvent(type:String, axisX:int=0, axisY:int=0, bubbles:Boolean=false):void
	{
		this.axisX = axisX;
		this.axisY = axisY;

		super(type, bubbles);
	}

	override public function clone():Event
	{
		return new JoystickEvent(type, axisX, axisY, bubbles);
	}
}
}
