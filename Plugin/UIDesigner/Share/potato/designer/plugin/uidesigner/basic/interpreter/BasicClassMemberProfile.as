package potato.designer.plugin.uidesigner.basic.interpreter
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	public class BasicClassMemberProfile implements IExternalizable
	{
		internal var isAccess:Boolean;
		internal var types:Vector.<String>;
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeBoolean(isAccess);
			output.writeObject(types);
		}
		
		public function readExternal(input:IDataInput):void
		{
			isAccess = input.readBoolean();
			types = Vector.<String>(input.readObject());
		}
	}
}