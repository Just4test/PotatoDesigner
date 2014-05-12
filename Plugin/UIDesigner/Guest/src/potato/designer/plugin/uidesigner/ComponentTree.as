package potato.designer.plugin.uidesigner
{
	public class ComponentTree
	{
		protected var _comp:*;
		protected var _children:Vector.<ComponentTree>;
		
		public function ComponentTree(comp:*, children:Vector.<ComponentTree>)
		{
			_comp = comp;
			_children = children;
		}

		public function get children():Vector.<ComponentTree>
		{
			return _children;
		}

		public function get comp():*
		{
			return _comp;
		}

	}
}