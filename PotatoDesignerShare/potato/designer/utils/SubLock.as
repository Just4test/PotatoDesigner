package potato.designer.utils
{
	/**
	 *MultiLock所使用的子锁 
	 * @author Just4test
	 * 
	 */
	public class SubLock
	{
		private var _parent:MultiLock;
		public function SubLock(parent:MultiLock)
		{
			_parent = parent;
		}
		
		/**释放子锁*/
		public function unLock():void
		{
			_parent.unLock(this);
		}
		
		/**杀死子锁*/
		public function kill():void
		{
			_parent.kill(this);
		}
	}
}