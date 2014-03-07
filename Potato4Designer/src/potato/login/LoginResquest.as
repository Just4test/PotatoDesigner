package potato.login
{
	import core.events.Event;
	import core.events.EventDispatcher;
	import core.events.HTTPStatusEvent;
	import core.events.IOErrorEvent;
	import core.events.TimerEvent;
	import core.net.URLRequest;
	import core.net.URLStream;
	import core.net.URLVariables;
	import core.system.System;
	import core.utils.Timer;
	
	import potato.events.LoginEvent;
	import potato.events.OtherPlatformEvent;
	import potato.logger.Logger;
	import potato.utils.SystemRelatedAPIUtil;
	import potato.utils.WebViewAPIUtil;
	

	public class LoginResquest extends EventDispatcher
	{
		private static var log:Logger = Logger.getLog("LoginResquest");
		private var loginInfoStream:URLStream;
		private var statusStream:URLStream;
		/**允许出错次数*/
		public static var ERROR_COUNT:int = 0;
		private var errorCount:int=1;
		private var outTime:Timer;
		private var req:URLRequest;
		private var v:String = System.getVersion();

		private var jsonStr:Object;
		public function LoginResquest()
		{
			outTime=new Timer(1000*30);
			outTime.addEventListener(TimerEvent.TIMER,onCheckOutTimer);
		}
		private function onCheckOutTimer(e:TimerEvent):void{
			this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false,"outTime"));
		}
		/**
		 *  获取服务器信息
		 * @param _type    类型
		 * @param fun      回调函数
		 * 
		 */		
 		public function getServer(_type:String):void{
			errorCount=1;
			outTime.start();
			req = new URLRequest(LoginData.address + "type="+ _type);
			req.method=URLRequest.POST;
			var data:URLVariables = new URLVariables();
			data.data = JSON.stringify(LoginData.obj);
			req.data=data;
			if(LoginData.IOS){
				log.debug("获取地址",LoginData.address + "type="+ _type + "&"+req.data);
			}else{
				log.debug("获取地址",LoginData.address + "type="+ _type);
			}
			statusStream=new URLStream();
			statusStream.addEventListener(Event.COMPLETE, getServerComplete);
			statusStream.addEventListener(IOErrorEvent.IO_ERROR, LoginError);
			statusStream.addEventListener(HTTPStatusEvent.HTTP_STATUS,getHttpStatus);
			statusStream.load(req);
			
			
		}
		private function getServerComplete(e:Event):void{
			outTime.stop();
			var info:String = statusStream.readUTFBytes(statusStream.bytesAvailable);
			log.debug("getServerComplete", info);
			jsonStr = JSON.parse(info);
			if(jsonStr.ErrorCode!="1"){
				LoginData.obj.errorcode = jsonStr.ErrorCode;
				SystemRelatedAPIUtil.getInstance().mobiFunPopUp("提示框",jsonStr.ErrorInfo,"确定");
				dispatchEvent(new LoginEvent(LoginEvent.SERVER_FAILURE));
				return;
			}
			log.debug("json",jsonStr.type);
			switch(jsonStr.type)
			{
				case LoginData.VERSIONCHECK://获取服务器版本信息
				{
					//v_new,v_basis,v_renewal,v_url.
					if(jsonStr.v_new == v || jsonStr.v_new == "" || jsonStr.v_new == null){
						dispatchEvent(new LoginEvent(LoginEvent.VERSIONCHECK_SUCCESS));
					}else{
						if(jsonStr.v_new){
							var versionLocalArr:Array = v.split(".");
							var versionNewArr:Array = jsonStr.v_new.split(".");
							var versionLocal:int =  versionLocalArr[0]+versionLocalArr[1]+versionLocalArr[2];
							var versionNew:int =  versionNewArr[0]+versionNewArr[1]+versionNewArr[2];
							if(versionLocal>versionNew){
								dispatchEvent(new LoginEvent(LoginEvent.VERSIONCHECK_SUCCESS));
							}else
							{
								upData();//更新包
							}
						}
					}
					break;
				}
				case LoginData.LOGINVERIFICATION://获取验证成功
				{
					if(jsonStr.userid){
						LoginData.obj.uid = jsonStr.userid;
					}
					if( jsonStr.refreshtoken){
						LoginData.obj.refreshtoken = jsonStr.refreshtoken;
					}
					
					if(jsonStr.callback){
						LoginData.obj.callbackcheckaddress = jsonStr.callback;
					}else{
						LoginData.obj.callbackcheckaddress = "";
					}
					if(jsonStr.accesstoken){
						LoginData.obj.accesstoken = jsonStr.accesstoken;
					}else{
						LoginData.obj.accesstoken ="";
					}
					log.debug("验证通过");
					dispatchEvent(new LoginEvent(LoginEvent.LOGINVERIFICATION_SUCCESS));
					break;
				}
				case LoginData.SERVERLIST://获取服务器列表
				{
					if(jsonStr.listpage){
						LoginData.listPage = jsonStr.listpage;
					}
					LoginData.notice = jsonStr.notice;
					getServerListData(jsonStr.server_info);
					break;
				}
				case LoginData.LOGINKEY://获取登录key
				{
//					抛出获取key成功消息
					LoginData.obj.keyobj = jsonStr;
					dispatchEvent(new LoginEvent(LoginEvent.LOGINKEY_SUCCESS));
					break;
				}
				case LoginData.APPSTOREPUSH://appstore推送
				{
//					var apppushobj:Object = JSON.parse(jsonStr.loginkey);
//					抛出appstore推送陈宫给消息
					log.debug("Returnapppush");
					break;
				}
				case LoginData.ANDROIDPUSH://android推送
				{
					log.debug("Returnandroidpush");
					break;
				}
				case LoginData.LOCALNOTIFICATION://ios android  本地通知
				{
					if(jsonStr.time && jsonStr.contents){
						System.nativeCall("MobiFunLocalNotification", [int(jsonStr.time), jsonStr.contents]);
					}
					log.debug("ReturnLocalNotification");
					break;
				}
				default:
				{
					log.debug("ServerTypeError",jsonStr.type);
					break;
				}
			}
			statusStream.removeEventListener(Event.COMPLETE, getServerComplete);
			statusStream.removeEventListener(IOErrorEvent.IO_ERROR, LoginError);
			statusStream.removeEventListener(HTTPStatusEvent.HTTP_STATUS,getHttpStatus);
			statusStream.close();
		}
		
		private function upData():void
		{
			if(jsonStr.v_basis){
				var versionLocalArr:Array = v.split(".");
				var versionBasisArr:Array = jsonStr.v_basis.split(".");
				var versionLocal:int =  versionLocalArr[0]+versionLocalArr[1]+versionLocalArr[2];
				var versionBasis:int =  versionBasisArr[0]+versionBasisArr[1]+versionBasisArr[2];
				log.debug("本地：",versionLocal,"最低版本：",versionBasis);
				if(jsonStr.v_renewal == "Y"){
					SystemRelatedAPIUtil.getInstance().mobiFunPopUp("提示框","版本更新","确定");
				}else{
					if(versionBasis <= versionLocal){
						SystemRelatedAPIUtil.getInstance().mobiFunPopUp("提示框","版本更新","确定","取消");
					}else{
						SystemRelatedAPIUtil.getInstance().mobiFunPopUp("提示框","版本更新","确定");
					}
				}
				SystemRelatedAPIUtil.getInstance().addEventListener(OtherPlatformEvent.POPUP_BUTTON_EVENT,onClickBtn)
			}
		}
		
		private function onClickBtn(e:OtherPlatformEvent):void
		{
			log.debug("code" , e.Code)
		    if(e.Code=="0"){
				WebViewAPIUtil.getInstance().mobiFunOpenUrl(jsonStr.v_url);
				System.exit(0);
			}else{
				dispatchEvent(new LoginEvent(LoginEvent.VERSIONCHECK_SUCCESS));
			}
		}
		private function getHttpStatus(e:HTTPStatusEvent):void{
			Logger.getLog("LoginResquest").debug("HTTPStatusEvent:"+e.status.toString());
		}
		private function LoginError(e:IOErrorEvent):void{
			SystemRelatedAPIUtil.getInstance().addEventListener(OtherPlatformEvent.POPUP_BUTTON_EVENT,onClickIoError)
			SystemRelatedAPIUtil.getInstance().mobiFunPopUp("提示框","网络错误","确定");
			Logger.getLog("LoginResquest").debug("Error");
		}
		
		private function onClickIoError(e:OtherPlatformEvent):void
		{
			dispatchEvent(new LoginEvent(LoginEvent.SERVER_FAILURE));
		}
		/**
		 * 整理服务器列表数据 
		 * @param status
		 * @param data
		 * @param account
		 * 
		 */		
		private function getServerListData(data:Array):void{
			LoginData.serverList = [];
			for each(var item:Object in data)
			{
				var list:ServerListItemData=new ServerListItemData(item);
				LoginData.serverList.push(list);
			}
			dispatchEvent(new LoginEvent(LoginEvent.SERVERLIST_SUCCESS))
		}
	}
}