/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 12-11-15
 * Time: 上午10:03
 * To change this template use File | Settings | File Templates.
 */
package potato.transitions
{
import core.display.DisplayObjectContainer;

import potato.tweenlite.TweenLite;
import potato.tweenlite.easeing.Circ;
import potato.ui.Dialog;

public class DialogTransition implements ITransition
{
	private var tl:TweenLite;
	private var tl2:TweenLite;

	public function DialogTransition():void
	{
	}

	/**
	 * 执行过场动画
	 * @param parent		父级
	 * @param complete		执行完成回调
	 * @param ing			执行过程中回调
	 * @param args fromPt:Point 动画起始坐标, isClose:boolean 是否是关闭阶段
	 *
	 */
	public function doTransition(parent:DisplayObjectContainer, complete:Function=null, ing:Function=null, args:Object=null):void
	{
		var tox:int = parent.x;
		var toy:int = parent.y;

		if (args != null && args.hasOwnProperty("fromPt")) {
			parent.x = args.fromPt.x;
			parent.y = args.fromPt.y;
		} else {
			parent.x = 0;
			parent.y = 0;
		}
		if (args.isClose == true) {
			tl = TweenLite.to(parent, 0.5, {scaleX:0.1, scaleY:0.1, x:tox, y:toy, alpha:0, ease:Circ.easeOut, onComplete:complete});
			if (Dialog.isNotRemainModal() && Dialog(parent).modal && Dialog.modalBmp != null) {
				tl2 = TweenLite.to(Dialog.modalBmp, 0.5, {alpha:0});
			}
		} else {
			parent.scaleX = parent.scaleY = 0.1;
			parent.alpha = 0;
			tl = TweenLite.to(parent, 0.5, {scaleX:1, scaleY:1, x:tox, y:toy, alpha:1, ease:Circ.easeOut});
		}
	}

	public function stopTransition():void
	{
		if (tl != null) {
			tl.kill();
		}
		if (tl2 != null) {
			tl2.kill();
		}
	}
}
}
