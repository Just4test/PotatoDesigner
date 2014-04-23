package potato.recharge
{
	import core.display.Quad;
	import core.text.TextField;
	
	import potato.logger.Logger;
	import potato.pay.OrderInfo;
	import potato.pay.Recharge;
	import potato.ui.Panel;
	import potato.ui.UIComponent;
	import potato.utils.Utils;

	/**
	 * 充值历史记录
	 * 记录中只显示成功的单子，不成功的单子会自动去轮询 
	 * @author Administrator
	 * 
	 */	
	public class RechargeHistory extends UIComponent
	{
		private var dataArr:Array=[];
		private var popTxt:TextField;
		private var pane:JPanel;
		private var mPad:Panel;
		
		private var fontName:String;
		private var fontSize:uint;
		private var fontColor:uint;
		public function RechargeHistory()
		{
			this.fontName=RechargeControler.getInstance().resElement.fontName;
			this.fontSize=RechargeControler.getInstance().resElement.fontSize;
			this.fontColor=RechargeControler.getInstance().resElement.fontColor;
			
			mPad=new Panel(520,360);
			mPad.disabledLeftRightDrag=true;
			this.addChild(mPad);
			mPad.x=20;
		}
		public function show():void{
			dataArr=potato.pay.Recharge.getIns().getOrderList();
			if(popTxt && popTxt.text!="" && popTxt.parent == this){
				this.removeChild(popTxt);
			}
			if(dataArr.length==0){
				popTxt=new TextField("暂无充值记录",195,50,fontName,fontSize,fontColor);
				this.addChild(popTxt);
				popTxt.x=190;
				popTxt.y=150;
			}else{
				initList();
			}
		}
		private var log:Logger = Logger.getLog( "RechargeHistroy" );
		private function initList():void{
			if(pane && mPad){
				mPad.removeContent(pane);
				pane=null;
			}
			pane=new JPanel(JPanel.VERTICAL,15);
			log.debug( "测试是否有充值记录" );
			for each (var oi:OrderInfo in dataArr){
				if(oi.state!=6){
					continue;
				}
				var vP:JPanel=new JPanel(JPanel.VERTICAL,0);
				var p:JPanel=new JPanel(JPanel.HORIZONTAL,0);
				p.append(new TextField("充值状态：",105,24,fontName,fontSize,0xffe051)); 
				p.append(new TextField(oi.getStateName(), 175,24,fontName,fontSize,0xf0eec5));
				vP.append(p);
				
				p=new JPanel(JPanel.HORIZONTAL,0);
				p.append(new TextField("充值编号：",105,24,fontName,fontSize,0xffe051)); 
				p.append(new TextField(oi.orderCode, 420,24,fontName,fontSize,0xf0eec5));
				vP.append(p);
				
				p=new JPanel(JPanel.HORIZONTAL,0);
				p.append(new TextField("充值金额：",105,24,fontName,fontSize,0xffe051)); 
				p.append(new TextField(String(oi.price*oi.num),70,24,fontName,fontSize,0xf0eec5));
				vP.append(p);
				
				p=new JPanel(JPanel.HORIZONTAL,0);
				p.append(new TextField("充值时间：",105,24,fontName,fontSize,0xffe051)); 
				p.append(new TextField(oi.time,220,24,fontName,fontSize,0xf0eec5));
				p.append(new TextField("充值方式：",105,24,fontName,fontSize,0xffe051)); 
//				if(Utils.platformVer() == Utils.IPA_IPAD|| Utils.platformVer() == Utils.IPA_IPHONE){
//					p.append(new TextField("RMB充值",105,36,fontName,fontSize,0xf0eec5)); 
//				} else if (Utils.platformVer() == Utils.UC_IPAD|| Utils.platformVer() == Utils.UC_IPHONE|| Utils.platformVer() == Utils.UC_ANDROID) {
//					p.append(new TextField("RMB充值",105,36,fontName,fontSize,0xf0eec5)); 
//				} else if (Utils.platformVer() == Utils.PP_IPAD||Utils.platformVer() == Utils.PP_IPHONE||Utils.platformVer() == Utils.PP_ANDROID) {
//					p.append(new TextField("PP币充值",105,36,fontName,fontSize,0xf0eec5)); 
//				} else if (Utils.platformVer() == Utils.DJ_IPAD||Utils.platformVer() == Utils.DJ_IPHONE||Utils.platformVer() == Utils.DJ_ANDROID) {
//					p.append(new TextField("RMB充值",105,36,fontName,fontSize,0xf0eec5)); 
//				} else if (Utils.platformVer() == Utils.MI_IPAD||Utils.platformVer() == Utils.MI_IPHONE||Utils.platformVer() == Utils.MI_ANDROID) {
//					p.append(new TextField("米币充值",105,36,fontName,fontSize,0xf0eec5)); 
//				} else {
//					p.append(new TextField("91豆充值",105,36,fontName,fontSize,0xf0eec5)); 
//				}
				vP.append(p);
				pane.append(vP);
				var quad:Quad=new Quad(500,3,0xffa9996d);
				pane.append(quad);
			}
			mPad.addContent(pane);
		}
		public function destroy():void{
			super.dispose();
			pane.dispose();
			pane=null;
			mPad.dispose();
			mPad=null;
		}
	}
}