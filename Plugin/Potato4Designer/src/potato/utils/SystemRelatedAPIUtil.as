package potato.utils
{
	import core.events.EventDispatcher;
	import core.events.TimerEvent;
	import core.system.System;
	import core.utils.Timer;
	
	import ext.events.ExtendNativeEvent;
	
	import potato.events.OtherPlatformEvent;
	import potato.logger.Logger;

	/**
	 * 2014-2-24
	 * @author 荣磊
	 * 
	 */	
	public class SystemRelatedAPIUtil extends EventDispatcher
	{
		private static var log:Logger = Logger.getLog("SystemRelatedAPIUtil");
		private static var instance:SystemRelatedAPIUtil;
		private var timer:Timer;
		private var autoComplete:Function;
		
		/**
		 *系统相关API 
		 * 
		 */		
		public function SystemRelatedAPIUtil(content:ConSingle)
		{
			edp = new EventDispatcher();
			edp.addEventListener(ExtendNativeEvent.STATE, handler);
		}
		public static function getInstance():SystemRelatedAPIUtil{
			if(instance == null)
			{
				instance = new SystemRelatedAPIUtil(new ConSingle);
			}
			return instance;
		}
		/**
		 *    第三方平台生成订单号
		 * @return 
		 * 
		 */		
		public function mobiMirageGetOrderSerial():String{
			return System.nativeCall("MobiMirageGetOrderSerial", []);
		}
		/**
		 *  获得IDFA(IOS专属接口,ios6以下返回openudid)
		 * @return 
		 * 
		 */		
		public function mobiMirageGetIdfa():String{
			return System.nativeCall("MobiMirageGetIdfa", []); 
		}
		/**
		 * 获得openudid
		 * @return 
		 * 
		 */		
		public function mobiMirageGetOpenUDID():String{
			return System.nativeCall("MobiMirageGetOpenUDID", []);
		}
		/**
		 * 获得获得mac地址(IOS7以后mac地址变成唯一  02:00:00:00:00:00)
		 * @return 
		 * 
		 */		
		public function mobiFunGetMacAddress():String{
			return System.nativeCall("MobiFunGetMacAddress", []);
		}
		private var edp:EventDispatcher;
		/**
		 *    系统弹出框   只支持3个按钮
		 * @param title   弹出框标题
		 * @param msg     弹出框消息
		 * @param aName   第一个按钮名字
		 * @param bName   第二个按钮名字
		 * @param cName   第三个按钮名字
		 * 
		 */		
		public function mobiFunPopUp(title:String,msg:String,aName:String,bName:String = "",cName:String = ""):void{
			if(!aName==""&& bName == ""&& cName ==""){
				System.nativeCall("MobiFunPopUp", [edp,title,msg,aName]);
			}else if(!bName=="" && cName ==""){
				System.nativeCall("MobiFunPopUp", [edp,title,msg,aName,bName]);
			}else{
				System.nativeCall("MobiFunPopUp", [edp,title,msg,aName,bName,cName]);
			}
		}
		
		private function handler(e:ExtendNativeEvent):void
		{
			Logger.getLog("SystemRelatedAPIUtil").debug("handler", e.id);
			if(e.id == NativeEventConst.PopUpButtonEvents){
				dispatchEvent(new OtherPlatformEvent(OtherPlatformEvent.POPUP_BUTTON_EVENT,false,e.msg))
			}else{
				Logger.getLog("SystemRelatedAPIUtil").debug("handler，error");
			}
		}
		/**
		 *    获得网络状态
		 * @return 0-无网络；1-WIFI；2-GPRS 
		 * 
		 */		
		public function mobiFunGetNetStatus():int{
			return System.nativeCall("MobiFunGetNetStatus", []);
		}
		/**
		 *   获得剩余磁盘空间 
		 * @return   单位Kb
		 * 
		 */		
		public function mobiFunGetDeviceLeft():int{
			return System.nativeCall("MobiFunGetDeviceLeft", []);
		}
		/**
		 *   本地通知 
		 * @param time   时间，多少秒后通知
		 * @param msg    通知的内容
		 * 
		 */		
		public function mobiFunLocalNotification(time:int,msg:String):void{
			System.nativeCall("MobiFunLocalNotification", [time,msg]);
		}
		/**
		 * 获得剪贴板内容
		 * @return 剪切板内容
		 * 
		 */		
		public function mobiFunReadPasteboard():String{
			return System.nativeCall("MobiFunReadPasteboard", []);
		}
		/**
		 * 将文本内容写入剪贴板
		 * @param msg  内容
		 * 
		 */		
		public function mobiFunWritePasteboard(msg:String):void{
			System.nativeCall("MobiFunWritePasteboard", [msg]);
		}
		/**
		 * 
		 * @param funName  
		 * @param custom
		 * 
		 */		
		public function mobiMirageExpandNative(funName:String,custom:String = ""):void{
			edp = new EventDispatcher();
			edp.addEventListener(ExtendNativeEvent.STATE, handler);
			System.nativeCall("MobiMirageExpandNative", [funName,edp,custom]);

		}
		/**
		 * 显示性能统计
		 * 
		 */		
		public function mobiMirageShowSystemInformation():void{
			System.nativeCall("MobiMirageShowSystemInformation", []);
		}
		/**
		 * 隐藏性能统计
		 * 
		 */		
		public function mobiMirageHideSystemInformation():void{
			System.nativeCall("MobiMirageHideSystemInformation", []);
		}
		/**
		 * 获得电池电量
		 * @return 获得电池电量(1为100%)
		 * 
		 */		
		public function mobiMirageGetBattery():Number{
			return System.nativeCall("MobiMirageGetBattery", []);
		}
		/**
		 * 获得CPU使用率
		 * @return 获得CPU使用率(1为100%)
		 * 
		 */		
		public function mobiMirageGetCPUUtilization():Number{
			return System.nativeCall("MobiMirageGetCPUUtilization", []);
		}
		
		
		/**
		 *    录音       和   mobiMirageStopRecord方法  配对使用
		 * @param name            存储录音的名字
		 * @param maxTime			最长录音时间。到了时间自动停止
		 * @param autoComplete		录音自动完成回调方法，参数(name)——等于开始录音的name
		 * @param samplingRate  采样率    默认为  8.000Hz 电话所用采样率,对于人的说话已经足够，
		 *                                4.000Hz 是最低标准，
		 *                                16.000Hz   
		 *                                44.100Hz 音频 CD,也常用于 MPEG-1音频（VCD, SVCD, MP3）所用采样率
		 * @param passage       通道       通常为16    有三个选择 (8,16,32)
		 * 
		 * @return 如果正在录音，则失败
		 */		
		public function mobiMirageRecord(name:String, maxTime:int = 20000, autoComplete:Function = null, samplingRate:Number=4000,passage:int = 8):Boolean{
			if (timer)
				return false;
			
			timer = new Timer(maxTime);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			
			this.autoComplete = autoComplete;
			
			System.nativeCall("MobiMirageRecord", [edp,name,samplingRate,samplingRate]);
			
			return true;
		}
		
		/**
		 *   停止录音    mobiMirageRecord 对应使用
		 */		
		public function mobiMirageStopRecord():void{
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.stop();
			timer = null;
			
			System.nativeCall("MobiMirageStopRecord", []);
		}
		
		/**
		 * 时间结束 
		 * @param e
		 */
		private function onTimer(e:TimerEvent):void{
			mobiMirageStopRecord();
			if(autoComplete != null)
			{
				autoComplete();
				autoComplete = null;
			}
		}
		/**
		 *  播放视频      和 mobiFunStopMovie方法 配对使用
		 * @param name         文件名字
		 * @param cycling      循环 默认为不循环      1为循环
		 * 
		 */		
		public function mobiFunPlayMovie(name:String,cycling:int = 0):void{
			System.nativeCall("MobiFunPlayMovie",[edp,name,cycling])
		}
		/**
		 * 停止视频 和 mobiFunPlayMovie方法配对使用
		 * 
		 */		
		public function mobiFunStopMovie():void{
			System.nativeCall("MobiFunStopMovie",[])

		}
	}
}
class ConSingle
{ 
}
