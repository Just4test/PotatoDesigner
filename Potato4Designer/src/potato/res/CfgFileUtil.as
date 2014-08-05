package potato.res
{
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import potato.utils.Utils;

	/**
	 * 资源配置文件解析工具 
	 */	
	public class CfgFileUtil
	{
		/**
		 * 解析配置文件，只在开发环境下使用
		 * @param cfg		配置文件
		 * @param Entity	实体类
		 * @param key		主键
		 * @param source	原有配置
		 * @return 			最新对象
		 */
		public static function readTxt(cfg:String, Entity:Class, key:String, source:Object = null):Object
		{
			var obj:Object = new Object();
			
			var arr:Array = cfg.split(/\r\n|\r|\n/);
			var title:Array;
			for (var i:int = 0; i < arr.length; i++)
			{
				if (arr[i] && arr[i].indexOf("#") != 0)
				{
					if(!title)
					{
						title = arr[i].split("\t");
					}
					else
					{
						var items:Array = arr[i].split("\t");
						var entity:* = new Entity();
						for (var j:int = 0; j < title.length; j++) 
						{
							//开发环境下，读取配置时就附加上路径前缀，之后处理与实机环境完全相同
							var val:String = items[j];
							if ((title[j] == "path" || title[j] == "atlas") && val) {
								val = Utils.parsePathInDev(val, Utils.DEFAULTLOCALE);
							}
							entity[title[j]] = val;
						}
						if(source)
						{
							source[entity[key]] = entity;
						}
						obj[entity[key]] = entity;
					}
				}
			}
			return obj;
		}
		
		/**
		 * 从bytes读取Object，格式为AMF3 
		 * @param bytes
		 * @param source
		 */		
		public static function readObject(bytes:ByteArray, source:Object):Object
		{
//			var count:int;
			var t1:int = getTimer();
			bytes.uncompress();
//			Logger.getLog("FileUtil").debug("解压耗时", getTimer()-t1, " 解压后大小 ", bytes.length);
			bytes.position = 0;
			var obj:Object = bytes.readObject();
//			Logger.getLog("FileUtil").debug("readObject  ", getTimer() - t1);
			for (var name:Object in obj) 
			{
				source[name] = obj[name];
//				count++;
			}
//			Logger.getLog("FileUtil").debug("Object项目 ", count);
			
//			t1 = getTimer();
//			var o:Object = new Object();
//			for (var i:int = 0; i < 100000; i++) 
//			{
//				var bean:SubBean = new SubBean();
//				bean.rect1 = new Rectangle(i,i,i,i);
//				bean.rect2 = new Rectangle(i,i,i,i);
//				o[i] = bean;
//			}
//			Logger.getLog("FileUtil").debug("for  ", getTimer() - t1);
			return obj;
		}
	}
}