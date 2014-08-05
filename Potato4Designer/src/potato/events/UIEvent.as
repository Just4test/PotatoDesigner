package potato.events
{
	import core.events.Event;
	
	/**
	 * 按钮事件
	 * @author Floyd
	 * Apr 25, 2012
	 */
	public class UIEvent extends Event
	{
		/**
		 * 对话框关闭事件
		 * */
		public static const STARTCLOSE:String = "startclose";
		
		/**
		 * 开始移动事件. 
		 */
		public static const STARTMOVE_EVENT:String = "startMoveEvent";
		
		
		/**
		 * 滑动条刻度改变事件.
		 * 在滑动条拖动，改变后调度.<br/>
		 * @see sf.ui.SlideBar
		 */
		public static const SLIDE_BAR_CHANGE:String = "slideBarChange";
		
		/**
		 * SlideBar		拖动后会派发
		 * <br/>
		 * ButtonBar	选项发生改变会派发
		 * <br/>
		 * Panel 		拖动后会派发
		 * */
		public static const CHANGE:String = "change";
		/**
		 * panel拖动完成，停止的时候派发 
		 */
		public static const STOP:String = "stop";
		
		public static const COMPLETE:String = "complete";
		/**Tab翻页的时候派发*/
		public static const PAGE_CHANGE:String = "pageChange";
		/**Tab页面数量变动的时候派发*/
		public static const PAGE_NUM_CHANGE:String = "pageNumChange";
		/**列表控件滚动个数改变派发*/
		public static const LIST_PAGE_CHANGE:String = "listPageChange";
		/**数字改变*/
		public static const NUM_CHANGE:String = "numChange";
		
		/**
		 * 传送的附加数据
		 */		
		public var data:Object = new Object();		//
		
		private var _localX:Number;
		private var _lovalY:Number;
		private var _stageX:Number;
		private var _stageY:Number;
		
		public function UIEvent(type:String, bubbles:Boolean=true, localX:Number=NaN, localY:Number=NaN, stageX:Number = NaN, stageY:Number = NaN)
		{
			super(type, bubbles);
			_localX = localX;
			_lovalY = localY;
			_stageX = stageX;
			_stageY = stageY;
		}
		
		public function get localX():Number{
			return _localX;
		}
		
		public function get localY():Number{
			return _lovalY;
		}
		
		public function get stageX():Number
		{
			return _stageX;
		}
		
		public function get stageY():Number
		{
			return _stageY;
		}
		
	}
}