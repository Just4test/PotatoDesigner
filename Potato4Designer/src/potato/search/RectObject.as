package potato.search
{
	import flash.geom.Point;

	public interface RectObject
	{
		function get point():Point;
		function update():void;
		function get width():Number;
		function get height():Number;
	}
}