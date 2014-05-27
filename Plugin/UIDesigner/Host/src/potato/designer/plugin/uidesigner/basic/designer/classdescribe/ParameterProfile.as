package potato.designer.plugin.uidesigner.basic.designer.classdescribe
{
	import potato.designer.plugin.uidesigner.basic.designer.TypeTransform;

	/**
	 * 参数描述
	 * @author Just4test
	 * 
	 */
	public class ParameterProfile
	{
		protected var _xml:XML;
		protected var _type:String;
		public function ParameterProfile(xml:XML)
		{
			initByXML(xml);
		}
		
		public function initByXML(xml:XML):void
		{
			_xml = xml;
		}
		
		public function get index():int
		{
			return _xml.@index;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function set type(value:String):void
		{
			_type = value;
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