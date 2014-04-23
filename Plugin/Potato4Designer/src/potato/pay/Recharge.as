package potato.pay
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	import core.events.EventDispatcher;
	import core.events.TimerEvent;
	import core.filesystem.File;
	import core.system.System;
	import core.utils.Timer;
	
	import ext.events.ExtendNativeEvent;
	
	import potato.logger.Logger;
	import potato.login.LoginData;
	import potato.pay.IAppRecharge;
	import potato.utils.NativeEventConst;
	import potato.utils.SystemRelatedAPIUtil;

	/**
	 * 支付工具类
	 */	
	public class Recharge extends EventDispatcher
	{
		private static const REFRESHTIME:int = 15000; //5min
		public static var ORDERFILE:String = "";
		private static function hideCtor():void{}
		private var timer:Timer;
		private var edp:EventDispatcher;
		
		private var orderList:Array;
		private var processList:Array;
		
		private var appPay:IAppRecharge;		//应用的付费接口
		
		private static var pay:Recharge;
		private static var inited:Boolean = false;
		
		private static var log:Logger = Logger.getLog("Recharge");
		
		public var _code:String;

		public static function getIns(reInstance:Boolean = false):Recharge {
			if(reInstance)
			{
				inited = false;
				if(pay && pay.edp)
				{
					pay.edp.removeEventListeners();
				}
				if(pay && pay.timer)
					pay.timer.removeEventListeners();
				pay = null;
			}
			if (pay == null) {
				pay = new Recharge(hideCtor);
			}
			return pay;
		}
		public function Recharge(fun:Function)
		{
			if (fun != hideCtor) Error.throwError(Recharge, 2012);
			registerClassAlias("sf.pay.OrderInfo", OrderInfo);
		}
		/**
		 * 初始化充值类，在使用充值前必须调用一次初始化
		 * @param appPay
		 */		
		public function init(appPay:IAppRecharge):void {
			if (inited) return;
			edp = new EventDispatcher();
			edp.addEventListener(ExtendNativeEvent.STATE, evtHandler);
			timer = new Timer(REFRESHTIME);
			timer.addEventListener(TimerEvent.TIMER, poll);
			this.appPay = appPay;
			orderList = [];
			processList = [];
			
			// 读取保存的订单列表
			log.debug("ORDERFILE", ORDERFILE, File.exists(ORDERFILE));
			if (File.exists(ORDERFILE)) {
				var b:ByteArray = File.readByteArray(ORDERFILE);
				orderList = b.readObject();
				for each (var oi:OrderInfo in orderList) {
					if (oi.state == 1) {
						processList.push(oi);
					}
					
					log.debug("processList", oi.toString());
				}
			}
			inited = true;
			
			if (processList.length > 0 && !timer.running) {
				timer.start();
			}
		}
		public function checkEventListener():void{
			log.debug("edp监听",edp,edp.hasEventListener(ExtendNativeEvent.STATE))
			if(edp && !edp.hasEventListener(ExtendNativeEvent.STATE)){
				log.debug("监听开始");
				edp.addEventListener(ExtendNativeEvent.STATE, evtHandler);
			}
		}
		/**
		 * 
		 * @param name 商品名        
		 * @param price 单价(精确小数点后两位,不能为0)
		 * @param num 购买个数
		 * @param des 商品描述    //需要其他
		 * @type  默认为0 同步充值   1异步充值
		 */
		public function webBuy(name:String, price:Number, num:int, des:String):String {
			checkEventListener();

			var orgPrice:Number =  price; //原始单价
			var orderCode:String = System.nativeCall("MobiMirageGetOrderSerial", []);
			System.nativeCall("OtherPlatformPay", [edp,LoginData.obj.server_id,LoginData.obj.rolename,orderCode, name, price, num, des]);	
			order=new OrderInfo();
			order.orderCode = orderCode;
			order.name = name;
			order.price = price;
			order.num = num;
			order.des = des;
			order.state = OrderInfo.STATE_PROCESS;
			
			
			processList.push(order);
			orderList.push(order);
			log.debug("新订单:" + order,orderList.length);
			
			// 写到文件
			writeToFile();
			
			return orderCode;
		}
		
		private var appOrder:OrderInfo;

		private var order:OrderInfo;
		/**
		 * 
		 * @param pid   net.giantmobile.oncient.pay6
		 * @param type  net.giantmobile.oncient.pay
		 * @return 
		 * 
		 */		
		public function iapBuy(pid:String,type:String=""):String
		{
			checkEventListener();

			var orderCode:String = System.nativeCall("MobiMirageGetOrderSerial", []);
			System.nativeCall("MobiFunIapBuyProduct", [edp, pid,orderCode]);
			appOrder = new OrderInfo();
			appOrder.orderCode = orderCode;
			appOrder.name = "游戏币";
			appOrder.price = 1;
			appOrder.num = int(pid.split(type)[1]);
			appOrder.state = OrderInfo.STATE_PROCESS;
			log.debug("iap新订单"+ appOrder);
			
			processList.push(appOrder);
			orderList.push(appOrder);
			writeToFile();

			return orderCode;
		}

		/**
		 * 获得所有订单列表
		 * @return 
		 */		
		public function getOrderList():Array {
			return orderList;
		}
		/**
		 * 获取指定的订购信息 
		 * @param orderCode
		 * @param state
		 * 
		 */						

		public function getOrderInfo(orderCode:String):OrderInfo{
			log.debug("test11111:",orderCode,orderList.length)
			for each(var item:OrderInfo in orderList){
				log.debug("222222:",item,item.orderCode)
				if(item.orderCode==orderCode){
					log.debug("3333333:")
					return item;
					log.debug("444444:")
				}
			}
			return null;
		}
		
		/**
		 * 设置订单的状态，应用一般不需要调用该方法 
		 * @param orderCode
		 * @param state
		 */		
		public function setOrderState(orderCode:String, state:int):void {
			var oi:OrderInfo;
			for (var i:int=orderList.length-1; i>=0; i--) {
				oi = orderList[i];
				if (oi.orderCode == orderCode) {
					oi.state = state;
					writeToFile();
					return;
				}
			}
		}
		
		internal function setOrderVerify(orderCode:String, data:String):void {
			var oi:OrderInfo;
			for (var i:int=orderList.length-1; i>=0; i--) {
				oi = orderList[i];
				if (oi.orderCode == orderCode) {
					oi.verifyData = data;
					writeToFile();
					return;
				}
			}
		}
		/**
		 * 支付事件 
		 * @param e
		 */		
		private function evtHandler(e:ExtendNativeEvent):void {
			log.debug("evtHandler", e.toString(),e.id);
			var orderArr:Array = e.msg.split(":")
			switch (e.id) {
				case NativeEventConst.OtherPlatformPayOrderSerialSubmitted://支付已提交
				case NativeEventConst.OtherPlatformPaySuccess://支付成功
					dispatchEvent(new RechargeEvent(RechargeEvent.OtherPlatformPaySuccess, false, e.msg));
					appPay.resultAsk(e.msg);
					writeToFile();
					if(!timer.running){
						if(timer && !timer.hasEventListener(TimerEvent.TIMER)){
							timer.addEventListener(TimerEvent.TIMER,poll);
						}
						timer.start();
					}
					break;
				case NativeEventConst.OtherPlatformPayParameterError:
					setOrderState(orderArr[0], OrderInfo.STATE_ERRORINSDK);
					dispatchEvent(new RechargeEvent(RechargeEvent.OtherPlatformPayParameterError, false, e.msg));
					break;
				case NativeEventConst.OtherPlatformUserCancelPay:
					setOrderState(orderArr[0], OrderInfo.STATE_CANCEL);
					dispatchEvent(new RechargeEvent(RechargeEvent.OtherPlatformUserCancelPay, false, e.msg));
					break;
				case NativeEventConst.OtherPlatformUnLogin:
					setOrderState(orderArr[0], OrderInfo.STATE_ERRORINSDK);
					dispatchEvent(new RechargeEvent(RechargeEvent.OtherPlatformUnLogin, false, e.msg));
					break;
				// app store
				case NativeEventConst.IapUserBanPay://用户禁止应用内购买
					dispatchEvent(new RechargeEvent(RechargeEvent.IapUserBanPay, false, e.msg));
					
					break;
				case NativeEventConst.IapBuyFinished://支付成功
					dispatchEvent(new RechargeEvent(RechargeEvent.OtherPlatformPaySuccess, false, e.msg));
					appPay.resultAsk(e.msg);
					break;
				case NativeEventConst.IapUserCancel://用户取消支付
					setOrderState(e.msg, OrderInfo.STATE_CANCEL);
					dispatchEvent(new RechargeEvent(RechargeEvent.OtherPlatformUserCancelPay, false, e.msg));
					break;
				case NativeEventConst.IapBuyError://支付错误
					setOrderState(e.msg, OrderInfo.STATE_ERRORINSDK);
					dispatchEvent(new RechargeEvent(RechargeEvent.OtherPlatformPayParameterError, false, e.msg));
					break;
				default:
					log.warn("Unkown ExtendNativeEvent.", e.toString());
			}
		}
		
		/**
		 * 写到文件
		 */		
		private function writeToFile():void {
			var b:ByteArray = new ByteArray();
			b.writeObject(orderList);
			for each(var item:OrderInfo in orderList)
			{
				log.debug("写文件", item.toString());
			}
			File.writeByteArray(ORDERFILE, b);
		}
		
		public function setTimeStatus(boo:Boolean):void{
			if(boo){
				timer.start();
			}else{
				timer.start();
			}
		}
		
		/**
		 *  
		 * @param e
		 */		
		private function poll(e:TimerEvent=null):void {
			//TODO 增加timer时间的判断，timer的bug
			var arr:Array = new Array();
			for each (var oi:OrderInfo in processList) {
				log.debug("轮询", oi.toString());
				if (oi.state == 1) {
					if (oi.retryNum < 10) {
						try {
							oi.state = appPay.resultAsk(oi.receipt);
						} catch (e:Error) {
							log.warn(e.toString());
						}
						oi.retryNum += 1;
						arr.push(oi);
					} else {
						oi.state = OrderInfo.STATE_ERRORINOUTTIME;	//支付发生错误（超过轮询次数）
						log.debug("充值失败")
						SystemRelatedAPIUtil.getInstance().mobiFunPopUp("提示"," 充值失败","确定");
					}
				}
			}
			
			processList.length = 0;
			processList = arr;
			if (arr.length == 0) {
				timer.stop();
			}
			
			// 写到文件
			writeToFile();
		}
	}
}