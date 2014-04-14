package potato.designer.framework
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class DataCenter
	{
		/**
		 *工作空间模板在应用程序安装目录中的路径 
		 */
		public static const WORKSPACE_TEMPLATE_FOLDER:String = "designer/workspaceTemplate";
		public static const WORKSPACE_FILE_NAME:String = "workspace.json";
		
		private static var _isWorkSpaceLoaded:Boolean;
		
		/**
		 *载入或创建工作空间
		 * <br>必须在工作空间已经关闭的情况下执行。载入工作是同步的。
		 * @param path 工作空间的目录。如果指定目录下没有工作空间主文件，则以默认设置创建工作空间主文件并载入它。
		 * 
		 */
		public static function loadWorkSpace(path:String):Boolean
		{
			if(_isWorkSpaceLoaded)
			{
				throw new Error("工作空间未被关闭之前不得再次载入工作空间");
			}
			
			var folder:File = new File(path);
			if(folder.exists && !folder.isDirectory)
			{
				log("[DataCenter] 载入工作空间失败。路径是一个已经存在的文件\n", path);
				return false;
			}
			
			try
			{
				if(!folder.exists)
				{
					var template:File = File.applicationDirectory.resolvePath(WORKSPACE_TEMPLATE_FOLDER);
					template.copyTo(folder);
				}
			} 
			catch(error:Error) 
			{
				log("[DataCenter] 拷贝工作空间模板时发生错误：\n", error);
				return false;
			}
			
			try
			{
				var workspaceFile:File = folder.resolvePath(WORKSPACE_FILE_NAME);
				var fileStream:FileStream = new FileStream();
				fileStream.open(workspaceFile, FileMode.READ);
				var str:String = fileStream.readMultiByte(fileStream.bytesAvailable, File.systemCharset);
				fileStream.close();
				var data:Object = JSON.parse(str);
			} 
			catch(error:Error) 
			{
				log("[DataCenter] 载入工作空间时发生错误：\n", error);
				return false;
			}
			
			
			return true;
		}
		
		
		/**
		 *保存工作空间。将派发事件以便所有插件能够保存工作空间。 
		 * <br>保存工作不是同步的。保存完成后将派发事件。
		 */
		public static function saveWorkSpace():void
		{
		}
		
		/**
		 *丢弃工作空间。将派发事件以便所有插件能够丢弃工作空间。
		 * <br>丢弃后将关闭工作空间，并且卸载所有插件。将派发工作空间关闭事件。请注意，任何插件都不能接收到工作空间关闭事件。
		 */
		public static function discardWorkSpace():void
		{
		}

		public static function get isWorkSpaceLoaded():Boolean
		{
			return _isWorkSpaceLoaded;
		}

	}
}