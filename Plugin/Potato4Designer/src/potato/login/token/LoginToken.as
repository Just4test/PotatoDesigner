package potato.login.token
{
	import core.events.Event;
	import core.events.EventDispatcher;
	import core.events.IOErrorEvent;
	import core.net.URLRequest;
	import core.net.URLStream;
	import core.system.System;
	
	import ext.events.ExtendNativeEvent;
	
	import potato.logger.Logger;
	import potato.login.LoginData;
	import potato.utils.NativeEventConst;


	/**
	 * 获取token值 
	 * @author Administrator
	 * 
	 */
	public class LoginToken extends EventDispatcher
	{
		private var resquestUrl:String;
		private var edp:EventDispatcher;
		private var status:String;
		public function LoginToken()
		{
			init();
		}
		public function init():void{
			edp = new EventDispatcher();
			edp.addEventListener(ExtendNativeEvent.STATE, evtHandler);
		}
		/**
		 * 获取新浪token 
		 * client_id:申请应用时分配的AppKey
		 * redirect_uri:授权回调地址，站外应用需与设置的回调地址一致，站内应用需填写canvas page的地址
		 * 新浪获取token先获取code，再用code去获取token
		 */		
		private var client_id:String;
		private var redirect_uri:String;
		private var client_secret:String;
		public function getSinaToken(_client_id:String,_redirect_uri:String,_client_secret:String):void{
			status="sina";
			client_id=_client_id;
			redirect_uri=_redirect_uri;
			client_secret=_client_secret;
			resquestUrl="https://open.weibo.cn/2/oauth2/authorize"+
						"?client_id="+client_id+											
						"&redirect_uri="+redirect_uri +								
						"&response_type=code"+
						"&display=mobile";
			Logger.getLog("LoginToken").debug("sina",resquestUrl);
			System.nativeCall("MobiFunAppWeb",[resquestUrl,edp]);
		}
		public function getGameCenter():void{
			System.nativeCall("MobiFunGameCenter",[edp]);
		}
		
		/**
		 * 关闭 sina 网页 
		 */		
		public function closeWeb():void{
			System.nativeCall("MobiFunAppWebClose",[]);
			switch(status){
				case "sina":
					System.nativeCall("MobiFunAppWebRemoveCookies",["https://open.weibo.cn/2/oauth2/authorize"]);
					break;
			}
		}
		/**
		 * 获取token事件
		 * @param e
		 */		
		private var codeStr:String;
		private function evtHandler(e:ExtendNativeEvent):void {
			var arr:Array=[];
			Logger.getLog("获取token事件").debug(e.id);
			switch (e.id) {
				case NativeEventConst.ANTIADDICTIONQUERY_ERROR:
					//查询出错
					dispatchEvent(new LoginTokenEvent(LoginTokenEvent.ANTI_ADDICTION_QUERY_ERROR));
					break;
				case NativeEventConst.ANTIADDICTIONQUERY_UNREALNAMEREGIST:
					//查询出错
					dispatchEvent(new LoginTokenEvent(LoginTokenEvent.ANTI_ADDICTION_QUERY_UNREALNAMEREGIST));
					break;
				case NativeEventConst.ANTIADDICTIONQUERY_NONAGE:
					//360 未成年
					dispatchEvent(new LoginTokenEvent(LoginTokenEvent.ANTI_ADDICTION_QUERY_NONAGE));
					break;
				case NativeEventConst.ANTIADDICTIONQUERY_OK:
					//360 已成年
					dispatchEvent(new LoginTokenEvent(LoginTokenEvent.ANTI_ADDICTION_QUERY_OK));
					break;
				case NativeEventConst.REALNAMEREGIST_OK:
					//360 注册成功
					dispatchEvent(new LoginTokenEvent(LoginTokenEvent.REALNAMEREGIST_OK));
					break;
				case NativeEventConst.REALNAMEREGIST_FAILURE:
					//360 注册失败
					dispatchEvent(new LoginTokenEvent(LoginTokenEvent.REALNAMEREGIST_FAILURE));
					break;
				case NativeEventConst.REALNAMEREGIST_FINISH:
					//360 注册结束
					dispatchEvent(new LoginTokenEvent(LoginTokenEvent.REALNAMEREGIST_FINISH));
					break;
				case NativeEventConst.AppWebViewFinishLoad:
					dispatchEvent(new LoginTokenEvent(LoginTokenEvent.AppWebViewFinishLoad));
					break;
				case NativeEventConst.AppWebViewFailLoad://加载错误
					dispatchEvent(new LoginTokenEvent(LoginTokenEvent.AppWebViewFailLoad));
					break;
				case NativeEventConst.AppGameCenter://GameCenter登录成功
					LoginData.obj.uid = e.msg;
					LoginData.obj.logintype = LoginData.LOGINGAMECENTER;
					Logger.getLog("LoginToken").debug("getgamecenter:"+ e.msg);
					dispatchEvent(new LoginTokenEvent(LoginTokenEvent.GET_TOKEN));
					break;
				case NativeEventConst.AppGameCenterError://GameCenter登录失败
					dispatchEvent(new LoginTokenEvent(LoginTokenEvent.GET_TOKEN_ERROR));
					break;
				case NativeEventConst.AppWebViewRedirect://获取token
					if(status == "sina"){
						if(e.msg.indexOf(redirect_uri)!=-1){
							//http://www.example.com/response&code=CODE
							arr=e.msg.split("code=")
							codeStr=arr[1];
							Logger.getLog("LoginToken").debug("sinaCode:"+codeStr);
							if(codeStr=="" || codeStr==null){
								return;
							}
							resultAsk(codeStr);
						}
					}
					break;
				case NativeEventConst.AppWebViewUserClose://用户关闭
					dispatchEvent(new LoginTokenEvent(LoginTokenEvent.AppWebViewUserClose));
					break;
				default:
					Logger.getLog("LoginToken").warn("Unkown_ExtendNativeEvent.", e.toString());
			}
		}
		private var tokenLoader:URLStream;
		private function resultAsk(str:String):void{
			var url:String;
			switch(status){
				case "sina":
					url="https://open.weibo.cn/2/oauth2/access_token" +
						"?code="+str+
						"&redirect_uri="+redirect_uri+
						"&client_secret=" +client_secret+		
						"&grant_type=authorization_code"+
						"&client_id="+client_id;								
					break;
			}
			Logger.getLog("LoginToken").debug("url:"+url);
			var req:URLRequest=new URLRequest(url);
			req.method=URLRequest.POST;
			tokenLoader = new URLStream();
			tokenLoader.addEventListener(Event.COMPLETE, complete);
			tokenLoader.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			tokenLoader.load(req);
		}
		private function complete(e:Event):void {
			var html:String = tokenLoader.readUTFBytes(tokenLoader.bytesAvailable);
			//{"access_token":"2.00BDtxqCKDgqUE3e7dc37085R3gbfD","remind_in":"626389","expires_in":626389,"uid":"2614908095"}
			Logger.getLog("LoginToken").debug("token:"+html);
			var jsonStr:Object = JSON.parse(html);
			LoginData.obj.uid = jsonStr.access_token;
			LoginData.obj.logintype = LoginData.LOGINSING;
			tokenLoader.removeEventListener(Event.COMPLETE, complete);
			tokenLoader = null;
			dispatchEvent(new LoginTokenEvent(LoginTokenEvent.GET_TOKEN));
		}
		private function ioError(e:IOErrorEvent):void {
			var loader:URLStream = e.target as URLStream;
			
			loader.removeEventListener(Event.COMPLETE, complete);
			loader = null;
		}
	}
}