package potato.utils
{
	import core.display.DisplayObjectContainer;
	import core.display.Quad;
	import core.display.Stage;
	import core.events.Event;
	import core.system.System;
	import core.text.TextField;
	
	import flash.utils.getTimer;
	
	import potato.ui.UIGlobal;

	/**
	 * 显示帧频等信息 
	 */	
	public class Fps extends DisplayObjectContainer
	{
		private var bg:Quad;
		private var mTextField:TextField;
		private var last:uint;
		private var ticks:uint;

		public function Fps()
		{
			bg = new Quad(500, 30, 0x77FF0000);
			this.addChild(bg);

			mTextField = new TextField("", 500, 30);
			mTextField.textColor = 0xffffff;
			mTextField.fontName = UIGlobal.defaultFont;
			mTextField.fontSize = 18;
			mTextField.vAlign = TextField.ALIGN_CENTER;
			addChild(mTextField);

			alpha = .5;
			mouseEnabled = false;
			mouseChildren = false;
			this.addEventListener(Event.ENTER_FRAME, onFrame);
		}

		public function onFrame(e:Event):void
		{
			if (last == 0)
			{
				last = getTimer();
				ticks = 0;
				return;
			}
			ticks++;
			var now:uint = getTimer();
			if (now - last >= 1000)
			{
				mTextField.text = uint((ticks * 1000 / (now - last)) * 10 + 0.5) / 10 + " fps  priv:" + (System.privateMemory >> 20) + 
							" total:" + (System.totalMemory >> 20) + 
							" free:" + (System.freeMemory >> 20) +
							" v:" + System.getVersion();
//				var t:int = (System.privateMemory >> 20) - 20;
//				mTextField.text = uint((ticks * 1000 / (now - last)) * 10 + 0.5) / 10 + " fps  total:" 
//					+ (t > 10 ? t : 10) + " M";
				
				last = now;
				ticks = 0;
			}
			Stage.getStage().addChild(this);
		}
	}
}
