package
{
	import core.events.Event;
	
	import potato.designer.framework.EventCenter;

	public function log(...args):void
	{
		trace.apply(null, args);
		
		var s:String = "";
		for each(var i:String in args)
		{
			s += i + " ";
		}
		
		EventCenter.dispatchEvent(new Event(EventCenter.EVENT_LOG));
		
		
//		Main.instance.connection.send(NetConst.C2S_LOG, s);
		
		
	}
}