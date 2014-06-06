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
		private var _info:String;
		
		
		/**请勿手动调用初始化方法*/
		public function SubLock(parent:MultiLock, info:String)
		{
			_parent = parent;
			_info = info;
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
		
		/**锁的信息，以便其他代码可以理解是何种对象加了锁*/
		public function get info():String
		{
			return _info;
		}

	}
}