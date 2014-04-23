package potato.login
{
	import core.system.Capabilities;
	import core.system.System;
	
	import potato.logger.Logger;
	import potato.utils.SharedObject;

	public class LoginData
	{
		/**版本检测*/
		public static const VERSIONCHECK:String = "versioncheck";
		/**登录验证*/	
		public static const LOGINVERIFICATION:String = "loginverification";
		/**请求服务器列表*/	
		public static const SERVERLIST:String = "serverlist";
		/**请求登录key*/	
		public static const LOGINKEY:String = "loginkey";
		/**苹果商店推送*/	
		public static const APPSTOREPUSH:String = "apppush";
		/**安卓推送*/
		public static const ANDROIDPUSH:String = "androidpush";
		/**本地推送*/
		public static const LOCALNOTIFICATION:String = "Localnotification";
		public static const PAY:String = "pay";
		public static const ORDER_SELECT:String = "order_select";

		/**新浪标识*/
		public static const LOGINSING:String = "sina";
		/**gamecenter标识*/
		public static const LOGINGAMECENTER:String = "gamecenter";
		public static const IAPIOS:String = "iapios"
		
		private static var _obj:Object = {};
		private static var _address:String;
		private static var _notice:String;
		private static var _listPageNum:String;
		private static var _serverList:Array;
		private static var _isappvip:String;
		private static var _IOS:Boolean;
		public function LoginData()
		{
		}

		public static function get IOS():Boolean
		{
			return _IOS;
		}

		public static function get listPage():String
		{
			return _listPageNum;
		}

		public static function set listPage(value:String):void
		{
			_listPageNum = value;
		}

		/**
		 *appstroe  是否显示vip 
		 */
		public static function get isappvip():String
		{
			return _isappvip;
		}

		/**
		 * @private
		 */
		public static function set isappvip(value:String):void
		{
			_isappvip = value;
		}

		/**
		 * 服务器列表 
		 */
		public static function get serverList():Array
		{
			return _serverList;
		}

		/**
		 * @private
		 */
		public static function set serverList(value:Array):void
		{
			_serverList = value;
		}

		/**
		 * notice公告文本内容 
		 */
		public static function get notice():String
		{
			return _notice;
		}

		/**
		 * @private
		 */
		public static function set notice(value:String):void
		{
			_notice = value;
		}

		/**
		 *  第一次必须把地址赋值 
		 */
		public static function get address():String
		{
			return _address;
		}

		/**
		 * @private
		 */
		public static function set address(value:String):void
		{
			_address = value;
		}

		/**
		 * 数据
		 */
		public static function get obj():Object
		{
			return _obj;
		}

		/**
		 * @private
		 */
		public static function set obj(value:Object):void
		{
			_obj = value;
		}

		public static function checkPid():void
		{
			if (!obj.pid)
			{
				var platformVer:String = Capabilities.version.toLowerCase();
				var arr:Array = platformVer.split(":");
				if(arr[1] == "android"){
					_IOS = false;
					obj.pid = arr[0] + arr[1];
				}else{
					_IOS = true;
					obj.pid = arr[0] + "ios";
				}
				Logger.getLog("LoginData").debug("platformVer:",platformVer,"pid:",obj.pid);
			}
		}
		
		
		public static function setConfig(key:String,value:String):void{
			var obj:Object = SharedObject.getLocal(key).data;
			obj[key] = value;
			SharedObject.getLocal(key).flush();
		}
		public static function getConfig(key:String):String{
			return SharedObject.getLocal(key).data[key];
		}
		/**
		 *获取 openUdid 
		 * @return 
		 * 
		 */		
		public static function getOpenUdid():String{
			if(LoginData.getConfig("openUdid")==null || LoginData.getConfig("openUdid")==""){
				var strUdid:String = System.nativeCall("MobiMirageGetOpenUDID",[]);
				LoginData.setConfig("openUdid",strUdid);
				return LoginData.getConfig("openUdid");
			}else{
				return LoginData.getConfig("openUdid");
			}
		}
		/**
		 *获取Idfa 
		 * @return 
		 * 
		 */		
		public static function getIdfa():String{
			return System.nativeCall("MobiMirageGetIdfa",[]);
		}
		/**
		 *获取Macaddress 
		 * @return 
		 * 
		 */		
		public static function getMacaddress():String{
			return System.nativeCall("MobiFunGetMacAddress",[]);
		/**
		 * 第三方平台 充值名字 
		 */
		}
		public static function getOhterPlatformPayName():String{
			
			return "";
		}
		
		/**
		 *  第三方平台用户反馈
		 * @return 
		 * 
		 */		
		public static function getIsUserFeedback():Boolean{
			switch(LoginData.obj.pid)
			{
				case "ndios":
				case "ndandroid":
				{
					return true;
					break;
				}
					
				default:
				{
					return false;
					break;
				}
			}
		}
		/**
		 * 第三方 平台 论坛 
		 * @return 
		 * 
		 */		
		public static function getIsBBS():Boolean{
			switch(LoginData.obj.pid)
			{
				case "ndios":
				case "ndandroid":
				case "ucios":
				case "ucandroid":
				case "qihuios":
				case "qihuandroid":
				case "ppios":
				case "ppandroid":
				{
					return true;
					break;
				}
					
				default:
				{
					return false;
					break;
				}
			}
		}
		/**
		 *第三方 平台 个人中心 
		 * @return 
		 * 
		 */		
		public static function getIsPersonalCenter():Boolean{
			switch(LoginData.obj.pid)
			{
				case "ndios":
				case "ndandroid":
				case "oppoios":
				case "oppoandroid":
				case "ppios":
				case "ppandroid":
				case "djios":
				case "djandroid":
				case "yyhios":
				case "yyhandroid":
				case "ppsios":
				case "ppsandroid":
				case "ucios":
				case "ucandroid":
				case "youmiios":
				case "youmiandroid":
				case "kugouios":
				case "kugouandroid":
				case "anzhiios":
				case "anzhiandroid":
				case "wanios":
				case "wanandroid":
				{
					return true;
					break;
				}
					
				default:
				{
					return false;
					break;
				}
			}
		}
	}
}