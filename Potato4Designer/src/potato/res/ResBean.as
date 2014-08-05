package potato.res
{
	/**
	 * 资源配置 
	 */	
	public class ResBean
	{
		/**id*/
		public var id:String;
		/**图片路径*/
		public var path:String;
		/**atlas*/
		public var atlas:String;
		/**是否缓存*/
		public var cache:int;
		/**
		 * 类型，可能的值如下：
		 * 	0	资源配置文件类型，允许包含子配置文件
		 * 	1	资源类型
		 * 	2	字符串资源文件（根据当前语言进行预处理）
		 *  3	动画配置文件
		 *  4   zilb压缩的图片资源文件
		 *  5   zilb压缩的其他文件（只能是类型为 8 的文件）
		 *  6   mp4压缩文件，扩展名m4a（需要安装FormatFactory）
		 * 	8	直接拷贝
		 * 	9	忽略任何处理
		 */
		public var type:int = -1;
		
		
		////////// 下面变量不在二进制配置文件中提供 //////
		
		public var type1:int;
		public var type2:int;
		
		/**是否第一次使用，用来判断文件存在和更新*/
		public var isFileExist:int = -1;
		
		private var _absoluteUrl:String;
		
		public function get absoluteUrl():String
		{
			return _absoluteUrl;
		}

	}
}