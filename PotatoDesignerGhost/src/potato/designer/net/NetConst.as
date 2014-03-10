package potato.designer.net
{
	public class NetConst
	{
		public static const PORT:int = 5489;
		
		/**服务器向客户端的问候语。包含服务器版本号。*/		
		public static const S2C_HELLO:String = "S2C_HELLO";
		
		/**客户端向服务器的问候语。包含版本号并表明客户端已经准备好*/		
		public static const C2S_HELLO:String = "C2S_HELLO";
		
		/**请求指定的类描述*/		
		public static const S2C_REQ_DESCRIBE_TYPE:String = "S2C_REQ_DESCRIBE_TYPE";
	}
}