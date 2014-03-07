package potato.login
{
	public class ServerListItemData
	{
		/**
		 * 服务器人数
		 */		
		public var online_num:String;
		/**
		 * 服务器ID
		 */		
		public var server_id:String;
		/**
		 *服务器名称 
		 */		
		public var server_name:String;
		/**
		 *服务器承载状态 
		 */		
		public var server_status_online:String;
		/**
		 *服务器状态 
		 */		
		public var server_status:String;
		/**
		 * 根据协议，可能多个，如socket链接地址等 
		 */		
		public var server_address:String;
		/**
		 *是否有角色 
		 */		
		public var create_flag:String;
		/**
		 *角色头像文件名 
		 */		
		public var user_face:String;
		/**
		 *角色等级 
		 */		
		public var user_level:String;
		public function ServerListItemData(obj:Object)
		{
			online_num=obj.online_num;
			server_id=obj.server_id;
			server_name=obj.server_name;
			server_status_online=obj.server_status_online;
			server_status=obj.server_status;
			server_address=obj.server_address;
			create_flag=obj.create_flag;
			user_face=obj.user_face;
			user_level=obj.user_level;
		}
		
		public function toString():String
		{
			return "online_num:"+online_num+
			" server_id:"+server_id+
			" server_name:"+server_name+
			" server_status_online:"+server_status_online+
			" server_status:"+server_status+
			" server_address:"+server_address+
			" create_flag:"+create_flag+
			" user_face:"+user_face+
			" user_level:"+user_level;
		}
	}
}