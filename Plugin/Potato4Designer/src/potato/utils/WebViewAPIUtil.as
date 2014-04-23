package potato.utils
{
	import core.events.EventDispatcher;
	import core.system.System;
	
	import ext.events.ExtendNativeEvent;
	
	import potato.events.OtherPlatformEvent;
	import potato.logger.Logger;

	public class WebViewAPIUtil extends EventDispatcher
	{
		private static var log:Logger = Logger.getLog("WebViewAPIUtil");
		private static var instance:WebViewAPIUtil;
		private var edp:EventDispatcher;

		/**
		 * WEB页面
		 * 
		 */		
		public function WebViewAPIUtil(content:ConSingle)
		{
			edp = new EventDispatcher();
			edp.addEventListener(ExtendNativeEvent.STATE, handler);
		}
		public static function getInstance():WebViewAPIUtil{
			if(instance == null)
			{
				instance = new WebViewAPIUtil(new ConSingle);
			}
			return instance;
		}
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function mobiFunAppWeb(url:String):void{
			System.nativeCall("MobiFunAppWeb", [url,edp]);
		}
		/**
		 * 关闭WebView
		 * 
		 */		
		public function mobiFunAppWebClose():void{
			System.nativeCall("MobiFunAppWebClose", []);
		}
		/**
		 *  清除指定url相关的Cookies
		 * @param url  要清除cookies的url
		 * 
		 */		
		public function mobiFunAppWebRemoveCookies(url:String):void{
			System.nativeCall("MobiFunAppWebRemoveCookies", [url]);
		}
		/**
		 * 跳转到外部浏览器
		 * @param url  跳转外部浏览器要打开的url
		 * 
		 */		
		public function mobiFunOpenUrl(url:String):void{
			System.nativeCall("MobiFunOpenUrl", [url]);
		}
		/**
		 * 调用谷歌地图
		 * @param address  要搜索的地址
		 * 
		 */		
		public function mobiFunOpenGoogleMap(address:String):void{
			System.nativeCall("MobiFunOpenUrl", ["http://maps.google.com/maps?q=" + address]);
		}
		/**
		 * 调用邮件客户端
		 * @param address   邮件地址
		 * 
		 */		
		public function mobiFunMail(mailAddress:String):void{
			System.nativeCall("MobiFunOpenUrl", ["mailto://" + mailAddress]);
		}
		/**
		 * 拨打电话
		 * @param num  电话号码
		 * 
		 */		
		public function mobiFunPhone(num:int):void{
			System.nativeCall("MobiFunOpenUrl", ["tel://" + num]);
		}
		/**
		 * 调用短信
		 * @param num  短信号码
		 * 
		 */		
		public function mobiFunSMS(num:int):void{
			System.nativeCall("MobiFunOpenUrl", ["sms://" + num]);
		}
		/**
		 * 调用应用商店APP
		 * @param appId   应用id
		 * 
		 */		
		public function mobiFunAppStore(appId:int):void{
			System.nativeCall("MobiFunOpenUrl", ["http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=" + appId + "&amp;mt=8"]);
		}
		/**
		 * 启动应用评论
		 * @param appId    应用id
		 * 
		 */		
		public function mobiFunReview(appId:int):void{
			System.nativeCall("MobiFunOpenUrl", ["itmsapps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=" + appId]);
		}
		/**
		 * 启动其他应用
		 * @param url   被调用应用的       URL Schemes  
		 * 例如：com.MobiMirage.Demo.iap
		 * 
		 */		
		public function mobiFunStartOtherApp(url:String):void{
			System.nativeCall("MobiFunOpenUrl", [url]);
		}
		
		private function handler(e:ExtendNativeEvent):void
		{
			Logger.getLog("WebViewAPIUtil").debug("handler", e.id);
			
			switch(e.id)
			{
				case NativeEventConst.AppWebViewFinishLoad:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.APPWEB_VIEW_FINISH))
					break;
				}
				case NativeEventConst.AppWebViewFailLoad:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.APPWEB_VIEW_FAIL))
					break;
				}
				case NativeEventConst.AppWebViewRedirect:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.APPWEB_REDIRECT))
					break;
				}
				case NativeEventConst.AppWebViewUserClose:
				{
					dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.APPWEB_VIEW_USERCLOSE))
					break;
				}
				default:
				{
					Logger.getLog("SystemRelatedAPIUtil").debug("handlerError");
					break;
				}
			}
		}
	}
}
class ConSingle
{ 
}