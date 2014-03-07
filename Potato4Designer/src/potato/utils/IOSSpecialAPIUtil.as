package potato.utils
{
	import core.events.EventDispatcher;
	import core.system.System;
	
	import ext.events.ExtendNativeEvent;
	
	import potato.events.OtherPlatformEvent;
	import potato.logger.Logger;

	public class IOSSpecialAPIUtil extends EventDispatcher
	{
		private static var log:Logger = Logger.getLog("IOSSpecialAPIUtil");
		private static var instance:IOSSpecialAPIUtil;
		private var edp:EventDispatcher;
		public function IOSSpecialAPIUtil(content:ConSingle)
		{
			edp = new EventDispatcher();
			edp.addEventListener(ExtendNativeEvent.STATE, handler);
		}
		public static function getInstance():IOSSpecialAPIUtil{
			if(instance == null)
			{
				instance = new IOSSpecialAPIUtil(new ConSingle);
			}
			return instance;
		}
		/**
		 * 注册推送通知功能
		 * 
		 */		
		public function mobiFunNotifications():void{
			System.nativeCall("MobiFunNotifications", [edp]);
		}
		/**
		 *GameCenter登录 
		 * 
		 */		
		public function mobiFunGameCenter():void{
			System.nativeCall("MobiFunGameCenter", [edp]);
		}
		/**
		 * 获得应用内支付产品信息
		 * @param id    产品id(在苹果开发者账户注册的id)
		 * 
		 */		
		public function mobiFunIapGetProductInfo(id:String):void{
			System.nativeCall("MobiFunIapGetProductInfo", [edp,id]);
		}
		/**
		 * 购买产品
		 * @param id       产品id(在苹果开发者账户注册的id)
		 * @param orders   订单号
		 */		
		public function mobiFunIapBuyProduct(id:String, orders:String):void{
			System.nativeCall("MobiFunIapBuyProduct", [edp,id,orders]);
		}
		
		private function handler(e:ExtendNativeEvent):void
		{
			Logger.getLog("IOSSpecialAPIUtil").debug("handler", e.id);
			switch(e.id)
			{
				case NativeEventConst.AppPushToken:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.APP_PUSH_TOKEN,false,e.msg));
					break;
				}
				case NativeEventConst.AppPushToken_Error:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.APP_PUSH_TOKEN_ERROR,false,e.msg));

					break;
				}
				case NativeEventConst.AppGameCenter:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.APP_GAMECENTER,false,e.msg));
					break;
				}
				case NativeEventConst.AppGameCenterError:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.APP_GAMECENTER_ERROR,false,e.msg));
					break;
				}
				case NativeEventConst.IapUserBanPay:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.IAP_USERBAN_PAY,false,e.msg));
					break;
				}
				case NativeEventConst.IapProductInfo:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.IAP_PRODUCT_INFO,false,e.msg));
					break;
				}
				case NativeEventConst.IapUserCancel:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.IAP_USER_CANCEL,false,e.msg));
					break;
				}
				case NativeEventConst.IapBuyError:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.IAP_BUY_ERROR,false,e.msg));
					break;
				}
				case NativeEventConst.IapBuyFinished:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.IAP_BUY_FINISHED,false,e.msg));
					break;
				}
				default:
				{
					Logger.getLog("IOSSpecialAPIUtil").debug("handlerError");
					break;
				}
			}
		}
	}
}
class ConSingle
{ 
}