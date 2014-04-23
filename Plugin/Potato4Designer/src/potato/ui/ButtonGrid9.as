package potato.ui
{
	import flash.geom.Rectangle;
	
	import core.display.Grid9Texture;
	import core.text.TextField;
	
	import potato.events.GestureEvent;
	import potato.res.Res;
	import potato.utils.Size;
	import potato.utils.Utils;

	/**
	 *九宫格-文字按钮 
	 * @author LuXianli
	 * 
	 */	
	public class ButtonGrid9 extends Button
	{
		private var _upName:String;
		private var _downName:String;
		private var _disabledName:String;
		private var _label:String;
		private var _w:int = 0;
		private var _h:int = 0;
		
		private var _width:int = 0;
		private var _height:int = 0;
		private var _rect:Rectangle;
		private var _textField:TextField;
		private var _lockFlag:Boolean;
		private var _fontName:String = "yh";
		private var _fontSize:int = 24;
		private var _fontColor:uint = 0xFFFFE051;
		private var _status:int = 1;
		
		private var _autoSizeByFont:Boolean;
		/**
		 *需要参数 
		 * @param upName	抬起状态背景图片名字
		 * @param downName	按下状态背景图片名字
		 * @param text		按钮上显示的文字
		 * @param disabledName	按钮禁用状态背景图片名字
		 * 
		 */		
		public function ButtonGrid9(upName:String,downName:String,text:String,disabledName:String = null)
		{
			_upName = upName;
			_downName = downName;
			_label = text;
			_disabledName = disabledName;
			mouseChildren = false;
			_autoSizeByFont = true;
			if(_upName){
				
				_img = Res.getImage(upName);
				addChild(_img);
				_w = _img.width;
				_h = _img.height;
			}
			
			_rect = new Rectangle(_w/3,_h/3,_w/3,_h/3);
			
			_textField = new TextField();
			addChild(_textField);
			_textField.x = _textField.y = 5;
			
			addEventListener(GestureEvent.GESTURE_DOWN,onGestureHandler);
			addEventListener(GestureEvent.GESTURE_UP,onGestureHandler);
			
		}
		
		override public function set isMultiTouch(value:Boolean):void{
			
			super.isMultiTouch = value;
			
			removeEventListeners(GestureEvent.GESTURE_DOWN);
			removeEventListeners(GestureEvent.GESTURE_UP);
			
			addEventListener(GestureEvent.GESTURE_DOWN,onGestureHandler);
			addEventListener(GestureEvent.GESTURE_UP,onGestureHandler);
		}
		
		private function onGestureHandler(event:GestureEvent):void{
			
			if(event.type == GestureEvent.GESTURE_DOWN){
				if(_downName)_img.texture = new Grid9Texture(Res.getTexture(_downName),_rect,_width,_height);
			}else{
				if(_upName)_img.texture = new Grid9Texture(Res.getTexture(_upName),_rect,_width,_height);
			}
		}
		
		public override function lock(num:int = 0):void{
			
			switch(num){
				
				case 0:
				case 1:
					_status = 1;
					_lockFlag = false;
					mouseEnabled = true;
					if(_upName)_img.texture = new Grid9Texture(Res.getTexture(_upName),_rect,_width,_height);
					break;
				
				case 2:
					_status = 2;
					_lockFlag = true;
					mouseEnabled = false;
					if(_downName)_img.texture = new Grid9Texture(Res.getTexture(_downName),_rect,_width,_height);
					break;
				
				case 3:
					_status = 3;
					_lockFlag = true;
					mouseEnabled = false;
					if(_disabledName)_img.texture = new Grid9Texture(Res.getTexture(_disabledName),_rect,_width,_height);
					break;
			}
		}
		
		public function get isLocked():Boolean{
			return _lockFlag;
		}
		
		/**
		 *设置按钮文字样式 
		 * @param fontName	字体名字
		 * @param fontSize	字体大小
		 * @param fontColor	字体颜色
		 * 
		 */	
		public function setStyle(fontName:String,fontSize:int,fontColor:uint):void{
			
			_fontColor = fontColor;
			_fontName = fontName;
			_fontSize = fontSize;
			label = _label;
		}
		
		/**
		 *更改按钮文字颜色 
		 * @param value
		 * 
		 */		
		public function set textColor(value:uint):void{
			
			_fontColor = value;
			if(_textField)_textField.textColor = value;
		}
		public function get textColor():uint{
			return _fontColor;
		}
		
		/**
		 *更改按钮文字显示 
		 * @param value
		 * 
		 */		
		public override function set label(value:String):void{
			
			_label = value;
			_textField.fontName = _fontName;
			_textField.fontSize = _fontSize;
			_textField.textColor = _fontColor;
			if(_label)_textField.htmlText = _label;
			if(_autoSizeByFont)
			{
				var _size:Size = Utils.getTextSize(_label,_fontName,_fontSize);
				_textField.setSize(_size.width,_size.height);
				_width = _size.width + 10;
				_height = _size.height + 10;
				lock();
			}
			
		}
		
		/**
		 * 设置按钮大小（仅限于Grid9）
		 * @param width
		 * @param height
		 *
		 */
		override public function setSize(width:int, height:int):void
		{
			_autoSizeByFont = false;
			_width = width;
			_height = height;
			_textField.setSize(_width,_height);
			_textField.x = _textField.y = 0;
			setTextAlign();
			lock();
		}
		
		public function setTextAlign(vAlign:uint = TextField.ALIGN_CENTER,hAlign:uint = TextField.ALIGN_CENTER):void
		{
			_textField.vAlign = vAlign;
			_textField.hAlign = hAlign;
		}
		
		public override function get label():String{
			return _label;
		}
		
		override public function get width():Number{
			return _width;
		}
		override public function get height():Number{
			return _height;
		}
		
		/**
		 * 禁用(启用)按钮，并且停顿在第三帧（第一帧）状态
		 * @return
		 */
		public override function get enabled():Boolean
		{
			return _enabled;
		}
		
		/**
		 * 
		 * @param value
		 */
		public override function set enabled(value:Boolean):void
		{
			if (!value)
			{
				lock(3);
			}
			else
			{
				lock();
			}
			mouseEnabled = value;
			_enabled = value;
		}
	}
}