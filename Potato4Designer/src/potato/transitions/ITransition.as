package potato.transitions
{
	import core.display.DisplayObjectContainer;

	/**
	 * 过场动画接口
	 * @author Floyd
	 * May 31, 2012
	 */
	public interface ITransition
	{
		/**
		 * 执行过场动画 
		 * @param parent		父级
		 * @param ing			执行过程中回调
		 * @param complete		执行完成回调
		 * @param args			可选参数
		 */
		function doTransition(parent:DisplayObjectContainer, complete:Function = null, ing:Function = null, args:Object=null):void;
		
		/**
		 * 马上终止并停止在当前进度
		 */
		function stopTransition():void;
	}
}