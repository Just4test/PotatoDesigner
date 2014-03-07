
package potato.logger
{
	import core.display.DisplayObjectContainer;
	import core.display.Graphics;
	import core.display.Image;
	import core.display.Quad;
	import core.display.Shape;
	import core.display.Stage;
	import core.display.Texture;
	import core.display.TextureData;
	import core.events.Event;
	import core.events.TouchEvent;
	
	import miniui.MiniButton;

	/**
	 * 文本框日志
	 * 在使用前需要调用 static function init(scene:DisplayObjectContainer)
	 * @author 白连忱 
	 * @date Nov 9, 2009
	 */
	public class TextBoxWriter implements ILogWriter
	{
		public static var DISPLAYHEIGHT:int = 200;
		public static var DISPLAYWIDTH:int = 0;
		
		private static var rootScene:DisplayObjectContainer;
//		private static var stage:Stage;
		private static var inited : Boolean = false;
		private static var bg:Quad;
		private static var content:TextAreaLog;
		private static var displayed:Boolean = false;
		
//		private const LOGO_PATH:String = "log.txt";
//		private var log:String = "";
		
		private static var touchDown:Boolean = false;
		private static var lastMoveY:int;
		
		private static var box:DisplayObjectContainer;
		private static var clearBtn:MiniButton;
		private static var pauseBtn:MiniButton
		
		private static function drawLogBtn():Image {
			var shap:Shape = new Shape();
			var g:Graphics = shap.graphics;
			g.beginGradientFill(Graphics.GRADIENT_RADIAL, [0x000000, 0xffffff], [1, 0.5], [0x00, 0xff]);
			g.moveTo(0, 0);
			g.lineTo(0, DISPLAYHEIGHT);
			g.lineTo(20, DISPLAYHEIGHT/2);
			g.lineTo(0, 0);
			g.endFill();
			
			var td:TextureData = TextureData.createRGB(20, DISPLAYHEIGHT, true, 0x0);
			td.draw(shap);
			var tex:Texture = new Texture(td);
			
			return new Image(tex);
		}
		
		public static function init(scene:DisplayObjectContainer):void 
		{
			if(inited) return;
			
			inited = true;
			rootScene = scene;
			var stage:Stage = Stage.getStage();
			
			DISPLAYWIDTH = stage.stageWidth - 30;
			
			
			content = new TextAreaLog();
			content.x = 30;
			content.visible = false;
			
			bg = new Quad(stage.stageWidth, TextBoxWriter.DISPLAYHEIGHT, 0x88000000);
			bg.visible = false;
			
			box = new DisplayObjectContainer();
			box.addChild(bg);
			box.addChild(content);
			
			var logBtn:Image = drawLogBtn();
			logBtn.addEventListener(TouchEvent.TOUCH_BEGIN, onSelect);
			box.addChild(logBtn);
			
			rootScene.addChild(box);
			
			clearBtn = new MiniButton(" 清 除 ", 0xff);
			clearBtn.addEventListener(MiniButton.CLICKED, clearLog);
			clearBtn.x = stage.stageWidth - 150;
			clearBtn.y = 30;
			box.addChild(clearBtn);
			pauseBtn = new MiniButton(" 暂 停 ", 0xff);
			pauseBtn.addEventListener(MiniButton.CLICKED, pauseLog);
			pauseBtn.x = stage.stageWidth - 150;
			pauseBtn.y = 100;
			box.addChild(pauseBtn);
			clearBtn.visible = false;
			pauseBtn.visible = false;
			
			content.addEventListener(TouchEvent.TOUCH_BEGIN, scrollContent);
			content.addEventListener(TouchEvent.TOUCH_END, scrollContent);
			content.addEventListener(TouchEvent.TOUCH_MOVE, scrollContent);
		}
		
		private static function clearLog(e:Event):void {
			content.clear();
		}
		
		private static function pauseLog(e:Event):void {
			content.pause();
		}
		
		private static function scrollContent(e:TouchEvent):void {
			if (e.type == TouchEvent.TOUCH_BEGIN) {
				touchDown = true;
				lastMoveY = e.stageY;
			} else if (e.type == TouchEvent.TOUCH_END) {
				touchDown = false;
			} else if (touchDown) {
				var dx:int = 0;//e.stageX - lastMoveX;
				var dy:int = e.stageY - lastMoveY;
				
				content.scroll(dy);
				
				lastMoveY = e.stageY;
			}
		}
		
		private static function onSelect(e:TouchEvent):void {
			if(!displayed) {
				show();
			} else {
				hide();
			}
		}
		
		private static function show():void {
			displayed = true;
			content.visible = true;
			bg.visible = true;
			clearBtn.visible = true;
			pauseBtn.visible = true;
			rootScene.addChild(box);
		}
		
		private static function hide():void {
			displayed = false;
			content.visible = false;
			clearBtn.visible = false;
			pauseBtn.visible = false;
			bg.visible = false;
		}
		
//		private static function resize(e:Event) : void {
//			if (content != null)
//			{
//				content.resize();
//			}
//		}
		
		public function print(msg:String):void
		{
			if (content != null)
			{
				content.append(msg);
				rootScene.addChild(box);
			} else {
//				trace(msg);
			}
			
//			log = log + msg + "\n";
//			File.write(LOGO_PATH, log);
		}
	}
}


