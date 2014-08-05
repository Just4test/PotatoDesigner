package potato.ui
{
	import potato.events.UIEvent;

	/**
	 * 带按钮的翻页控件，不支持XML配置
	 * Jun 4, 2012
	 */
	public class TabPages extends Pages
	{
		/**按钮组*/
		protected var btnBar:ButtonBar;
		/**样式*/
		private var _tabPagsStyle:TabPagesStyle;

		public function TabPages(width:int, height:int, isHorizontal:Boolean = true)
		{
			super(width, height, isHorizontal);
			btnBar = new ButtonBar(false);
			btnBar.isStopEvent =true;
			btnBar.addEventListener(UIEvent.CHANGE, btnBarChange);
			addChild(btnBar);

			_tabPagsStyle = new TabPagesStyle();
			_tabPagsStyle.horizontal = isHorizontal;
			updateStyle();
		}

		/**
		 * 添加 一个按钮
		 * @param btn
		 */
		public function addBtn(btn:Button):void
		{
			if (btn)
				btnBar.addButton(btn);
		}

		/**
		 * 添加一组按钮
		 * @param buttons
		 */
		public function addButtons(... buttons):void
		{
			for (var i:int = 0, m:int = buttons.length; i<m; i++)
				addBtn(buttons[i]);
		}

		/**
		 * TabPages样式
		 * @return
		 */
		public function get tabPagesStyle():TabPagesStyle
		{
			return _tabPagsStyle;
		}

		/**
		 * @private
		 * @param value
		 */
		public function set tabPagesStyle(value:TabPagesStyle):void
		{
			_tabPagsStyle = value;
			updateStyle();
		}

		/**
		 * 更新样式
		 */
		protected function updateStyle():void
		{
			if (_tabPagsStyle)
			{
				btnBar.spacing = _tabPagsStyle.btnSpacing;
				btnBar.x = _tabPagsStyle.btnsX;
				btnBar.y = _tabPagsStyle.btnsY;
				btnBar.isHorizontal = _tabPagsStyle.horizontal;
			}
		}

		/**
		 * 跳转到哪一页
		 * @param index
		 */
		override public function gotoPage(index:int, dispatchEvent:Boolean = true):void
		{
			super.gotoPage(index, dispatchEvent);
			btnBar.select(index);
		}

		/**
		 * 点击了标签页
		 * @param e
		 */
		private function btnBarChange(e:UIEvent):void
		{
			var btn:Button = btnBar.selectBtn[0];
			var index:int = btnBar.getSelectIndex(btn);
			gotoPage(index);
		}
		
		/**
		 * 获得选中的按钮，如果是单选按钮数组第一个就是选中的。如果是复选按钮，选中的是个数组
		 * @return
		 */
		public function get selectBtn():Vector.<Button>
		{
			if(btnBar)btnBar.selectBtn;
			return null;
		}
		/**
		 *单选状态得到选中按钮索引（-1为无选中按钮） 
		 * @return 
		 * 
		 */		
		public function get selectIndex():int{
			
			if(btnBar)btnBar.selectIndex;
			return -1;
		}
	}
}