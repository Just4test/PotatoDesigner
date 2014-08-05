/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 12-11-14
 * Time: 下午6:10
 * To change this template use File | Settings | File Templates.
 */
package potato.ui
{
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	import core.display.Image;
	import core.display.Quad;
	import core.display.Stage;
	import core.display.Texture;
	import core.display.TextureData;
	import core.events.Event;
	import core.text.TextField;
	import core.utils.WeakDictionary;
	
	import flash.geom.Point;
	
	import potato.events.GestureEvent;
	
	import potato.events.UIEvent;
	
	import potato.transitions.DialogTransition;
	
	import potato.transitions.ITransition;
	
	import potato.utils.SharedObject;
	
	/**
	 * 对话框开始关闭时调度
	 * @eventType core.events.Event.CLOSE
	 */
	[Event(name="startclose", type = "potato.events.UIEvent")]
	
	/**
	 * 对话框关闭后调度
	 * @eventType core.events.Event.CLOSE
	 */
	[Event(name="close", type = "core.events.Event")]
	
	/**
	 * 对话框动画后调度
	 * @eventType core.events.Event.COMPLETE
	 */
	[Event(name="complete", type = "core.events.Event")]
	
	/**
	 * 对话框基础类
	 */
	public class Dialog extends UIComponent
	{
		private static var SO_DIALOG:String = "so_dlg";	//共享对象名
		
		private static var dlgMap:WeakDictionary;		//所有对话框map
		
		//全局事件遮挡层，所有对话框公用一个
		private static var _modalBmp:Image;
		private static var modalTex:Texture;		//使用材质，方便做效果
		private static var showModal:Boolean = false;
		
		//		private var _bgColor:uint = 0xFFFFFF;		//背景颜色
		//		private var _bgAlpha:Number = 1;			//背景透明度
		
		private var _modal:Boolean = false;			//模态
		private var _isSavePostion:Boolean = true;		//是否记录上次位置
		private var _popupInitPt:Point = null;			//记录对话框弹出的起始位置
		
		//		private var _name:String;
		private var screen:DisplayObjectContainer;
		private var _title:TextField;		//标题
		private var _bg:DisplayObject;
		private var shareObj:SharedObject;
		private var closeBtn:Button;		//关闭按钮
		private var _isOpen:Boolean = false;
		
		private var _transition:ITransition;
		
		private var modalLay:Quad;		//对话框的遮挡层
		private var isIndependModal:Boolean;
		
		
		/**
		 *
		 * @param name 对话框名，唯一
		 * @param screen 对话框显示根容器
		 * @param bg 背景图片
		 * @param title 对话框标题
		 * @param closeBtn 对话框关闭按钮
		 * @param modal 对话框强制响应模式
		 * @param isSavePostion 是否保存上次打开位置
		 * @param isIndependModal 是否有自己的遮挡层
		 */
		public function Dialog(name:String,
							   screen:DisplayObjectContainer,
							   bg:DisplayObject,
							   title:TextField=null,
							   closeBtn:Button=null,
							   modal:Boolean=false,
							   isSavePostion:Boolean=true,
							   isIndependModal:Boolean=true)
		{
			//清除同名对话框
			if (dlgMap == null)
			{
				dlgMap = new WeakDictionary();
			}
			var dlg:Dialog = Dialog(dlgMap[name]);
			if (dlg != null)
			{
				dlg.dispose();
			}
			dlgMap[name] = this;
			
			super.visible  = false;
			
			this.name = name;
			this.screen = screen;
			this.title = title;
			this.closeBtn = closeBtn;
			this._modal = modal;
			this._isSavePostion = isSavePostion;
			
			if (bg is UIComponent)
				this._bg = bg;
			else
			{
				this._bg = new UIComponent();
				UIComponent(this._bg).addChild(bg);
			}
			this.transition = new DialogTransition();  //默认弹出效果
			this.isIndependModal = isIndependModal;
			
			if (this._isSavePostion)
			{
				shareObj = SharedObject.getLocal(SO_DIALOG);
			} else {
				shareObj = null;
			}
			
			//初始化
			init();
		}
		
		private  function transitionComplete():void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function init():void
		{
			//		addEventListener(UIEvent.LONG_TOUCH_EVENT, long);
			//		addEventListener(GestureEvent.GESTURE_LONG_PRESS, long);
			//背景
			if (_bg == null) {
				throw new ArgumentError("Dialog bg is null.");
				return;
			}
			
			this.addChildAt(_bg, 0);
			//		_bg.addEventListener(TouchEvent.TOUCH_BEGIN, mouseDown);
			//			_bg.addEventListener(TouchEvent.TOUCH_END, mouseUp);
			//		_bg.addEventListener(DragEvent.DRAGEND_EVENT, mouseUp);
			
			_bg.addEventListener(GestureEvent.GESTURE_DOWN, mouseDown);
			//		_bg.addEventListener(GestureEvent.GESTURE_MOVE, onDragedHandler);
			_bg.addEventListener(GestureEvent.GESTURE_UP, mouseUp);
			
			//关闭按钮
			if (closeBtn != null)
			{
				//			closeBtn.addEventListener(UIEvent.CLICK, closeEvent);
				closeBtn.addEventListener(GestureEvent.GESTURE_CLICK, closeEvent);
				this.addChild(closeBtn);
				
				//				closeBtn.x=_bg.width-closeBtn.width;
				//				closeBtn.y=0;
			}
			
			//标题
			if (_title != null)
			{
				this.addChild(_title);
			}
		}
		
		private var _enableDragFlag:Boolean = true;
		public function set enableDrag(value:Boolean):void{
			
			_enableDragFlag = value;
			if(value){
				
				if(_bg){
					
					//				_bg.addEventListener(TouchEvent.TOUCH_BEGIN, mouseDown);
					//				_bg.addEventListener(DragEvent.DRAGEND_EVENT, mouseUp);
					
					_bg.addEventListener(GestureEvent.GESTURE_DOWN, mouseDown);
					_bg.addEventListener(GestureEvent.GESTURE_UP, mouseUp);
				}
			}else{
				
				if(_bg){
					
					//				_bg.removeEventListener(TouchEvent.TOUCH_BEGIN, mouseDown);
					//				_bg.removeEventListener(DragEvent.DRAGEND_EVENT, mouseUp);
					
					_bg.removeEventListener(GestureEvent.GESTURE_DOWN, mouseDown);
					_bg.removeEventListener(GestureEvent.GESTURE_UP, mouseUp);
				}
			}
		}
		public function get enableDrag():Boolean{
			
			return _enableDragFlag;
		}
		
		private function long(e:GestureEvent):void
		{
			
		}
		
		override public function set visible(_arg1:Boolean):void
		{
			if(_modalBmp)
				_modalBmp.visible=_arg1;
			if(modalLay)
				modalLay.visible = _arg1;
			super.visible = _arg1;
		}
		/**
		 * 显示对话框
		 * @param initPt 过程动画开始位置
		 * @param toPoint 过程动画结束位置（对话框位置）
		 */
		public function open(initPt:Point=null, toPoint:Point=null):void
		{
			if (this.screen == null || this.isOpen()) return;
			
			this._isOpen = true;
			
			if (initPt == null) {
				_popupInitPt = new Point(0, 0);
			} else {
				_popupInitPt = initPt;
			}
			
			if (toPoint == null) {
				toPoint = restorePosition();
			}
			this.x = toPoint.x;
			this.y = toPoint.y;
			
			if (this._transition != null) {
				this._transition.stopTransition();
				this._transition.doTransition(this, transitionComplete, null, {fromPt:this.popupInitPt});
			}
			
			if (!visible) {
				super.visible = true;
			}
			
			if (this._modal) {
				var stage:Stage = Stage.getStage();
				if (showModal == false) {
					if (modalTex == null || stage.stageWidth != modalTex.width || stage.stageHeight != modalTex.height) {
						modalTex = new Texture(TextureData.createRGB(stage.stageWidth, stage.stageHeight, true, 0x30ffffff));
						_modalBmp = new Image(modalTex);
					}
					
					_modalBmp.alpha = 1;
					
					//					if (_modalBmp.parent == null) {
					screen.addChild(_modalBmp);
					//					}
					showModal = true;
				}
				
				if (modalLay == null) {
					modalLay = new Quad(stage.stageWidth, stage.stageHeight, 0x0);
				}
				if (this.isIndependModal) {
					//					modalLay.addEventListener(TouchEvent.TOUCH_BEGIN, stopEvent);
					//					modalLay.addEventListener(TouchEvent.TOUCH_BEGIN, stopEvent);
					//					modalLay.addEventListener(TouchEvent.TOUCH_BEGIN, stopEvent);
					screen.addChild(modalLay);
				}
			}
			
			screen.addChild(this);
		}
		
		/**
		 * 对话框是否显示
		 * @return
		 */
		public function isOpen():Boolean {
			return this._isOpen;
		}
		
		public static function isNotRemainModal():Boolean {
			if (dlgMap.length > 0) {
				for each (var dlg:Dialog in dlgMap) {
					if (dlg.modal == true && dlg.stage != null) {
						return false;
					}
				}
			}
			return true;
		}
		
		private function removeThis():void {
			//从列表中删除
			delete dlgMap[name];
			
			if (isNotRemainModal() && _modalBmp != null && _modalBmp.parent != null) {
				showModal = false;
				_modalBmp.parent.removeChild(_modalBmp);
				_modalBmp.removeEventListeners();
			}
		}
		
		/**
		 * 关闭对话框。有过场动画
		 * @param initPt
		 */
		public function close(toPt:Point=null):void {
			
			removeThis();
			
			var fPt:Point = new Point(this.x, this.y);
			if (toPt == null) toPt = _popupInitPt;
			this.x = toPt.x;
			this.y = toPt.y;
			
			if (this._transition != null) {
				this._transition.stopTransition();
				this._transition.doTransition(this, closeWindow, null, {fromPt:fPt, isClose:true});
			}
			else
			{
				closeWindow();
			}
			// initPt.x, initPt.y 为过场动画的 toPoint
			dispatchEvent(new UIEvent(UIEvent.STARTCLOSE, false, toPt.x, toPt.y));
		}
		
		private function closeEvent(e:GestureEvent=null):void {
			//			if (e != null)
			//			{
			//				e.stopPropagation();
			//			}
			
			
			removeThis();
			
			var fPt:Point = new Point(this.x, this.y);
			if (_popupInitPt == null) _popupInitPt = new Point();
			this.x = _popupInitPt.x;
			this.y = _popupInitPt.y;
			
			if (this._transition != null) {
				this._transition.stopTransition();
				this._transition.doTransition(this, closeWindow, null, {fromPt:fPt, isClose:true});
			}
			else
			{
				closeWindow();
			}
			// initPt.x, initPt.y 为过场动画的 toPoint
			dispatchEvent(new UIEvent(UIEvent.STARTCLOSE, false, _popupInitPt.x, _popupInitPt.y));
		}
		
		/**
		 * 关闭对话框
		 */
		private function closeWindow():void
		{
			if (this._transition != null) {
				this._transition.stopTransition();
			}
			
			if (closeBtn != null) {
				closeBtn.removeEventListeners(null);
				closeBtn = null;
			}
			
			if (modalLay != null) {
				modalLay.removeEventListeners();
				if (modalLay.parent != null) {
					modalLay.parent.removeChild(modalLay);
				}
			}
			
			if (this.parent != null)
			{
				this.parent.removeChild(this);
			}
			
			//			this.removeEventListeners(null);
			//		_bg.removeEventListener(TouchEvent.TOUCH_BEGIN, mouseDown);
			//			_bg.removeEventListener(TouchEvent.TOUCH_END, mouseUp);
			//		_bg.removeEventListener(DragEvent.DRAGEND_EVENT, mouseUp);
			
			_bg.removeEventListener(GestureEvent.GESTURE_DOWN, mouseDown);
			_bg.removeEventListener(GestureEvent.GESTURE_UP, mouseUp);
			
			//			//从列表中删除
			//			delete dlgMap[name];
			
			this._isOpen = false;
			
			// 关闭事件
			this.dispatchEvent(new Event(Event.CLOSE));
		}
		
		/**
		 * 销毁 ， 没有过场动画
		 */
		override public function dispose():void {
			removeThis();
			
			if (this._isOpen) closeWindow();
			
			super.dispose();
		}
		
		
		/**
		 * 恢复以前保存的位置
		 */
		private function restorePosition():Point
		{
			var pt:Point = new Point();
			
			var xt:int = 0;
			var yt:int = 0;
			
			if (_isSavePostion == false || shareObj == null || shareObj.data[name] == null)
			{
				//居中显示
				xt = Stage.getStage().stageWidth - bg.width;
				yt = Stage.getStage().stageHeight - bg.height;
				pt.x = xt / 2;
				pt.y = yt / 2;
				return pt;
			}
			
			xt = shareObj.data[name].x;
			yt = shareObj.data[name].y;
			
			if (xt > 0 && xt < Stage.getStage().stageWidth-bg.width) {
				pt.x = xt;
			}
			if (yt > 0 && yt < Stage.getStage().stageHeight-bg.height) {
				pt.y = yt;
			}
			return pt;
		}
		
		/**
		 * 保存当前位置
		 */
		private function savePosition():void
		{
			if (shareObj == null) return;
			
			shareObj.data[name] = new Point(this.x, this.y);
			shareObj.flush();
		}
		
		private function mouseDown(e:GestureEvent):void
		{
			var container:DisplayObjectContainer=this.parent as DisplayObjectContainer;
			container.setChildIndex(this,container.numChildren-1);
			this.touchPointID = e.touchPointID;
			this.startDrag();
		}
		
		private function mouseUp(e:GestureEvent):void
		{
			this.stopDrag();
			
			savePosition();
		}
		
		public function get title():TextField
		{
			return _title;
		}
		
		public function set title(value:TextField):void
		{
			_title = value;
		}
		
		public function get bg():DisplayObject
		{
			return _bg;
		}
		
		public function set bg(value:DisplayObject):void
		{
			if (_bg != null)
			{
				this.removeChild(_bg);
			}
			
			_bg = value;
			
			if (_bg != null)
			{
				this.addChildAt(_bg, 0);
			}
		}
		
		public function set transition(value:ITransition):void
		{
			_transition = value;
		}
		
		public static function get modalBmp():Image
		{
			return _modalBmp;
		}
		
		public function get modal():Boolean
		{
			return _modal;
		}
		
		public function get popupInitPt():Point
		{
			return _popupInitPt;
		}
		
		public function setClosable(b:Boolean):void {
			if (this.closeBtn) closeBtn.visible = b;
		}
	}
}
