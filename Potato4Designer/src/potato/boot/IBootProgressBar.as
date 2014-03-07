package potato.boot
{
	/**
	 * 通用的进度条接口，BootLoader中的进度条也是使用这个接口  
	 */	
	public interface IBootProgressBar
	{
		/**当前操作进度*/
		function set progress(v:Number):void;
		
//		/**已经下载的字节数*/
//		function set loadedBytes(n:int):void;
//		/**文件的总字节数*/
//		function set loadedTotal(n:int):void;
//		
//		
//		/**当前操作类型<br/>1=下载，2=解压 android适用*/
//		function set type(type:int):void;
//		
//		/**当前正在处理（下载/解压）的文件名*/
//		function set processFile(name:String):void;
	}
}