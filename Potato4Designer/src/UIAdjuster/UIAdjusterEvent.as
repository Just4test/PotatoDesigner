package UIAdjuster
{
	import core.events.Event;
	
	public class UIAdjusterEvent extends Event
	{
		// ================firstType=================== //
		public static var EVENT:String = "UEE_EVENT";			//UIEditor事件
		
		// ================secType=================== //
		public static var IN:String = "UEE_IN";					// 向下一层
		public static var OUT:String = "UEE_OUT";				// 向上一层
		public static var BACK_FIRST:String = "UEE_BACK_FIRST";	// 撤销-最开始
		public static var BACK_BACK:String = "UEE_BACK_BACK";	// 撤销-后退
		public static var BACK_NEXT:String = "UEE_BACK_NEXT";	// 撤销-前进
		public static var BACK_LAST:String = "UEE_BACK_LAST";	// 撤销-最后
		public static var BACK_CLEAR:String = "UEE_BACK_CLEAR";	// 撤销-记录清除
		public static var CLOSE:String = "UEE_CLOSE";			// 关闭编辑功能
		
		public var secType:String;									// 自定义事件数据
		/**
		 *  UIEditorEvent
		 * @param secType	具体操作类型
		 * @param firstType	监听的事件类型
		 * 
		 */
		public function UIAdjusterEvent(secType:String,firstType:String="UEE_EVENT")
		{
			this.secType = secType;
			super(firstType, false);
		}
	}
}