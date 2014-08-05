
package potato.logger
{
	/**
	 * 日志输出器通用接口
	 * @author 白 
	 * @date 2009-08-28
	 */
    public interface ILogWriter {
        
        /**
		 * 字符串输出
		 * @param msg 消息字符串
		 * @author 白 
		 */
		function print(msg:String):void;

    }

}