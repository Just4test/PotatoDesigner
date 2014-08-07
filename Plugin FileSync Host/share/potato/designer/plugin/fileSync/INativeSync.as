package potato.designer.plugin.fileSync 
{
	public interface INativeSync
	{
		function nativeScanLocal():void;
		
		function nativeSync():void;
	}
}