package
{
	import potato.designer.net.NetConst;

	public function log(...args):void
	{
		trace.apply(null, args);
		
		var s:String = "";
		for each(var i:String in args)
		{
			s += i + " ";
		}
		
		Main.instance.connection.send(NetConst.C2S_LOG, s);
		
		
	}
}