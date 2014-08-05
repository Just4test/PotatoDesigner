package UIAdjuster
{
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	import core.display.Stage;
	
	import potato.utils.Size;
	
	/**
	 * 单个编辑对象的扩展功能条 in out close...
	 * @author sheep
	 * 
	 */
	public class UIAdjusterItemMenu extends DisplayObjectContainer
	{
		/**
		 * 原始坐标点,用来回查 代码里面的位置 
		 */
		private var strFirstPoint:String = "";
		private var showIn:Boolean;
		private var showOut:Boolean = true;
		private var _showUndo:Boolean;
		private var undoCount:int; // 撤销次数
		public function UIAdjusterItemMenu(obj:DisplayObject)
		{
			super();
			strFirstPoint = obj.x + "," + obj.y;
			showIn = obj is DisplayObjectContainer;
//			showOut = (obj.parent && obj.parent!=UIEditorManager._stage.parent)?true:false;
			goMain();
		}
		
		/**
		 * 扩展功能的主菜单 + 快速undo
		 * in out undo X
		 */
		public function goMain():void{
			clear();
			if(showIn) addBtn("in",function():void{dispatchEvent(new UIAdjusterEvent(UIAdjusterEvent.IN))});
			if(showOut) addBtn("out",function():void{dispatchEvent(new UIAdjusterEvent(UIAdjusterEvent.OUT))});
			if(_showUndo){
				if(undoCount!=1) addBtn("undo",goBack);
				else addBtn("undo",function():void{
					// 如果只有一条操作记录,就不出菜单直接还原
					dispatchEvent(new UIAdjusterEvent(UIAdjusterEvent.BACK_CLEAR));
				});
			}
			addBtn("X",function():void{dispatchEvent(new UIAdjusterEvent(UIAdjusterEvent.CLOSE))});
		}
		
		/**
		 *  扩展功能 撤销子菜单 
		 *  < > << >> X 初始坐标
		 */
		public function goBack():void{
			clear();
			addBtn("  <  ",function():void{dispatchEvent(new UIAdjusterEvent(UIAdjusterEvent.BACK_BACK))});
			addBtn("  >  ",function():void{dispatchEvent(new UIAdjusterEvent(UIAdjusterEvent.BACK_NEXT))});
			addBtn(" << ",function():void{dispatchEvent(new UIAdjusterEvent(UIAdjusterEvent.BACK_FIRST))});
			addBtn(" >> ",function():void{dispatchEvent(new UIAdjusterEvent(UIAdjusterEvent.BACK_LAST))});
			addBtn(" X ",goMain);
			if(strFirstPoint) addBtn("["+strFirstPoint+"]");
		}
		/**
		 * 添加一个自动布局的功能键 
		 * @param str
		 * @param func
		 * 
		 */
		private function addBtn(str:String,func:Function = null):void{
			var btn:UIAdjusterButton = new UIAdjusterButton(str,func,new Size(30,17));
			btn.x = this.width + 5;
			addChild(btn);
		}
		
		/**
		 * 清除所有菜单内容 
		 * 
		 */
		public function clear():void{
			var count:int = this.numChildren;
			var disp:DisplayObject;
			while(count){
				disp = getChildAt(--count);
				disp.dispose();
				removeChild(disp);
			}
		}
		
		/**
		 * 设置是否显示撤销,并统计可撤销次数
		 * @param value
		 * 
		 */
		public function set showUndo(value:Boolean):void
		{
			if(value) undoCount++;
			else undoCount = 0;
			if(undoCount < 3){
				_showUndo = value;
				goMain();
			}
		}
	}
}