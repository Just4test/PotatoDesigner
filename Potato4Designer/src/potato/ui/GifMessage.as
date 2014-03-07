package potato.ui
{
	import core.display.DisplayObject;
	import core.events.TextEvent;
	import core.text.TextField;
	
	import potato.movie.Movie;

	/**
	 * 支持图文混排的文本组件
	 * 如果文本需链接点击事件，请设置public function handleLink(e:TextEvent):void
	 * @author	tufei
	 * @date	2013-01-17
	 */
	public class GifMessage extends UIComponent
	{
		/**最大消息数量**/
		public static const MAX:int = 5;
		/**动画名字字典**/
		public static var movKey:Array = [];
		/**解析动画名字的长度, **/
		public static var parseNameLen:int = 2;
		/**解析动画名字的起始符**/
		public static var parsePre:String = "$";
		/**动画名字前缀**/
		public static var movPre:String = "";
		/**解析表情最大个数**/
		public static var movMax:uint = 3;
		/**动画宽度**/
		public static var movWidth:int = 50;
		/**动画高度**/
		public static var movHeight:int = 50;
		
		private var curLen:int = 0;//当前条数
		private var txt:TextField;//文本，不能设置x,y属性，否则导致表情位置不正确
		private var _w:int;
		private var mv:Vector.<DisplayObject>;//存放movie，提供给表情文本
		
		private var _faceW:int;
		private var _faceH:int;
		
		/**
		 * 构造函数
		 * @parm width 文本框宽度
		 * @parm color 文本默认颜色
		 * @parm fontName 字体，默认土豆库默认字体
		 * @parm fontSize 字体大小，默认20
		 */
		public function GifMessage(width:int, color:uint=0xFFFFFFFF, fontName:String=UIGlobal.defaultFont, fontSize:int=20,faceW:int=0,faceH:int=0)
		{
			_w = width;
			txt = new TextField("", width, 0, fontName, fontSize, color);
			txt.htmlText = "";
			this.addChild(txt);
			
			_faceW = faceW;
			_faceH = faceH;
			
			mv = new Vector.<DisplayObject>();
			txt.setImages(mv);
			
			txt.addEventListener(TextEvent.LINK, linkHandler);
		}
		
		private function linkHandler(e:TextEvent):void
		{
			var o:Object = parent;
			while ( o ) {
				if ( o.hasOwnProperty("handleLink") ) {
					o.handleLink(e);
					break;
				}
				o = o.parent;
			}
		}
		
		//处理HTML支持表情
		private function formatHTML(s:String):String
		{
			var rs:String = "\\"+ parsePre +"\\d{"+ parseNameLen +"}";
			var reg:RegExp = new RegExp(rs, "gi");
			
			var ra:Array = s.match(reg);
			
			var len:int = ra.length;
			var i:int;
			var ps:String;
			var mov:Movie;
			var mn:String;
			var cur:int = 0;
			
			for(i=0;i<len;i++)
			{
				if(cur >= movMax)break;
				
				ps = ra[i];
				mn = ps.replace(parsePre, movPre);
				
				if(-1 == movKey.indexOf(mn))continue;
				
				mov = new Movie(mn);
				if(_faceW > 0 && _faceH > 0){
					mov.scaleX=mov.scaleY=Math.max(_faceW/mov.width,_faceH/mov.height);
				}
				this.addChild(mov);
				mv.push(mov);
				
				var mod:String = "<img id="+(mv.length-1)+" width="+movWidth+" height="+movHeight+"/>"
				s = s.replace(ps, mod);
				
				cur++;
			}
			
			return s;
		}
		
		
		/**
		 * 获取该消息组内消息条数
		 */
		public function getCurrentLength():int
		{
			return curLen;
		}
		
		/**
		 * 获取文本高度
		 */
		public function getHeight():int
		{
			return txt.textHeight;
		}
		
		/**
		 * 添加一条消息
		 */
		public function addMessage(msg:String):void
		{
			if(curLen >= MAX)
			{
				throw new Error("消息组数量过大");
				return;
			}

			msg = formatHTML(msg);
			
			if(txt.htmlText == "")
			{
				txt.htmlText = msg;
			}else
			{
				txt.htmlText += "<br />" + msg;
			}
			
			txt.setSize(_w, txt.textHeight);
			
			curLen++;
		}
		
		/**
		 * 获取处理后的文本字符串
		 */
		public function getHTML():String
		{
			return txt.htmlText;
		}
		
		/**
		 * 清理
		 */
		public function clearData():void
		{
			txt.htmlText = "";
			curLen = 0;
		}
	}
}