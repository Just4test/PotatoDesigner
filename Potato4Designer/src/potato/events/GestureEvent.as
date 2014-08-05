package potato.events
{
	import core.events.Event;
	
	/**
	 *手势事件类 
	 * @author LuXianli
	 * 
	 */	
	public class GestureEvent extends Event
	{
		/**
		 * 手势 按下事件
		 * */
		static public const GESTURE_DOWN:String = "gestureDown";
		/**
		 * 手势 长按事件
		 * */
		static public const GESTURE_LONG_PRESS:String = "gestureLongPress";
		/**
		 * 手指 移动事件
		 * */
		static public const GESTURE_MOVE:String = "gestureMove";
		/**
		 *手势 移动事件 基于舞台触发 
		 */		
		static public const GESTURE_STAGE_MOVE:String = "gestureStageMove";
		/**
		 * 手势抬起事件
		 * */
		static public const GESTURE_UP:String = "gestureUp";
		/**
		 *手势抬起事件	基于舞台触发 
		 */		
		static public const GESTURE_STAGE_UP:String = "gestureStageUp";
		/**
		 * 手势 开始事件
		 * */
		static public const GESTURE_MULTI_BEGIN:String = "gestureMultiBegin";
		/**
		 * 手势结束事件
		 * */
		static public const GESTURE_MULTI_END:String = "gestureMultiEnd";
		/**
		 * 手势 多指 移动事件
		 * */
		static public const GESTURE_MULTI_MOVE:String = "gestureMultiMove";
		/**
		 * 手势 单指 点击事件
		 * */
		static public const GESTURE_CLICK:String = "gestureClick";
		/**
		 * 手势 双指 点击事件
		 * */
		static public const GESTURE_TWO_CLICK:String = "gestureTwoClick";
		/**
		 * 手势 三指 点击事件
		 * */
		static public const GESTURE_THREE_CLICK:String = "gestureThreeClick";
		/**
		 *手势事件	指定区域内	单指上滑 事件 
		 */		
		static public const GESTURE_SLIDE_UP:String = "gestureSlideUp";
		/**
		 *手势事件 	指定区域内	单指下滑事件 
		 */		
		static public const GESTURE_SLIDE_DOWN:String = "gestureSlideDown";
		/**
		 *手势事件	指定区域内	单指左滑事件 
		 */		
		static public const GESTURE_SLIDE_LEFT:String = "gestureSlideLeft";
		/**
		 *手势事件	指定区域内	单指右滑事件 
		 */		
		static public const GESTURE_SLIDE_RIGHT:String = "gestureSlideRight";
		/**
		 *手势事件	指定区域内	双指外滑事件 
		 */		
		static public const GESTURE_SLIDE_OUT:String = "gestureSlideOut";
		/**
		 *手势事件	指定区域内	双指内滑事件 
		 */		
		static public const GESTURE_SLIDE_IN:String = "gestureSlideIn";
		
		public function GestureEvent(type:String, bubbles:Boolean = false, stageX:Number = 0, stageY:Number = 0 )
		{
			super(type, bubbles);
			_type = type;
			_bubbles = bubbles;
			_stageX = stageX;
			_stageY = stageY;
		}
		
		private var _bubbles:Boolean = false;
		private var _type:String = "";
		override public function clone():Event 
		{
			var gestureEvent:GestureEvent = new GestureEvent(_type, _bubbles, _stageX, _stageY);
			gestureEvent.localX = _localX;
			gestureEvent.localY = _localY;
			gestureEvent.distanceX = _distanceX;
			gestureEvent.distanceY = _distanceY;
			gestureEvent.touchPointID = touchPointID;
			gestureEvent.setGestureTarget(target);
			gestureEvent.gesturePoints = _gesturePoints;
			return gestureEvent;
		}
		
		public override function toString():String{
			return formatToString("GestureEvent","type", "bubbles","touchPointID","stageX","stageY");
		}
		
		/**
		 *设定当前target属性 
		 * @param gestureTarget
		 * 
		 */		
		public function setGestureTarget(gestureTarget:Object):void{
			if(hasOwnProperty("setTarget"))this["setTarget"](gestureTarget);
			else _target = gestureTarget;
		}
		
		private var _target:Object;
		/**
		 *返回值 触发事件对象
		 * @return 
		 * 
		 */		
		public override function get target():Object{
			if(_target)return _target;
			else return super.target;
		}
		
		private var _gesturePoints:Array = [];
		/**
		 * 得到点击点 （多点）
		 * @return _gesturePoints 点击点数组[GesturePoint]
		 * */
		public function get gesturePoints():Array{
			return _gesturePoints;
		}
		public function set gesturePoints(value:Array):void{
			_gesturePoints = value;
		}
		
		/**
		 * 设置与获取 本地 X坐标
		 */
		private var _localX:Number = 0;
		public function set localX(value:Number):void {
			_localX = value;
		}
		public function get localX():Number {
			return _localX;
		}
		/**
		 * 设置与获取 本地 Y坐标
		 */
		private var _localY:Number = 0;
		public function set localY(value:Number):void {
			_localY = value;
		}
		public function get localY():Number {
			return _localY;
		}
		
		private var _stageX:Number = 0;
		/**
		 * 得到当前点击点舞台X坐标
		 * @return _stageX  当前舞台X坐标
		 */
		public function get stageX():Number {
			return _stageX;
		}
		
		private var _stageY:Number = 0;
		/**
		 * 得到当前点击点舞台Y坐标
		 * @return _stageY  当前舞台Y坐标
		 */
		public function get stageY():Number {
			return _stageY;
		}

		private var _distanceX:Number = 0;
		/**
		 * 设置从起点开始到目前为止在 X 轴向上滑动的距离。
		 * @param value         X 轴向上滑动的距离
		 */
		public function set distanceX(value:Number):void
		{
			if (_distanceX != value)
			{
				_distanceX = value;

				// 因为条件变化了，需要把 LAZY 计算属性清空
				clearLazyProperties();
			}
		}
		/**
		 * 获取从起点开始到目前为止在 X 轴向上滑动的距离
		 */
		public function get distanceX():Number
		{
			return _distanceX;
		}

		private var _distanceY:Number = 0;
		/**
		 * 设置从起点开始到目前为止在 Y 轴向上滑动的距离。
		 * @param value         Y 轴向上滑动的距离
		 */
		public function set distanceY(value:Number):void
		{
			if (_distanceY != value)
			{
				_distanceY = value;

				// 因为条件变化了，需要把 LAZY 计算属性清空
				clearLazyProperties();
			}
		}
		/**
		 * 获取从起点开始到目前为止在 X 轴向上滑动的距离
		 */
		public function get distanceY():Number
		{
			return _distanceY;
		}

		/**
		 * 清除 distance 和 rotation 这两个 LAZY 计算属性
		 */
		private function clearLazyProperties():void
		{
			_distance = undefined;
			_rotation = undefined;
		}
		
		private var _rotation:Number = undefined;
		/**
		 *设定滑动产生的角度 
		 * @param value
		 * 
		 */		
		/*public function set rotation(value:Number):void {
			_rotation = value;
		}*/

		/**
		 *得到滑动产生的弧度（起点向右为 0 度，起点向上为 -pi/2 度，向下为 pi/2 度，顺时针方向为正，值范围：[-pi ~ pi]）
		 * @return 
		 * 
		 */		
		public function get rotation():Number {
			if (!_rotation)
				_rotation = Math.atan2(distanceY, distanceX);

			return _rotation;
		}
		
		private var _distance:Number = undefined;
		/**
		 *设定滑动距离 
		 * @param value
		 * 
		 */		
		/*public function set distance(value:Number):void{
			_distance = value;
		}*/
		/**
		 *得到滑动距离 
		 * @return 
		 * 
		 */		
		public function get distance():Number{
			if (!_distance)
				_distance = Math.sqrt(distanceX * distanceX + distanceY * distanceY);

			return _distance;
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