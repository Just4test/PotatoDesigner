package potato.designer.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	/**
	 *消息结构： pkgLength:uint, typeCode:uint, [type:String,] msgIndex:uint, answerIndex:uint, data:Object
	 * pkgLength:消息除了pkgLength所占空间外剩余的长度
	 * typeCode:类型的短代码。每个短代码对应了一个类型的完整路径。注意，对于发送和接收同样的type，其短代码是不同的。
	 * type:类型的完整路径。如果第一次使用一个类型，将为其指定一个短代码，并在消息中附加完整路径
	 * msgIndex:消息的index。注意一个消息如果不需要应答，其index固定为0
	 * answerIndex:指定该消息是对另一个消息的应答。当此值为0时说明其不应答任何消息，而是一条广播消息
	 * @author Just4test
	 * 
	 */
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
		 *指示还未收到的包的长度 
		 */
		protected var _packageLength:uint;
		/**
		 *指示下一个发送消息的index 
		 */
		protected var _nextSendIndex:uint;
		
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
		
		/**
		 *发送消息 
		 * @param type 消息类型
		 * @param data 消息的数据
		 * @param answerHandle 指定应答处理函数。如果对方有应答，则调用此处理函数而不是派发事件。
		 * <br>原型 function(msg:Message)
		 * @param answerIndex 指定该消息是对对方的某目标消息的应答，这是目标消息的index
		 * 
		 */
		public function send(type:String, data:* = null, answerHandle:Function = null, answerIndex:uint = 0):void
		{
			//encode
			var ba:ByteArray = new ByteArray;
			//写入type
			if(undefined === _sendType2Code[type])
			{
				ba.writeUnsignedInt(_nextSendTypeIndex);
				ba.writeUTF(type);
				_sendType2Code[type] = _nextSendTypeIndex;
				_nextSendTypeIndex += 1;
			}
			else
			{
				ba.writeUnsignedInt(_sendType2Code[type]);
			}
			//写入index
			var index:uint;
			if(answerHandle is Function)
			{
				index = _nextSendIndex;
				_msgMap[index] = answerHandle;
				_nextSendIndex += 1;
			}
			ba.writeUnsignedInt(index);
			//写入answerIndex
			ba.writeUnsignedInt(answerIndex);
			//写入数据
			ba.writeObject(data);
			
			_socket.writeUnsignedInt(ba.length);
			_socket.writeBytes(ba);
			_socket.flush();
		}
		
		public function close():void
		{
			_socket.close();
		}
		
		
		
		/////////////////////////////////////////////////////////////////
		
		protected function connectHandler(e:Event):void
		{
			trace("[Connection] 连接已经建立!");
		}
		
		protected function closeHandler(e:Event):void
		{
			trace("[Connection] 远端切断了连接");
		}
		
		protected function errorHandler(e:Event):void
		{
			trace("[Connection] 发生错误");
			trace(e);
		}
		
		protected function dataHandler(e:Event):void
		{
			while(_socket.bytesAvailable)
			{
				if(!_packageLength)
				{
					if(_socket.bytesAvailable >= 4)
					{
						_packageLength = _socket.readUnsignedInt();
					}
					else
					{
						return;
					}
				}
				
				if(_socket.bytesAvailable < _packageLength)
				{
					return;
				}
				
				var typeCode:uint = _socket.readUnsignedInt();
				if(typeCode == _receiveCode2Type.length)
				{
					_receiveCode2Type[typeCode] = _socket.readUTF();
				}
				
				var index:uint = _socket.readUnsignedInt();
				var answerIndex:uint = _socket.readUnsignedInt();
				var data:* = _socket.readObject();
				
				if(answerIndex)
				{
					var answerHandle:Function = _msgMap[answerIndex];
					if(answerHandle is Function)
					{
						answerHandle(_receiveCode2Type[typeCode], data);
						delete _msgMap[answerIndex];
					}
					else
					{
						trace("[Connection] 远端发来了对消息号", answerIndex, "的应答。但对应的原始消息未找到。");
					}
				}
				else
				{
					dispatchEvent( new MessageEvent(new Message(this, _receiveCode2Type[typeCode], index, data)));
				}
			}
		}
	}
}