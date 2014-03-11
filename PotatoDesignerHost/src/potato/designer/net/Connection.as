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
		 *需要应答的消息index与应答句柄映射表 
		 */
		protected var _callbackMap:Object;
		/**
		 *指示下一个需要应答消息的index 
		 */
		protected var _nextCallbackIndex:uint;
		
		
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
			
			if(_socket.connected)
			{
				initSocket();
			}
		}
		
		
		
		protected function initSocket():void
		{
			_socket.addEventListener(Event.CLOSE, closeHandler);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
			
			//连接建立后才创建，以免之前断掉的连接污染本次
			_sendType2Code = new Object;
			_nextSendTypeIndex = 0;
			_receiveCode2Type = new Vector.<String>;
			_callbackMap = new Object;
			_nextCallbackIndex = 1;
		}
		
		public function connect(host:String, port:int):void
		{
			if(!_socket.connected)
			{
				_socket.connect(host, port);
				_packageLength = 0;
				_socket.addEventListener(Event.CONNECT, connectHandler);
				_socket.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			}
		}
		
		/**
		 *发送或应答一条消息 
		 * @param type 消息类型
		 * @param data 消息数据体
		 * @param callbackHandle 指定应答回调函数
		 * @param answerIndex 表示这是对某条消息的应答
		 * 
		 */
		public function send(type:String, data:* = null, callbackHandle:Function = null, answerIndex:uint = 0):void
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
			if(callbackHandle is Function)
			{
				index = _nextCallbackIndex;
				_callbackMap[index] = callbackHandle;
				_nextCallbackIndex += 1;
			}
			ba.writeUnsignedInt(index);
			//写入answerIndex
			ba.writeUnsignedInt(answerIndex);
			//写入数据
			ba.writeObject(data);
			
			_socket.writeUnsignedInt(ba.length);
			_socket.writeBytes(ba);
			_socket.flush();
			
			var traceStr:String;
			if(answerIndex)
			{
				traceStr = "[Connection] 发送对消息号 " + answerIndex + " 的应答[" + type + "]";
			}
			else
			{
				traceStr = "[Connection] 发送广播消息[" + type + "]";
			}
			if(index)
			{
				traceStr += "，并请求应答，请求消息号 " + index;
			}
			else
			{
				
			}
			trace(traceStr);
		}
		
		public function close():void
		{
			_socket.close();
			_socket.removeEventListener(Event.CONNECT, connectHandler);
			_socket.removeEventListener(Event.CLOSE, closeHandler);
			_socket.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_socket.removeEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
		}
		
		public function get connected():Boolean
		{
			return _socket.connected;
		}
		
		
		
		/////////////////////////////////////////////////////////////////
		
		protected function connectHandler(e:Event):void
		{
			trace("[Connection] 连接已经建立!");
			initSocket();
			dispatchEvent(e);
		}
		
		protected function closeHandler(e:Event):void
		{
			trace("[Connection] 远端切断了连接");
			_packageLength = 0;
			dispatchEvent(e);
		}
		
		protected function errorHandler(e:Event):void
		{
			trace("[Connection] 发生错误");
			trace(e);
			dispatchEvent(e);
			
			if(!_socket.connected)
			{
				_socket.close();//AVM的BUG，如果开始连接后没有连接成功，将占用最大连接数。需要用close()清除。
			}
		}
		
		protected function dataHandler(e:Event):void
		{
			try
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
					
					var type:String = _receiveCode2Type[typeCode];
					var index:uint = _socket.readUnsignedInt();
					var answerIndex:uint = _socket.readUnsignedInt();
					var data:* = _socket.readObject();
					
					if(answerIndex)
					{
						var answerHandle:Function = _callbackMap[answerIndex];
						if(answerHandle is Function)
						{
							trace("[Connection] 收到对消息号", answerIndex, "的应答[" + type + "]");
							answerHandle(new Message(this, type, index, data));
							delete _callbackMap[answerIndex];
						}
						else
						{
							trace("[Connection] 收到对消息号", answerIndex, "的应答[" + type + "]，但对应的原始消息未找到。");
						}
					}
					else
					{
						trace("[Connection] 收到消息 [" + type + "]");
						dispatchEvent( new MessageEvent(new Message(this, type, index, data)));
					}
					_packageLength = 0;
				}
			} 
			catch(error:Error) 
			{
				trace("[Connection] 协议错误，连接崩溃。这可能是因为您连接到了一个非Connection管理的Socket，或者Connection版本不兼容。");
				close();
			}
			
		}
	}
}