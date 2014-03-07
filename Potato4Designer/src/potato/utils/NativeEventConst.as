package potato.utils
{
	public class NativeEventConst
	{
		public static const 	PopUpButtonEvents	:int	 = 	200	;	//	弹出框按钮按下
		public static const     MovieFinished:int            =  230 ;   //  视频播放完成 
		
		public static const 	DownloadStartEvents	:int	 = 	300	;	//	文件下载开始
		public static const 	DownloadErrorEvents	:int	 = 	301	;	//	文件下载错误
		public static const 	DownloadBytesEvents	:int	 = 	302	;	//	文件每次下载的字节数
		public static const 	DownloadFinishEvents:int	 = 	303	;	//	文件下载完成
		
		public static const 	UnZipStartEvents	:int	 = 	350	;	//	文件解压开始
		public static const 	UnZipErrorEvents	:int	 = 	351	;	//	文件解压错误
		public static const 	UnZipCurFileEvents	:int	 = 	352	;	//	本次解压文件
		public static const 	UnZipFinishEvents	:int	 = 	353	;	//	文件解压完成
		
		public static const 	Web91LoginSuccess	    :int	 = 	8000	;	//	普通账户登录成功
		public static const 	Web91TouristLoginSuccess:int	 = 	8001	;	//	游客账号登录成功
		public static const 	Web91GuestRegistSuccess	:int	 = 	8002	;	//	游客成功注册为普通账号
		public static const 	Web91GuestRegistCancel	:int	 = 	8003	;	//	用户取消游客注册为普通账号
		public static const 	Web91LoginCancel	    :int	 = 	8004	;	//	用户取消登录
		public static const 	Web91LoginError	        :int	 = 	8005	;	//	登录错误
		public static const 	Web91ComplatformUI	    :int	 = 	8006	;	//	平台退出消息
		public static const 	Web91SessionInvalid	    :int	 = 	8007	;	//	会话过期通知
		
		public static const 	Web91BuyUnLogin:int              = 8008	;	//	支付未登陆
		public static const 	Web91OrdersProcess:int           = 8009	;	//	支付订单已处理
		public static const 	Web91buyParameterError:int       = 8010	;	//	支付发生错误
		public static const 	Web91buyUserCancel:int           = 8011	;	//	用户取消支付
		public static const 	Web91buySuccess:int              = 8012	;	//	支付成功
		public static const 	Web91buyOrderSerialSubmitted:int = 8013	;	//	异步支付订单已经提交(在91豆余额不足时，用户选择充值或邀请朋友代充时产生该消息)
		
		public static const     OtherPlatformSuccessLogin:int     = 9000;//  登录成功
		public static const     OtherPlatformCancelLogin:int      = 9001;//  用户取消登录
		public static const     OtherPlatformLoginError:int       = 9002;//  登录错误
		public static const     OtherPlatformSuccessLogout:int    = 9003;//  登出成功
		public static const     OtherPlatformLogoutError:int      = 9004;//  登出错误
		public static const     OtherPlatformExitComplatformUI:int= 9005;//  退出平台
		public static const     OtherPlatformUnLogin:int          = 9006;//  用户未登陆
		
		public static const     OtherPlatformPaySuccess:int              = 9007;//  支付成功
		public static const     OtherPlatformPayOrderSerialSubmitted:int = 9008;//  支付订单已经提交
		public static const     OtherPlatformUserCancelPay:int           = 9009;//  用户取消支付
		public static const     OtherPlatformPayParameterError:int       = 9010;//  支付发生错误
		
		public static const     ANTIADDICTIONQUERY_ERROR:int            =  8014;//查询出错
		public static const     ANTIADDICTIONQUERY_UNREALNAMEREGIST:int =  8015; //未进行实名
		public static const     ANTIADDICTIONQUERY_NONAGE:int           =  8016;//未成年
		public static const     ANTIADDICTIONQUERY_OK:int               =  8017;//已成年
		public static const     REALNAMEREGIST_OK:int                   =  8018;//注册成功
		public static const     REALNAMEREGIST_FAILURE:int              =  8019;//注册失败
		public static const     REALNAMEREGIST_FINISH:int               =  8020;//注册结束,成功与失败未知
		
		public static const AppPushToken:int            =   211;    //App推送完成
		public static const AppPushToken_Error:int      =   212;    //App推送失败
		public static const	AppWebViewFinishLoad:int	=	215;	//AppWebView加载完成(重定向也会产生该消息)
		public static const	AppWebViewFailLoad:int	    =   216;	//AppWebView加载错误(重定向也会产生该消息)
		public static const	AppWebViewRedirect:int	    =	217;	//AppWebView的URL改变
		public static const	AppWebViewUserClose:int     =	218;	//AppWebView被用户关闭
		public static const AppGameCenter:int           =   220;    //GameCenter登录成功
		public static const AppGameCenterError:int      =   221;    //GameCenter登录失败
		
		public static const 	IapUserBanPay	:int	 = 		205;	//用户禁止应用内购买
		public static const 	IapProductInfo	:int	 = 		206;	//产品信息
		public static const 	IapUserCancel	:int	 = 		207;	//用户取消支付
		public static const 	IapBuyError	:int	     = 		208;	//支付错误
		public static const 	IapBuyFinished	:int	 = 		209;	//支付完成

	}
}