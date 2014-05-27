package potato.designer.plugin.uidesigner.basic.designer
{
	public class TypeProfile
	{
		private var _name:String;
		private var _code:uint;
		
		public function TypeProfile(name:String, code:uint)
		{
			_name = name;
			_code = code;
		}

		public function get name():String
		{
			return _name;
		}

		public function get code():uint
		{
			return _code;
		}
	}
}