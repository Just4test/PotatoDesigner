package UIAdjuster
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	import core.display.Quad;
	import core.display.Stage;
	import core.events.Event;
	import core.events.TouchEvent;
	import core.text.TextField;
	
	import potato.ui.UIGlobal;

	/**
	 * 单个编辑对象 
	 * @author sheep
	 * 
	 */
	public class UIAdjusterItem extends DisplayObjectContainer
	{
		/**
		 * 源对象 
		 */
		public var res:DisplayObject;
		/**
		 * 操作记录 用于撤销操作
		 */
		protected var operLog:UIAdjusterItemLog = new UIAdjusterItemLog;
		/**
		 * 源对象显示区域 
		 */
		protected var quad:Quad;
		/**
		 * 坐标点 
		 */
		protected var txt:TextField = new TextField("",70,20,UIGlobal.defaultFont,16,0xffff00);
		/**
		 * 扩展菜单,例如 in out... 
		 */
		protected var menu:UIAdjusterItemMenu;
		/**
		 * 颜色
		 */
		protected var color:uint = 0x55000000 + 0xFFFFFF * Math.random();
		/**
		 * 延时加载的帧数 
		 */
		protected var delayFrame:int;
		/**
		 * 开始拖拽的点 
		 */
		protected var dragStartPoint:Point = new Point;
		/**
		 * 保存递归子内容 对象类型文本HTML
		 */
		protected var strLvInfo:String="";
		/**
		 * 显示内部显示对象列表 
		 */
		protected var txtLvInfo:TextField;
		/**
		 * 延时初始化序列
		 */
		protected static var runs:Vector.<Function> = new Vector.<Function>();
		
		public function UIAdjusterItem(obj:DisplayObject)
		{
			res = obj;
			operLog.pushOperPont(res);
			addChild(txt);
			txt.addEventListener(TouchEvent.TOUCH_BEGIN,onDragStart);
			menu = new UIAdjusterItemMenu(res);
			menu.x = 55;
			addChild(menu);
			menu.addEventListener(UIAdjusterEvent.EVENT,menuEvent)
			addWait(wait);
		}
		
		/**
		 * 扩展菜单显示/隐藏,例如 in out close...  
		 * @return 显示隐藏
		 * 
		 */
		public function menuVisibleChange():Boolean{
			menu.visible = !menu.visible;
			return menu.visible;
		}
		
		/**
		 * 用增量撤销操作 退回到某个相关索引的点 
		 * < > << >>
		 * @param index
		 * 
		 */
		public function backOperLogPoint(index:int):void{
			var p:Point = operLog.goOperPoint(index);
			res.x  = p.x;
			res.y = p.y;
			resetDrag();
		}
		
		/**
		 * 还原到初始的位置,并清除自己的操作记录
		 *
		 */
		public function resetOper():void{
			var p:Point = operLog.clear();
			res.x  = p.x;
			res.y = p.y;
			resetDrag();
		}
		
		/**
		 * 根据源 重设位置和大小 
		 * 
		 */
		public function resetDrag():void{
			if(quad){
				removeChild(quad);
			}
			var tempDispPoint:Rectangle = res.getBounds(Stage.getStage());
			this.x = tempDispPoint.x;
			this.y = tempDispPoint.y;
			quad = new Quad(tempDispPoint.width > 10?tempDispPoint.width:20,
				tempDispPoint.height > 10?tempDispPoint.height:20,color);
			quad.mouseEnabled = false;
			addChildAt(quad,0);
			txt.htmlText = res.x + "," + res.y;
		}
		
		/**
		 * 扩展菜单处理,例如 in out close...   
		 * @param e
		 * 
		 */
		public function menuEvent(e:UIAdjusterEvent):void{
			switch(e.secType)
			{
				case UIAdjusterEvent.IN:{
					UIAdjusterManager.clear();
					UIAdjusterManager.regAllChild(res);
					break;}
				case UIAdjusterEvent.OUT:{
					if(!res.parent) return;
					UIAdjusterManager.clear();
					UIAdjusterManager.reg(res.parent);
					break;}
				case UIAdjusterEvent.CLOSE:{
					UIAdjusterManager.clear(this);
					break;}
				case UIAdjusterEvent.BACK_BACK:{
					backOperLogPoint(-1);
					break;}
				case UIAdjusterEvent.BACK_NEXT:{
					backOperLogPoint(1);
					break;}
				case UIAdjusterEvent.BACK_FIRST:{
					backOperLogPoint(-10000);
					break;}
				case UIAdjusterEvent.BACK_LAST:{
					backOperLogPoint(10000);
					break;}
				case UIAdjusterEvent.BACK_CLEAR:{
					resetOper();
					menu.showUndo = false;
					break;}
				default:
				{
					break;
				}
			}
		}

		/**
		 * 获取容器内的层级关系HTML
		 * @return 
		 * 
		 */
		public function getInfo():String{
			setSeachInfo(res);
			return strLvInfo;
		}
		
		/**
		 * 递归查询所有子的类型 
		 * @param disp
		 * @param lv
		 * 
		 */
		protected function setSeachInfo(disp:DisplayObject,lv:int=-1):void{
			lv++;
			setSeachInfoLine(disp,lv);
			// 递归所有子
			if(disp is DisplayObjectContainer){
				var regCount:int = DisplayObjectContainer(disp).numChildren;
				while(regCount){
					setSeachInfo(DisplayObjectContainer(disp).getChildAt(--regCount),lv);
				}
			}
		}
		/**
		 * 设置自己显示列表内的 对象列表HTML
		 * @param obj
		 * @param lv
		 * 
		 */
		protected function setSeachInfoLine(obj:DisplayObject,lv:int):void{
			var str:String = "";
			for(var i:int;i<lv;i++){
				str+="  ";
			}
			strLvInfo += str + lv + "." + getQualifiedClassName(obj) + "<br/>";
		}
		/**
		 * 开始拖动 文字坐标
		 * @param e
		 * 
		 */
		protected function onDragStart(e:TouchEvent):void{
			dragStartPoint.x = e.stageX;
			dragStartPoint.y = e.stageY;
			txt.addEventListener(TouchEvent.TOUCH_MOVE,onDragMove);
			txt.addEventListener(TouchEvent.TOUCH_END,onDragEnd);
			quad.color = 0x99000000;
			txtLvInfo = new TextField("",600,10,"yh",16,0xFFFFFF);
			txtLvInfo.y = 40;
			txtLvInfo.htmlText = getInfo();
			txtLvInfo.setSize(txtLvInfo.textWidth+10,txtLvInfo.textHeight+10);
			txtLvInfo.mouseEnabled;
			addChild(txtLvInfo);
		}
		
		/**
		 * 结束拖动 + 保存操作记录 
		 * @param e
		 * 
		 */
		protected function onDragEnd(e:TouchEvent):void
		{
			txt.removeEventListener(TouchEvent.TOUCH_MOVE,onDragMove);
			txt.removeEventListener(TouchEvent.TOUCH_END,onDragEnd);
			// 保存一个操作点 如果没动,则不提供undo功能
			if(operLog.pushOperPont(res)){
				menu.showUndo = true;
			}
			quad.color = color;
			removeChild(txtLvInfo);
			txtLvInfo = null;
			strLvInfo = "";
		}
		
		protected function onDragMove(e:TouchEvent):void
		{
			var p:Point = new Point(e.stageX - dragStartPoint.x,e.stageY - dragStartPoint.y);
			this.x += p.x;
			this.y += p.y;
			res.x += p.x;
			res.y += p.y;
			txt.htmlText = res.x + "," + res.y;
			dragStartPoint.x = e.stageX;
			dragStartPoint.y = e.stageY;
		}
		
		/**
		 * 延时加载 防止前几帧 异步图片改变大小
		 * 手动的单个注册 可以一直等到添加到显示列表内
		 */
		protected function wait():void{
			//手动的单个注册 可以一直等到添加到显示列表内
			if(res.parent){
				delayFrame++;
				if(delayFrame > 10){
					removeWait(wait);
					delayFrame = 0;
					resetDrag();
				}
			}
		}
		
		/**
		 * 同对象,方法只被添加一次 
		 * @param run
		 * 
		 */
		protected static function addWait(run:Function):void {
			if(runs.length==0){
				Stage.getStage().addEventListener(Event.ENTER_FRAME,frameWait);
			}
			if (runs.indexOf(run) != -1){
				return;
			}
			runs.push(run);
		}
		
		protected static function removeWait(run:Function):void {
			var i:int = runs.indexOf(run);
			if (i >= 0)
				runs.splice(i, 1);
			if(runs.length==0){
				Stage.getStage().removeEventListener(Event.ENTER_FRAME,frameWait);
			}
		}
		
		protected static function frameWait(event:Event):void {
			for each(var func:Function in runs)func();
		}
		
		override public function dispose():void{
			txt.removeEventListener(TouchEvent.TOUCH_BEGIN,onDragStart);
			txt.removeEventListener(TouchEvent.TOUCH_MOVE,onDragMove);
			txt.removeEventListener(TouchEvent.TOUCH_END,onDragEnd);
			menu.removeEventListener(UIAdjusterEvent.EVENT,menuEvent)
			removeWait(wait);
			super.dispose();
		}
	}
}