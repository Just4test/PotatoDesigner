package potato.designer.plugin.ghostManager
{
	import core.events.Event;
	import core.events.IOErrorEvent;
	import core.events.TimerEvent;
	import core.system.Capabilities;
	import core.text.TextField;
	import core.utils.Timer;
	
	import potato.designer.net.Connection;
	import potato.designer.net.Message;
	import potato.designer.net.NetConst;
	import potato.events.GestureEvent;
	import potato.events.InputEvent;
	import potato.ui.Button;
	import potato.ui.TextInput;
	import potato.ui.UIComponent;
	import potato.ui.UIGlobal;

	/**
	 * 提供UI以便用户决定要连接到哪个主机。
	 * @author Administrator
	 * 
	 */
	public class ConnectHelper extends UIComponent
	{
		protected static var _instance:ConnectHelper;
		
		
//		protected var _textHost:TextField;
		protected var _textHost:TextInput;
		protected var _textAlerm:TextField;
		protected var _btnConnect:Button;
		protected var _timer:Timer;
		protected var _connection:Connection;
		
		
		protected var returnIfSuccess:Boolean;
		
		/**
		 *连接超时的时间 
		 */
		protected const TIME_OUT:int = 500;
		
		public function ConnectHelper()
		{
//			_textHost = new TextField("", 200, 30, UIGlobal.defaultFont, 32, 0xffffffff);
//			_textHost.type = TextField.INPUT;
//			_textHost.inputType = 4;
			_textHost = new TextInput("", 300, 30, UIGlobal.defaultFont, 32, 0xffffffff);
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
			
			_btnConnect = new Button("btn_up","btn_down", "连接", "btn_disable")
			_btnConnect.y = 60;
			addChild(_btnConnect);
			_btnConnect.enabled = false;
			_btnConnect.addEventListener(GestureEvent.GESTURE_CLICK, onButtonHandler);
			
			_timer = new Timer(TIME_OUT, 1);
			test();
			
		}
		
		protected function onInputChangeHandler(event:InputEvent):void
		{
			_timer.removeEventListeners();
			_timer.addEventListener(TimerEvent.TIMER, test);
			_timer.reset();
			_timer.start();
		}
		protected function onInputCompleteHandler(event:Event):void
		{
			test();
		}
		
		protected function test(e:Event = null):void
		{
			trace("正在检测");
			_textAlerm.text = "正在检测";
			if(_connection)
			{
				_connection.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_connection.removeEventListener(NetConst.S2C_HELLO, helloHandler);
				if(_connection.connected)
				{
					_connection.close();
				}
			}
			
			//目前桌面环境connect一个非法的主机路径会导致崩溃
//			_connection = new Connection;
//			_connection.addEventListener(Event.CONNECT, connectHandler);
//			_connection.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
//			_connection.addEventListener(NetConst.S2C_HELLO, helloHandler);
//			try
//			{
//				_connection.connect(_textHost.text, NetConst.PORT);
//			} 
//			catch(error:Error) 
//			{
//				_textAlerm.text = "不合法的主机路径";
//			}
			if(testIP(_textHost.text))
			{
			
				_connection = new Connection;
				_connection.addEventListener(Event.CONNECT, connectHandler);
				_connection.addEventListener(Event.CLOSE, closeHandler);
				_connection.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_connection.addEventListener(NetConst.S2C_HELLO, helloHandler);
				_connection.connect(_textHost.text, NetConst.PORT);
			}
			else
			{
				_textAlerm.text = "不合法的主机路径";
			}
			
		}
		
		protected function testIP(text:String):Boolean
		{
			if(!/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/.test(text))
			{
				return false;
			}
			
				
			for each (var s:String in text.split(".")) 
			{
				if(int(s) > 255)
				{
					return false;
				}
			}
			
			return true;
		}
		
		protected function connectHandler(event:Event):void
		{
			_timer.removeEventListeners();
			_timer.addEventListener(TimerEvent.TIMER, timeoutHandler);
			_timer.reset();
			_timer.start();
		}
		protected function closeHandler(event:Event):void
		{
			_timer.stop();
			failed();
		}
		protected function timeoutHandler(e:Event):void
		{
			failed();
		}
		
		/**
		 *接收到了服务器Hello事件，说明正确的连接到了服务器。
		 * @param event
		 * 
		 */
		protected function helloHandler(event:Message):void
		{
			connected();
			_timer.stop();
		}
		protected function errorHandler(event:IOErrorEvent):void
		{
			failed();
		}
		
		protected function connected():void
		{
			_textAlerm.text = "连接成功";
			_btnConnect.enabled = true;
		}
		
		protected function failed():void
		{
			trace("连接失败");
			_textAlerm.text = "连接失败";
			_btnConnect.enabled = false;
			
			//如果无响应则重复尝试
			_timer.removeEventListeners();
			_timer.addEventListener(TimerEvent.TIMER, test);
			_timer.reset();
			_timer.start();
		}
		
		
		protected function onButtonHandler(event:Event):void
		{
			Main.instance.setConnection(_connection);
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			parent && parent.removeChild(this);
			_instance = null;
		}
		
		

		protected static function get instance():ConnectHelper
		{
			if(!_instance)
			{
				_instance = new ConnectHelper;
			}
			
			return _instance;
		}

	}
}