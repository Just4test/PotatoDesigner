package potato.events
{
	import core.events.Event;
	
	public class LoginEvent extends Event
	{
		/** 获取token成功 */		
		public static const TOKEN:String = "token";
		/** 获取token失败  */		
		public static const TOKEN_ERROR:String = "token_error";
		/**登录成功  9000 */		
		public static const LOGIN_SUCCESS:String = "login_success";
		/**登出成功 */		
		public static const LOGIN_OUT_SUCCESS:String = "login_out_success";
		/**登出错误*/		
		public static const LOGIN_OUT_ERROR:String = "login_out_error";
		/**登录错误  */		
		public static const LOGIN_ERROR:String = "login_error";
		/**退出平台窗口*/		
		public static const OUT_PEV:String = "out_pev";
		/**苹果获得推送通知*/		
		public static const APPPUSHTOKEN:String = "apppushtoekn";
		/**苹果获得推送通知失败 */		
		public static const APPPUSHTOKEN_ERROR:String = "apppushtoekn_error";
		/**appwebClose
		 */		
		public static const APPWEB_CLOSE:String = "appweb_close";
		/**检测版本信息成功*/
		public static const VERSIONCHECK_SUCCESS:String = "versioncheck_success";
		/**验证登录信息成功*/
		public static const LOGINVERIFICATION_SUCCESS:String = "loginverification_success";
		/**获取服务器列表成功*/		
		public static const SERVERLIST_SUCCESS:String = "serverlist_success";
		/**获取服登录key成功*/
		public static const LOGINKEY_SUCCESS:String = "loginkey_success";
		/**获取苹果推送成功*/
		public static const APPPUSH_SUCCESS:String = "apppush_success";
		/**获取安卓推送成功*/
		public static const ANDROID_SUCCESS:String = "android_success";
		/**获取本地推送成功*/
		public static const LOCALNOTIFICATION_SUCCESS:String = "localnotification_success";
		/**获取服务器失败*/		
		public static const SERVER_FAILURE:String = "server_failure";
		public var loginObj:Object; 
		public function LoginEvent(type:String, bubbles:Boolean=false,obj:Object=null)
		{
			super(type, bubbles);
			this.loginObj = obj;
		}
		
		override public function clone():Event
		{
			return new LoginEvent(type, bubbles,loginObj);
		}
	}
}