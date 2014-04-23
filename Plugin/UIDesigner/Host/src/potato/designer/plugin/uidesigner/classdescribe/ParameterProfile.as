package potato.designer.plugin.uidesigner.classdescribe
{
	/**
	 * 参数描述
	 * @author Just4test
	 * 
	 */
	public class ParameterProfile
	{
		protected var _xml:XML;
		public function ParameterProfile(xml:XML)
		{
			initByXML(xml);
		}
		
		public function initByXML(xml:XML):void
		{
			_xml = xml;
//			xml = <parameter index="1" type="String" optional="true"/>
		}
		
		public function get index():int
		{
			return _xml.@index;
		}
		
		public function get typeCode():int
		{
			return Const.type2typeCode(_xml.@type);
		}
		
		public function get type():String
		{
			return Const.getShortClassName(_xml.@type);
		}
		
		public function get optional():Boolean
		{
			return _xml.@optional;
		}
	}
}