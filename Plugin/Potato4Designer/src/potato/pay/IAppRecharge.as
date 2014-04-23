package potato.pay
{
	/**
	 * 应用支付接口
	 */	
	public interface IAppRecharge
	{
		/**
		 * 查询支付结果，支付模块可能会多次调用该函数查询
		 * @return  返回订单当前状态
		 *  		1  正在处理
		 *  		2  支付发生错误（sdk）
		 *  		3  支付发生错误（游戏服务器返回）
		 *  		5  用户取消支付
		 *  		6  支付成功
		 */
		function resultAsk(orderCode:String):int;
	}
}