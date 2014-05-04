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
		protected var _availability:Boolean;
		protected var _typeCode:int;
		protected var _className:String;
		
		protected var _suggest:*;
		
		public function get suggest():*
		{
			return _suggest;
		}
		
		public function set suggest(value:*):void
		{
			_suggest = value;
		}
		
		public function AccessorProfile(xml:XML)
		{
			initByXML(xml);
		}
		
		public function initByXML(xml:XML):void
		{
			_xml = xml;
			
			_name = xml.@name;
			_className = _xml.@type;
			_typeCode = TypeTransform.getDefaultCodeByClass(_xml.@type);
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
			
			//检查suggest
			_suggest = SuggestProfile.makeSuggestByXml(this, xml);
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

		public function get className():String
		{
			return _className;
		}


	}
}