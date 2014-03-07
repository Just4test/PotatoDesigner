package potato.utils
{
	import core.system.System;
	/**
	 * 使用友盟参数     第一步必须先使用uMstartWithAppkey方法
	 * @author stone0331
	 * 
	 */	
	public class UmengUtil
	{
		/**
		 *     友盟统计
		 *    必须先调  uMstartWithAppkey方法
		 * 
		 */		
		public function UmengUtil()
		{
			
		}
		/**
		 * 开启友盟统计
		 * @param appkey  友盟appKey
		 * @param name   渠道名称
		 * @param i    发送策略
		 *     REALTIME = 0,       //实时发送
               BATCH = 1,          //启动发送
               SENDDAILY = 4,      //每日发送
               SENDWIFIONLY = 5,   //仅在WIFI下启动时发送
               SEND_INTERVAL = 6,  //按最小间隔发送
               SEND_ON_EXIT = 7     //退出或进入后台时发送
		 * 
		 */		
		public static function uMstartWithAppkey(appkey:String,name:String,i:int = 0):void{
			System.nativeCall("UMstartWithAppkey", [appkey,i,name]);
		}
		/**
		 *   当发送策略为:SEND_INTERVAL 时设定log发 送间隔
		 * @param i   当发送策略为:SEND_INTERVAL 时设定log发送间隔,单位为秒,最小为10,最大为86400(一天).
		 */		
		public static function uMsetLogSendInterval(i:int):void{
			System.nativeCall("UMsetLogSendInterval", [i]);
		}
		/**
		 * 记录某个页面被打开多长时间,自己计时
		 * @param view   需要记录时长的view名称
		 * @param time   秒数，int型.
		 * 
		 */		
		public static function uMlogPageView(view:String,time:int):void
		{
			System.nativeCall("UMlogPageView", [view,time]);
		}
		/**
		 * 页面计时开始                        需要和uMendLogPageView方法配对使用
		 * @param name   需要记录时长的页面名称
		 * 
		 */		
		public static function uMbeginLogPageView(name:String):void{
			System.nativeCall("UMbeginLogPageView", [name]);
		}
		/**
		 *  页面计时结束    需要和uMbeginLogPageView方法配对使用
		 * @param name   需要记录时长的页面名称
		 * 
		 */		
		public static function uMendLogPageView(name:String):void{
			System.nativeCall("UMendLogPageView", [name]);
		}
		/**
		 *
		 * @param eventId   事件 id
		 * 
		 */		
		public static function Umevent(eventId:String):void{
			System.nativeCall("UMevent",[eventId]);
		}
		/**
		 * 
		 * @param eventId   事件 id
		 * @param label  分类标签。不同的标签会分别进行统计，方便同一事件的不同标签的对比
		 * 
		 */		
		public static function Umeventlabel(eventId:String,label:String):void{
			System.nativeCall("UMeventlabel",[eventId,label]);
		}
		/**
		 * 
		 * @param eventId
		 * @param i  累加值。为减少网络交互，可以自行对某一事件ID的某一分类标签进行累加，再传入次数作为参数。
		 * 
		 */		
		public static function Umeventacc(eventId:String,i:int):void{
			System.nativeCall("UMeventacc",[eventId,i]);
		}
		
		/**
		 * 
		 * @param eventId
		 * @param label  分类标签。不同的标签会分别进行统计，方便同一事件的不同标签的对比
		 * @param i      累加值。为减少网络交互，可以自行对某一事件ID的某一分类标签进行累加，再传入次数作为参数。
		 * 
		 */		
		public static function Umeventlabelacc(eventId:String,label:String,i:int):void{
			System.nativeCall("UMeventlabelacc",[eventId,label,i]);
		}
		/**
		 * 和UMendEvent  配对使用
		 * @param eventId    事件id
		 * 
		 */		
		public static function UMbeginEvent(eventId:String):void{
			System.nativeCall("UMbeginEvent",[eventId]);
		}
		/**
		 * 和UMbeginEvent  配对使用
		 * @param eventId   事件id
		 * 
		 */		
		public static function UMendEvent(eventId:String):void{
			System.nativeCall("UMendEvent",[eventId]);
		}
		/**
		 *    和UMendEventlabel  配对使用
		 * @param eventId
		 * @param label   分类标签。不同的标签会分别进行统计，方便同一事件的不同标签的对比
		 * 
		 */		
		public static function UMbeginEventlabel(eventId:String,label:String):void{
			System.nativeCall("UMbeginEventlabel",[eventId,label]);
		}
		/**
		 *  和UMbeginEventlabel  配对使用
		 * @param eventId
		 * @param label  分类标签。不同的标签会分别进行统计，方便同一事件的不同标签的对比
		 * 
		 */		
		public static function UMendEventlabel(eventId:String,label:String):void{
			System.nativeCall("UMendEventlabel",[eventId,label]);
		}
		/**
		 *  时长统计 
		 * @param eventId
		 * @param time   自己计时需要的话需要传毫秒进来
		 * 
		 */		
		public static function UMeventdurations(eventId:String,time:int = 1000):void{
			System.nativeCall("UMeventdurations",[eventId,time]);
		}
		/**
		 * 时长统计 
		 * @param eventId
		 * @param label   分类标签。不同的标签会分别进行统计，方便同一事件的不同标签的对比
		 * @param time   自己计时需要的话需要传毫秒进来
		 * 
		 */		
		public static function Umeventlabeldurations(eventId:String,label:String,time:int = 1000):void{
			System.nativeCall("UMeventlabeldurations",[eventId,label,time]);
		}
		/**
		 *  获得友盟在线参数设置  
		 * 需要 先到友盟网站内添加此项目的在线参数
		 * @param name 参数名称
		 * @return 
		 */		
		public static function UMgetConfigParams(name:String):String{
			if(Utils.platformVer() == Utils.PV_WIN)
				return "";
			
			var str:String = System.nativeCall("UMgetConfigParams",[name]);
			return str;
		}
		/**
		 * 按渠道自动更新
		 * 
		 */		
		public static function UMcheckUpdate():void{
			System.nativeCall("UMgetConfigParams",[]);
		}
		
	}
}
