package potato.display
{
	import core.display.Stage;

	public class StageProxy
	{
		public static var stage:Stage;
		public static var isRegisted:Boolean;

		private static var _curHeight:Number = 480;
		private static var _curWidth:Number = 800;
		private static var _stageWidth:Number;
		private static var _stageHeight:Number;

		public static function registed( s:Stage ):void
		{
			isRegisted = true;
			stage = s;

			_stageHeight = s.stageHeight;
			_stageWidth = s.stageWidth;
			_curHeight = _stageHeight;
			_curWidth = _stageWidth;
		}

		public static function get height():Number
		{
			return _curHeight;
		}

		public static function get width():Number
		{
			return _curWidth;
		}

		public static function set height( value:Number ):void
		{
			_curHeight = value;
		}

		public static function set width( value:Number ):void
		{
			_curWidth = value;
		}

		public static function stageHeight():Number
		{
			return _stageHeight;
		}

		public static function stageWidth():Number
		{
			return _stageWidth;
		}
	}

}