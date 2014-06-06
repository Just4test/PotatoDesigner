package potato.designer.plugin.uidesigner.basic.interpreter
{
	public class BasicTargetMemberProfile
	{
		protected var _name:String;
		protected var _values:Vector.<String>;
		
		public function BasicTargetMemberProfile(name:String, values:Array)
		{
			_name = name;
			_values = Vector.<String>(values);
		}

		public function get name():String
		{
			return _name;
		}

		public function get values():Vector.<String>
		{
			return _values;
		}

	}
}