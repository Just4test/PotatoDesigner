package potato.designer.net
{
	public class NetConst
	{
		public static const PORT:int = 5489;
		
		/**主机多播端口<br>主机端在启动时会每秒广播数据包，以便客户端进行设备发现。*/
		public static const HOST_MULTICAST_PORT:int = 9964;
		/**主机多播地址<br>主机端在启动时会每秒广播数据包，以便客户端进行设备发现。*/
		public static const HOST_MULTICAST_IP:String = "224.0.2.199";
		
		/**服务器向客户端的问候语。包含服务器版本号。*/		
		public static const S2C_HELLO:String = "S2C_HELLO";
		
		/**客户端向服务器的问候语。表明客户端已经准备好。*/
		public static const C2S_HELLO:String = "C2S_HELLO";
		
		/**客户端向服务端发送LOG信息*/			
		public static const C2S_LOG:String = "C2S_LOG";
		
		/**客户端通知服务端，有一个插件已经被激活。*/
		public static const C2S_PLUGIN_ACCTIVATED:String = "C2S_PLUGIN_ACCTIVATED";
	}
}