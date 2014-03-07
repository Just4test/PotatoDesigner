package potato.ui
{
	/**
	 * 文本样式
	 * Jun 5, 2012
	 */
	public class TextStyle
	{
		/**字体名*/
		public var fontName:String;
		/**字体大小*/
		public var fontSize:int;
		/**颜色*/
		public var textColor:uint;
		/**横向对其*/
		public var hAlign:uint;
		/**纵向对其*/
		public var vAlign:uint;
		
		public function TextStyle(fontName:String="宋体", fontSize:int=12, textColor:uint=0x00000000, hAlign:uint = 0, vAlign:uint = 0)
		{
			this.fontName = fontName;
			this.fontSize = fontSize;
			this.textColor = textColor;
			this.hAlign = hAlign;
			this.vAlign = vAlign;
		}
		
		public function clone():TextStyle
		{
			return new TextStyle(fontName, fontSize, textColor, hAlign, vAlign);
		}
	}
}