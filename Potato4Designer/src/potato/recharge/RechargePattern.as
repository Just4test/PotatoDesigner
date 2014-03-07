package potato.recharge
{
	import core.text.TextField;
	
	import potato.events.GestureEvent;
	import potato.events.UIEvent;
	import potato.logger.Logger;
	import potato.login.LoginData;
	import potato.ui.Button;
	import potato.ui.ButtonBar;
	import potato.ui.TextInput;
	import potato.ui.UIComponent;

	/**
	 * 充值付费 
	 * @author Administrator
	 * 
	 */	
	public class RechargePattern extends UIComponent
	{
		public var sureBtn:Button;
		private var selectBar:ButtonBar;
		private var btnSourceArr:Array=[];
		private var btnArr:Array=[];
		private var infoText:TextField;
		private var inputTxt:TextInput;
		private var value:int=10;//充值的钱数
		
		private var discount:Number=1; //折扣
		
		private var fontName:String;
		private var fontSize:uint;
		private var fontColor:uint;
		private var defaultSelect:int = 2;
		private var log:Logger = Logger.getLog("RcchargeFirstView");
		public function RechargePattern()
		{
			initView();
		}
		private var pane:JPanel;
		private function initView():void{
			btnArr=[];
			
			this.fontName=RechargeControler.getInstance().resElement.fontName;
			this.fontSize=RechargeControler.getInstance().resElement.fontSize;
			this.fontColor=RechargeControler.getInstance().resElement.fontColor;
			
			
			pane=new JPanel(JPanel.HORIZONTAL,2);
			var titleTxt:TextField=new TextField(RechargeControler.getInstance().resElement.languageTextArrar[10],195,24,fontName,fontSize,fontColor)
			pane.append(titleTxt);
			
			infoText=new TextField("",535,24,fontName,20,0x2fb705);
			this.addChild(infoText);
			showInfo(value);
			infoText.x=20;
			infoText.y=240;
			var txt:TextField;
			log.debug("进入什么充值",LoginData.obj.pid)
			switch(LoginData.obj.pid)
			{
				case LoginData.IAPIOS:
					log.debug("进入ipad充值");
					pane.append(new TextField(RechargeControler.getInstance().resElement.languageTextArrar[8],170,24,fontName,fontSize,0xdcca06));
					txt = new TextField(RechargeControler.getInstance().resElement.languageTextArrar[9],300,24,fontName,fontSize,fontColor);
					btnSourceArr=RechargeControler.getInstance().resElement.rechargeNum;
					titleTxt.visible=false;
					infoText.visible=false;
					break;
				case "mobilemmandroid":
					pane.append(new TextField(RechargeControler.getInstance().resElement.languageTextArrar[8],170,24,fontName,fontSize,0xdcca06));
					txt = new TextField(RechargeControler.getInstance().resElement.languageTextArrar[9],300,24,fontName,fontSize,fontColor);
					btnSourceArr = RechargeControler.getInstance().resElement.glodNameArr;
					value=1000;
					showInfo(1000);
					break;
				case "youmiadnroid":
					//有米充值金额选项在sdk中选择 游戏内面板不可选
					pane.append(new TextField(RechargeControler.getInstance().resElement.languageTextArrar[9],170,24,fontName,fontSize,0xdcca06));
					btnSourceArr=[];
					value=100;
					showInfo(100);
					break;
				default:
					pane.append(new TextField(RechargeControler.getInstance().resElement.languageTextArrar[8],170,24,fontName,fontSize,0xdcca06));
					txt = new TextField(RechargeControler.getInstance().resElement.languageTextArrar[9],300,24,fontName,fontSize,fontColor);
					btnSourceArr=RechargeControler.getInstance().resElement.glodNameArr;
					value=10000;
					showInfo(10000);
					break;
			}
			this.addChild(pane);
			pane.x=20;
			if(txt){
				this.addChild(txt);
				txt.x=20;
				txt.y=40;
			}
			
			var k:int=0;
			var selectBg:String=RechargeControler.getInstance().resElement.selectBtn;
			if(LoginData.obj.pid==LoginData.IAPIOS){
				for(var j:int=0;j<6;j++){
					var ipaBtn:Button=new Button("appRecharge_"+j.toString(),"appRecharge_"+j.toString());
//					var ipaBtn:Button=new Button("pay_down","pay_up");
					ipaBtn.name="btn"+j;
					ipaBtn.addEventListener(GestureEvent.GESTURE_CLICK,onSureChongzhi);
					btnArr.push(ipaBtn);
					if(j%2==0 && j!=0){
						k++;
					}
					ipaBtn.x=50 + (j%2)*250//(ipaBtn.width+10)+40;
					ipaBtn.y=70 + k*100//(ipaBtn.height+10)+10;
					this.addChild(ipaBtn);
				}
			}else{
				selectBar=new ButtonBar(false);
				selectBar.addEventListener(UIEvent.CHANGE,onChangeButtonBar);
				for(var i:int=0,m:int=btnSourceArr.length;i<m;i++){
					var btn:Button=new Button(selectBg+"_up",selectBg+"_down");
					btn.name = "btn" + i;
					var txtMoney:TextField=new TextField(btnSourceArr[i],120,30,"yh",20,0xa9996d);
					btn.addChild(txtMoney);
					txtMoney.x=34;
					txtMoney.y=6;
					selectBar.addButton(btn);
					btnArr.push(btn);
					if(i%3==0 && i!=0){
						k++;
					}
					btn.x=(i%3)*160;
					btn.y=k*50;
					if(i == RechargeControler.getInstance().resElement.disSelect)//使其有默认显示值
					{
						value = parseInt(btnSourceArr[i]);
						showInfo(value);
					}
				}
				this.addChild(selectBar);
				selectBar.x=20;
				selectBar.y=90;
				selectBar.select(RechargeControler.getInstance().resElement.disSelect);
				
			}
			var buttonBg:String=RechargeControler.getInstance().resElement.buttonBg;
			sureBtn=new Button(buttonBg+"_up",buttonBg+"_down",RechargeControler.getInstance().resElement.languageTextArrar[7],buttonBg+"_dis");
			sureBtn.setTextStyle(RechargeControler.BUTTONTEXTSTYLE);
			sureBtn.addEventListener(GestureEvent.GESTURE_CLICK,onSureChongzhi);
			this.addChild(sureBtn);
			sureBtn.x=360;
			sureBtn.y=280;
			if(LoginData.obj.pid==LoginData.IAPIOS){
				sureBtn.visible=false;
			}
		}
		private function checkInput(s:String):Boolean
		{
			if(inputTxt.text.length > 6)
				return false;
			var reg:RegExp =/[0-9]/;
			return reg.test(s);
		}
		private function onChangeButtonBar(e:UIEvent):void{
			value=parseInt(btnSourceArr[selectBar.getSelectIndex((selectBar.selectBtn[0])as Button)]);
			showInfo(value);
		}
		private function onSureChongzhi(e:GestureEvent):void{
			var str:String;
			if(LoginData.obj.pid ==LoginData.IAPIOS){
				RechargeControler.getInstance().resElement.loadingStart();
				switch(e.currentTarget.name)
				{
					case "btn0":
					{
						str = RechargeControler.getInstance().resElement.payStr +RechargeControler.getInstance().resElement.rechargeNum[0];
						break;
					}
					case "btn1":
					{
						str = RechargeControler.getInstance().resElement.payStr+RechargeControler.getInstance().resElement.rechargeNum[1];
						break;
					}
					case "btn2":
					{
						str = RechargeControler.getInstance().resElement.payStr+RechargeControler.getInstance().resElement.rechargeNum[2];
						break;
					}
					case "btn3":
					{
						str =RechargeControler.getInstance().resElement.payStr +RechargeControler.getInstance().resElement.rechargeNum[3];
						break;
					}
					case "btn4":
					{
						str =RechargeControler.getInstance().resElement.payStr +RechargeControler.getInstance().resElement.rechargeNum[4];
						break;
					}
					case "btn5":
					{
						str =RechargeControler.getInstance().resElement.payStr +RechargeControler.getInstance().resElement.rechargeNum[5];
						break;
					}
				}
			}else{
				str = value.toString();
			}
			log.debug("购买多少",str)
			RechargeControler.getInstance().sendPayEvent(str);
		}
		private function showInfo(num:int):void{
			
			var per:Number=RechargeControler.getInstance().resElement.gameGlodPercent;
			var name:String=RechargeControler.getInstance().resElement.gameGlodName;
			var currency:String = RechargeControler.getInstance().resElement.languageTextArrar[11];
			log.debug("换算",num*per,"单价",per,"个数",num)
			txtInfoShow=num+name+"  等于  "+num*per+currency;
		}
		private function set txtInfoShow(str:String):void{
			infoText.htmlText="<strong><noshade>"+str+"</noshade></strong>";
		}
		private function getDou(v:Number):Number{
			return v+10*(1-(discount*1));
		}
		public function destroy():void{
			super.dispose();
			for(var i:* in btnArr){
				if(btnArr[i]){
					if(LoginData.obj.pid!=LoginData.IAPIOS){
						selectBar.removeButton(btnArr[i]);
					}else{
						btnArr[i].removeEventListener(GestureEvent.GESTURE_CLICK,onSureChongzhi);
					}
					btnArr[i].dispose();
					btnArr[i]=null;
				}
			}
			btnArr=null;
				
			sureBtn.removeEventListener(GestureEvent.GESTURE_CLICK,onSureChongzhi);
			if(selectBar )
			{
				selectBar.removeEventListener(UIEvent.CHANGE,onChangeButtonBar);
				selectBar.dispose();
				selectBar=null;
			}
			pane.dispose();
			pane=null;
		}
	}
}