package potato.designer.framework
{
	import flash.utils.ByteArray;
	
	import potato.designer.framework.zip.ZipFile;

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
			swcBytes.position = 0;
			var zipFile:ZipFile = new ZipFile(swcBytes);
			return zipFile.getInput(zipFile.getEntry("library.swf"));
		}
	}
}