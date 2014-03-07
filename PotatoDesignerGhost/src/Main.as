package
{
	import core.display.DisplayObjectContainer;
	import core.display.Stage;
	import core.system.Domain;
	
	import potato.designer.net.Connection;
	import potato.designer.net.MessageEvent;
	
	public class Main extends DisplayObjectContainer
	{
		protected var domain:Domain;
		
		protected var connection:Connection;
		
		public function Main(arg:String = null)
		{
			connection = new Connection;
			connection.addEventListener("hello", helloHandler);
			connection.connect("127.0.0.1", 9999);
			function helloHandler(msg:MessageEvent):void
			{
				trace("问好消息", msg.data);
			}
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