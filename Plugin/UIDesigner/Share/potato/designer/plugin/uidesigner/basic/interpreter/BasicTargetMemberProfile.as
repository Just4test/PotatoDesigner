package potato.designer.plugin.uidesigner.basic.interpreter
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;

	public class BasicTargetMemberProfile implements IExternalizable
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
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeUTF(_name);
			output.writeObject(_values);
		}
		
		public function readExternal(input:IDataInput):void
		{
			_name = input.readUTF();
			_values = Vector.<String>(input.readObject());
		}
		
	}
}