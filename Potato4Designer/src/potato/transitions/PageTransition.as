package potato.transitions
{
	import core.display.DisplayObjectContainer;
	import core.events.Event;
	
	import potato.tweenlite.TweenLite;
	import potato.ui.Pages;
	import potato.ui.UIComponent;

	/**
	 * 翻页过场动画
	 * @author Floyd
	 * May 31, 2012
	 */
	public class PageTransition implements ITransition
	{
		private var timeline:DisplayObjectContainer;
		
		private var pages:Pages;
		
		private var _complete:Function;
		
		private var _ing:Function;
		
		private var tween:TweenLite;
		
		public function PageTransition()
		{
			timeline = new DisplayObjectContainer();
			
		}
		
		public var content:UIComponent;
		public function doTransition(parent:DisplayObjectContainer, complete:Function = null, ing:Function = null, args:Object = null):void
		{
			if (tween)
			{
				tween.kill();
				tween = null;
			}
			
			pages = Pages(parent);
			_complete = complete;
			_ing = ing;
			
			if(pages.isHorizontal)
			{
				var destX:int = pages.toPage * pages.displayWidth;
				tween = TweenLite.to(pages.content, .5, {x: -destX, onComplete: this.complete});
			}
			else
			{
				var destY:int = pages.toPage * pages.displayHeight;
				tween = TweenLite.to(pages.content, .5, {y: -destY, onComplete: this.complete});
			}
			
			content = pages.content;
			timeline.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		public function stopTransition():void
		{
			if (tween)
			{
				tween.kill();
			}
			complete();
		}
		
		private function complete():void
		{
			if(_complete != null)
				_complete();
			_complete = null;
			_ing = null;
			tween = null;
			
			if(content)
				trace("sectet "+content.x);
		}
		
		private function enterFrame(e:Event):void
		{
			if(_ing != null)
				_ing();
		}
	}
}