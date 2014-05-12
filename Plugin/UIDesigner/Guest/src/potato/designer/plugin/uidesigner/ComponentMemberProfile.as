package potato.designer.plugin.uidesigner
{
	public class ComponentMemberProfile
	{
		protected var _name:String;
		protected var _values:Vector.<String>;
		
		public function ComponentMemberProfile(name:String, values:Array)
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