package potato.events.gesture.tools
{
	import core.events.TouchEvent;
	
	import flash.geom.Point;
	import flash.sampler.NewObjectSample;

	public class GesturePoint
	{
		public var local:Point = new Point(0,0);
		public var stage:Point = new Point(0,0);
		public var touchPointID:int = 0;
		public function GesturePoint(event:TouchEvent = null)
		{
			if(event){
				local.x = event.localX;
				local.y = event.localY;
				stage.x = event.stageX;
				stage.y = event.stageY;
				touchPointID = event.touchPointID;
				event = null;
			}
			
		}
	}
}