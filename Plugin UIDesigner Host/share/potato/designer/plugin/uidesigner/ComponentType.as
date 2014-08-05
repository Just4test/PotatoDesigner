package potato.designer.plugin.uidesigner
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	/**
	 *组件类型 
	 * @author Administrator
	 * 
	 */
	public class ComponentType implements IExternalizable
	{
		protected var _name:String;
		protected var _isContainer:Boolean;
		protected var _icon:*;
		
		public function ComponentType(name:String = null, isContainer:Boolean = false, icon:* = null)
		{
			_name = name;
			_isContainer = isContainer;
			_icon = icon;
		}
		
		public function readExternal(input:IDataInput):void
		{
			_name = input.readUTF();
			_isContainer = input.readBoolean();
			
		}
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeUTF(_name);
			output.writeBoolean(_isContainer);
		}

		public function get name():String
		{
			return _name;
		}

		public function get isContainer():Boolean
		{
			return _isContainer;
		}

		public function get icon():*
		{
			return _icon;
		}

		
	}
}