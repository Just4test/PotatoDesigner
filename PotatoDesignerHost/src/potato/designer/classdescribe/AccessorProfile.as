package potato.designer.classdescribe
{
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
		protected var _availability:Boolean;
		protected var _typeCode:int;
		
		public function AccessorProfile(xml:XML)
		{
			initByXML(xml);
		}
		
		public function initByXML(xml:XML):void
		{
			_xml = xml;
			
			_name = xml.@name;
			_typeCode = Const.type2typeCode(_xml.@type);
			if("accessor" == xml.name())
			{
				_access = Const.ACCESS_MAP[xml.@access];
				if(Const.ACCESS_READONLY == _access)
				{
					_availability = false;
					return;
				}
			}
			else//variable
			{
				_access = Const.ACCESS_READWRITE;
			}
			_availability = Const.TYPE_UNSUPPORT != _typeCode;
		}
		
		public function get visible():Boolean
		{
			return false;
		}
		
		public function set visible(value:Boolean):void
		{
		}
		
		public function get name():String
		{
			return null;
		}
		
		public function get typeCode():int
		{
			return _typeCode;
		}
		
		public function get availability():Boolean
		{
			return false;
		}

		public function get access():int
		{
			return _access;
		}

	}
}