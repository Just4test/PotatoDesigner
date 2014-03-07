package potato.ui
{
	
	import potato.events.GestureEvent;
	
	
	/**
	 * 原因一：
	 *	在《命运》中发现设计对此组建还是情有独钟，
	 *	 故此将用在《命运》中的CheckBox移植进土豆库；
	 * 原因二：
	 * 	由于大家一直不太建议用复选框，甚至都没有该组建，
	 * 	导致设计中有用到的时候大家在用Button当作复选框来使用，
	 * 	带来诸多不便；
	 * 
	 * 10月29日
	 * 支持自定义点击事件；
	 * 添加自定义变量；
	 * 
	 * @author ZW
	 * 
	 */
	public class CheckBox extends UIComponent
	{
		protected var _isSelected:Boolean = false;
		protected var _imgSq:ImageSequence;
		public var customObject:Object;
		
		/**
		 * 
		 * @imgArr		标题序列['settings_anniu_0','settings_anniu_1'],依次存放未选中与选中的素材id；
		 * @isSelect 	是否显示选中；
		 * @customLogic	是否使用自定义事件；
		 * 0:未选中
		 * 1：选中（有对勾） 
		 * 
		 */
		public function CheckBox(imgArr:Array=null, isSelect:Boolean=false,customLogic:Boolean=false)
		{
			super();
			
			_isContainer=false;
			
			//初始化UI
			imageArray=imgArr;
			
			//默认是否选中;
			selected =isSelect;
			
			if(!customLogic)this.addEventListener(GestureEvent.GESTURE_CLICK,onClickedHandler);
			
		}
		
		public function set imageArray(arr:Array):void{
			
			if(arr==null)return;
			if(_imgSq){
				removeChild(_imgSq);
				_imgSq.dispose();
				_imgSq=null;
			}
			
			addChild(_imgSq=new ImageSequence(arr));
		}
		
		
		protected function onClickedHandler(evt:GestureEvent):void
		{
			selected=!_isSelected;
		}
		
		public function get selected():Boolean{
			return _isSelected;
		}
		
		public function set selected(b:Boolean):void{
			if(_imgSq==null)return;
			_imgSq.showTextureAt(b?1:0);
			_isSelected=b;
		}
		
		override public function dispose():void
		{
			if(hasEventListener(GestureEvent.GESTURE_CLICK))
				this.removeEventListener(GestureEvent.GESTURE_CLICK,onClickedHandler);
			if(_imgSq)
				_imgSq.dispose();
			_imgSq=null;
			super.dispose();
		}
		
		
	}
}