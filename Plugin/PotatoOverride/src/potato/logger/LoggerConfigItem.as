
package potato.logger
{
	/**
	 * 日志配置对象
	 * @author 白 
	 * @date 2009-08-28
	 */
	public class LoggerConfigItem
	{
		/**
		 * 日志配置名
		 */
		private var _name:String;
		
		/**
		 * 日志级别
		 */
		private var _level:int;
		
		/**
		 * 日志输出器
		 */
		private var _writer:ILogWriter;
		
		
		public function LoggerConfigItem()
		{
		}
		
		
		public function set name(name:String):void
		{
			this._name = name;
		}
		
		public function get name():String
		{
			return this._name;
		}
		
		
		public function set level(level:int):void
		{
			this._level = level;
		}
		
		public function get level():int
		{
			return this._level;
		}
		
		
		public function set writer(writer:ILogWriter):void
		{
			this._writer = writer;
		}
		
		public function get writer():ILogWriter
		{
			return this._writer;
		}

	}
}