
package potato.logger
{
import core.display.Stage;
import core.filesystem.File;
//import core.sfcore;

//import flash.display.LoaderInfo;
//import flash.system.ApplicationDomain;
import flash.utils.getDefinitionByName;

	/**
	 * 日志配置信息
	 * 配置说明
	 * 				<Writer>com.gamfe.logger.FileLogger</Writer>	日志输出类，需实现ILogWriter接口
	 * 				<level>INFO</level>								缺省日志输出级别
	 * 				<logger name="com.gamfe.logger">				每个包的日志输出配置
	 *					<level>DEBUG</level>
	 * 				</logger>
	 * @author 白 
	 * @date 2009-08-28
	 */
	public class LogConfig
	{
		FileLogger;
		
		public static var ConfigXml:XML;// = 
//			<root>
//				<Writer>sf.logger.FileLogger</Writer>
//				<level>DEBUG</level>
//				
//				<logger name="mx">
//					 <level>DEBUG</level>
//				</logger>
//			</root>;
		
		private static var hasConfigFile:Boolean = false;
			
		
		/**
		 * 装载日志配置
		 * @return 日志配置对象数组
		 * @author 白 
		 */
		public static function loadConfig():Array
		{
			var logItemsArr:Array = new Array();
			var li:LoggerConfigItem = new LoggerConfigItem();
			li.name = "rootLog";
			li.writer = null;
			li.level = getLevel(null);
			logItemsArr.push(li);

			if (File.exists("loggerConfig.xml")) {
				hasConfigFile = true;
				ConfigXml = XML(File.read("loggerConfig.xml"));
				
				li.writer = getLogWriter();
				li.level = getLevel(ConfigXml);
				
				var cml:XMLList = ConfigXml.child("logger");
				for each (var xm:XML in cml)
				{
					var liTmp:LoggerConfigItem = new LoggerConfigItem();
					liTmp.name = xm.@name;
					liTmp.level = getLevel(xm);
					liTmp.writer = li.writer;		//使用全局输出器
					logItemsArr.push(liTmp);
				}
			}
			
			return logItemsArr;
		}
		
		/**
		 * 获得日志输出器
		 * @return 日志输出对象
		 * @author 白 
		 */
		private static function getLogWriter():ILogWriter
		{
			if (hasConfigFile) {
				var logClsName:String = LogConfig.ConfigXml.Writer;
				var cl:Class = getDefinitionByName(logClsName) as Class;
				return new cl();
			} else {
				return null;
			}
		}
		
		/**
		 * 获得日志级别
		 * @param configXml 日志配置xml
		 * @return 日志级别
		 * @author 白 
		 */
		private static function getLevel(configXml:XML):int
		{
			if (configXml == null) {
				return 0;
			}
			
			var rootLevel:String = "OFF";	
			if (configXml.hasOwnProperty("level"))
			{
				rootLevel = configXml.level;
			}
			
			//缺省值 OFF
			if ("DEBUG" == rootLevel)
			{
				return Logger.DEBUG;
			} else if ("INFO" == rootLevel)
			{
				return Logger.INFO;
			} else if ("WARN" == rootLevel)
			{
				return Logger.WARN;
			} else if ("ERROR" == rootLevel)
			{
				return Logger.ERROR;
			} else if ("FATAL" == rootLevel)
			{
				return Logger.FATAL;
			} else
			{
				return 0;
			}
		}
	}
}