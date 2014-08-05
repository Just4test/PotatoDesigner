package potato.designer.plugin.console
{
	import flashx.textLayout.elements.TextFlow;

	public class TabData
	{
		internal var tabName:String;
		internal var keyWord:String;
		internal var text:String = "";
		
		public function TabData(tabName:String, keyWord:String)
		{
			this.tabName = tabName;
			this.keyWord = keyWord;
		}
		
		public function toString():String
		{
			return tabName;
		}
	}
}