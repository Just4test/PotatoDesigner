package potato.ui
{
	import core.display.DisplayObject;

	/**
	 * Box容器可以水平或垂直排列其子项，默认横向排列
	 * <Box id="" space="30" direction="vertical"></Box>
	 */
	public class Box extends UIComponent
	{
		/**横向排列**/
		public static const HORIZONTAL:String = "horizontal";
		/**纵向排列**/
		public static const VERTICAL:String = "vertical";
		
		/**排列方向**/
		protected var _direction:String;
		/**子项间距**/
		protected var _space:uint;
		/**addChild后是否自动排列子项**/
		protected var _auto:Boolean;
		
		public function Box(__direction:String="horizontal", __space:uint=0, auto:Boolean=false)
		{
			_direction = __direction;
			_space = __space;
			_auto = auto;
		}
		
		/**
		 * 更新子项的位置
		 */
		protected function updateDisplayList():void
		{
			var i:int = 0;
			var m:int = 0;
			var t:int;
			var obj:DisplayObject;
			
			if(HORIZONTAL == _direction)
			{
				while(i < this.numChildren)
				{
					obj = this.getChildAt(i);
					obj.x = m;
					obj.y = 0;
					
					if(obj is UIComponent && UIComponent(obj).expectWidth > 0)
					{
						t = UIComponent(obj).expectWidth;
					}else
					{
						t = obj.width;
					}
					m += t + space;
					i++;
				}
			}else
			{
				while(i < this.numChildren)
				{
					obj = this.getChildAt(i);
					obj.x = 0;
					obj.y = m;
					
					if(obj is UIComponent && UIComponent(obj).expectHeight > 0)
					{
						t = UIComponent(obj).expectHeight;
					}else
					{
						t = obj.width;
					}
					m += t + space;
					i++;
				}
			}
		}
		
		public override function addElement(obj:DisplayObject):DisplayObject
		{
			super.addElement(obj);
			if(_auto)
			{
				updateDisplayList();
			}
			return obj;
		}
		
		public override function addElementAt(obj:DisplayObject, index:int):DisplayObject
		{
			super.addElementAt(obj, index);
			if(_auto)
			{
				updateDisplayList();
			}
			return obj;
		}
		
		public override function removeElement(obj:DisplayObject):DisplayObject
		{
			super.removeElement(obj);
			if(_auto)
			{
				updateDisplayList();
			}
			return obj;
		}
		
		public override function removeElementAt(index:int):DisplayObject
		{
			var obj:DisplayObject = super.removeElementAt(index);
			if(_auto)
			{
				updateDisplayList();
			}
			return obj;
		}
		
		
		public override function render():void
		{
			updateDisplayList();
		}
		
		/**
		 * 设置排列间距
		 */
		public function set space(value:uint):void
		{
			_space = value;
		}
		
		/**
		 * 获取排列间距
		 */
		public function get space():uint
		{
			return _space;
		}
		
		/**
		 * 设置排列方向
		 */
		public function set direction(value:String):void
		{
			if(value == HORIZONTAL)_direction = HORIZONTAL;
			else if(value == VERTICAL)_direction = VERTICAL;
		}
		
		/**
		 * 获取排列方向
		 */
		public function get direction():String
		{
			return _direction;
		}
	}
}