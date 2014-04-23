package potato.events
{
	import core.events.Event;
	
	public class DragEvent extends Event
	{
		/**
		 * 滑动事件.
		 * 手势弹起调度该事件<br/>
		 * 从手势按下，到手势移动，在手势弹起时计算滑动的力量通过event.slideX 和 event.slideY 获得值。<br/>
		 * 取值范围是-100 到 +100<br/>
		 * 手势移动速度加速度达到30毫秒50像素 则值是 -100 或者 +100<br/>
		 * 如果手势结束前30毫秒 * UIGlobal.SLIDE_SMAPLE_COUNT 内没有移动则力量为0<br/>
		 * @see sf.ui.UIGlobal
		 * */
		public static const SLIDE_EVENT:String = "slideEvent";
		
		
		/////////////////// 拖动相关 ///////////////////
		/**
		 * 拖动事件.
		 * 在startDrag() 之后并且开始拖动对象之后，每次移动都会调度
		 */
		public static const DRAGING_EVENT:String = "dragingEvent";
		
		/**
		 * 拖拽结束事件. 
		 */
		public static const DRAGEND_EVENT:String = "dragEndEvent";
		
		
		/**滑动x力量*/
		private var _slideX:int;
		/**滑动y力量*/
		private var _slideY:int;
		
		private var _stageX:Number;
		private var _stageY:Number;
		
		
		public function DragEvent(type:String, bubbles:Boolean=false, stageX:Number = NaN, stageY:Number = NaN, slideX:int = 0, slideY:int = 0)
		{
			super(type, bubbles);
			
			_stageX = stageX;
			_stageY = stageY;
			_slideX = slideX;
			_slideY = slideY;
		}
		
		public function get stageX():Number
		{
			return _stageX;
		}
		
		public function get stageY():Number
		{
			return _stageY;
		}
		
		/**
		 * 滑动x力
		 * @return 
		 */		
		public function get slideX():int
		{
			return _slideX;
		}
		/**
		 * 滑动y力
		 * @return 
		 */		
		public function get slideY():int
		{
			return _slideY;
		}
	}
}