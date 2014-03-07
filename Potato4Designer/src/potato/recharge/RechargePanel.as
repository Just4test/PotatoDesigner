package potato.recharge
{
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	import core.display.Image;
	import core.events.Event;
	import core.text.TextField;
	
	import potato.events.GestureEvent;
	import potato.login.LoginData;
	import potato.ui.Button;
	import potato.ui.Dialog;
	import potato.ui.UIComponent;
	
	public class RechargePanel extends UIComponent
	{
		private var bg:Image;
		public var frame:Dialog;
		private var container:UIComponent;
		private var mpad:UIComponent;
		public var fistView:RechargePattern;
		private var jiuyi:Button;
		private var buttonBg:String;
		private var pev:String;
		public var _closeBtn:Button;
		public function RechargePanel(name:String,screen:DisplayObjectContainer,bg:DisplayObject,title:TextField=null,closeBtn:Button=null,modal:Boolean=false,isSavePostion:Boolean=true,isIndependModal:Boolean=true)
		{
			this.container=new UIComponent();
			_closeBtn=closeBtn;
			closeBtn.x=bg.width-closeBtn.width;
			frame = new Dialog(name,screen,bg,null,closeBtn,true);
			frame.enableDrag=false;
			frame.addEventListener(Event.CLOSE,onClosedkBtn);
			frame.addChild(container);
			initView();

		}
		public function show():void{
			frame.open();
		}
		
		private function initView():void{
			
			buttonBg=RechargeControler.getInstance().resElement.buttonBg;
			var str:String;
			switch(LoginData.obj.pid)
			{
				case LoginData.IAPIOS:
					str = "RMB充值"
					break;
				case "ucandroid":
				case "ucios":
					str = "UC充值"
					break;
				case "ppandroid":
				case "ppios":
					str = "PP充值"
					break;
				case "djandroid":
				case "djios":
					str = "当乐充值"
					break;
				case "miandroid":
				case "miios":
					str = "小米充值"
					break;
				case "bdandroid":
				case "bdios":
				case "bdyxandroid":
				case "bdyxios":
				case "bdyandroid":
				case "bdyios":
					str = "百度充值"
					break;
				case "wanandroid":
				case "wanios":
					str = "37wan充值"
					break;
				case "ppsandroid":
				case "ppsios":
					str = "PPS充值"
					break;
				case "wdjandroid":
				case "wdjios":
					str = "豌豆荚充值"
					break;
				case "yyhandroid":
				case "yyhios":
					str = "应用会充值"
					break;
				case "cmgeandroid":
				case "cmgeios":
					str = "中手游充值"
					break;
				case "pptvandroid":
				case "pptvios":
					str = "PPTV充值"
					break;
				case "pipawandroid":
				case "pipawios":
					str = "琵琶网充值"
					break;
				case "qihuandroid":
				case "qihuios":
					str = "奇虎360充值"
				case "youmiandroid":
				case "youmiios":
					str = "偶玩充值"
					break;
				case "app49android":
				case "app49ios":
					str = "49app充值"
					break;
				case "gfanandroid":
				case "gfanios":
					str = "机锋充值"
					break;
				case "kuaiyongandroid":
				case "kuaiyongios":
					str = "快用充值"
					break;
				case "itoolsandroid":
				case "itoolsios":
					str = "iTools充值"
					break;
				case "tongbuandroid":
				case "tongbuios":					
					str = "同步推充值"
					break;
				case "anzhiandroid":
				case "anzhiios":
					str = "安智网充值"
					break;
				case "shandagamesandroid":
				case "shandagamesios":
					str = "盛大充值"
					break;
				case "huaweiandroid":
				case "huaweiios":
					str = "华为充值"
					break;
				case "fiveoneandroid":
				case "fiveoneios":
					str = "51充值"
					break;
				case "oppoandroid":
				case "oppoios":
					str = "oppo充值"
					break;
				case "ndandroid":
				case "ndios":
					str = "91充值"
					break;
				default:
					str = "充值";
					break;
			}
			jiuyi=new Button(buttonBg+"_up",buttonBg+"_down","",buttonBg+"_dis");
//			jiuyi.setTextStyle(RechargeControler.BUTTONTEXTSTYLE);
			jiuyi.name="recharge_jiuyi1";
			jiuyi.addEventListener(GestureEvent.GESTURE_CLICK,onChangeView);
			container.addChild(jiuyi);
			
			var jiuyiText:TextField = new TextField(str,jiuyi.width,jiuyi.height,"yh",22,0xffffffb5);
			jiuyiText.hAlign = TextField.ALIGN_CENTER;
			jiuyiText.vAlign = TextField.ALIGN_CENTER;
			jiuyi.x=45;
			jiuyi.y=120;
			jiuyi.addChild(jiuyiText);
			changeView(1);
		}
		private function onChangeView(e:GestureEvent):void{
			var crtNameString:String = e.currentTarget.name;
			switch(crtNameString){
				case "recharge_lishi1":
					changeView(2);
					break;
				case "recharge_jiuyi1":
					changeView(1);
					break;
			}
		}
		/**
		 * 切换界面 
		 * @param type
		 * 
		 */		
		private function changeView(type:int):void{
			if(mpad){
				container.removeChild(mpad);
				mpad=null;
			}
			switch(type){
				case 1:
					if(!fistView){
						fistView=new RechargePattern();
					}
					mpad=fistView;
					break;
				case 2:
//					if(!secondView){
////						secondView=new RechargeHistory();
//					}
//					secondView.show();
//					mpad=secondView;
					break;
			}
			container.addChild(mpad);
			mpad.x=230;
			mpad.y=100;
		}
		private function onClosedkBtn(e:Event=null):void
		{
			if(mpad){
				mpad.dispose();
				mpad=null;
			}
			if(fistView){
				fistView.destroy();
				fistView=null;
			}
//			if(secondView){
//				secondView=null;
//			}
			if(container){
				container.dispose();
				container=null;
			}
//			lishiBtn.removeEventListener(GestureEvent.GESTURE_CLICK,onChangeView);
			jiuyi.removeEventListener(GestureEvent.GESTURE_CLICK,onChangeView);
			frame.removeEventListener(Event.CLOSE,onClosedkBtn);
			frame.dispose();
			frame=null;
			RechargeControler.getInstance().destory();
			_closeBtn=null;
		}
	}
}