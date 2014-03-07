
package potato.logger
{
	import flash.utils.getQualifiedClassName;
	
	/**
	 * 日志输出器
	 * @author 白 
	 * @date 2009-08-28
	 */
	public class TraceWriter implements ILogWriter
	{
		public function TraceWriter()
		{
//			trace(getQualifiedClassName(obj));
		}
		
		/**
		 * 输出
		 * @param msg 输出消息
		 * @author 白
		 */
		public function print(msg:String):void
		{
//			trace(msg);
		}
	}
}