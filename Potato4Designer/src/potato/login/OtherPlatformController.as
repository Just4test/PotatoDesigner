package potato.login
{
	import core.events.EventDispatcher;
	import core.system.System;
	
	import ext.events.ExtendNativeEvent;
	
	import potato.events.OtherPlatformEvent;
	import potato.logger.Logger;
	import potato.utils.NativeEventConst;

	public class OtherPlatformController extends EventDispatcher
	{
		public  var edp:EventDispatcher = new EventDispatcher();
		private static var log:Logger = Logger.getLog("LoginOtherPlatformController");
		private static var instance:OtherPlatformController;
		public function OtherPlatformController(content:ConSingle)
		{
			edp.addEventListener(ExtendNativeEvent.STATE,handler)
		}
		public static function getInstance():OtherPlatformController{
			if(instance == null)
			{
				instance = new OtherPlatformController(new ConSingle);
			}
			return instance;
		}
		/**
		 *   发送游戏服务器id及其服务器名称到第三方平台(部分平台有自己统计)
		 * @param sreverId   服务器id
		 * @param sreverName 服务器名称
		 * @param des        自定义参数(可以没有该参数)
		 */		
		public function otherPlatformPostSrever(sreverId:String,sreverName:String,des:String = null):void{
			System.nativeCall("OtherPlatformPostSrever", [edp,sreverId,sreverName,des]);
		}
		/**
		 *  发送创建角色到第三方平台(部分平台有自己统计)
		 * @param sreverId   服务器id
		 * @param userId     角色id
		 * @param userName   角色名称
		 * @param des        自定义参数(可以没有该参数)
		 * 
		 */		
		public function otherPlatformPostCreateRole(sreverId:String,userId:String,userName:String,des:String = null):void{
			System.nativeCall("OtherPlatformPostCreateRole", [edp,sreverId,userId,userName,des]);
		}
		/**
		 * 发送登录角色到第三方平台(部分平台有自己统计)
		 * @param sreverId  服务器id
		 * @param userId    角色id
		 * @param userName  角色名称
		 * @param des       自定义参数(可以没有该参数)
		 * 
		 */		
		public function otherPlatformPostLoginRole(sreverId:String,userId:String,userName:String,des:String = null):void{
			System.nativeCall("OtherPlatformPostLoginRole", [edp,sreverId,userId,userName,des]);
		}
		/**
		 * 发送进入应用到第三方平台(部分平台有自己统计)
		 * 
		 */		
		public function otherPlatformPostEnterApp():void{
			System.nativeCall("OtherPlatformPostEnterApp", [edp]);
		}
		/**
		 *  第三方平台用户反馈 
		 * 
		 */		
		public function otherPlatformFeedBack():void{
			System.nativeCall("OtherPlatformFeedBack", [edp]);
		}
		/**
		 * 第三方平台 论坛
		 * 
		 */		
		public function otherPlatformBBS():void{
			System.nativeCall("OtherPlatformBBS", [edp]);
		}
		/**
		 *获取本次登录后的验证凭证      SID
		 * @return 
		 * 
		 */		
		public function otherPlatformSessionID():String{
			var str:String = System.nativeCall("OtherPlatformSessionID",[edp])
		    return str;
		}
		/**
		 * 获取第三方平台用户id    UID
		 * @return 
		 * 
		 */		
		public function otherPlatformGetUID():String{
			var str:String = System.nativeCall("OtherPlatformGetUID",[edp]);
			return str;
		}
		/**
		 *  获取第三方平台昵称
		 * @param custom  
		 * @return 
		 * 
		 */
		public function otherPlatformGetUserName():String{
			var str:String = System.nativeCall("OtherPlatformGetUserName",[edp]);
			return str;
		}
		/**
		 * 第三方平台个人中心  
		 * @param custom   自定义参数(可以没有该参数)
		 * 
		 */		
		public function otherPlatformPersonalCenter(custom:String=null):void{
			System.nativeCall("OtherPlatformPersonalCenter",[edp,custom]);
		}
		/**
		 * 第三方平台登出接口
		 * @param custom   自定义参数(可以没有该参数)
		 * 
		 */		
		public function otherPlatformLogout(custom:String = null):void{
			System.nativeCall("OtherPlatformLogout",[edp,custom]);
		}
		/**
		 * 第三方平台登录接口
		 * @param custom  自定义参数(可以没有该参数)
		 * 
		 */		
		public function otherPlatformLogin(custom:String = null):void{
			System.nativeCall("OtherPlatformLogin",[edp,custom]);
		}
		/**
		 *  充值 接口
		 * @param serverid     服务器id
		 * @param playerid     角色id
		 * @param ordercode    订单号
		 * @param name         商品名称
		 * @param price        单价
		 * @param num          购买个数
		 * @param des          自定义参数
		 * 
		 */		
		public function otherPlatformPay(serverid:int,playerid:String,ordercode:String,name:String,price:Number,num:int,des:String):void{
			System.nativeCall("OtherPlatformPay",[edp,serverid,playerid,ordercode,name,price,num,des]);
		}
		/**
		 * 自定义方法
		 * @param name  方法名
		 * @param des   自定义参数(可以没有该参数)
		 * 
		 */		
		public function otherPlatformNativeCall(name:String,des:String = null):void{
			System.nativeCall("OtherPlatformNativeCall",[name,edp,des]);
		}
		
		private function handler(e:ExtendNativeEvent):void
		{
			switch(e.id)
			{
				case NativeEventConst.OtherPlatformUnLogin:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.OTHER_PLATFORM_UNLOGIN));
					break;
				}
				case NativeEventConst.OtherPlatformSuccessLogin:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.OTHER_PLATFORM_SUCCESS_LOGIN));
					break;
				}
				case NativeEventConst.OtherPlatformCancelLogin:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.OTHER_PLATFORM_CANCEL_LOGIN));
					break;
				}
				case NativeEventConst.OtherPlatformLoginError:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.OTHER_PLATFORM_LOGIN_ERROR));
					break;
				}
				case NativeEventConst.OtherPlatformSuccessLogout:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.OTHER_PLATFORM_SUCCESS_LOGOUT));
					break;
				}
				case NativeEventConst.OtherPlatformLogoutError:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.OTHER_PLATFORM_LOGOUT_ERROR));
					break;
				}
				case NativeEventConst.OtherPlatformExitComplatformUI:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.OTHER_PLATFORM_EXIT_COMPLATFORM_UI));
					break;
				}
				//充值
				case NativeEventConst.OtherPlatformPaySuccess:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.OTHER_PLATFORM_PAY_SUCCESS,false,e.msg));
					break;
				}
				case NativeEventConst.OtherPlatformPayOrderSerialSubmitted:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.OTHER_PLATFORM_PAY_ORDER_SERIAL_SUBMITTED,false,e.msg));
					break;
				}
				case NativeEventConst.OtherPlatformUserCancelPay:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.OTHER_PLATFORM_USER_CANCEL_PAY,false,e.msg));
					break;
				}
				case NativeEventConst.OtherPlatformPayParameterError:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.OTHER_PLATFORM_PAY_PARAMETER_ERROR,false,e.msg));
					break;
				}
				default:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.OTHER_PLATFORM_ERROR));
					break;
				}
			}
		}
	}
}
class ConSingle
 { 
 }