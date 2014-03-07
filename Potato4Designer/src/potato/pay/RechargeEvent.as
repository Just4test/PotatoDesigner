package potato.pay
{
	import core.events.Event;
	
	
	public class RechargeEvent extends Event
	{
		/**
		 * 支付未登陆
		 */		
		public static const OtherPlatformUnLogin:String = "OtherPlatformUnLogin";
		/**
		 * 支付发生错误
		 */		
		public static const OtherPlatformPayParameterError:String = "OtherPlatformPayParameterError";
		/**
		 * 用户取消支付
		 */		
		public static const OtherPlatformUserCancelPay:String = "OtherPlatformUserCancelPay";
		/**
		 * 支付成功
		 */		
		public static const OtherPlatformPaySuccess:String = "OtherPlatformPaySuccess";
		/**
		 *苹果商店禁止购买 
		 */		
		public static const IapUserBanPay:String="IapUserBanPay";
		
		public static const CLICK_PAY:String = "click_pay";
		
		/**
		 * 订单号
		 */		
		public var orderCode:String;
		public function RechargeEvent(type:String, bubbles:Boolean=false,orderCode:String = null)
		{
			super(type, bubbles);
			this.orderCode = orderCode
		}
		
		override public function clone():Event
		{
			return new RechargeEvent(type, bubbles, orderCode);
		}
	}
}