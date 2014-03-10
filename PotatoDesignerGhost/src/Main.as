package
{
	import core.display.DisplayObjectContainer;
	import core.display.Stage;
	import core.events.Event;
	import core.events.IOErrorEvent;
	import core.net.Socket;
	import core.system.Capabilities;
	import core.system.Domain;
	
	import potato.designer.net.Connection;
	import potato.designer.net.MessageEvent;
	import potato.designer.ui.ConnectHelper;
	import potato.events.HttpEvent;
	import potato.res.Res;
	
	public class Main extends DisplayObjectContainer
	{
		protected var domain:Domain;
		public var socket:Socket
		public var socket2:Socket
		static public var connection:Connection;
		
		public function Main(arg:String = null)
		{
			
			var res:Res = new Res();
			//			res.addEventListener(HttpEvent.RES_LOAD_COMPLETE, onLoaded);
			res.appendCfg("rcfg.txt", true);
			
			var connectHelper:ConnectHelper = new ConnectHelper;
			addChild(connectHelper);
			
		}
		protected function errorHandler(event:IOErrorEvent):void
		{
			trace("[Connection] 连接出错", event);
		}
		protected function errorHandler2(event:IOErrorEvent):void
		{
			trace("[Connection] 连接2出错", event);
		}
		protected function connectHandler(e:Event):void
		{
			trace("[Connection] 连接已经建立!");
			dispatchEvent(e);
		}
		
		public function load(fileName:String):void
		{
			if(domain)
			{
				return;
			}
			domain = new Domain(Domain.currentDomain);
			domain.load(fileName);
			
		}
		
		/**
		 *卸载所有类，并保证内存得到完全回收。 
		 * 
		 */
		public function unload():void
		{
			var stage:Stage = Stage.getStage();
			while(stage.numChildren)
			{
				stage.removeChildAt(0);
			}
			
			stage.removeEventListeners();
			
			domain = null;
		}
	}
}