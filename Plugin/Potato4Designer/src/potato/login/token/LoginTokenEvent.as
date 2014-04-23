package potato.login.token
{
	import core.events.Event;

	public class LoginTokenEvent extends Event
	{
		/**用户获取token成功 */		
		public static const GET_TOKEN:String = "getToken";
		/**用户获取token失败*/
		public static const GET_TOKEN_ERROR:String = "getTokenError";
		/**AppWebView加载完成(重定向也会产生该消息)*/
		public static const AppWebViewFinishLoad :String = "appweb_view_finishload";
		/**AppWebView加载错误(重定向也会产生该消息)*/
		public static const AppWebViewFailLoad:String= "appweb_view_finishload";
		/**AppWebView的URL改变*/
		public static const AppWebViewRedirect:String= "appweb_view_redirect";
		/**AppWebView被用户关闭*/
		public static const AppWebViewUserClose:String= "appweb_view_userclose"; 
		/**360 查询出错*/		
		public static const ANTI_ADDICTION_QUERY_ERROR:String = "anti_addiction_query_error";
		/**360 未进行实名注册*/	
		public static const ANTI_ADDICTION_QUERY_UNREALNAMEREGIST:String = "anti_addiction_query_unrealnameregist";
		/**360 未成年*/	
		public static const ANTI_ADDICTION_QUERY_NONAGE :String = "anti_addiction_query_nonage";
		/**360已成年*/	
		public static const ANTI_ADDICTION_QUERY_OK :String = "anti_addiction_query_ok";
		/**360 注册成功*/	
		public static const REALNAMEREGIST_OK :String = "realnameregist_ok";
		/**360注册失败*/	
		public static const REALNAMEREGIST_FAILURE :String = "realnameregist_failure";
		/**360注册结束*/	
		public static const REALNAMEREGIST_FINISH :String = "realnameregist_finish";
		public var tokenObj:Object;
		
		public function LoginTokenEvent(type:String, bubbles:Boolean=false, obj:Object=null)
		{
			super(type, bubbles);
			this.tokenObj = obj;
		}
		
		override public function clone():Event {
			return new LoginTokenEvent(type, bubbles, tokenObj);
		}
	}
}