package potato.recharge
{
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	import core.events.Event;
	import core.events.EventDispatcher;
	import core.events.HTTPStatusEvent;
	import core.events.IOErrorEvent;
	import core.text.TextField;
	
	import potato.logger.Logger;
	import potato.login.LoginData;
	import potato.pay.Recharge;
	import potato.pay.RechargeEvent;
	import potato.ui.Button;
	import potato.ui.TextStyle;

	/**
	 * 支付控制类 
	 * @author Administrator
	 * 要用支付系统  必须 把这两个赋值
	 * LoginData.obj.rolename  角色名称
	 * LoginData.obj.roleLevel 角色等级
	 */	
	public class RechargeControler extends EventDispatcher
	{
		private var money:RechargePanel;
		
		public var resElement:RechargeElement;
		
		private var event:RechargeEvent;
		
		private var charge:Recharge;
		
		public static const BUTTONTEXTSTYLE:TextStyle = new TextStyle("yh", 25, 0xffffffb5, TextField.ALIGN_CENTER, TextField.ALIGN_CENTER);
		
		private static var instance:RechargeControler;
		
		private  static var oldUserId:String="nidaye";
		public function RechargeControler()
		{
			charge = Recharge.getIns();
			charge.addEventListener(RechargeEvent.OtherPlatformPaySuccess, chargeSuccess);
			charge.addEventListener(RechargeEvent.OtherPlatformPayParameterError, chargeError);
			charge.addEventListener(RechargeEvent.OtherPlatformUnLogin, chargeUnLogin);
			charge.addEventListener(RechargeEvent.IapUserBanPay, chargeBanPay);
			charge.addEventListener(RechargeEvent.OtherPlatformUserCancelPay, cancelPayApp);//appstore取消充值
		}
		private function chargeSuccess(e:RechargeEvent):void{
			if(LoginData.obj.pid==LoginData.IAPIOS){
				resElement.loadingStop();
				resElement.prompt(resElement.languageTextArrar[0]);
			}
		}
		
		private function chargeError(e:RechargeEvent):void{
			if(LoginData.obj.pid==LoginData.IAPIOS){
				resElement.loadingStop();
			}
			if( LoginData.obj.pid==LoginData.IAPIOS){
				resElement.prompt(resElement.languageTextArrar[1]);
			}
		}
		
		private function chargeUnLogin(e:RechargeEvent):void{
			if(LoginData.obj.pid==LoginData.IAPIOS){
				resElement.loadingStop();
			}
			if( LoginData.obj.pid==LoginData.IAPIOS){
				resElement.prompt(resElement.languageTextArrar[2]);
			}
		}
		private function chargeBanPay(e:RechargeEvent):void{
			if(LoginData.obj.pid==LoginData.IAPIOS){
				resElement.loadingStop();
				resElement.prompt(resElement.languageTextArrar[3]);
			}
		}
		private function cancelPayApp(e:RechargeEvent):void{
			if(LoginData.obj.pid==LoginData.IAPIOS){
				resElement.loadingStop();
				resElement.prompt(resElement.languageTextArrar[4]);
			}
		}
		public static function reset():void{
			instance.dispose();
			instance=null;
			oldUserId="nidaye";
		}
		public static function getInstance():RechargeControler
		{
			if(!checkUserId)
			{
				Recharge.ORDERFILE="odrlst"+oldUserId+".dat";
				var rec1:Recharge = Recharge.getIns(true);
				rec1.init(new AppRecharge());
				Logger.getLog("RechargeControleAppPayInit").debug("init new AppRecharge",oldUserId);
			}
			if(!instance){
				instance = new RechargeControler();
				Logger.getLog("RechargeControleAppPayInit").debug("init" );
			}
			return instance;
		}
		private static function get checkUserId():Boolean{
			var newUserId:String = LoginData.obj.rolename;
			if(oldUserId==newUserId){
				return true;
			}
			oldUserId=newUserId;
			return false;
		}
		/**
		 * 设置充值面板的一些资源和 
		 * @param res
		 * 
		 */		
		public function set setResource(res:RechargeElement):void{
			resElement = res;
		}
		//		18675433353 2564403
		/**
		 *
		 * @param name 对话框名，唯一
		 * @param screen 对话框显示根容器
		 * @param bg 背景图片
		 * @param title 对话框标题
		 * @param closeBtn 对话框关闭按钮
		 * @param modal 对话框强制响应模式
		 * @param isSavePostion 是否保存上次打开位置
		 * @param isIndependModal 是否有自己的遮挡层
		 */
		public function getDialog(name:String,
								  screen:DisplayObjectContainer,
								  bg:DisplayObject,
								  title:TextField=null,
								  closeBtn:Button=null,
								  modal:Boolean=false,
								  isSavePostion:Boolean=true,
								  isIndependModal:Boolean=true):void
		{
			LoginData.checkPid();
			money=new RechargePanel(name,screen,bg,title,closeBtn,modal,isSavePostion,isIndependModal);
			money.show();
		}
		private function ioerrorHandler(e:IOErrorEvent):void
		{
			log.debug("::ioerrorHandler  出错。",e.toString());
		}
		private function statusHandler(e:HTTPStatusEvent):void
		{
			log.debug("::statusHandler status ", e.status);
		}
		
		private var log:Logger = Logger.getLog("rechargeControler");
		public function sendPayEvent(str:String):void{
			log.debug("充值",LoginData.obj.pid)
			switch(LoginData.obj.pid)
			{
				case LoginData.IAPIOS:
					payAPP(str,resElement.payStr);
					break;
				default:
					pay(resElement.gameGlodName,resElement.gameGlodPercent,int(str),"",resElement.type);
					break;
			}
		}
		public function setCloseBtnHide(boo:Boolean):void{
			money._closeBtn.visible=boo;
		}
		/**
		 * 购买黄金 
		 * @param name	商品名
		 * @param num  用户选择的充值个数
		 * @param des  描述，由客户端和服务器端一起制定，一般传指定加密方式的用户id
		 * 
		 */		
		public function pay(name:String,per:Number,num:int,des:String,type:int=0):void{
			// 服务器id + 角色名字 + 360accesstoken+360回调地址 + 自定义参数
			log.debug("RechargeControler:",name, per, num * per, des,type);
			des = LoginData.obj.server_id+","+LoginData.obj.rolename +","+LoginData.obj.accesstoken +","+LoginData.obj.callbackcheckaddress + ","+des;
			log.debug("RechargeControler:",name, per, num * per, des,type);
			charge.webBuy(name, per, num, des);
		}
		/**
		 * appstore充值 
		 * @param num     net.giantmobile.oncient.pay6
		 * @param payStr  net.giantmobile.oncient.pay
		 */		
		public function payAPP(num:String,payStr:String):void{
			log.debug("appstore充值",num,payStr);
			charge.iapBuy(num,payStr);
		}
		/**
		 * 获取时间 
		 * @return 
		 * 
		 */		
		private function getTime():String{
			var timeStr:String;
			var date:Date=new Date();
			var year:int = date.fullYear;
			var month:int=date.month+1;
			var day:int=date.date;
			var hours:int=date.hours+1;
			var minutes:int=date.minutes+1;
			var seconds:int=date.seconds;
			
			timeStr = year.toString();
			if(month<9){
				timeStr += "0"+month.toString();
			}else{
				timeStr += month.toString();
			}
			
			if(day<9){
				timeStr += "0"+day.toString();
			}else{
				timeStr += day.toString();
			}
			
			if(hours<9){
				timeStr += "0"+hours.toString();
			}else{
				timeStr += hours.toString();
			}
			
			if(minutes<9){
				timeStr += "0"+minutes.toString();
			}else{
				timeStr += minutes.toString();
			}
			
			if(seconds<9){
				timeStr += "0"+seconds.toString();
			}else{
				timeStr += seconds.toString();
			}
			return timeStr;
		}
		public function destory():void{
			if(money){
				money.dispose();
				money=null;
				dispatchEvent(new Event("PayClose"));
			}
		}
	}
}