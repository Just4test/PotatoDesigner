package potato.ui
{
	import core.display.Image;
	import core.media.Sound;
	import core.text.TextField;
	
	import potato.events.GestureEvent;
	import potato.res.Res;
	
	/**
	 * 按钮对象
	 */
	public class Button extends UIComponent
	{
		protected var _img:Image;
		/**按钮文字*/
		protected var _text:TextField;
		/**按钮文字颜色**/
		protected var _textColor:uint;
		/**按钮文字大小**/
		protected var _textSize:uint;
		/**按钮文字样式*/
		protected var _textStyle:TextStyle;
		/**是否启用状态*/
		protected var _enabled:Boolean = true;
		/**是否属于指定的ButtonBar，值为ButtonBar的id**/
		protected var _group:String;
		
		/**按钮状态<br/>
		 * 1、普通<br/>
		 * 2、按下<br/>
		 * 3、禁用
		 * */
		protected var status:int = 1;
		
		/**当前是否锁定*/
		protected var locking:Boolean;
		
		/**按钮谈起来的声音*/
		protected var _upSound:Sound;
		/**按钮按下声音*/
		protected var _downSound:Sound;
		
		private var _excat:Boolean = false;
		/**
		 *
		 * @param up
		 * @param down
		 * @param text
		 * @param disabled
		 * @param grid9
		 *
		 */
		
		public function Button(up:String = "", down:String = "", text:String = "", disabled:String = "")
		{
			mouseChildren = false;
			_isContainer = false;
			upSkin = up;
			downSkin = down;
			disableSkin = disabled;
			_img = new Image(null);
			addChild(_img);
			if(upSkin)_img.texture = Res.getTexture(upSkin);
			
			if (text)
			{
				_text = new TextField(text);
				setTextStyle(new TextStyle(UIGlobal.defaultFont));
				_text.setSize(this.width, this.height);
				addChild(_text);
			}
			
			addEventListener(GestureEvent.GESTURE_DOWN, this.down);
			addEventListener(GestureEvent.GESTURE_UP, this.end);
		}
		
		override public function set isMultiTouch(value:Boolean):void{
			super.isMultiTouch = value;
			
			removeEventListeners(GestureEvent.GESTURE_DOWN);
			removeEventListeners(GestureEvent.GESTURE_UP);
			
			addEventListener(GestureEvent.GESTURE_DOWN, this.down);
			addEventListener(GestureEvent.GESTURE_UP, this.end);
		}
		
		/**
		 * 按下
		 * @param e
		 */
		protected function down(e:GestureEvent):void
		{
			if (status == 3)
				return;
			if (!locking)
			{
				if(downSkin)_img.texture = Res.getTexture(downSkin);
				
				if (_downSound && UIGlobal.sound)
				{
					_downSound.play();
				}
			}
			status = 2;
		}
		
		/**
		 * 弹起
		 * @param e
		 */
		protected function end(e:GestureEvent):void
		{
			if (status == 3)
				return;
			
			if (!locking)
			{
				if(upSkin)_img.texture = Res.getTexture(upSkin);
				
				if (_upSound  && UIGlobal.sound)
					_upSound.play();
			}
			
			status = 1;
		}
		
		/**
		 * 禁用(启用)按钮，并且停顿在第三帧（第一帧）状态
		 * @return
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		/**
		 * private
		 * @param value
		 */
		public function set enabled(value:Boolean):void
		{
			if (!value)
			{
				status = 3;
				if(disableSkin)_img.texture = Res.getTexture(disableSkin);
			}
			else
			{
				if (status == 3)
				{
					if(upSkin)_img.texture = Res.getTexture(upSkin);
				}
				status = 1;
			}
			mouseEnabled = value;
			_enabled = value;
		}
		
		/**
		 * 设置按钮大小（仅限于Grid9）
		 * @param width
		 * @param height
		 *
		 */
		public function setSize(width:int, height:int):void
		{
		}
		
		/**
		 * 锁定按钮
		 * @param status
		 */
		public function lock(status:int = 0):void
		{
			if (status == 1)
			{
				this.status = 1;
				if(upSkin)_img.texture = Res.getTexture(upSkin);
				locking = true;
			}
			else if (status == 2)
			{
				this.status = 2;
				
				if (downSkin)
				{
					_img.texture = Res.getTexture(downSkin);
				}
				else
				{
					if(upSkin)_img.texture = Res.getTexture(upSkin);
				}
				locking = true;
			}
			else
			{
				locking = false;
				this.status = 1;
				if(upSkin)_img.texture = Res.getTexture(upSkin);
			}
		}
		
		public function setTextStyle(textStyle:TextStyle):void
		{
			if (textStyle)
			{
				_textStyle = textStyle;
				_text.fontName = _textStyle.fontName;
				_text.fontSize = _textStyle.fontSize;
				_text.textColor = _textStyle.textColor;
//				_text.vAlign = _textStyle.vAlign;
//				_text.hAlign = _textStyle.hAlign;
				_text.vAlign = TextField.ALIGN_CENTER;
				_text.hAlign = TextField.ALIGN_CENTER;
			}
		}
		
		public function set label(value:String):void
		{
			if (!_text)
			{
				_text = new TextField(value);
				setTextStyle(new TextStyle(UIGlobal.defaultFont));
				_text.setSize(this.width, this.height);
				addChild(_text);
			}
			else
			{
				_text.text = value;
			}
		}
		
		public function get label():String
		{
			if (_text)
			{
				return _text.text;
			}
			return "";
		}
		
		public function getTextStyle():TextStyle
		{
			return _textStyle;
		}
		
		public function setUpSound(resName:String):void
		{
//			_upSound = Res.getSound(resName, true);
		}
		
		public function setDownSound(resName:String):void
		{
//			_downSound = Res.getSound(resName, true);
		}
		
		public function get isLock():Boolean
		{
			return locking;
		}
		
		public function set upSound(value:Sound):void
		{
			_upSound = value;
		}
		
		public function get upSound():Sound
		{
			return _upSound;
		}
		
		public function set downSound(value:Sound):void
		{
			_downSound = value;
		}
		
		public function get downSound():Sound
		{
			return _downSound;
		}
		
		override public function get width():Number
		{
			if(_img)return _img.width
			return super.width;
		}
		
		override public function get height():Number
		{
			if(_img)return _img.height;
			return super.width;
		}
		
		/**
		 * 设置普通状态图片
		 */
		public function set upSkin(__up:String):void
		{
			if(!_renderArr)_renderArr = new Array();
			_renderArr[0] = __up;
		}
		
		public function get upSkin():String
		{
			return _renderArr[0] ;
		}
		/**
		 * 设置按下状态图片
		 */
		public function set downSkin(__down:String):void
		{
			if(!_renderArr)_renderArr = new Array();
			_renderArr[1] = __down;
		}
		
		public function get downSkin():String
		{
			return _renderArr[1] ;
		}
		
		/**
		 * 设置禁用状态图片
		 */
		public function set disableSkin(__disable:String):void
		{
			if(!_renderArr)_renderArr = new Array();
			_renderArr[2] = __disable;
		}
		public function get disableSkin():String{
			return _renderArr[2];
		}
		
		/**
		 * 按钮文字颜色
		 */
		public function set color(value:uint):void
		{
			_textColor = value;
			if(_text)
			{
				_text.textColor = value;
			}
		}
		
		/**
		 * 按钮文字大小
		 */
		public function set fontSize(value:int):void
		{
			_textSize = value;
			if(_text)
			{
				_text.fontSize = value;
			}
		}
		
		/**
		 * 设置组
		 */
		public function set group(value:String):void
		{
			_group = value;
		}
		
		/**
		 * 获取所属组
		 */
		public function get group():String
		{
			return _group;
		}
		
		override public function dispose():void
		{
//			_downSound = null;
//			_upSound = null;
//			_img = null;
//			_text = null;
//			_textStyle = null;
			super.dispose();
		}
		
		public override function render():void
		{
			if(_renderArr && _renderArr.length > 0)
			{
				var bName:String
				if (_renderArr[0])
				{
					upSkin = _renderArr[0] as String;
					if(status == 1)bName = upSkin;
				}
				if (_renderArr[1])
				{
					downSkin = _renderArr[1] as String;
					if(status == 2)bName = downSkin;
				}
				if (_renderArr[2])
				{
					disableSkin = _renderArr[2] as String;
					if(status == 3)bName = disableSkin;
				}
				if(bName){
					
					if(_img){
						_img.texture = Res.getTexture(bName); 
					}else{
						_img = Res.getImage(bName);
						addChildAt(_img,0);
					}
					
					this.expectWidth = _img.width
					this.expectHeight = _img.height;
				}
			}

			if(_text)
			{
				_text.setSize(this.width, this.height);
				
				if(_textColor)_text.textColor = _textColor;
				if(_textSize)_text.fontSize = _textSize;
				
				setChildIndex(_text, this.numChildren - 1);
			}
			
			if(_group && this.parent && (this.parent is ButtonBar))
			{
				ButtonBar(this.parent).addButton(this);
			}
		}
		
		public override function set exactHitTest(value:Boolean):void{
			
			_excat = value;
			if(_img)_img.exactHitTest = value;
		}
		
		public override function get exactHitTest():Boolean{
			return _excat;
		}
		
		public function setGrey(b:Boolean):void
		{
			_img.filter = b?UIGlobal.FILTER_IMG_GRAY:null;
			if(_text)
			{
				_text.filter = b?UIGlobal.FILTER_IMG_GRAY:null;
			}
		}
	}
}