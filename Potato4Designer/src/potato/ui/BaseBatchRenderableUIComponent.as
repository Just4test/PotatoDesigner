/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 12-11-16
 * Time: 上午9:42
 * To change this template use File | Settings | File Templates.
 */
package potato.ui
{
	import core.events.TimerEvent;
	import core.utils.Timer;
	
	/**
	 * 可批量渲染的 UIComponent 组件基础类
	 */
	public class BaseBatchRenderableUIComponent extends UIComponent implements IBatchRenderableUIComponent
	{
		// 批量渲染的延时毫秒数
		// 使用 15 毫秒作为 Timer 的运行时间，
		// 因为在一个 60fps 的游戏里，在不掉帧的情况下，
		// 两帧间隔为 16.6666666 毫秒，所以采用小一点的整值
		// 以初步保证在进入下一帧之前，统一调度渲染计算
		private static const BATCH_RENDER_MILLIONSECONDS:uint = 15;
		
		// 批量渲染的计时器。
		// 为了防止反复调用 render 造成的重复计算，特别使用一个计时器，在 fps 间隔之间才进行真正的渲染
		private var _batchRenderTimer:Timer;
		
		/**
		 * 请求渲染
		 */
		override public function render():void
		{
			if (!_batchRenderTimer)
			{
				_batchRenderTimer = new Timer(BATCH_RENDER_MILLIONSECONDS, 1);
				_batchRenderTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onBatchRenderTimerCompleteHandler);
			}
			
			_batchRenderTimer.stop();
			_batchRenderTimer.reset();		// 尼玛 AVM 里需要调用 reset 方法来清空计时
			_batchRenderTimer.start();
		}
		
		/**
		 * 立即渲染
		 * 等子类重写这个方法，完成实际的渲染计算
		 * 子类中推荐在这个方法一开始，调用 super.renderImmediately() 调用清理方法
		 */
		public function renderImmediately():void
		{
			if (_batchRenderTimer && _batchRenderTimer.running)
			{
				_batchRenderTimer.stop();
				_batchRenderTimer.reset();
			}
		}
		
		/**
		 * 如果还未渲染，则马上进行渲染操作
		 */
		//	protected function ensureRenderImmediately():void
		//	{
		////		if (_batchRenderTimer && _batchRenderTimer.running)
		//			renderImmediately();
		//	}
		
		private function onBatchRenderTimerCompleteHandler(e:TimerEvent):void
		{
			renderImmediately();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if (_batchRenderTimer)
			{
				if (_batchRenderTimer.running)
					_batchRenderTimer.stop();
				
				_batchRenderTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onBatchRenderTimerCompleteHandler);
				_batchRenderTimer = null;
			}
		}
	}
}
