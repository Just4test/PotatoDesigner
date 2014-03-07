package potato.recharge
{
	import core.display.DisplayObject;
	
	import potato.ui.UIComponent;
	
	
	public class JPanel extends UIComponent
	{
		private var mPad:UIComponent;
		public static const HORIZONTAL:String="horizontal";
		public static const VERTICAL:String ="vertical";
		
		private var space:int=10;
		
		private var direction:String;
		/**
		 * 1：左对齐
		 * 2：右对齐
		 * 3:居中对齐
		 */		
		private var algin:int=1;
		
		private var itemArr:Array=[];
		
		public function JPanel(d:String=JPanel.VERTICAL,sp:int=10,a:int=1)
		{
			space=sp;
			direction=d;
			algin=a;
			mPad=new UIComponent();
			this.addChild(mPad);
		}
		/**
		 * 手动设置指定容器内的显示对象 
		 * @param _x
		 * @param _y
		 * 
		 */		
		public function setPoint(_x:Number,_y:Number):void{
			mPad.x=_x;
			mPad.y=_y;
		}
		/**
		 * 添加显示对象到容器 
		 * @param item
		 * 
		 */		
		public function append(item:DisplayObject):void{
			if(itemArr.length>0){
				switch(direction){
					case JPanel.HORIZONTAL:
						item.x=itemArr[itemArr.length-1].x+itemArr[itemArr.length-1].width+space;
						break;
					case JPanel.VERTICAL:
						item.y=itemArr[itemArr.length-1].y+itemArr[itemArr.length-1].height+space;
						break;
				}
				
			}
			mPad.addChild(item);
			itemArr.push(item);
			if(algin==2 || algin==3){
				alginItem();
			}
		}
		public function alginItem():void{
			var w:Number=0;
			var item:*;
			for each(item in itemArr){
				if(w<item.width){
					w=item.width;
				}
			}
			
			for each(item in itemArr){
				if(algin==2){
					item.x=w-item.width;
				}else if(algin==3){
					item.x=(w-item.width)/2;
				}
			}
			
		}
		override public function dispose():void{
			super.dispose();	
			for each(var k1:* in itemArr)
			{   
				k1.dispose();
				k1 = null;
			}
			if(mPad){
				mPad.removeChildren();
				mPad.dispose();
				mPad=null;
			}
			itemArr=null;
		}
	}
}