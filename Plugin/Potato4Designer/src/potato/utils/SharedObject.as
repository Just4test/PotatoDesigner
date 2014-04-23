package potato.utils
{
	import core.filesystem.File;
	
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	registerClassAlias("SharedObject", SharedObject);
	
	/**
	 * SharedObject 简单实现。对象编码使用AMF3。
	 */	
	public class SharedObject
	{
		private static const saveFile:String = "so.dat";
		
		private static var objDic:Object = null; //所有SharedObject
		
		/**
		 * 赋给对象的 data 属性 (property) 的属性 (attribute) 集合；
		 * 可以共享和存储这些属性 (attribute)。
		 */		
		private var _data:Object = new Object();
		
		
		private static function hideCtor():void {}
		
		/**
		 * @private
		 */		
		public function SharedObject(fun:Function)
		{
			if (fun != hideCtor) {
				Error.throwError(SharedObject, 2012);
//				throw new ArgumentError("Error #2012: 无法实例化 SharedObject$ 类。");
			}
		}
		
		/**
		 * 返回对本地永久保留的共享对象的引用，该对象只能用于当前客户端。 
		 * 如果尚不存在共享对象，则此方法将创建一个共享对象。
		 * @param name 共享对象名
		 * @return 
		 */		
		public static function getLocal(name:String):SharedObject {
			if (objDic == null) {
				objDic = new Object(); 
				if (File.exists(saveFile)) {
					var ba:ByteArray = File.readByteArray(saveFile);
					while (ba.bytesAvailable > 0) {
						var so:SharedObject = new SharedObject(hideCtor);
						objDic[ba.readUTF()] = so;
						so._data = ba.readObject();
					}
				}
			}
			
			var so1:SharedObject = objDic[name];
			if (so1 == null) {
				so1 = new SharedObject(hideCtor);
				objDic[name] = so1;
			}
			return so1;
		}
		
		/**
		 * 将本地永久共享对象写入本地文件。
		 * 跟flash不同，必须调用此方法才能将数据写入文件永久保存。
		 */	
		public function flush():void {
			var ba:ByteArray = new ByteArray();
			for (var s:String in objDic) {
				ba.writeUTF(s);
				ba.writeObject(objDic[s].data);
			}
			File.writeByteArray(saveFile, ba);
		}

		public function get data():Object
		{
			return _data;
		}

	}
}