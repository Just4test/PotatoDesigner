package potato.designer.plugin.uidesigner.construct
{
	public class BasicClassProfile
	{
		public static const TYPE_ACCESSOR:int = 1;
		public static const TYPE_METHOD:int = 2;
		
		protected var _className:String;
		
		protected var _memberTypeMap:Object = {};
		protected var _memberParameterMap:Object = {};
		
		public function BasicClassProfile(className:String)
		{
			_className = className;
		}
		
		public function setMethod(name:String, ...values):void
		{
			
		}
		
		public function testMember(name:String):int
		{
			return _memberTypeMap[name];
		}

		public function get className():String
		{
			return _className;
		}

	}
}