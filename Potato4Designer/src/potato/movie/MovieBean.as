package potato.movie
{
	/**
	 * 配置文件bean
	 * @author Floyd
	 * Jun 6, 2012
	 */
	public class MovieBean
	{
		/**动画名*/
		public var movieName:String;
		/**方向数*/
		public var dirNumber:int = 1;
		/**关键帧数量，即需要换图片的帧*/
		public var frameNumber:int;
		/**播放速度*/
		public var speed:int;
		/**设置基准点X*/
		public var footX:int;
		/**设置基准点Y*/
		public var footY:int;
		
		/**
		 *  当前动画影片的缩放系数，它直接影响当前实例的 scaleX 和 scaleY
		 */
		public var scale:Number;

		/**
		 * 图片播放帧数,  第n帧延时 = frameArr[n] * speed
		 * 当为负数时，表示该帧为空白帧，绝对值表示帧的延长时间
		 */		
		public var frameArr:Array;
		
		/**全部帧，不需要在配置文件中配置 */
		public var allFrame:int;

		
//		public var inited:Boolean;
		public function MovieBean()
		{
		}
	}
}