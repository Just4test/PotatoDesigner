package potato.designer.framework
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import potato.designer.framework.deng.fzip.FZip;

	public class Utils
	{
		/**
		 * 将swc解压，获取其中的swf文件
		 * @param swcBytes swc文件的原始字节数组
		 * @return swf文件的内容。如果解压出错，返回null
		 * 
		 */
		public static function unzipSWC(swcBytes:ByteArray):ByteArray
		{
			var fZip:FZip = new FZip;
			var ret:ByteArray;
			//利用了loadBytes在return之前就会派发事件的特性
			fZip.addEventListener(Event.COMPLETE, onUnzipCompleteHandler);
			fZip.loadBytes(swcBytes);
			fZip.removeEventListener(Event.COMPLETE, onUnzipCompleteHandler);
			
			return ret;
			
			function onUnzipCompleteHandler():void
			{
				ret = fZip.getFileByName("library.swf").content;
			}
			
		}
	}
}