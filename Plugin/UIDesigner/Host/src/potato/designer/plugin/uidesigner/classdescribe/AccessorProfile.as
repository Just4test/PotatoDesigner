package potato.designer.plugin.uidesigner.classdescribe
{
	import potato.designer.plugin.uidesigner.TypeTransform;

	/**
	 * 变量和存取器描述符
	 * @author Just4test
	 * 
	 */
	public class AccessorProfile implements IMemberProfile
	{
		protected var _xml:XML;
		protected var _name:String;
		
		protected var _access:int;
		/**访问修饰符。确定存取器是只读、只写还是读写。对于变量，此值总是读写。*/
		public static const ACCESS_READONLY:int = 1;
		public static const ACCESS_READWRITE:int = 0;
		public static const ACCESS_WRITEONLY:int = 2;
		protected static const ACCESS_MAP:Object =
			{
				"readonly":     ACCESS_READONLY,
				"readwrite":    ACCESS_READWRITE,
				"writeonly":    ACCESS_WRITEONLY
			};
		
		protected var _availability:*;
		protected var _enable:Boolean;
		protected var _className:String;
		protected var _type:String;
		
		public function AccessorProfile(xml:XML)
		{
			initByXML(xml);
		}
		
		public function initByXML(xml:XML):void
		{
			_xml = xml;
			
			_name = xml.@name;
			_className = _xml.@type;
			if("accessor" == xml.name())
			{
				_access = ACCESS_MAP[xml.@access];
				_availability = null;
			}
			else//variable
			{
				_access = ACCESS_READWRITE;
			}
		}
		
		public function get enable():Boolean
		{
			return _enable;
		}
		
		public function set enable(value:Boolean):void
		{
			_enable = value;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get availability():Boolean
		{
			if(null == _availability)
			{
				_availability = (ACCESS_READONLY != _access) && _type;
			}
			return _availability;
			
		}
		
		/**确定存取器是只读、只写还是读写。对于变量，此值总是读写 */
		public function get access():int
		{
			return _access;
		}

		public function get className():String
		{
			return _className;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_availability = null;
			_type = value;
		}


	}
}