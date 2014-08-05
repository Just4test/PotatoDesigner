package potato.ui
{
	/**
	 * TabPages 样式
	 * Jun 4, 2012
	 */
	public class TabPagesStyle
	{
		/**按钮组x*/
		public var btnsX:int;
		/**按钮组y*/
		public var btnsY:int;
		/**按钮间距*/
		public var btnSpacing:int;
		/**是否是横向按钮*/
		public var horizontal:Boolean;
		
		public function TabPagesStyle(btnsX:int = 0, btnsY:int = 0, btnSpacint:int = 0, horizontal:Boolean = true)
		{
			this.btnsX = btnsX;
			this.btnsY = btnsY;
			this.btnSpacing = btnSpacint;
			this.horizontal = horizontal;
		}
	}
}