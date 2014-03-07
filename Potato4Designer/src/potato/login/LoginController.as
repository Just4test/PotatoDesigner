package potato.login
{
	import core.events.EventDispatcher;
	import core.events.IOErrorEvent;
	import core.system.System;
	
	import ext.events.ExtendNativeEvent;
	
	import potato.events.LoginEvent;
	import potato.logger.Logger;
	import potato.login.token.LoginToken;
	import potato.login.token.LoginTokenEvent;
	import potato.utils.NativeEventConst;
	/**
	 * 在获取服务器列表时调度
	 * @eventType potato.events.LoginEvent。serverlist_success
	 */
	[Event(name="serverlist_success", type = "potato.events.LoginEvent")]
	
	/**
	 * 在 获取服务器登录key时调度
	 * @eventType potato.events.LoginEvent。login_success
	 */
	[Event(name="loginkey_success", type = "potato.events.LoginEvent")]
	
	/**
	 * 在获取服务器消息 导致错误的时调度
	 * @eventType potato.events.LoginEvent。server_failure
	 */
	[Event(name="server_failure", type = "potato.events.LoginEvent")]
	
	/**
	 * 在登录第三方平台成功时调度
	 * @eventType potato.events.LoginEvent。login_success
	 */
	[Event(name="login_success", type = "potato.events.LoginEvent")]
	/**
	 * 在登录第三方平台错误时调度
	 * @eventType potato.events.LoginEvent。login_out_success
	 */
	[Event(name="login_error", type = "potato.events.LoginEvent")]
	/**
	 * 在登录第三方平台页面退出调度
	 * @eventType potato.events.LoginEvent。OUT_PEV
	 */
	[Event(name="out_pev", type = "potato.events.LoginEvent")]
	/**
	 *          必须要赋值的数据
	 *          LoginData.obj.rolename
	 *          LoginData.obj.roleLevel
	 * 	  		LoginData.obj.server_id
	 *          LoginData.obj.servername
	 */	
	public class LoginController extends EventDispatcher implements ILogin
	{
		private var edp:EventDispatcher;
		/**
		 * 1:appstore平台 2：其他平台登录 
		 */		
		private var loginType:int;
		private var loginRequest:LoginResquest;
		private var token:LoginToken;
		public function LoginController(type:int=2)
		{
			this.loginType = type;
			if(loginType==1){
				token=new LoginToken();
				token.addEventListener(LoginTokenEvent.GET_TOKEN,getTokenComplete);
				token.addEventListener(LoginTokenEvent.GET_TOKEN_ERROR,getTokenError);
				token.addEventListener(LoginTokenEvent.AppWebViewUserClose,onUserClose);
			}
			loginRequest = new LoginResquest();
			loginRequest.addEventListener(LoginEvent.VERSIONCHECK_SUCCESS,onVersioncheckSuccess)
			loginRequest.addEventListener(LoginEvent.LOGINVERIFICATION_SUCCESS,onLoginVerificationSuccess);
			loginRequest.addEventListener(LoginEvent.SERVERLIST_SUCCESS,onServerSuccess);
			loginRequest.addEventListener(LoginEvent.LOGINKEY_SUCCESS,onLoginKey_Success);
			loginRequest.addEventListener(LoginEvent.SERVER_FAILURE,onServer_Failure);
			loginRequest.addEventListener(IOErrorEvent.IO_ERROR, getLoginInfoError);
			edp = new EventDispatcher();
			edp.addEventListener(ExtendNativeEvent.STATE, loginHandler);
		}
		
		/**
		 * 登录平台开始 
		 * appstore不用调
		 * 使用 login方法 
		 * 必须监听的方法
		 * 登录成功
		 * 	addEventListener(LoginEvent.LOGIN_SUCCESS, loginHandler);
		 * 登录错误
	     *  addEventListener(LoginEvent.LOGIN_ERROR, loginAgain);
		 * 	此监听  接收对象属性介绍
		 *    e.loginObj.id =   9001     用户取消登录
		 *    e.loginObj.id =   9002     登录错误
		 *    e.loginObj.id =   9003     登录成功
		 *    e.loginObj.id =   9004    登出错误
		 *    e.loginObj.id =   9006    用户未登录
		 * 平台页面退出消息
		 * 	addEventListener(LoginEvent.OUT_PEV, loginOutPev);
		 */		
		public function login():void
		{
			System.nativeCall("OtherPlatformLogin", [edp,""]);
		}
		/**
		 * 登出平台 
		 * 
		 */		
		public function logout():void
		{
			System.nativeCall("OtherPlatformLogout", [edp,""]);
			LoginData.obj.token = "";
			LoginData.obj.uid = "";
			LoginData.obj.nikename = "";
		}
		private function loginHandler(e:ExtendNativeEvent):void
		{
			Logger.getLog("LoginController").debug("loginHandler", e.id);
			if (e.id == NativeEventConst.OtherPlatformSuccessLogin)
			{ //第三方平台登录成功 
				var token:String = System.nativeCall("OtherPlatformSessionID", [edp,""]);
				var uid:String = System.nativeCall("OtherPlatformGetUID", [edp,""]);
				var nikename:String = System.nativeCall("OtherPlatformGetUserName", [edp,""]);
				LoginData.obj.token = token;
				LoginData.obj.uid = uid;
				LoginData.obj.nikename = nikename;
				Logger.getLog("LoginController").debug("token:"+token,"uid:"+uid,"nikename:"+nikename);
				dispatchEvent(new LoginEvent(LoginEvent.LOGIN_SUCCESS));
			}
			else if (e.id == NativeEventConst.OtherPlatformCancelLogin)
			{//用户取消登录
				dispatchEvent(new LoginEvent(LoginEvent.LOGIN_ERROR,false,{id:e.id}));
			}
			else if (e.id == NativeEventConst.OtherPlatformLoginError)
			{//登录错误
				dispatchEvent(new LoginEvent(LoginEvent.LOGIN_ERROR,false,{id:e.id}));
			}
			else if (e.id == NativeEventConst.OtherPlatformSuccessLogout)
			{//登出成功
				dispatchEvent(new LoginEvent(LoginEvent.LOGIN_OUT_SUCCESS,false,{id:e.id}));
			}
			else if (e.id == NativeEventConst.OtherPlatformLogoutError)
			{//登出错误
				dispatchEvent(new LoginEvent(LoginEvent.LOGIN_OUT_ERROR,false,{id:e.id}));
			}
			else if(e.id == NativeEventConst.OtherPlatformExitComplatformUI)
			{//推出平台
				dispatchEvent(new LoginEvent(LoginEvent.OUT_PEV));
			}
			else if(e.id == NativeEventConst.AppPushToken)
			{//获取到app推送token成功
				LoginData.obj.apppushtoken = e.msg;
				dispatchEvent(new LoginEvent(LoginEvent.APPPUSHTOKEN));
			}
			else if(e.id == NativeEventConst.AppPushToken_Error)
			{//获取到app推送token失败
				dispatchEvent(new LoginEvent(LoginEvent.APPPUSHTOKEN_ERROR));
			}
			else
			{
				Logger.getLog("LoginController").debug("Unknow ExtendNativeEvent: ", e.id, e.msg);
				dispatchEvent(new LoginEvent(LoginEvent.LOGIN_ERROR));
			}
		}
		/**
		 * 获取token完成 
		 * @param e
		 * 
		 */		
		private function getTokenComplete(e:LoginTokenEvent):void{
			dispatchEvent(new LoginEvent(LoginEvent.TOKEN));
			token.removeEventListener(LoginTokenEvent.GET_TOKEN,getTokenComplete);
			token.removeEventListener(LoginTokenEvent.GET_TOKEN_ERROR,getTokenError);
		}
		/**
		 * 获取token失败
		 * @param e
		 * 
		 */		
		private function getTokenError(e:LoginTokenEvent):void{
			dispatchEvent(new LoginEvent(LoginEvent.TOKEN_ERROR));
		}
		/**
		 * 获取新浪或gamecenter的登录信息
		 * 新浪登录
		 * 新浪登录要先调一下这个方法setSinaClient()
		 * getLoginToken(LoginData.LOGINSING)；
		 * gamecenter登录
		 * getLoginToken(LoginData.LOGINGAMECENTER)；
		 * LoginData。obj.token
		 */		
		public function getLoginToken(type:String):void{
			if(type == LoginData.LOGINSING){
				token.getSinaToken(_client_id,_redirect_url,_client_secret);
			}else{
				token.getGameCenter();
			}
		}
		private var _client_id:String;
		private var _redirect_url:String;
		private var _client_secret:String;
		/**
		 * @param id        client_id:申请应用时分配的AppKey
		 * @param url       redirect_uri:授权回调地址，站外应用需与设置的回调地址一致，站内应用需填写canvas page的地址
		 * @param secret    client_secret:申请应用时获得的加密key
		 */	    
		public function setSinaClient(id:String,url:String,secret:String):void
		{
			_client_id = id;
			_redirect_url = url;
			_client_secret = secret;
		}
		private function onUserClose(e:LoginTokenEvent):void
		{
			dispatchEvent(new LoginEvent(LoginEvent.APPWEB_CLOSE));
			token.removeEventListener(LoginTokenEvent.AppWebViewUserClose,onUserClose);
		}
		/**
		 * 关闭获取token的网页 
		 * 
		 */		
		public	function closeTokenWeb():void{
			token.closeWeb();
		}
		
	    public function getVersioncheck():void{
			loginRequest.getServer(LoginData.VERSIONCHECK);
		}
		
		/**
		 * 获取登录验证信息 
		 * 
		 */		
		public function getServerVerificationNew():void{
			loginRequest.getServer(LoginData.LOGINVERIFICATION);
		}
		/**
		 * 游戏获取服务器信息  必须先设置    LoginData.address地址
		 * @param type   类型         服务器列表
		 * 设置分页必须传的参数
		 * LoginData.obj.page      页码默认为0
		 * LoginData.obj.pagenum   一页多少个数
		 * 弱国 这两个参数不传 就会获得全部服务器列表
		 * 
		 *   必须监听的三个方法
		 *  addEventListener(LoginEvent.SERVERLIST_SUCCESS,onServerSuccess);
		 * LoginData.serverList   服务器列表
		 * LoginData.notice       公告            
		 * 
		 * 如果page，pagenum 赋值
		 * LoginData.listPage 就会有数据
		 * 
		 * addEventListener(LoginEvent.SERVER_FAILURE,onFailure);
		 * 返回服务器错误吗
		 * ErrorCode'=>0,'ErrorInfo'=>'请求失败'),
		 * ErrorCode'=>1,'ErrorInfo'=>'请求成功'),				
		 * ErrorCode'=>2,'ErrorInfo'=>'参数不全'),		
		 * ErrorCode'=>3,'ErrorInfo'=>'服务器列表请求失败'),			
		 * ErrorCode'=>4,'ErrorInfo'=>'服务器列表数据为空'),
		 * ErrorCode'=>5,'ErrorInfo'=>'游戏公告内容为空'),								
		 * ErrorCode'=>6,'ErrorInfo'=>'登录key请求失败'),								
		 * ErrorCode'=>7,'ErrorInfo'=>'Token 没有过期'),								
		 * ErrorCode'=>8,'ErrorInfo'=>'订单不存在').
		 */		
		public function getServerList():void{
			loginRequest.getServer(LoginData.SERVERLIST);
		}
		/**获取登录key 
		 * addEventListener(LoginEvent.LOGINKEY_SUCCESS,onLoginkeySuccess);
		 * LoginData.obj.keyobj     获得到的数据
		 * addEventListener(LoginEvent.SERVER_FAILURE,onFailure);
		 * 返回服务器错误吗
		 * ErrorCode'=>0,'ErrorInfo'=>'请求失败'),
		 * ErrorCode'=>1,'ErrorInfo'=>'请求成功'),				
		 * ErrorCode'=>2,'ErrorInfo'=>'参数不全'),		
		 * ErrorCode'=>3,'ErrorInfo'=>'服务器列表请求失败'),			
		 * ErrorCode'=>4,'ErrorInfo'=>'服务器列表数据为空'),
		 * ErrorCode'=>5,'ErrorInfo'=>'游戏公告内容为空'),								
		 * ErrorCode'=>6,'ErrorInfo'=>'登录key请求失败'),								
		 * ErrorCode'=>7,'ErrorInfo'=>'Token 没有过期'),								
		 * ErrorCode'=>8,'ErrorInfo'=>'订单不存在')
		 */		
	    public function getServerLoginKey():void{
			loginRequest.getServer(LoginData.LOGINKEY);
		}
		/**
		 *  设置 苹果 安卓 推送
		 * 要想设置 先获取苹果安卓的参数
		 * LoginData.APPSTOREPUSH;      苹果设备推送
		 * LoginData.ANDROIDPUSH;       安卓设备推送
		 * LoginData.LOCALNOTIFICATION; 本地推送
		 * @param type
		 * 
		 */		
		public function setServerPush(type:String):void{
			loginRequest.getServer(type);
		}
		/**
		 *  获取服务期本地推送 
		 * @return 
		 * 
		 */		
		public function getLocalnotification():void{
			loginRequest.getServer(LoginData.LOCALNOTIFICATION);
		}
		/**
		 ** 获取苹果推送参数
		 * appStorePushToken();
		 * addEventListener(LoginEvent.APPPUSHTOKEN,onOK);
		 * addEventListener(LoginEvent.APPPUSHTOKEN_ERROR,onNO);
		 * appstore推送参数:
		 * LoginData.obj.apppushtoken
		 */		
		public function appStorePushToken():void{
			System.nativeCall("MobiFunNotifications", [edp]);
		}
		/**
		 ** 获取安卓推送参数
		 * androidPushToken();
		 * addEventListener(LoginEvent.APPPUSHTOKEN,onOK);
		 * addEventListener(LoginEvent.APPPUSHTOKEN_ERROR,onNO);
		 * android推送参数:
		 * LoginData.obj.androidtoken
		 */		
		public function androidPushToken():void{
			
		}
		private function onVersioncheckSuccess(e:LoginEvent):void
		{
			dispatchEvent(new LoginEvent(LoginEvent.VERSIONCHECK_SUCCESS));
		}
		private function onLoginVerificationSuccess(e:LoginEvent):void
		{
			dispatchEvent(new LoginEvent(LoginEvent.LOGINVERIFICATION_SUCCESS));
		}
		private function onLoginKey_Success(e:LoginEvent):void
		{
			dispatchEvent(new LoginEvent(LoginEvent.LOGINKEY_SUCCESS));
		}
		private function onServer_Failure(e:LoginEvent):void
		{
			dispatchEvent(new LoginEvent(LoginEvent.SERVER_FAILURE));
		}
		private function onServerSuccess(e:LoginEvent):void
		{
			dispatchEvent(new LoginEvent(LoginEvent.SERVERLIST_SUCCESS));
		}
		private function getLoginInfoError(e:IOErrorEvent):void{
			this.dispatchEvent(e);
		}
	}
}