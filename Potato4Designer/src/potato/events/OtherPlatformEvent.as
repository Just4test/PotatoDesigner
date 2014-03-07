package potato.events
{
	import core.events.Event;
	
	public class OtherPlatformEvent extends Event
	{
		public static const OTHER_PLATFORM_UNLOGIN:String = "otherPlatformUnLogin";                                    //用户未登陆
		public static const OTHER_PLATFORM_SUCCESS_LOGIN:String = "otherPlatformSuccessLogin";                         //登录成功
		public static const OTHER_PLATFORM_CANCEL_LOGIN:String = "otherPlatformCancelLogin";                           //用户取消登录
		public static const OTHER_PLATFORM_LOGIN_ERROR:String = "otherPlatformLoginError";                             //登录错误
		public static const OTHER_PLATFORM_SUCCESS_LOGOUT:String = "otherPlatformSuccessLogout";                       //登出成功
		public static const OTHER_PLATFORM_LOGOUT_ERROR:String = "otherPlatformLogoutError";                           //登出错误
		public static const OTHER_PLATFORM_EXIT_COMPLATFORM_UI:String = "otherPlatformExitComplatformUI";              //退出平台界面
		public static const OTHER_PLATFORM_ERROR:String = "otherPlatformError";                                        //发生错误

		public static const OTHER_PLATFORM_PAY_SUCCESS:String = "otherPlatformPaySuccess";                             //支付成功
		public static const OTHER_PLATFORM_PAY_ORDER_SERIAL_SUBMITTED:String = "otherPlatformPayOrderSerialSubmitted"; //支付订单已经提交
		public static const OTHER_PLATFORM_USER_CANCEL_PAY:String = "otherPlatformUserCancelPay";                      //用户取消支付
		public static const OTHER_PLATFORM_PAY_PARAMETER_ERROR:String = "otherPlatformPayParameterError";              //支付发生错误

		public static const POPUP_BUTTON_EVENT:String = "popupButtonEvent";                                        //弹出框按钮按下
		public static const MOVIE_FINISHED:String     = "movieFinished";                                           //视频播放完成
		public static const APPWEB_VIEW_FINISH:String = "appwebViewFinish";
		public static const APPWEB_VIEW_FAIL :String  = "appwebViewFail";
		public static const APPWEB_REDIRECT:String    = "appwebViewRedirect";  
		public static const APPWEB_VIEW_USERCLOSE:String = "appwebViewUserclose";
		
		public static const APP_PUSH_TOKEN:String = "apppushtoken";
		public static const APP_PUSH_TOKEN_ERROR:String="apppushtokenerror";
		public static const APP_GAMECENTER:String="appgamecenter";
		public static const APP_GAMECENTER_ERROR:String="appgamecentererror";
		public static const IAP_USERBAN_PAY:String="iapuserbanpay";
		public static const IAP_PRODUCT_INFO:String="iapproductinfo";
		public static const IAP_USER_CANCEL:String="iapusercancel";
		public static const IAP_BUY_ERROR:String="iapbuyerror";
		public static const IAP_BUY_FINISHED:String="iapbuyfinished";
		
		public var Code:String;
		public function OtherPlatformEvent(type:String, bubbles:Boolean=false,Code:String = null)
		{
			super(type, bubbles);
			this.Code = Code;
		}
		override public function clone():Event
		{
			return new OtherPlatformEvent(type, bubbles, Code);
		}
	}
}