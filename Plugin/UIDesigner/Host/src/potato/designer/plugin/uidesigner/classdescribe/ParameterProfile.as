package potato.designer.plugin.uidesigner.classdescribe
{
	import potato.designer.plugin.uidesigner.TypeTransform;

	/**
	 * 参数描述
	 * @author Just4test
	 * 
	 */
	public class ParameterProfile
	{
		protected var _xml:XML;
		protected var _typeCode:uint;
		public function ParameterProfile(xml:XML)
		{
			initByXML(xml);
		}
		
		public function initByXML(xml:XML):void
		{
			_xml = xml;
			_typeCode = TypeTransform.getDefaultCodeByClass(_xml.@type);
		}
		
		public function get index():int
		{
			return _xml.@index;
		}
		
		public function get typeCode():int
		{
			return _typeCode;
		}
		
//		public function get type():String
//		{
//			return Const.getShortClassName(_xml.@type);
//		}
		
		public function get className():String
		{
			return _xml.@type;
		}
		
		public function get optional():Boolean
		{
			return _xml.@optional;
		}
	}
}