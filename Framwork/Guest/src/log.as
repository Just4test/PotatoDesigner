package
{
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;

	public function log(...args):void
	{
		var s:String = "";
		for each(var i:String in args)
		{
			s += i + " ";
		}
		
		var event:DesignerEvent = new DesignerEvent(EventCenter.EVENT_LOG, s);
		EventCenter.dispatchEvent(event);
		
		if(!event.isDefaultPrevented())
		{
			trace.apply(null, args);
		}
	}
}