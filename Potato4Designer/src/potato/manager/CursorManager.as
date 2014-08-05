package potato.manager
{
	import core.display.Stage;
	import core.system.Capabilities;
	
	import potato.events.GestureEvent;
	import potato.ui.UIComponent;
	
//	import sf.movie.Movie;
//	import sf.utils.Utils;

	/**
	 * 光标管理
	 * @author Floyd
	 * Jun 6, 2012
	 */
	public class CursorManager
	{
		/**光标动画*/
//		private static var cursor:Movie;
		/**获得最后一次按下X*/
		public static var lastTouchX:int;
		/**获得最后 一次按下Y*/
		public static var lastTouchY:int;
		
		/**最后移动的位置x*/
		public static var lastMoveX:int;
		/**最后移动的位置y*/
		public static var lastMoveY:int;
		/**
		 * 初始化光标管理类
		 * @st 舞台，必须为UIComponent对象
		 */		
		public static function initManager(st:UIComponent):void {
			st.addEventListener(GestureEvent.GESTURE_DOWN, begin);
		}
		
		/**
		 * 设置光标按下之后会执行playCursor()
		 * @param movieName
		 * @param action
		 */
		public static function setCursor(movieName:String):void
		{
//			if(Capabilities.version == "dev")
//				return;
//			if (cursor)
//			{
//				if (cursor.parent)
//					cursor.parent.removeChild(cursor);
//				cursor.dispose();
//				cursor.removeEventListener(TouchEvent.TOUCH_BEGIN, begin);
//			}
//
//			cursor = new Movie(movieName);
//			cursor.mouseEnabled = false;
//			cursor.mouseChildren = false;
//			cursor.playComplete = playComplete;
//			cursor.gotoAndStop(1);
//			
//			Stage.getStage().addEventListener(TouchEvent.TOUCH_BEGIN, begin);
		}

		/**
		 * 手动播放光标动画 
		 * @param x		在舞台上的x
		 * @param y		舞台上的y
		 */		
		public static function playCursor(x:int, y:int):void
		{
//			if (cursor)
//			{
//				if(x && y)
//				{
//					cursor.gotoAndPlay(1);
//					Stage.getStage().addChild(cursor);
//					cursor.x = x ;
//					cursor.y = y ;
//				}
//			}
		}

		private static function playComplete():void
		{
//			if (cursor.parent)
//				cursor.parent.removeChild(cursor);
//
//			cursor.gotoAndStop(1);
		}

		private static function begin(e:GestureEvent):void
		{
			lastTouchX = e.stageX;
			lastTouchY = e.stageY;
			playCursor(lastTouchX, lastTouchY);
			
		}
	}
}