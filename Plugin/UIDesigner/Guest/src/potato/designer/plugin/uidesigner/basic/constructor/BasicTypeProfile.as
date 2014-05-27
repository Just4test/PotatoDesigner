package potato.designer.plugin.uidesigner.basic.constructor
{
	public class BasicTypeProfile
	{
		protected var _typeName:String;
		protected var _translater:Function;
		protected var _isSerializable:Boolean;
		protected var _className:String;
		
		public function BasicTypeProfile(typeName:String, translater:Function, isSerializable:Boolean = false, className:String = null)
		{
			_typeName = typeName;
			_translater = translater;
			_isSerializable = isSerializable;
			_className = className;
		}
		
		
		
		public function get typeName():String
		{
			return _typeName;
		}

		public function get translater():Function
		{
			return _translater;
		}

		public function get isSerializable():Boolean
		{
			return _isSerializable;
		}

		public function get className():String
		{
			return _className;
		}


	}
}