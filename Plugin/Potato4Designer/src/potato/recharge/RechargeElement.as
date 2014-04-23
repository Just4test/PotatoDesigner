package potato.recharge
{
	public class RechargeElement
	{
		/**
		 * 是否是异步充值 1：是  0：否 
		 */		
		public var type:int=1;
		/**
		 * 充值面板按钮背景 
		 */		
		public var buttonBg:String; 
		/**
		 * 充值单选框按钮背景 
		 */		
		public var selectBtn:String;
		/**
		 * 输入框背景 
		 */		
		public var inputBg:String;
		/**
		 * 程序内提示窗函数 
		 */		
		public var prompt:Function;
		/**
		 * 忙动画开始 
		 */		
		public var loadingStart:Function;
		/**
		 * 忙动画关闭
		 */
		public var loadingStop:Function;
		/**
		 * 文本字体 
		 */
		public var fontName:String="yh";
		/**
		 * 文本大小 
		 */
		public var fontSize:uint=20;
		/**
		 * 文本颜色 
		 */		
		public var fontColor:uint=	0xa9996d;
		/**
		 * 游戏内游戏币的名称（黄金，元宝等） 
		 */		
		public var gameGlodName:String;
		/**
		 * 游戏币跟RMB的比例 
		 */		
		public var gameGlodPercent:Number=10;
		/**
		 * 充值的其他参数，比如用户id或其他的标识，
		 * 由客户端和服务器一起商讨 
		 */		
		public var gameGlodArg:String;
		/**
		 *DL专用
		 *服务器需要的参数，由服务器人员和客户端一起制定，一般由(sid+"|"+订单号)组成 
		 */		
		public var eif:String;
		/**
		 * appstore充值档的字段,如net.giantmobile.tenyear.pay 
		 * 
		 */		
		public var payStr:String;
		/**
		 *appstore  充值分档
		 */		
		public var rechargeNum:Array ;

		/**
		 * 充值界面显示的充值档的文本内容 
		 */		
		public var glodNameArr:Array=[];
		/**
		 * 默认选择的是第几个充值档 
		 */		
		public var disSelect:int=0;
		/**
		 * 文本语言数组
		 */		
		public var languageTextArrar:Array;
		
		public function RechargeElement()
		{
		}
	}
}