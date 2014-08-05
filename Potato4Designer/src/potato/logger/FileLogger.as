package potato.logger
{
	import flash.utils.ByteArray;
	
	import core.filesystem.File;
	import core.filesystem.FileStream;
	
	/**
	 * 文件日志
	 * Jun 11, 2012
	 */
	public class FileLogger implements ILogWriter
	{
		private static var log:String = "";
		
		private const LOGO_PATH:String = "log.txt";
		
		private var fs:FileStream;
		private var ba:ByteArray;
		
		public function FileLogger()
		{
			if(File.exists(LOGO_PATH))
			{
				log = File.read(LOGO_PATH);
			}
			return;
			
			ba = new ByteArray();
			
			fs = new FileStream();
			fs.open(LOGO_PATH, FileStream.APPEND);
			
			ba.writeUTFBytes("----------------- app restart -------------------------------\n");
			ba.position = 0;
			fs.writeBytes(ba);
			ba.clear();
		}
		
		public function print(msg:String):void
		{
			log = log + msg + "\n";
			File.write(LOGO_PATH, log);
			trace(msg);
			return;
			
			ba.writeUTFBytes(msg);
			ba.writeUTFBytes("\n");
			ba.position = 0;
			fs.writeBytes(ba);
			ba.clear();
			
			// 永远不关
		}
	}
}