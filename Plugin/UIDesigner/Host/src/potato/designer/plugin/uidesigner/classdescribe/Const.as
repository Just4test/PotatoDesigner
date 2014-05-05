package potato.designer.plugin.uidesigner.classdescribe
{
	public class Const
	{
//		/**不支持的类型*/
//		public static const TYPE_UNSUPPORT:int = 0;
//		/**
//		 * 默认的类型
//		 * <br>设计器会猜测其类型，并在字符串、整数、浮点、布尔值中选择一个。
//		 */
//		//    public static const TYPE_DEFULT:int = 0;
//		/**字符串类型*/
//		public static const TYPE_STRING:int = 1;
//		/**整数类型*/
//		public static const TYPE_INT:int = 2;
//		/**浮点类型*/
//		public static const TYPE_NUMBER:int = 3;
//		/**布尔值类型*/
//		public static const TYPE_BOOLEAN:int = 4;
//		/**字符串数组类型。分隔符默认为","*/
//		public static const TYPE_ARRAY:int = 5;
//		/**图片材质类型*/
//		public static const TYPE_TEXTURE:int = 6;
		
		
//		public static const TYPE_MAP:Object =
//			{
//				"String":
//				TYPE_STRING,
//				"int":
//				TYPE_INT,
//				"Number":
//				TYPE_NUMBER,
//				"Boolean":
//				TYPE_BOOLEAN,
//				"Array":
//				TYPE_ARRAY,
//				"core.display::Texture":
//				TYPE_TEXTURE
//			};
		
//		public static function type2typeCode(type:String):int
//		{
//			return TYPE_MAP[type] || 0;
//		}
		
		
		public static function getShortClassName(fullName:String):String
		{
			return fullName.split("::").pop();
		}
		
		
		
		

	}
}