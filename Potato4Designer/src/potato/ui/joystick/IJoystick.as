/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 12-12-3
 * Time: 下午4:47
 * To change this template use File | Settings | File Templates.
 */
package potato.ui.joystick
{
	import core.events.EventDispatcher;

[Event(name="joystick_press", type="potato.events.JoystickEvent")]
[Event(name="joystick_update", type="potato.events.JoystickEvent")]
[Event(name="joystick_release", type="potato.events.JoystickEvent")]

/**
 * 摇杆类公共接口
 */
public interface IJoystick
{
	/**
	 * 摇杆在 X 轴向上的偏移值
	 * 范围在 -128 ~ 127 之间
	 * 负数表示向左，正数表示向右
	 */
	function get axisX():int;

	/**
	 * 摇杆在 Y 轴向上的偏移值
	 * 范围在 -128 ~ 127 之间
	 * 负数表示向左，正数表示向右
	 */
	function get axisY():int;
	
	/**
	 * 返回一个监听事件的对象 
	 * @return 
	 */	
	function get eventDispatcher():EventDispatcher;
}
}
