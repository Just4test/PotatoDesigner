package potato.designer.plugin.fileSync
{
	import potato.designer.net.Connection;

	public interface INativeSync
	{
		function nativeScanLocal():void;
		
		function nativeSync():void;
		
		function addEventListener(type:String, listener:Function):void
		
		function send(type:String, data:* = null, callbackHandle:Function = null):void
	}
}