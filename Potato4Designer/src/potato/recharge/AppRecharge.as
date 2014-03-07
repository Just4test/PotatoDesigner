package potato.recharge
{
	import flash.utils.Dictionary;
	
	import core.events.Event;
	import core.events.HTTPStatusEvent;
	import core.events.IOErrorEvent;
	import core.net.URLRequest;
	import core.net.URLStream;
	import core.net.URLVariables;
	
	import potato.logger.Logger;
	import potato.login.LoginData;
	import potato.pay.IAppRecharge;
	import potato.pay.OrderInfo;
	import potato.pay.Recharge;
	import potato.utils.SystemRelatedAPIUtil;
	
	public class AppRecharge implements IAppRecharge
	{
		private var loaderDic:Dictionary;
		private var orderDic:Object;
		private var log:Logger = Logger.getLog("AppRecharge");
		public function AppRecharge()
		{
			loaderDic = new Dictionary();
			orderDic = new Object();
		}
		private var loader:URLStream;
		public function resultAsk(msg:String):int
		{
			log.debug( "msg1:",msg);
			var orderCode:String;
			var orderData:Array ;
			if(LoginData.obj.pid == LoginData.IAPIOS){
				var appData:Array=msg.split("data=");
				var receipt:String=appData[1];
				orderCode=appData[0].split(",")[0].split("OrderSerial=")[1];
				if (!orderDic.hasOwnProperty(orderCode)) {
					orderDic[orderCode] = OrderInfo.STATE_PROCESS;
				} else {
					if (orderDic[orderCode] != OrderInfo.STATE_PROCESS) {
						return orderDic[orderCode];
					}
				}
				Recharge.getIns().getOrderInfo(orderCode).receipt=msg;
				LoginData.obj.receiptdata = receipt;
				LoginData.obj.order_id = orderCode;
				
			}else{
				orderData=msg.split(":");
				orderCode=orderData[0];
				Recharge.getIns().getOrderInfo(orderCode).receipt=msg;
				LoginData.obj.order_id = orderData[1];
			}
			if (!orderDic.hasOwnProperty(orderCode)) {
				orderDic[orderCode] = OrderInfo.STATE_PROCESS;
			} else {
				if (orderDic[orderCode] != OrderInfo.STATE_PROCESS) {
					return orderDic[orderCode];
				}
			}
			log.debug( "msg5:",msg);
			var url:String;
			if(LoginData.obj.pid == LoginData.IAPIOS){
				url = LoginData.address  + "type=" + LoginData.PAY;
			}else{
				url = LoginData.address  + "type=" + LoginData.ORDER_SELECT;
			}
			var data:URLVariables = new URLVariables();
			data.data = JSON.stringify(LoginData.obj);
			
			loader = new URLStream();
			loader.addEventListener(Event.COMPLETE, complete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,getHttpStatus);
			
			var req:URLRequest;
			req = new URLRequest(url);
			req.data=data;
			req.method=URLRequest.POST;
			loader.load(req);
			loaderDic[loader] = orderCode;
			if(LoginData.IOS){
				log.debug("充值请求的地址：" + url + "&"+  req.data);
			}
			return OrderInfo.STATE_PROCESS;
		}
		
		private function getHttpStatus(e:HTTPStatusEvent):void
		{
			log.debug("HTTPStatusEvent:"+e.status.toString());
		}
		
		private function ioError(e:IOErrorEvent):void {
			var loader:URLStream = e.target as URLStream;
			orderDic[loaderDic[loader]] = OrderInfo.STATE_ERRORINGAME;
			loader.removeEventListener(Event.COMPLETE, complete);
			delete loaderDic[loader];
			loader = null;
		}
		private function complete(e:Event):void {
			var loader:URLStream = e.target as URLStream;
			try {  //// 在网页返回的状态不是200时，会发生错误
				var html:String = loader.readUTFBytes(loader.bytesAvailable);
				log.debug("pay  html", html);
				var jsonStr:Object = JSON.parse(html);
				log.debug( "ErrorCode  " + jsonStr.ErrorCode);
					if (jsonStr != null) {
						if (jsonStr.ErrorCode == "1") {
							log.debug( "Congratulations,Money has arrive!!" );
							SystemRelatedAPIUtil.getInstance().mobiFunPopUp("提示"," 充值成功","确定");
							log.debug( "Congratulations,Money has arrive!! 1" );
							var orderInfo:OrderInfo=Recharge.getIns().getOrderInfo(loaderDic[loader]);
							log.debug( "Congratulations,Money has arrive!! 2" );
							log.debug("code:", loaderDic[loader] );
							orderInfo.state=OrderInfo.STATE_SUCESS;
							log.debug( "Congratulations,Money has arrive!! 3" );
							orderDic[loaderDic[loader]] = OrderInfo.STATE_SUCESS;
							log.debug( "Congratulations,Money has arrive!! 4" );
						}
						else
						{
							log.debug( "no,Money !" );
						}
					}
			} catch (e:Error) {
				log.warn(e.toString());
			}
			loader.removeEventListener(Event.COMPLETE, complete);
			delete loaderDic[loader];
			loader = null;
		}
	}
}