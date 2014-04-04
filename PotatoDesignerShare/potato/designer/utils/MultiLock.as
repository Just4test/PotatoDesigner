package potato.designer.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 *众锁<b>[这不是一个多线程锁]</b>
	 * <br>允许多个模块为同一对象加锁。当所有子锁都解锁时，派发解锁事件
	 * <br>当任何一个子锁被杀死时，众锁死亡。派发死亡事件。
	 * <br>死亡的众锁可以被加锁、释放子锁或者杀死子锁。但众锁本身不会再派发任何事件。
	 * @author Just4test
	 * 
	 */
	public final class MultiLock extends EventDispatcher 
	{
		/**当没有被锁定时，加锁会派发此事件*/
		public static const EVENT_LOCKED:String = "LOCKED";
		/**在所有子锁都解除锁定时派发此事件*/
		public static const EVENT_UNLOCKED:String = "UNLOCKED";
		/**当任何子锁被指定为死亡时派发*/
		public static const EVENT_DEAD:String = "DEAD";
		
		
		private const locks:Vector.<SubLock> = new Vector.<SubLock>;
		private var _isDead:Boolean;
		
		public function MultiLock()
		{
		}
		
		/**为众锁加一个子锁，并获得此子锁*/
		public function getLock():SubLock
		{
			var lock:SubLock = new SubLock(this);
			if(!_isDead && !locks.length)
			{
				dispatchEvent(new Event(EVENT_LOCKED));
			}
			locks.push(lock);
			return lock;
		}
		
		internal function unLock(lock:SubLock):void
		{
			var index:int = locks.indexOf(lock)
			if(-1 != index)
			{
				locks.splice(index, 1);
				if(!_isDead && !locks.length)
				{
					dispatchEvent(new Event(EVENT_UNLOCKED));
				}
			}
		}
		
		internal function kill(lock:SubLock):void
		{
			var index:int = locks.indexOf(lock)
			if(-1 != index)
			{
				isDead = true;
				locks.splice(index, 1);
				
				if(!_isDead)
				{
					dispatchEvent(new Event(EVENT_DEAD));
				}
			}
		}
		
		/**指示当前还有多少锁未被释放也未死亡*/
		public function get numLocks():int
		{
			return locks.length;
		}
		
		/**指示众锁是否处于死亡状态*/
		public function get isDead():Boolean
		{
			return _isDead;
		}
	}
}