package
{
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import potato.designer.framework.deng.fzip.FZip;
	
	[SWF(width = "400",height = "300",backgroundColor="#CCCCCC")]
	public class LoadSWCExample extends Sprite
	{
		private var fZipLoader :FZip;
		
		public function LoadSWCExample() :void
		{
			fZipLoader = new FZip();
			fZipLoader.load(new URLRequest("GameCommon.swc"));
			fZipLoader.addEventListener(Event.COMPLETE, onComplete);
		}
		/**
		 *加载swc完毕
		 * @param evt
		 *
		 */        
		private function onComplete(evt:Event):void
		{
			var swfData :ByteArray = fZipLoader.getFileByName("library.swf").content;//取swf内容
			fZipLoader.removeEventListener(Event.COMPLETE, onComplete);
			
			fZipLoader  = null;
			//
			var loader :Loader = new Loader();
			loader.loadBytes(swfData,new LoaderContext(false,ApplicationDomain.currentDomain));//加载到域
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e :Event):void{
				trace("com.global.GlobalDef");
			});
		}
	}
}