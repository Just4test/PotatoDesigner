package potato.ui
{
	import flash.geom.Rectangle;
	
	import core.display.DisplayObjectContainer;
	import core.display.Grid9Texture;
	import core.display.Image;
	import core.events.TextEvent;
	import core.text.TextField;
	
	import potato.events.InputEvent;
	import potato.res.Res;
	import potato.utils.KeyboardConst;

	[Event(name="inputChange", type="potato.events.InputEvent")]
	[Event(name="inputComplete", type="potato.events.InputEvent")]

	public class TextInput extends UIComponent
	{
		public static const VERSION:String='1.2';
		
		
		public static const ALIGN_TYPE_RIGHT:int=2; 
		public static const ALIGN_TYPE_MIDDLE:int=1;
		public static const ALIGN_TYPE_LEFT:int=0;
		public static const ALIGN_TYPE_UP:int=0;
		public static const ALIGN_TYPE_DONW:int=2;
		
		public static const REG_NLC:RegExp=/^[\u4E00-\u9FA5A-Za-z0-9]+$/;
		public static const REG_NL:RegExp=/^[A-Za-z0-9]+$/;
		public static const REG_LC:RegExp=/^[\u4E00-\u9FA5A-Za-z]+$/;
		public static const REG_NC:RegExp=/^[\u4E00-\u9FA50-9]+$/;
		public static const REG_N:RegExp=/^[0-9]+$/;
		public static const REG_L:RegExp=/^[A-Za-z]+$/;
		public static const REG_C:RegExp=/^[\u4E00-\u9FA5]+$/;
		
		/**
		 * 正则匹配汉字，数字，英文大小写
		 * 
		 * N=number		数字
		 * L=letter		英文大小写
		 * C=chinese	中文字符
		 * check作为中间人使用；
		 * @param str
		 * @return 
		 * 
		 */
		public static function checkNLC(str:String):Boolean
		{
			return REG_NLC.test(str);
		}
		
		
		/**
		 * 正则匹配数字
		 */
		public static function checkN(str:String):Boolean
		{
			return REG_N.test(str);
		}
		
		/**
		 * 正则匹配数字，英文大小写
		 */
		public static function checkNL(str:String):Boolean
		{
			return REG_NL.test(str);
		}
		/**
		 * 正则匹配数字，汉字
		 */
		public static function checkNC(str:String):Boolean
		{
			return REG_NC.test(str);
		}
		/**
		 * 正则匹配英文大小写汉字
		 */
		public static function checkLC(str:String):Boolean
		{
			return REG_LC.test(str);
		}
		
		/**
		 * 正则匹配汉字
		 */
		public static function checkC(str:String):Boolean
		{
			return REG_C.test(str);
		}
		
		/**
		 * 正则匹配英文大小写
		 */
		public static function checkL(str:String):Boolean
		{
			return REG_L.test(str);
		}
		
		public static const CHECKFUNCS:Object={
			N:checkN,L:checkL,C:checkC,NL:checkNL,NC:checkNC,LC:checkLC,NLC:checkNLC
		}
		
			
		protected var _textFieldOffsetX:int=5;
		/**
		 *TextField的偏移，有时候添加的背景四周有花边，这就需要将输入框水平做一定的偏移；
		 * @param offsetx
		 * 
		 */
		public function set textFieldOffsetX(offsetx:int):void{
			_textFieldOffsetX=offsetx;
			_textField.x=_textFieldOffsetX;
			
			reSetTFVisualSize();
		}
		
		
		/**
		 *密码格式下显示的符号； 
		 */
		protected var _passwordMark:String='*';
		/**
		 *当前是否密码输入格式 
		 */
		protected var _isPwdFormat:Boolean=false;
		
		/**
		 *最大输入个数 ，1个英文字母，一个汉字，一个特殊符号都是一个字符
		 */
		protected var _maxCharsNum:int=0;
		
		/**
		 *最大字节数
		 * 英文，数字都占用一个字节，汉字占据2个； 
		 */
		protected var _maxBytesNum:int=0;
		
		protected var _hAlignType:int=ALIGN_TYPE_LEFT;
		protected var _vAlignType:int=ALIGN_TYPE_UP;
		
		protected var _textFieldCtn:DisplayObjectContainer;
		protected var _textField:TextField;
		
		/**当前显示文本*/
		protected var _textStr:String = "";
		
		/**
		 *是否允许滚动； 
		 */
		protected var _isScroll:Boolean=false;
		
		/**是否是多行文本*/
		protected var _isMultiline:Boolean=false;
		public function set isMultiline(value:Boolean):void{
			_isMultiline=value;
			
			renderTFSize();
		}
		protected var _fontName:String='yh';
		public function set fontName(name:String):void{
			_fontName=name;
			
		}
		public function set fontSize(size:int):void{
			_fontSize=size;
		}
		
		
		/**默认字符串显示*/
		protected var _defaultText:String = "";
		/**默认字符串颜色*/
		protected var _defaultTextColor:uint = 0x99999999;
		
		
		protected var _fontSize:uint=20;
		
		/**文本框可见区域*/
		protected var tfVisualRect:Rectangle=new Rectangle();
		/**TextInput实例整体可见区域*/
		protected var visualRect:Rectangle=new Rectangle();
		
		
		
		
		/**输入检查（传入字符 返回 true|false）*/
		protected var _inputCheck:Function;
		
		
		/**
		 *设置密码显示下的符号样式；默认的样式为：* 
		 * @param mark
		 * 
		 */
		public function set passwordMark(mark:String):void{
			_passwordMark=mark;
		}
		
		public function set isPasswordFormat(value:Boolean):void{
			_isPwdFormat=value;
		}
		
		public function set maxChars(value:int):void{
			_maxCharsNum=value;
		}
		public function get maxChars():int{
			return _maxCharsNum;
		}
		public function set maxBytes(value:int):void{
			_maxBytesNum=value;
		}
		public function get maxBytes():int{
			return _maxBytesNum;
		}
		
		public function set inputType(v:int):void
		{
			_textField.inputType = v;
		}
		
		public function get inputType():int
		{
			return _textField.inputType;
		}
		
		/**
		 *设置输入框文本显示的排列方式； 如果要设置成居中对齐或者靠右对齐的话，整个文本框将不再随着输入内容的增加而自动调整偏移；
		 * @param value		参考该类静态常量ALIGN_TYPE_XXXX，缺省值：ALIGN_TYPE_LEFT（左对齐）
		 * 
		 */
		public function set hAlign(value:int):void{
			_hAlignType=value;
			_textField.hAlign=_hAlignType;
			renderTFSize();
		}
		
		public function set vAlign(value:int):void{
			_vAlignType=value;
			_textField.vAlign=_vAlignType;
			renderTFSize();
		}
		
		/**
		 *给输入框赋值，包括赋值，渲染2部分；
		 * 注意！！！！
		 * 用这种方式赋予TextInput的值不做条件检测；因为这个方法只有编程人员才能使用。既然编程人员想要显示这个字符串，那也就无须检测输入的合法性了。
		 * 不过会截断长度；
		 * @param value
		 */
		public function set text(value:String):void
		{
			_textStr = value;
			
			renderTextFieldText();
		}
		
		public function get text():String
		{
			//FIXME:这里需要在以后修复；
			if(_textStr==''||_textStr==null)return _defaultText;
			return _textStr;
		}
		
		private var _editable:Boolean=true;
		public function get editable():Boolean{
			return _editable;
		}
		public function set editable(value:Boolean):void{
			_editable=value;
			if(_editable)
			_textField.addEventListener(TextEvent.TEXT_INPUT, onTextInputHandler);
			else
				_textField.removeEventListener(TextEvent.TEXT_INPUT, onTextInputHandler);
		}
			

		
		protected var _textColor:uint=0x0;
		/**文字颜色*/
		public function set textColor(value:uint):void
		{
			_textColor = value;
		}
		public function get textColor():uint
		{
			return _textColor;
		}
		
		public function get defaultText():String
		{
			return _defaultText;
		}
		
		public function set defaultText(value:String):void
		{
			_defaultText = value;
			_textStr='';
			renderTextFieldText();
		}
		
		public function get defaultTextColor():uint
		{
			return _defaultTextColor;
		}
		
		public function set defaultTextColor(value:uint):void
		{
			_defaultTextColor = value;
		}
		
		/**
		 *常见的几种检测：纯数字、数字字母汉字、汉字、汉字字母、数字字母等
		 * 这样设置主要是为了迎合xml布局；
		 * 'NLC'
		 * N=number;
		 * L=letter
		 * C=汉字
		 * 注意顺序； 
		 * @param value		'NLC'
		 * 
		 */
		public function set commonCheck(value:String):void{
			
			check=TextInput.CHECKFUNCS[value] as Function;
			
		}
		
		public function set check(value:Function):void
		{
			_inputCheck = value;
		}
		
		
		/**
		 * 重新设置文整个文本输入框的高宽
		 * @param expectWidth
		 * @param expectHeight
		 */
		public function setSize(expectWidth:int, expectHeight:int):void
		{
			//保存可见（期望）文本区域的大小；
			_expectWidth=expectWidth;
			_expectHeight=expectHeight;	
			
			render();
		}
		
		/**
		 *立即渲染文本框输入的文本，包括字体，字号，颜色等； 
		 * 
		 */
		public function renderTextFieldImmediatly():void{
			renderTextFieldText();
			renderTextFieldTextAd();
		}
		
		protected var _backgroundImgId:String='';
		public function set backgroundImgId(id:String):void{
			_backgroundImgId=id;
		}
		
		protected var _backgroundImgRect:Rectangle=new Rectangle();
		protected const REG_RECT:RegExp=/^\d+,\d+,\d+,\d+$/;
		/**
		 *设置背景材质9宫格的数据，字符串形式，依次输入x,y,width,height，用逗号分开,4个数据必去齐全；
		 * 例如：
		 * '0,0,10,10' 
		 * @param rectStr
		 * 
		 */
		public function set backgroundImgRect(rectStr:String):void{
			if(!REG_RECT.test(rectStr))return;
			var ar:Array=rectStr.split(',');
			with(_backgroundImgRect){
				x=ar[0];
				y=ar[1];
				width=ar[2];
				height=ar[3];
			}
			ar=null;
			
		}
		
		protected var backgroundImg:Image;
		/**
		 *渲染背景图片的大小到期望大小 
		 * @param imgId
		 * @param rect
		 * 
		 */
		protected function renderBackgroundImg():void{
			if(_backgroundImgId==''||_backgroundImgId==null||_backgroundImgRect==null||_backgroundImgRect.isEmpty())return;
			
			if(backgroundImg){
				this.removeChild(backgroundImg);
				backgroundImg.dispose();
				backgroundImg=null;
			}
			backgroundImg=new Image(new Grid9Texture(Res.getTexture(_backgroundImgId),_backgroundImgRect,_expectWidth,_expectHeight));
			this.addChildAt(backgroundImg,0);
			
			
		}
		
		
		/**
		 * 
		 * @param defaultTxt			文本无内容时候的灰色提示文字
		 * @param expectWidth			显示的宽度(取输入数字的绝对值）；
		 * @param expectHeight			显示（ui，用户看到的）的高度(取输入数字的绝对值）；
		 * @param fontName				字体
		 * @param fontSize				字号
		 * @param textColor				文本颜色
		 * @param isMultiline			是否多行显示,文本输入框一般都是单行输入，默认false
		 * @param isScroll				是否允许输入框在输入满后滚动;
		 * 
		 * <TextInput backgroundImgId='Common_Tip_BG' backgroundImgRect='10,10,40,40' commonCheck='NL' maxChars='100'  x='0' y='0' id="test" width="400" height="30" textColor="0x0000ff" defaultText="这里输入文本"/>
		 */
		public function TextInput(defaultTxt:String="", 
								  expectWidth:int=100, 
								  expectHeight:int=30, 
								  fontName:String = "yh", 
								  fontSize:Number = 20, 
								  textColor:uint = 0,
								  isMultiline:Boolean=false,
									isScroll:Boolean=false
		)
		{
			_isContainer = false;
			
			_defaultText = defaultTxt;
			_expectHeight=Math.abs(expectHeight);
			_expectWidth=Math.abs(expectWidth);
			_fontSize=fontSize;
			_textColor=textColor;
			
			_textFieldCtn=new DisplayObjectContainer();
			this.addChild(_textFieldCtn);
			_textField=new TextField(_defaultText,
				_expectWidth-2*_textFieldOffsetX,
				_expectHeight,
				fontName,
				fontSize,
				_defaultTextColor);
			_textField.type = TextField.INPUT;
			if(_editable)
			_textField.addEventListener(TextEvent.TEXT_INPUT, onTextInputHandler);
			_textFieldCtn.addChild(_textField);
			this.isMultiline=isMultiline;
			_isScroll=isScroll;
			
			render();
			
			
		}
		
		
		
		/**
		 * 记录用户前一次按键的键值；
		 * */
		protected var lastKeyCode:int;
		protected function onTextInputHandler(event:TextEvent):void
		{
			lastKeyCode=event.text.charCodeAt(0);
			switch(lastKeyCode)
			{
				case KeyboardConst.BACKSPACE:
				{
					//delete key
					_textStr= _textStr.substr(0, _textStr.length - 1);
					break;
				}
				case KeyboardConst.ENTER:
				{
					//enter key
					if (_isMultiline)_textStr += "\n";
					else
					{
						this.dispatchEvent(new InputEvent(InputEvent.INPUT_COMPLETE));
						
						return;
					}
					break;
				}
					
				default:
				{
					if(_inputCheck != null)if(!_inputCheck(event.text))return;
					
					_textStr += event.text;
					break;
				}
			}
			
			renderTextFieldText();
			this.dispatchEvent(new InputEvent(InputEvent.INPUT_CHANGE));
		}
		
		/**
		 *渲染组件中TextField部分；
		 * 具体包括：
		 * 坐标定位，
		 * 显示的文字，
		 * 文字颜色，
		 * 
		 */
		protected function renderTextFieldText():void
		{
			if (_textStr == ""||_textStr==null)
			{
				//如果没有输入任何字符，那么将显示默认的字符串与该字符串的颜色；
				_textField.textColor = _defaultTextColor;
				_textField.text = _defaultText;
				_textField.x=_textFieldOffsetX;
				
				
			}
			else
			{
				
				
				//截断字符串(_textStr)的长度，其长度不能大于设定的长度；
				truncateStr();
				
				if(_isPwdFormat){
					//将字符串整理成为密码格式；
					_textField.text=changeToPwdFormat(_textStr);
					
				}else{
					if(_suffix!=null && _suffix!='' && _inputCheck==checkN ){
						
						//将字符串整理为用户定义的显示格式；(检测方式必须是数字）
						_textField.text=changeToUserFormat(_textStr);
					}else{
						
						//普通显示；
						_textField.text=_textStr;
					}
				}
				
				//渲染文本颜色；
				_textField.textColor = _textColor;
				
				//只有当单行输入并且允许滚动的时候才设置新坐标;
				if(!_isMultiline && _isScroll){
					reCoordinateTextField();
				}
				
				
			}
		}
		
		/**
		 *渲染TextField不常用的属性；
		 *  renderTextFieldText（）这个函数是用户每次输入都会调用，并渲染，但TextField的大部分属性不需要总是不停的渲染，
		 * 比如字号，字体等；
		 * 该函数主要用来渲染不常用属性；
		 * 
		 */
		protected function renderTextFieldTextAd():void{
			_textField.fontName=_fontName;
			_textField.fontSize=_fontSize;
			//TODO:more render..
		}
		
		
		protected function changeToPwdFormat(str:String):String
		{
			var pwdStr:String='';
			var lgth:int=str.length;
			for(var i:int=0;i<lgth-1;i++){
				pwdStr+=_passwordMark;
			}
			pwdStr+=lastKeyCode==KeyboardConst.BACKSPACE?_passwordMark:str.charAt(lgth-1);
			
			return pwdStr;
		}
		
		/**
		 *截断字符串_textStr的长度为已设长度；
		 * 该类有2种长度：字符长度与字节长度
		 * 必须使显示的字符串都符合2种长度；
		 * 
		 * 如果长度为0，表示不做对应的限制；
		 * 
		 */
		protected function truncateStr():void{
			
			//截断长度以符合字符长度；
			_maxCharsNum==0?null:_textStr=_textStr.substr(0,_maxCharsNum);
			
			//截断长度以符合字节长度
			if(_maxBytesNum==0)return;
			
			var sumBytes:int=0;
			var sumLgth:int=0;
			
			var lgth:int=_textStr.length;
			var i:int=0;
			
			while(i<lgth&&sumBytes<_maxBytesNum){
				sumBytes+=_textStr.charCodeAt(i)<256?1:2;
				sumLgth++;
				i++;
			}
			if(sumBytes>_maxBytesNum)sumLgth--;
			
			_textStr=_textStr.substr(0,sumLgth);
			
		}
		
		/**
		 * 刷新需要显示的tf的x坐标；
		 * 
		 * //单行的话，需要判断用户输入的文字是否超过了可显示区域，超过了就要让txtFeidl向左偏移，以便让光标显示在中间；
		 * //当然如果用户输入了好多，现在开始删除，又要将txtField右移；
		 * 算法简述：
		 * 只看当前输入的所有字符的右边界与原点的x偏移，这个偏移如果在rect（可显示区域）以内，就不做任何变化，
		 * 如果在rect的右边，tf需要左移
		 * 如果在rect的左边，tf需要右移；
		 * */
		protected function reCoordinateTextField():void{
			if(!_isExpaned){
				_isExpaned=true;
				renderTFSize();
			}
			
			if(_textField.textWidth<visualRect.width-2*_textFieldOffsetX){
				_textField.x=_textFieldOffsetX;
				return;
			}
			
			var tfXOffset:int=_textField.textWidth+_textField.x-_textFieldOffsetX;
			
			if(tfXOffset>visualRect.width-_textFieldOffsetX*2||tfXOffset<_textFieldOffsetX){
				_textField.x=-_textField.textWidth+visualRect.width*0.5+_textFieldOffsetX;
			}
			
			
		}
		
		protected var _isExpaned:Boolean=false;
		protected function renderTFSize():void{
			
			if(!_isMultiline && _isScroll)
				//单行输入并且允许滚动的时候，由于文本框需要根据输入位置而变化，故此需要较长的区域；
				_textField.setSize(2000,_expectHeight);
			else 
				_textField.setSize(_expectWidth-2*_textFieldOffsetX,_expectHeight);
			
		}
		
		/**
		 *刷新整个组件可视区域
		 * 
		 */
		protected function reSetVisualSize():void
		{
			with(visualRect){
				width=_expectWidth;
				height=_expectHeight;
			}
			
			this.clipRect = visualRect;
		}
		/**
		 *刷新TextField的可视区域； 
		 * 
		 */
		protected function reSetTFVisualSize():void
		{
			with(tfVisualRect){
				x=_textFieldOffsetX;
				y=0;
				width=_expectWidth-2*_textFieldOffsetX;
				height=_expectHeight;
			}
			
			_textFieldCtn.clipRect = tfVisualRect;
		}
		
		
		override public  function render():void{
			//渲染文本框大小；
//			renderTFSize();
			//渲染背景大小
			renderBackgroundImg();
			//渲染文本框输入的文本；
			renderTextFieldText();
			//高级渲染输入的文本；
			renderTextFieldTextAd();
			//重置整体可视区域大小
			reSetVisualSize();
			//重置输入框可见区域大小
			reSetTFVisualSize();
		}
		
		
		
		
		
		/**
		 *设置格式化的显示数字 （该功能目前比较脆弱）
		 * @param suffix			格式化后显示的后缀符号比如：w，W，万，千等
		 * @param value				该后缀格式需要个位数字移动多少位实现（向高位移动为+），如果后缀要显示‘万’，那么就需要移动+4位；
		 * @param precise			精度位数（小数点后的，精度不会四舍五入，简单的截取）比如12345->1.2W（精度1）->1.23W（精度2）
		 * 
		 */
		public function setShowFormat(suffix:String='w',value:int=4,precise:int=0,value2:int=5):void{
			_suffix=suffix;
			_tmpValue=value;
			_precise=precise;
			_tmpValue2=value2;
		}
		
		
		private var _suffix:String;
		private var _tmpValue:int=1;
		private var _precise:int=0;
		private var _tmpValue2:int=100;
		private function changeToUserFormat(str:String):String
		{
			var num:int=int(str);
			if(str.length<_tmpValue2){
				return str;
			}
			
			var j:int=int(num/(Math.pow(10,_tmpValue-_precise)));
			var result:String=String(j/(Math.pow(10,_precise)));
			
			return result+_suffix;
		}
		
		public function get textField():TextField
		{
			return _textField;
		}
	}
}