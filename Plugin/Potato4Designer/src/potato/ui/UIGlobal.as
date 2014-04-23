package potato.ui
{
	import core.display.Image;
	import core.display.Shape;
	import core.display.Texture;
	import core.display.TextureData;
	import core.filters.BorderFilter;
	import core.filters.ColorMatrixFilter;
	import core.filters.Filter;
	import core.filters.ShadowFilter;
	import core.system.Capabilities;
	import core.text.Font;
	
	import potato.events.gesture.Gesture;
	
	/**
	 * 
	 * @author Floyd
	 * May 17, 2012
	 */
	public class UIGlobal
	{
		/**当前是否可以横向拖动*/
		public static var hDrag:Boolean = true;
		/**当前是否可以纵向拖动*/
		public static var vDrag:Boolean = true;
		
//		/**移动超过这个距离确定 移动方向*/
//		public static var moveSize:int = 30;
//		
		/**默认使用字体*/
		public static const defaultFont:String = "yh";
		/**默认使用字体大小*/
		public static const FONTSIZE:int = 24;
		/**20号字体大小**/
		public static const FONTSIZE20:int = 20;
		/**使用最小字体大小**/
		public static const MINFONTSIZE:int = 18;
		{ //注册字体
			Font.registerFont("asset/yh.ttf", defaultFont);
		}
		
		
//		/**点击、拖动。最大偏移量*/
//		public static var ACTION_OFFECT:int = 10;
//		
		/**
		 * 超过当前时间为长按（毫秒）
		 */
		public static const LONG_PRESS_TIME:int = 250;
		
		/**
		 * 多点触摸时 单指触摸间隔时间 手势开始事件  
		 */
		static public const MULTI_BEGIN_TIME:int = 100;
		
		/**
		 * 多点触摸时 单指抬起间隔时间 手势结束事件
		 */
		static public const MULTI_END_TIME:int = 100;
		
		static public const GESTURE_CLCIK_DISTANCE:int = 20; 
		/**
		 *移动事件触发距离 
		 */		
		static public const GESTURE_MOVE_DISTANCE:int = 5;
		
		/**
		 * 滑动过程中用来收集计算滑动的力量的点个数。
		 */		
		public static var SLIDE_SMAPLE_COUNT:int = 5;
		/**
		 *手势滑动事件开关 
		 */		
		public static var GESTURE_SLIDE_EVENT_FLAG:Boolean = true;
		/**
		 *手势移动事件 单体拖动时panel组件禁止跟随移动 
		 */		
		public static var GESTURE_PANEL_DRAG_FLAG:Boolean = true;
		
		//布局属性
		public static const LEFT:String = "left";
		public static const TOP:String = "top";
		public static const RIGHT:String = "right";
		public static const BOTTOM:String = "bottom";
		public static const CENTER:String = "center";
		
		//设备DPI
		static public const DENSITY_LOW:int = 120;
		static public const DENSITY_MEDIUM:int = 160;
		static public const DENSITY_HIGH:int = 240;
		static public const DENSITY_TV:int = 213;
		static public const DENSITY_XHIGH:int = 320;
		
		
		// 文字滤镜
		static public var TEXT_DROP_SHADOW:Filter = new ShadowFilter(0xff000000, 1, 1, false);
		// 可接任务滤镜效果
		static public const TASK_FILTER_ACCEPTABLE:Filter = new ColorMatrixFilter(Vector.<Number>([0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0]));
		static public const FILTER_BLACK_WHITE:Filter = new ColorMatrixFilter(Vector.<Number>([0.2225, 0.7169, 0.0606, 0, 0, 0.2225, 0.7169, 0.0606, 0, 0, 0.2225, 0.7169, 0.0606, 0, 0, 0, 0, 0, 1, 0]));
		
		/** 文字阴影 */
		public static const FILTER_TEXT_SHADOW:ShadowFilter = new ShadowFilter(0xff000000,2,2,false);
		/** 文字边缘描边*/
		public static const FILTER_TEXT_BORDER:BorderFilter = new BorderFilter(0xff000000,1,false);
		/** 灰色图片滤镜*/
		public static const FILTER_IMG_GRAY:ColorMatrixFilter=new ColorMatrixFilter(Vector.<Number>([0.4,0.4,0.4,0,0, 0.4,0.4,0.4,0,0, 0.4,0.4,0.4,0,0, 0,0,0,1,0]));

		//color
		/**青色*/
		static public var COLOR_CYAN:uint = 0xFF34C0FA;
		/**紫色*/
		static public var COLOR_PURPLE:uint = 0xC24FFD;
		/**黄色*/
		static public var COLOR_YELLOW:uint = 0xFFFFE051;
		//绿色
		static public var COLOR_GREEN :uint = 0xFF20EF4C;
		//蓝色
		static public var COLOR_BLUE:uint = 0x3888E9;
		//橙色
		static public var COLOR_ORANGE:uint = 0xFF6600;
		//红色
		static public var COLOR_RED:uint = 0xFFFF0000;
		//金色
		static public var COLOR_GLOD:uint = 0xFFFCFFA9;
		//粉色
		static public var COLOR_PINK:uint = 0xFFff305c;
		//白色
		static public var COLOR_WHITE:uint = 0xFFFFFFFF;
		//青蓝
		static public var COLOR_HALO_BLUE:uint = 0xFFC3EFD8;
		//灰色
		static public const COLOR_HUISE:uint = 0xFFfef98b;
		/**库内声音开关*/
		public static var sound:Boolean = true;
		/**
		 *绘制一个单颜色矩形 
		 * @param width
		 * @param height
		 * @param color
		 * @return 
		 * 
		 */		
		static public function getRectShape(width:int,height:int,color:uint):Image{
			
			var _shape:Shape = new Shape();
			_shape.graphics.beginFill(color);
			_shape.graphics.drawRect(0,0,width,height);
			_shape.graphics.endFill();
			var textureData:TextureData = TextureData.createRGB(width, height, true, 0);
			textureData.draw(_shape);
			_shape.graphics.clear();
			_shape = null;
			return new Image(new Texture(textureData));
			
		}
		/**
		 *设定手指滑动后 关闭手势事件的滑动距离 
		 * 
		 */		
		static public function setTouchOffLen():void{
			
			_dpi = (Capabilities.screenXDPI + Capabilities.screenYDPI)/2;
			
			if(_dpi <= DENSITY_LOW){
				Gesture.TOUCH_OFF_LENGTH = 30;
			}else if(_dpi > DENSITY_LOW && _dpi <= DENSITY_MEDIUM){
				Gesture.TOUCH_OFF_LENGTH = 35;
			}else if(_dpi > DENSITY_MEDIUM && _dpi <= DENSITY_HIGH){
				Gesture.TOUCH_OFF_LENGTH = 40;
			}else if(_dpi > DENSITY_HIGH && _dpi <= DENSITY_XHIGH){
				Gesture.TOUCH_OFF_LENGTH = 45;
			}else{
				Gesture.TOUCH_OFF_LENGTH = 50;
			}
		}
		
		static private var _dpi:int = 0;
		/**
		 *得到设备当前DPI 
		 * @return 
		 * 
		 */		
		static public function getScrenDPI():int{
			
//			return 333;
			if(_dpi != 0){
				return _dpi;
			}
			else{
				_dpi = (Capabilities.screenXDPI + Capabilities.screenYDPI)/2;
				return _dpi;
			}
		}
	}
}