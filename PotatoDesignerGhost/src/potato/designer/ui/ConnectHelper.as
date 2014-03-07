package potato.designer.ui
{
	import core.events.Event;
	import core.events.IOErrorEvent;
	import core.events.TextEvent;
	import core.events.TimerEvent;
	import core.system.Capabilities;
	import core.text.TextField;
	import core.utils.Timer;
	
	import potato.designer.net.Connection;
	import potato.designer.net.MessageEvent;
	import potato.designer.net.NetConst;
	import potato.events.InputEvent;
	import potato.ui.Button;
	import potato.ui.TextInput;
	import potato.ui.UIComponent;
	import potato.ui.UIGlobal;
	import potato.utils.KeyboardConst;

	/**
	 * 提供UI以便用户决定要连接到哪个主机。
	 * @author Administrator
	 * 
	 */
	public class ConnectHelper extends UIComponent
	{
//		protected var _textHost:TextField;
		protected var _textHost:TextInput;
		protected var _textAlerm:TextField;
		protected var _btnConnect:Button;
		protected var _timer:Timer;
		protected var _connection:Connection;
		
		public function ConnectHelper()
		{
//			_textHost = new TextField("", 200, 30, UIGlobal.defaultFont, 32, 0xffffffff);
//			_textHost.type = TextField.INPUT;
//			_textHost.inputType = 4;
			_textHost = new TextInput("", 200, 30, UIGlobal.defaultFont, 32, 0xffffffff);
			_textHost.addEventListener(InputEvent.INPUT_CHANGE, onInputChangeHandler);
			_textHost.addEventListener(InputEvent.INPUT_COMPLETE, onInputCompleteHandler);
			addChild(_textHost);
			
			//确定系统版本
			if(Capabilities.version.indexOf("WIN") != -1)
			{
				_textHost.text = "127.0.0.1";
			}
			
			
			_textAlerm = new TextField("错误信息", 200, 30, UIGlobal.defaultFont, 16, 0xff0000);
			_textAlerm.y = 40;
			addChild(_textAlerm);
			
			_timer = new Timer(500, 1);
			_timer.addEventListener(TimerEvent.TIMER, testHost);
			
			_connection = new Connection;
//			_connection.addEventListener(Event.CONNECT, connectHandler);
			_connection.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_connection.addEventListener(NetConst.S2C_HELLO, helloHandler);
			
		}
		
//		protected function onTextInputHandler(event:TextEvent):void
//		{
//			var key:uint = event.text.charCodeAt(0);
//			if(KeyboardConst.ENTER == key)
//			{
//				testHost();
//			}
//			else
//			{
//				_timer.stop();
//				_timer.start();
//			}
//		}
		protected function onInputChangeHandler(event:InputEvent):void
		{
			testHost();
		}
		protected function onInputCompleteHandler(event:Event):void
		{
			_timer.stop();
			_timer.start();
		}
		/**
		 *接收到了服务器Hello事件，说明正确的连接到了服务器。
		 * @param event
		 * 
		 */
		protected function helloHandler(event:MessageEvent):void
		{
			_textAlerm.text = "连接成功";
		}
		protected function errorHandler(event:IOErrorEvent):void
		{
			_textAlerm.text = "连接失败";
		}
		
		protected function testHost(e:Event = null):void
		{
			_connection.close();
			_textAlerm.text = "正在检测";
			try
			{
				_connection.connect(_textHost.text, NetConst.PORT);
			} 
			catch(error:Error) 
			{
				_textAlerm.text = "不合法的主机路径";
			}
		}
	}
}