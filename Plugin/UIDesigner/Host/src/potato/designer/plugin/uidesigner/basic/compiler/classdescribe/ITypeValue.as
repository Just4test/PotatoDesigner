package potato.designer.plugin.uidesigner.basic.compiler.classdescribe
{
	public interface ITypeValue
	{
		function get className():String;
		
		function get type():String;
		
		function set type(value:String):void;
		
		function get hasDefaultValue():Boolean;
		
		function get defaultValue():String;
		
		function set defaultValue(value:String):void;
		
		function deleteDefaultValue():void;
	}
}