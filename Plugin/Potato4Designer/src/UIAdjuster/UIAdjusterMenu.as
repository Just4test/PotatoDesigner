package UIAdjuster
{
	import flash.geom.Point;
	
	import core.display.DisplayObjectContainer;
	
	import potato.events.GestureEvent;
	
	/**
	 * 编辑器主菜单(右上角那里)
	 * 1.刷新 注册的控件自己移动后,不会通知编辑器,需要自己手动更新一下
	 * 2.清除 不用的时候 清空
	 * 3.置顶 在Stage上重新置顶
	 * 4.扩展显/隐 显示或隐藏,除坐标外的其他东西
	 * @author sheep
	 * 
	 */
	public class UIAdjusterMenu extends DisplayObjectContainer
	{
		private var title:UIAdjusterButton;
		private var panel:DisplayObjectContainer = new DisplayObjectContainer;
		private var moveOffset:Point = new Point;;
		public function UIAdjusterMenu()
		{
			super();
			title = new UIAdjusterButton("显/隐+拖",changVisible);
			title.addEventListener(GestureEvent.GESTURE_MOVE,onMove);
			addChild(title);
			panel.y = title.height +20;
			addChild(panel);
			
			initBtns()
		}
		
		/**
		 * 各个功能btn集合 
		 * 
		 */
		private function initBtns():void
		{
			addBtn("刷新",UIAdjusterManager.refresh);
			addBtn("清除",UIAdjusterManager.clear);
			addBtn("置顶",UIAdjusterManager.toTop);
			addBtn("扩展显/隐",UIAdjusterManager.itemMore);
		}
		
		/**
		 * 添加一个自动布局的功能键 
		 * @param str
		 * @param func
		 * 
		 */
		public function addBtn(str:String,func:Function):void{
			var btn:UIAdjusterButton = new UIAdjusterButton(str,func);
			btn.y = panel.height;
			panel.addChild(btn);
		}
//		private function clear():void{
//			UIEditorManager.clear();
//		}
		/**
		 * 显示/隐藏 工具条
		 * 
		 */
		public function changVisible():Boolean{
			panel.visible = !panel.visible;
			return panel.visible;
		}
		/**
		 * 拖动工具条 
		 * @param e
		 * 
		 */
		private function onMove(e:GestureEvent):void
		{
			var moveX:int = e.stageX - moveOffset.x;
			var moveY:int = e.stageY - moveOffset.y;
//			trace(moveX,moveY);
			if(Math.abs(moveX)>20){
				moveOffset.x = e.stageX;
				moveOffset.y = e.stageY;
				return;
			}
			this.x += moveX;
			this.y += moveY;
			moveOffset.x = e.stageX;
			moveOffset.y = e.stageY;
		}
	}
}
