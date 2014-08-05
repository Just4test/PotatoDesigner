
package potato.logger
{
	import flash.utils.ByteArray;
	
	/**
	 * 日志类
	 * <listing>
	 * 使用方法:
	 *	 public class LoggerTest
	 *	 {
	 *	 	private var log:Logger = Logger.getLog("LoggerTest");
	 *	 	public function LoggerTest()
	 *	 	{
	 *	 		log.fatal("fatal");
	 *	 		log.error("error");
	 *	 		log.warn("warn");
	 *	 		log.info("info");
	 *	 		log.debug("debug");
	 *	 	}
	 *	 }
	 * </listing>
	 * @author 白 
	 * @date 2009-08-28
	 */
	public class Logger
	{
		/**
		 * 日志输出级别常量
		 */
		public static const DEBUG:int = 5;
		public static const INFO:int = 4;
		public static const WARN:int = 3;
		public static const ERROR:int = 2;
		public static const FATAL:int = 1;
		public static const OFF:int = 0;
		
		
		private static var loggerDic:Object;	//日志
		private static var rootLogger:Logger;		//全局logger
		private static var rootLoggerConfigItem:LoggerConfigItem;		////全局logger配置项
		
		private static var logConfigItemsArr:Array;	//配置项数组
		
		private var name:String;				//日志配置名
		private var level:int;					//日志级别
		private var logWriter:ILogWriter;		//输出器

		/**
		 * @param name 日志名（包路径）
		 * @param level 日志输出级别
		 * @param logWriter 日志输出器
		 * @author 白 
		 */
		public function Logger(name:String, level:int, logWriter:ILogWriter)
		{
			this.name = name;
			this.level = level;
			this.logWriter = logWriter;
		}
		
		/**
		 * 获得日志器
		 * @param obj 调用该日志的对象
		 * @return 日志对象
		 * @author 白 
		 * @example sample:<listing version="3.0">
		 *	 public class LoggerTest
		 *	 {
		 *	 	private var log:Logger = Logger.getLog("LoggerTest");
		 *	 	public function LoggerTest()
		 *	 	{
		 *	 		log.fatal("fatal");
		 *	 		log.error("error");
		 *	 		log.warn("warn");
		 *	 		log.info("info");
		 *	 		log.debug("debug");
		 *	 	}
		 *	 }
		 * </listing>
		 */
		public static function getLog(className:String):Logger
		{
			if (loggerDic == null)
			{
				loggerDic = new Object();
				
//				var logConfigItemsArr:Array = LogConfig.loadConfig();	//配置项数组
				logConfigItemsArr = LogConfig.loadConfig();	//配置项数组
				
				//全局日志器
				rootLoggerConfigItem = logConfigItemsArr[0];
				rootLogger = new Logger(rootLoggerConfigItem.name, rootLoggerConfigItem.level, rootLoggerConfigItem.writer);
			}
			
			if (loggerDic == null || loggerDic.length == 0)
			{
				return rootLogger;
			}

			return getLoggerByName(className);
		}
		
		/**
		 * 输出debug信息
		 * @param rest 输出消息
		 * @author 白
		 */
		public function debug(...rest):void
		{
			__J4T_BootLoader.log && __J4T_BootLoader.log(formatMsg(rest));

			if (this.level == OFF)
			{
				return;
			}
			
			if (this.level >= DEBUG)
			{
				logWriter.print("DEBUG:" + formatMsg(rest));
			}
		}
		
		/**
		 * 输出info信息
		 * @param msg 输出消息
		 * @author 白
		 */
		public function info(...rest):void
		{
			__J4T_BootLoader.log && __J4T_BootLoader.log(formatMsg(rest));
			
			if (this.level == OFF)
			{
				return;
			}
			
			if (this.level >= INFO)
			{
				logWriter.print("INFO:" + formatMsg(rest));
			}
		}
		
		/**
		 * 输出warn信息
		 * @param msg 输出消息
		 * @author 白
		 */
		public function warn(...rest):void
		{
			__J4T_BootLoader.log && __J4T_BootLoader.log(formatMsg(rest));
			
			if (this.level == OFF)
			{
				return;
			}
			
			if (this.level >= WARN)
			{
				logWriter.print("WARN:" + formatMsg(rest));
			}
		}
		
		/**
		 * 输出error信息
		 * @param msg 输出消息
		 * @author 白
		 */
		public function error(...rest):void
		{
			__J4T_BootLoader.log && __J4T_BootLoader.log(formatMsg(rest));
			
			if (this.level == OFF)
			{
				return;
			}
			
			if (this.level >= ERROR)
			{
				logWriter.print("ERROR:" + formatMsg(rest));
			}
		}
		
		/**
		 * 输出fatal信息
		 * @param msg 输出消息
		 * @author 白
		 */
		public function fatal(...rest):void
		{
			__J4T_BootLoader.log && __J4T_BootLoader.log(formatMsg(rest));
			
			if (this.level == OFF)
			{
				return;
			}
			
			if (this.level >= FATAL)
			{
				logWriter.print("FATAL:" + formatMsg(rest));
			}
		}
		
		/**
		 * 格式化消息
		 * @param msg 输出消息
		 * @return 格式化后的消息
		 * @author 白 
		 */
		private function formatMsg(msg:*):String
		{
			var str:String = "";
			
			for each (var itm:* in msg)
			{
				if (itm is ByteArray)
				{
					str += (byteArray2Hex(itm) + " ");
				} else {
					str += (itm + " ");
				}
			}
			
			var time:Date = new Date();
			msg = time.toLocaleString() + " " + this.name + " " + str;
			return msg;
		}
		
		/**
		 * 通过类路径取得日志
		 * @param classFullName 类路径
		 * @return 日志
		 * @author 白
		 */
		private static function getLoggerByName(classFullName:String):Logger
		{
			var log:Logger = loggerDic[classFullName];
			
			if (log == null)
			{
				var pageName:String = classFullName.substr(0, classFullName.indexOf("::", 0));
				
				var b:Boolean = false;
				var logConfig:LoggerConfigItem = null;
				var index:int;
				do {
					for each (logConfig in logConfigItemsArr)
					{
						if (logConfig.name == pageName)
						{
							b = true;
							break;
						}
					}
					
					index = pageName.lastIndexOf(".");
					pageName = pageName.substr(0, index);
					
				} while (index > 0)
				
				if (b == false)
				{
					logConfig = rootLoggerConfigItem;
				}
				
				log = new Logger(classFullName, logConfig.level, logConfig.writer);
			}
			
			return log;
		} 
		
		public static function byteArray2Hex(bta:ByteArray):String
		{
			var restr:String = "0x";
			var str:String;
			for (var i:int = 0; i<bta.length; i++)
			{
				str = bta[i].toString(16);
				if (str.length == 1)
				{
					str = "0" + str;
				}
				restr += str + " ";
			}
			return restr;
		}
		
		
		public function print(...rest):void {
//			trace(rest);
		}

	}
}