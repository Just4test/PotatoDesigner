package potato.designer.net
{
	import flash.utils.ByteArray;
	
	import core.events.Event;
	import core.events.EventDispatcher;
	import core.events.IOErrorEvent;
	import core.events.ProgressEvent;
	import core.net.Socket;
	
	public class Connection extends EventDispatcher
	{
		protected var _socket:Socket;
		
//		/**
//		 *指定数据包是一个应答。
//		 * 应答直接传给对应的处理函数，而不会派发事件。 
//		 */
//		protected static const HEAD_TYPE_ANSWER:int = 1;
		
//		protected static const HEAD_TYPE_CODE:int = 1;
		
		/**
		 *指示下一个发送消息的index 
		 */
		protected var _nextSendIndex:int;
		
		/**
		 *已发送且需要应答的消息index与应答句柄映射表 
		 */
		protected var _msgMap:Object;
		
		
		/**
		 *发送用的类型-短代码映射表 
		 */
		protected var _sendType2Code:Object;
		/**
		 *指示下一个可用的发送用短代码 
		 */
		protected var _nextSendTypeIndex:uint;
		
		
		
		/**
		 *接收用的短代码-类型映射表 
		 */
		protected var _receiveCode2Type:Vector.<String>;
		
		public function Connection(socket:Socket = null)
		{
			_socket = socket || new Socket;
			
			_socket.addEventListener(Event.CONNECT, connectHandler);
			_socket.addEventListener(Event.CLOSE, closeHandler);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
			
			_sendType2Code = new Object;
			_receiveCode2Type = new Vector.<String>;
		}
		
		
		public function connect(host:String, port:int):void
		{
			_socket.connect(host, port);
		}
		
		public function send(type:String, data:* = null, answerHandle:Function = null, answerIndex:uint = 0):void
		{
			//encode
			var ba:ByteArray = new ByteArray;
			//写入type
			if(undefined === _sendType2Code[type])
			{
				_sendType2Code[type] = _nextSendTypeIndex;
				
				ba.writeUnsignedInt(_nextSendTypeIndex);
				ba.writeUTF(type);
				_nextSendTypeIndex += 1;
			}
			else
			{
				ba.writeUnsignedInt(_sendType2Code[type]);
			}
			
			//写入index
			if(answerHandle)
			{
				
			}
			
			//写入answerIndex
			ba.writeUnsignedInt(answerIndex);
			
		}
		
		public function encode(code:uint, data:*):ByteArray
		{
			var ret:ByteArray = new ByteArray;
			return ret;
		}
		
		
		
		/////////////////////////////////////////////////////////////////
		
		protected function connectHandler(e:Event):void
		{
			trace
		}
		
		protected function closeHandler(e:Event):void
		{
			
		}
		
		protected function errorHandler(e:Event):void
		{
			
		}
		
		protected function dataHandler(e:Event):void
		{
			
		}
	}
}