import flash.geom.Rectangle;

import core.display.DisplayObjectContainer;
import core.text.TextField;

import potato.logger.TextBoxWriter;
import potato.ui.UIGlobal;

/**
 * 文本日志控件
 * @author 白连忱 
 * @date Nov 9, 2009
 */
internal class TextAreaLog extends DisplayObjectContainer
{
	private var tf:TextField;
	private var scRect:Rectangle;
	
	private var tw:Number;
	private var th:Number;
	
	private var sizeH:int = 1024;
	
	private var isPause:Boolean = false;
	
	public function TextAreaLog()
	{
		this.mouseChildren = false;
		
		scRect = new Rectangle(0, 0, TextBoxWriter.DISPLAYWIDTH, TextBoxWriter.DISPLAYHEIGHT);
		this.clipRect = scRect;
		
		tf = new TextField();
		tf.fontName = UIGlobal.defaultFont;
		tf.fontSize = 14;
		tf.textColor = 0xEEEEEE;
		tf.setSize(TextBoxWriter.DISPLAYWIDTH, sizeH);
		tf.y = 10;
		
		this.addChild(tf);
	}
	
	public function append(str:String):void
	{
		if (isPause) return;
		
		var s:String = tf.text + "\n" + str;
		tf.text = s;
//		trace(tf.text);
		
		//文本框自动换行，所以不需要修改宽度
		th = tf.textHeight;
		if (th > sizeH) {
			var i:int = s.indexOf("\n");
			tf.text = s.substr(s.indexOf("\n", i+1));
			th = sizeH;
		}
		if (th > TextBoxWriter.DISPLAYHEIGHT) {
			tf.y = TextBoxWriter.DISPLAYHEIGHT - th;
		}
	}
	
	public function scroll(dy:int):void {
		if (th <= TextBoxWriter.DISPLAYHEIGHT) {
			return;
		}
		var toy:int = tf.y + dy;
		
		if (toy > 0) {
			toy = 0;
		}
		var t:int = TextBoxWriter.DISPLAYHEIGHT - th;
		if (toy < t) {
			toy = t;
		}
		
		tf.y = toy;
	}
	
	public function clear():void {
		tf.text = "";
		tf.setSize(TextBoxWriter.DISPLAYWIDTH, sizeH);
	}
	
	public function pause():void {
		isPause = !isPause;
	}
	
//	public function resize(e:Event = null) : void {
//		//背景
//		var vec:Graphics = this.graphics;
//		vec.clear();
//		vec.beginFill(0x000000, 0.5);
//		vec.drawRect(0, 0, stage.stageWidth, 250);
//		vec.endFill();
//		
//		this.text.width = this.width - 20;
//		this.text.height = this.height - 10;
//	}
	
}