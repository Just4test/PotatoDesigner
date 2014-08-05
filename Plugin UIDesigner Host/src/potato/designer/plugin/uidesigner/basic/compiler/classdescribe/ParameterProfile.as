package potato.designer.plugin.uidesigner.basic.compiler.classdescribe
{
	/**
	 * 参数描述
	 * @author Just4test
	 * 
	 */
	public class ParameterProfile implements ITypeValue
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
		
		public function get className():String
		{
			return _xml.@type;
		}
		
		public function get optional():Boolean
		{
			return "true" == _xml.@optional;
		}
		
		protected var _defaultValue:*;
		
		public function get hasDefaultValue():Boolean
		{
			return undefined !== _defaultValue;
		}
		
		public function get defaultValue():String
		{
			return _defaultValue;
		}
		
		public function set defaultValue(value:String):void
		{
			_defaultValue = value;
		}
		
		
		public function deleteDefaultValue():void
		{
			_defaultValue = undefined;
		}
		

	}
}