package potato.events.gesture
{
	import core.events.Event;
	
	import potato.events.GestureEvent;
	import potato.ui.UIComponent;
	/**
	 *手势事件处理基类（定义实现规则） 
	 * @author LuXianli
	 * 
	 */	
	public class Gesture
	{
		static public var TOUCH_OFF_LENGTH:int = 50;
		/**
		 *事件触发对象 
		 */		
		protected var _uiComponent:UIComponent;
		/**
		 *手势事件类编号（实现类类名称） 
		 */		
		public var eventID:String = "Gesture";
		/**
		 * 手势事件名
		 */		
		public var eventName:String = "GestureEvent";
		/**
		 * 手势事件基类
		 */		
		public function Gesture()
		{
		}
		
		/**
		 *初始化事件 
		 * @param listener
		 * @param uiComponent	接受实现UI基类实例
		 */		
		public function initEvent(uiComponent:UIComponent,listener:Function):void{
			
		}
		/**
		 * 处理组合事件，可能多次触发事件
		 * @param event	
		 * 
		 */		
		public function optionEvent(event:Event):void{
			
		}
		/**
		 *受保护方法，事件处理完成之后发送事件 
		 * @param event	手势事件
		 * 
		 */		
		protected function dispatchEvent(event:GestureEvent):void{
			_uiComponent.dispatchEvent(event);
		}
		/**
		 *释放本身内存 
		 * 
		 */		
		public function clear():void{
			_uiComponent = null;
		}
		
		private var _touchPointID:int = -1;
		/**
		 * 触摸点的唯一标识符
		 * @return
		 */
		public function get touchPointID():int {
			return _touchPointID;
		}
		public function set touchPointID(value:int):void {
			_touchPointID = value;
		}
	}
}