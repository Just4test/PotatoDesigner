package potato.pay
{
	public class OrderInfo
	{
		/** 正在处理 */		
		public static const STATE_PROCESS:int = 1;
		/** 支付发生错误（91 sdk） */	
		public static const STATE_ERRORINSDK:int = 2;
		/** 支付发生错误（游戏服务器返回） */	
		public static const STATE_ERRORINGAME:int = 3;
		/** 支付发生错误（超过轮询次数） */	
		public static const STATE_ERRORINOUTTIME:int = 4;
		/** 用户取消支付 */	
		public static const STATE_CANCEL:int = 5;
		/** 支付成功 */	
		public static const STATE_SUCESS:int = 6;
		
		
		public var orderCode:String;	//订单号
		public var name:String;			//商品名 / 产品id(在苹果开发者账户注册的id)
		public var price:Number;		//单价(精确小数点后两位,不能为0)
		//		public var appNum:String;      //苹果的购买个数
		public var num:int;				//购买个数
		public var des:String;			//商品描述
		public var time:String;			//创建订单时间
		public var receipt:String;			//苹果支付的验证请求
		
		public var verifyData:String;	//支付验证数据字符串
		
		/**
		 *  订单当前状态
		 *  1  正在处理
		 *  2  支付发生错误（91 sdk）
		 *  3  支付发生错误（游戏服务器返回）
		 *  4  支付发生错误（超过轮询次数）
		 *  5  用户取消支付
		 *  6  支付成功
		 */
		public var state:int = 0;
		
		/**
		 * 到游戏服务器查询订单的尝试次数
		 */		
		public var retryNum:int = 0;
		
		public function OrderInfo()
		{
			time = getTime();
		}
		
		/**
		 * 获得订单状态名 
		 * @return 
		 */		
		public function getStateName():String {
			if (state == 6) {
				return "充值成功";
			} else if (state == 5) {
				return "用户取消";
			} else if (state == 1) {
				return "正在处理";
			} else {
				return "充值失败";
			}
		}
		
		public function toString():String {
			return "{orderCode:" + orderCode + ", name:" + name 
				+ ", price:" + price + ", num:" + num
				+ ", state:" + state + ", retryNum:" + retryNum
				+ ", des:" + des + ", time:" + time +", receipt" + receipt;
		}
		
		
		private function getTime():String {
			var str:String;
			var date:Date = new Date();
			str = date.fullYear+"/"+(date.month+1)+"/"+date.date+"  "+date.hours+":"+(date.minutes+1)+":"+(date.seconds);
			return str;
		}
	}
}