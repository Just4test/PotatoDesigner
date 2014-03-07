package potato.ui
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	import core.events.Event;
	
	import potato.events.DragEvent;
	import potato.events.GestureEvent;
	import potato.events.gesture.Gesture;
	import potato.events.gesture.GestureClass;
	
	/**
	 * 手势 按下事件
	 * */
	[Event(name="gestureDown", type="potato.events.GestureEvent")]
	/**
	 * 手势 长按事件
	 * */
	[Event(name="gestureLongPress", type="potato.events.GestureEvent")]
	/**
	 * 手势 单指移动事件
	 * */
	[Event(name="gestureMove", type="potato.events.GestureEvent")]
	/**
	 * 手势 抬起事件
	 * */
	[Event(name="gestureUp", type="potato.events.GestureEvent")]
	/**
	 * 手势 开始事件
	 * */
	[Event(name="gestureMultiBegin", type="potato.events.GestureEvent")]
	/**
	 * 手势结束事件
	 * */
	[Event(name="gesturMultieEnd", type="potato.events.GestureEvent")]
	/**
	 * 手势移动事件
	 * */
	[Event(name="gestureMultiMove", type="potato.events.GestureEvent")]
	/**
	 * 手势单指点击事件
	 * */
	[Event(name="gestureClick", type="potato.events.GestureEvent")]
	/**
	 * 手势双指点击事件
	 * */
	[Event(name="gestureTwoClick", type="potato.events.GestureEvent")]
	/**
	 * 手势三指点击事件
	 * */
	[Event(name="gestureThreeClick", type="potato.events.GestureEvent")]

	/**
	 * 基础控件类
	 *
	 * XML 配置示例如下：
	 * <code>
	 * &lt;UIComponent width=100 height=100 id="aaa" name="aaa" expectWidth=100 expectHeight=100 posRow="0" posCol="0"&gt;&lt;/UIComponent&gt;
	 * </code>
	 * 控件是一种特殊的显示对象，它及它的子类们，拥有可以经由 XML 配置文件装配成舞台上显示对象的能力。
	 * 另外它也是手势事件的接收基础，手势类所产生的事件和动作，都能被发送到 UIComponent 类对象中。
	 * 
	 * isStopEvent（false） 此容器存在手势事件的情况下，是否截断底层touchEvent事件流
	 * isMultiTouch（false） 设置此容器是否支持多指事件 【必须在添加手势事件之前设置】【此属性只对当前容器有效，对父容器和子容器无效】
	 */	
	public class UIComponent extends DisplayObjectContainer
	{
		/**编号**/
		protected var _id:String;
		/**名称**/
		protected var _name:String;
		/**期望宽度**/
		protected var _expectWidth:Number;
		/**期望高度**/
		protected var _expectHeight:Number;
		/**放入虚拟网格位置，只有父容器为SmartLayout时才真正有效**/
		protected var _posRow:uint;
		/**放入虚拟网格位置，只有父容器为SmartLayout时才真正有效**/
		protected var _posCol:uint;
		/**子节点引用，默认XML根节点有；如果需要指定组件需要为根，则实例化该字典**/
		protected var _children:Dictionary;
		/**图片资源临时存放**/
		protected var _renderArr:Array;
		/**指示该节点的根节点**/
		public var UIRoot:UIComponent;
		/**是否是容器类型**/
		protected var _isContainer:Boolean = true;
		/**是否阻止底层事件的派发**/
		private var _isStopEvent:Boolean = false;
		/**是否支持多点事件**/
		private var _isMultiTouch:Boolean = false;
		public function UIComponent()
		{
			
		}
		
		private var _gestureEventArr:Array = [];
		/**
		 *添加监听函数 
		 * @param type	 事件名字
		 * @param listener	触发函数
		 * 
		 */		
		override public function addEventListener(type:String, listener:Function):void{
			
			super.addEventListener(type,listener);
			
			var event:Gesture = GestureClass.getGestureClass(type);
			if(event && isGestureEventNotPushed(event)){
				event.initEvent(this,flushEvent);
				_gestureEventArr.push(event);
			}
		}
		
		override public function removeEventListener(type:String, listener:Function):void{
			
			super.removeEventListener(type,listener);
			
			if(!hasEventListener(type))removeGestureEvent(type);
		}
		override public function removeEventListeners(type:String=null):void{
			
			super.removeEventListeners(type);
			removeGestureEvent(type);
		}
		/**
		 *便利事件处理类 
		 * @param event
		 * 
		 */		
		public function flushEvent(event:Event):void{
			
			for each(var gesture:Gesture in _gestureEventArr){
				gesture.optionEvent(event);
			}
			if(_isStopEvent)event.stopPropagation();
			
		}
		
		public function set isStopEvent(value:Boolean):void{
			_isStopEvent = value;
		}
		
		public function set isMultiTouch(value:Boolean):void{
			_isMultiTouch = value;
		}
		public function get isMultiTouch():Boolean{
			return _isMultiTouch;
		}
		
		/**
		 *检查当前事件数组是否存在此事件 
		 * @param id	手势类ID
		 * @return 
		 * 
		 */		
		private function isGestureEventNotPushed(event:Gesture):Boolean{
			
			for (var i:uint= 0, m:uint=_gestureEventArr.length; i<m; i++)
			{
				if(_gestureEventArr[i].eventID == event.eventID)
					return false;
			}
			return true;
		}
		/**
		 *移除指点手势事件 
		 * @param type
		 * 
		 */		
		private function removeGestureEvent(type:String = null):void{
			if(type){
				
				var index:int = -1;
				for (var i:int = 0, m:int = _gestureEventArr.length;i<m;i ++){
					var typeEvent:Gesture = _gestureEventArr[i];
					if(typeEvent.eventName == type){
						typeEvent.clear();
						typeEvent = null;
						index = i;
						break;
					}
					typeEvent = null;
				}
				if(index != -1)
					_gestureEventArr.splice(index,1);
			}
			else
			{
				for each(var event:Gesture in _gestureEventArr){
					event.clear();
				}
				_gestureEventArr = [];
			}
		}
		
		public function toString():String
		{
			return this["constructor"];
		}
		
		/**
		 * 期望宽度
		 * @param value
		 */
		public function set expectWidth(value:Number):void
		{
			_expectWidth = value;
		}
		
		/**
		 * 期望高度
		 * @param value
		 */
		public function set expectHeight(value:Number):void
		{
			_expectHeight = value;
		}
		
		/**
		 * 期望宽度
		 * @param value
		 */
		public function get expectWidth():Number
		{
			return _expectWidth;
		}
		
		/**
		 * 期望高度
		 * @param value
		 */
		public function get expectHeight():Number
		{
			return _expectHeight;
		}
		
		/**
		 * 放入虚拟网格行位置
		 * 只有父容器为SmartLayout时，才起效
		 */
		public function set posRow(value:uint):void
		{
			_posRow = value;
		}
		
		/**
		 * 获取虚拟网格行位置
		 */
		public function get posRow():uint
		{
			return _posRow;
		}
		
		/**
		 * 放入虚拟网格列位置
		 * 只有父容器为SmartLayout时，才起效
		 */
		public function set posCol(value:uint):void
		{
			_posCol = value;
		}
		
		/**
		 * 获取虚拟网格列位置
		 */
		public function get posCol():uint
		{
			return _posCol;
		}
		
		/**
		 * 当前对象的名称
		 * @default null
		 * @return
		 */
		public function get name():String
		{
			return _name;
		}
		
		/**
		 * @private
		 * @param value
		 */
		public function set name(value:String):void
		{
			_name = value;
		}
		
		/**
		 * @private
		 * @param value
		 */
		public function set id(value:String):void
		{
			_id = value;
		}
		
		/**
		 * 当前对象的名称
		 * @default null
		 * @return
		 */
		public function get id():String
		{
			return _id;
		}
		
		/**
		 * 是否是根节点
		 */
		public function isRoot():Boolean
		{
			if(_children)return true;
			else return false;
		}

		/**
		 * 设置节点为根节点
		 */
		public function setRoot(b:Boolean):void
		{
			if(b)
			{
				_children = new Dictionary();
			}else
			{
				_children = null;
			}
		}
		
		/**
		 * 获取是否是容器类型
		 */
		public function get isContainer():Boolean
		{
			return _isContainer;
		}
		
		/**
		 * 渲染，由于配置属性存在顺序问题，或有图片延迟显示，需重写该函数
		 */
		public function render():void
		{
			//需要渲染的子类需重写该函数
		}
		
		/**
		 * 子节点引用
		 */
		public function get children():Dictionary
		{
			return _children;
		}
		
		/**
		 * 查找子节点
		 */
		public function findViewById(ids:String):DisplayObject
		{
			if(isRoot())
			{
				var i:Number = ids.indexOf(".");
				if(-1 == i)
				{
					return _children[ids];
				}else
				{
					var k:String = ids.substring(0, i);
					/*if(_children[k] && _children[k] is UIComponent && UIComponent(_children[k]).isRoot())
					{
						return UIComponent(_children[k]).findViewById(ids.substr(i+1));
					}else
					{
						return null;
					}*/
					var object:Object = _children[k];
					var component:UIComponent = (object) ? object as UIComponent : null;
					return (component && component.isRoot()) ? component.findViewById(ids.substr(i+1)) : null;
				}
			}else if(this.UIRoot)
			{
				return UIRoot.findViewById(ids);
			}else
			{
				return null;
			}
			
			
		}
		
		/**
		 * 添加元素，相当于原addChild
		 */
		public function addElement(obj:DisplayObject):DisplayObject
		{
			super.addChild(obj);
			setupRootForComponent(obj);

			return obj;
		}
		
		/**
		 * 添加元素，相当于原addChildAt
		 */
		public function addElementAt(obj:DisplayObject, index:int):DisplayObject
		{
			super.addChildAt(obj, index);
			setupRootForComponent(obj);

			return obj;
		}

		private function setupRootForComponent(displayObject:DisplayObject):void
		{
			var component:UIComponent = displayObject as UIComponent;

			if (component)
			{
				var __root:UIComponent;
				if (isRoot())
				{
					__root = this;
				} else
				{
					__root = this.UIRoot;
				}

				if (__root && __root == component.UIRoot)
				{
					if (component.id)
						__root.children[component.id] = component;
				}
				else
				{
					setRootForComponent(component, __root);
				}
			}
		}
		
		/**
		 * 在根节点中添加当前对象的引用
		 */
		public function addToRoot():void
		{
			if(this.UIRoot)
			{
				if(this.id)this.UIRoot.children[this.id] = this;
				
				var __root:UIComponent = this.UIRoot;
				/*var obj:DisplayObject;
				var len:int = this.numChildren;
				while(len > 0)
				{
					obj = this.getChildAt(len-1);
					if(obj is UIComponent)
					{
						UIComponent(obj).root = __root;
						UIComponent(obj).addToRoot();
					}
					len--;
				}*/
				for (var i:int = 0, m:int = numChildren; i<m; i++)
				{
					setRootForComponent(getChildAt(i), __root);
				}
			}
		}

		/**
		 * 为一个疑似为组件的显示对象指定根结点
		 * @param displayObject         疑似为组件的显示对象
		 * @param root                  要指定的根结点
		 */
		private function setRootForComponent(displayObject:DisplayObject, root:UIComponent):void
		{
			var component:UIComponent = displayObject as UIComponent;
			if (component)
			{
				component.UIRoot = root;
				component.addToRoot();
			}
		}
		
		/**
		 * 移除元素，相当于原removeChild
		 */
		public function removeElement(obj:DisplayObject):DisplayObject
		{
			super.removeChild(obj);
			clearAsUIComponent(obj);

			return obj;
		}
		
		/**
		 * 移除指定索引的元素，相当于removeChildAt
		 */
		public function removeElementAt(index:int):DisplayObject
		{
			var obj:DisplayObject = super.removeChildAt(index);
			clearAsUIComponent(obj);

			return obj;
		}

		private function clearAsUIComponent(displayObject:DisplayObject):void
		{
			var component:UIComponent = displayObject as UIComponent;
			if(component && component.id && component.UIRoot)
			{
				delete component.UIRoot.children[component.id];
			}
		}
		
		/**
		 * 清理根节点对当前节点及子节点的引用
		 */
		public function clear():void
		{	
			if(this.UIRoot && this.UIRoot.children && this.UIRoot.children[this.id])
			{
				delete this.UIRoot.children[this.id];
			}
			
			var obj:UIComponent;
			for (var i:int = 0, m:int = numChildren; i<m; i++)
			{
				obj = getChildAt(i) as UIComponent;

				if (obj)
					obj.clear();
			}
		}
		
		/**
		 * 清理引用，并且清理事件
		 */
		override public function dispose():void
		{
			removeGestureEvent();
			
			clear();
			if(isRoot())_children = null;

			super.dispose();
		}
		
		public override function addChild(disObj:DisplayObject):DisplayObject
		{
			return addElement(disObj);
		}
		
		public override function addChildAt(disObj:DisplayObject, index:int):DisplayObject
		{
			return addElementAt(disObj, index);
		}
		
		public override function removeChild(disObj:DisplayObject):DisplayObject
		{
			return removeElement(disObj);
		}
		
		public override function removeChildAt(index:int):DisplayObject
		{
			return removeElementAt(index);
		}
		/**
		 * 移除多个子对象
		 * @param index		开始索引
		 * @param end		结束索引
		 */
		public function removeChildren(index:int = 0, end:int = int.MAX_VALUE):void
		{
			if(numChildren < 1)return;
			if (index == end)
			{
				removeElementAt(index);
				return;
			}
			else if (index > end)
			{
				var temp:int = index;
				index = end;
				end = temp;
			}

			index = index > numChildren - 1 ? (numChildren - 1 > 0 ? numChildren - 1 : 0 ): index;
			end = end > numChildren - 1 ? (numChildren - 1 > 0 ? numChildren - 1 : 0 ) : end;
			
			for (var i:int = end; i>=index; i--)
			{
				removeElementAt(i);
			}
		}

		private static var isDraging:Boolean = false;
		
		/**
		 * 是否启用拖动
		 */
		public var dragEnable:Boolean = false;
		/**按下之后是否移动过*/
		private var moved:Boolean;
		/**可拖动范围*/
		private var _dragRect:Rectangle;
		
		/**开始拖拽时的对象坐标x*/
		private var startDragX:int;
		/**开始拖拽时的对象坐标y*/
		private var startDragY:int;
		
		/**按下开始的舞台x*/
		private var touchX:int;
		/**按下开始的舞台y*/
		private var touchY:int;
		
		/**当前按下的舞台x*/
		private var curTouchX:int;
		/**当前按下的舞台y*/
		private var curTouchY:int;
		
		/**移动过程中被采样的点*/
		private var samplePoints:Array = [];
		/**上次移动时间*/
		private var upMoveTime:int;
		/**应该像哪个索引添加*/
		private var index:int;
		
		/**
		 * 判断力量
		 */
		private function ifPorw():void
		{
			var speedX:Number = 0;
			var speedY:Number = 0;
			
			if (samplePoints)
			{
				if (samplePoints.length > UIGlobal.SLIDE_SMAPLE_COUNT)
				{
					samplePoints = samplePoints.slice(samplePoints.length - UIGlobal.SLIDE_SMAPLE_COUNT);
				}
				
				var uptime:int = -1;
				var upx:int = -1;
				var upy:int = -1;
				
				for (var i:int = 0; i < samplePoints.length; i++)
				{
					if (samplePoints[i] is Point)
					{
						if (upx == -1)
						{
							upx = samplePoints[i].x;
							upy = samplePoints[i].y;
							uptime = i * 30;
							i = samplePoints.length - 2;
							continue;
						}
						//当前移动x距离
						var csx:Number = samplePoints[i].x - upx;
						//当前移动y距离
						var csy:Number = samplePoints[i].y - upy;
						//当前移动时间
						var t:int = i * 30 - uptime;
						//加速度
						speedX = csx / (.5 * t * t) * t;
						speedY = csy / (.5 * t * t) * t;
						
						speedX *= 30;
						speedY *= 30;
						if (speedX > 100)
							speedX = 100;
						if (speedX < -100)
							speedX = -100;
						
						if (speedY > 100)
							speedY = 100;
						if (speedY < -100)
							speedY = -100;
					}
				}
			}
			
			if (hasEventListener(DragEvent.SLIDE_EVENT))
			{
				dispatchEvent(new DragEvent(DragEvent.SLIDE_EVENT, false, NaN, NaN, speedX, speedY));
			}
		}
		
		
		/**
		 * 在移动中收集过程中的点。用于计算滑动的力量
		 */
		private function samplePoint(e:GestureEvent):void
		{
			if (samplePoints.length > 0)
			{
				var now:int = getTimer();
				var time:int = now - upMoveTime;
				if (time < 30)
					return;
				
				var stageX:int = e.stageX;
				var stageY:int = e.stageY;
				var x:int = (stageX - samplePoints[index].x);
				var y:int = (stageY - samplePoints[index].y);
				upMoveTime = now;
				index = index + int(time / 30);
				samplePoints[index] = new Point(stageX, stageY);
			}else{
				samplePoints[index] = new Point(e.stageX,e.stageY);
			}
		}
		/**
		 * 开始拖动.
		 * 该方法必须在手势按下之前调用有效.
		 * @param rect	可拖动的范围。
		 */
		public function startDrag(rect:Rectangle = null):void
		{
//			if (isDraging)
//			{
////				trace("Error, an component object is already been draging....");
////				return;
//				stopDrag();
//				startDrag(rect);
//			}
			
			samplePoints = [];
			upMoveTime = getTimer();
			index = 0;
//			samplePoints[0] = new Point(CursorManager.lastTouchX, CursorManager.lastTouchY);
			moved = true;
			isDraging = true;
			UIGlobal.GESTURE_SLIDE_EVENT_FLAG = false;
			UIGlobal.GESTURE_PANEL_DRAG_FLAG = false;
			this.addEventListener(GestureEvent.GESTURE_STAGE_MOVE, dragHandler);
			this.addEventListener(GestureEvent.GESTURE_STAGE_UP, dragEndHandler);
			
			touchX = -1;
			touchY = -1;
			
			startDragX = this.x;
			startDragY = this.y;
			
			_dragRect = rect;
		}
		
		private function dragHandler(e:GestureEvent):void
		{
			if (touchX == -1)
			{
				/// 由于取不到当前鼠标的舞台坐标，头一次用来取坐标，不移动
				touchX = e.stageX;
				touchY = e.stageY;
				return;
			}
			
			curTouchX = e.stageX;
			curTouchY = e.stageY;
			
			var dX:int = curTouchX - touchX;
			var dY:int = curTouchY - touchY;
			
			var newThisX:int = startDragX + dX;
			var newThisY:int = startDragY + dY;
			
			if (_dragRect)
			{
				if (newThisX < _dragRect.x)
					newThisX = _dragRect.x;
				if (newThisX > _dragRect.right)
					newThisX = _dragRect.right;
				
				if (newThisY < _dragRect.y)
					newThisY = _dragRect.y;
				if (newThisY > _dragRect.bottom)
					newThisY = _dragRect.bottom;
			}
			
			this.x = newThisX;
			this.y = newThisY;
			
			samplePoint(e);
			
			dispatchEvent(new DragEvent(DragEvent.DRAGING_EVENT, false, e.stageX, e.stageY));
		}
		
		private function dragEndHandler(e:GestureEvent):void
		{
			stopDrag();
			
			// 拖拽结束事件
			dispatchEvent(new DragEvent(DragEvent.DRAGEND_EVENT, false, e.stageX, e.stageY));
		}
		
		/**
		 * 停止拖动
		 */
		public function stopDrag():void
		{
			isDraging = false;
			UIGlobal.GESTURE_SLIDE_EVENT_FLAG = true;
			UIGlobal.GESTURE_PANEL_DRAG_FLAG = true;
			this.removeEventListener(GestureEvent.GESTURE_STAGE_MOVE, dragHandler);
			this.removeEventListener(GestureEvent.GESTURE_STAGE_UP, dragEndHandler);
			
			this.ifPorw();
		}
		
		private var _touchPointID:int = -1;
		/**
		 * 触摸点的唯一标识符
		 *
		 * 如果该标识符与手势事件的 ID 不同，
		 * 则对象实例会无法接收到对应的手势事件。
		 *
		 * @return
		 */
		public function get touchPointID():int {
			return _touchPointID;
		}
		public function set touchPointID(value:int):void {
			if (_touchPointID != value)
			{
				_touchPointID = value;

				// 如果当前为容器类型，则还要把所有子组件的 touchPointID 与设置的事件 ID 做同步
				// 否则就会出现子组件无法接收触摸事件的现象
				if (isContainer)
				{
					var child:UIComponent;
					for (var i:uint = 0, m:uint = numChildren; i<m; i++)
					{
						child = getChildAt(i) as UIComponent;
						if (child)
							child.touchPointID = value;
					}
				}
			}
		}
	}
}