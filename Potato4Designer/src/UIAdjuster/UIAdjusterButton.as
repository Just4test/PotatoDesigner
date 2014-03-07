package UIAdjuster
{
	import core.display.Quad;
	import core.text.TextField;
	
	import potato.events.GestureEvent;
	import potato.ui.UIComponent;
	import potato.ui.UIGlobal;
	import potato.utils.Size;
	
	/**
	 * 菜单的按钮 
	 * @author sheep
	 * 
	 */
	public class UIAdjusterButton extends UIComponent
	{
		private var callFunc:Function;
		private var quad:Quad;
		private var minSize:Size = new Size(100,30);
		/**
		 *  一个绘制的btn
		 * @param label	label
		 * @param func	点击执行
		 * @param size	最小的按钮尺寸
		 * 
		 */
		public function UIAdjusterButton(label:String,func:Function,size:Size = null){
			if(size) minSize = size;
			var txt:TextField = new TextField(label,200,minSize.height
				,UIGlobal.defaultFont,16,0xFFFFFF);
			if(txt.textWidth > minSize.width){
				txt.setSize(txt.textWidth+6,minSize.height);
				minSize.width = txt.width;
			}else{
				txt.setSize(minSize.width,minSize.height);
			}
			txt.vAlign = txt.hAlign =1;
			quad = new Quad(txt.width,txt.height,0xFF000000);
			quad.alpha = 0.5;
			addChild(quad);
			addChild(txt);
			callFunc = func;
			addEventListener(GestureEvent.GESTURE_DOWN,onDown);
			addEventListener(GestureEvent.GESTURE_UP,onUp);
			addEventListener(GestureEvent.GESTURE_CLICK,onClick)
		}
		
		private function onClick(e:GestureEvent):void
		{
			if(callFunc) callFunc();
		}
		private function onDown(e:GestureEvent):void{
			quad.alpha = 1;
		}
		private function onUp(e:GestureEvent):void{
			quad.alpha = 0.5;
		}
		
		override public function dispose():void{
			removeEventListener(GestureEvent.GESTURE_DOWN,onDown);
			removeEventListener(GestureEvent.GESTURE_UP,onUp);
			removeEventListener(GestureEvent.GESTURE_CLICK,onClick);
			callFunc = null;
			super.dispose();
		}
	}
}