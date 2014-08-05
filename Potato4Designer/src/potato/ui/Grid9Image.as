package potato.ui
{
	import flash.geom.Rectangle;
	
	import core.display.Grid9Texture;
	import core.display.Image;
	import core.display.Texture;
	import core.events.Event;
	
	import potato.res.Res;

	/**
	 * grid9图片 
	 * @author floyd
	 */
	public class Grid9Image extends Image
	{
		private var _dWidth:int;
		private var _dHeight:int;
		private var _gx:int;
		private var _gy:int;
		private var _gw:int;
		private var _gh:int;
		private var _source:String;
		private var _texture:Texture;
		private var isRender:Boolean;

		public function Grid9Image()
		{
			super(null);
			addEventListener(Event.ENTER_FRAME, render);
		}

		/**
		 * 显示宽度
		 * @return
		 */
		public function get dWidth():int
		{
			return _dWidth;
		}

		public function set dWidth(value:int):void
		{
			_dWidth = value;
			isRender = true;
		}

		/**
		 * 显示高度
		 * @return
		 */
		public function get dHeight():int
		{
			return _dHeight;
		}

		public function set dHeight(value:int):void
		{
			_dHeight = value;
			isRender = true;
		}

		public function get gx():int
		{
			return _gx;
		}

		public function set gx(value:int):void
		{
			_gx = value;
			isRender = true;
		}

		public function get gy():int
		{
			return _gy;
		}

		public function set gy(value:int):void
		{
			_gy = value;
			isRender = true;
		}

		public function get gw():int
		{
			return _gw;
		}

		public function set gw(value:int):void
		{
			_gw = value;
			isRender = true;
		}

		public function get gh():int
		{
			return _gh;
		}

		public function set gh(value:int):void
		{
			_gh = value;
			isRender = true;
		}

		public function get source():String
		{
			return _source;
		}

		public function set source(value:String):void
		{
			_source = value;
			_texture = Res.getTexture(value);
			isRender = true;
		}

		private function update():void
		{
			isRender = false;
			if (_texture)
			{
				var grid:Grid9Texture = new Grid9Texture(_texture, new Rectangle(_gx, _gy, _gw, _gh), _dWidth, _dHeight);
				texture = grid;
			}
		}

		private function render(e:Event):void
		{
			if (null != render)
				update();
		}

		override public function dispose():void
		{
			removeEventListener(Event.ENTER_FRAME, render);
			super.dispose();
		}
	}
}