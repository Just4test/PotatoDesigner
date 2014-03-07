package miniui
{
	import core.display.DisplayObjectContainer;
	import core.display.Graphics;
	import core.display.Image;
	import core.display.Shape;
	import core.display.Texture;
	import core.display.TextureData;
	import core.events.Event;
	import core.events.TouchEvent;
	import core.text.TextField;
	
	import flash.geom.Matrix;
	
	import potato.ui.UIGlobal;
	import potato.utils.Size;
	import potato.utils.Utils;
	
	/**
	  * The button was clicked
	 */
	[Event(name="clicked", type="core.events.Event")]
	
	
	public class MiniButton extends DisplayObjectContainer
	{
		public static const CLICKED:String = "clicked";
		
		protected static const SIZE_X:Number = 10.0;
		protected static const SIZE_Y:Number = 7.0;
		protected static const CURVE:Number = 16.0;
		
		private var _label:TextField;
		private var _skin:Shape;
		private var _bg:Image;
		private var _enabled:Boolean = false;
		
		private var upTex:Texture;
		private var downTex:Texture;
		
		protected var _colour:uint;
		protected var _border:Number = 1;
		
		public function MiniButton(text:String, colour:uint = 0x9999AA)
		{
			_colour = colour;
			_skin = new Shape();
			
			var size:Size = Utils.getTextSize(text, UIGlobal.defaultFont, UIGlobal.FONTSIZE);
			_label = new TextField(text, size.width, size.height, UIGlobal.defaultFont, UIGlobal.FONTSIZE, 0xFFFFFF);
			_label.y = SIZE_Y - 1;
			_label.x = SIZE_X;
			
			_bg = new Image(null);
			addChild(_bg);
			addChild(_label);
			
			this.mouseChildren = false;
			
			addEventListener(TouchEvent.TOUCH_BEGIN, mouseDown);
			draw();
		}
		
		public function set text(t:String):void {
			var size:Size = Utils.getTextSize(t, UIGlobal.defaultFont, UIGlobal.FONTSIZE);
			_label.text = t;
			_label.setSize(size.width, size.height);
			draw();
		}
		
		private function mouseDown(event:TouchEvent):void {
			_bg.texture = downTex;
			_enabled = true;
			addEventListener(TouchEvent.TOUCH_END, mouseUp);
		}
		
		protected function mouseUp(event:TouchEvent):void {
			_bg.texture = upTex;
			if (_enabled/* && event.target == this*/) {
				dispatchEvent(new Event(CLICKED));
			}
			removeEventListener(TouchEvent.TOUCH_END, mouseUp);
			_enabled = false;
		}
		
		private function draw(pressed:Boolean = false):void {
			var width:Number = Math.max(_label.textWidth + 2 * SIZE_X);
			var height:Number = _label.textHeight + SIZE_Y * 2;
			
			var matr:Matrix = new Matrix();
			matr.createGradientBox(width, height, Math.PI/2, 0, 0);
			
			_skin.graphics.clear();
			_skin.graphics.beginGradientFill(Graphics.GRADIENT_LINEAR, [Colour.darken(_colour),Colour.lighten(_colour)], [1.0,1.0], [0x00,0xff], matr);
			_skin.graphics.drawRoundRect(0, 0, width, height, CURVE, CURVE);
			
			var gradient:Array = [Colour.lighten(_colour,80),Colour.darken(_colour), Colour.darken(_colour)];
			_skin.graphics.beginGradientFill(Graphics.GRADIENT_LINEAR, gradient, [1.0,1.0,1.0], [0x00,0x80,0xff], matr);
			_skin.graphics.drawRoundRect(_border, _border, width-2*_border, height-2*_border, CURVE, CURVE);
			
			var texDataUp:TextureData = TextureData.createRGB(width, height, true, 0);
			texDataUp.draw(_skin);
			upTex = new Texture(texDataUp);
			
			_skin.graphics.clear();
			_skin.graphics.beginGradientFill(Graphics.GRADIENT_LINEAR, [Colour.darken(_colour),Colour.lighten(_colour)], [1.0,1.0], [0x00,0xff], matr);
			_skin.graphics.drawRoundRect(0, 0, width, height, CURVE, CURVE);
			
			gradient = [Colour.darken(_colour,128),Colour.lighten(_colour), Colour.darken(_colour)];
			_skin.graphics.beginGradientFill(Graphics.GRADIENT_LINEAR, gradient, [1.0,1.0,1.0], [0x00,0x80,0xff], matr);
			_skin.graphics.drawRoundRect(_border, _border, width-2*_border, height-2*_border, CURVE, CURVE);
			
			var texDataDown:TextureData = TextureData.createRGB(width, height, true, 0);
			texDataDown.draw(_skin);
			downTex = new Texture(texDataDown);
			
			_bg.texture = upTex;
		}
	}
}