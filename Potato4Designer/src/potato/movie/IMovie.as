package potato.movie
{
	/**
	 * 动画接口
	 */	
	public interface IMovie
	{
		function play():void;
		function stop():void;
		function gotoAndStop(frame:int):void;
		function gotoAndPlay(frame:int):void;
		function get totalFrames():int;
	}
}