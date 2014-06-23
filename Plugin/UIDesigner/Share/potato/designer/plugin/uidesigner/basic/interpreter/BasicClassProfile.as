package potato.designer.plugin.uidesigner.basic.interpreter
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;

	/**
	 *基础类描述文件
	 * @author Just4test
	 * 
	 */
	public class BasicClassProfile implements IExternalizable
	{
		public static const TYPE_ACCESSOR:int = 1;
		public static const TYPE_METHOD:int = 2;
		
		protected var _className:String;
		
		protected var _constructorTypes:Vector.<String>;
		
		protected var _memberTypeTable:Object = {};
		protected var _memberParameterTable:Object = {};
		
		public function BasicClassProfile(className:String = null)//从二进制数据流恢复对象，必须具有0参构造方法
		{
			_className = className;
		}
		
		/**
		 * 设定方法 
		 * @param name
		 * @param types
		 * 
		 */
		public function setMethod(name:String, types:Vector.<String>):void
		{
			_memberTypeTable[name] = TYPE_METHOD;
			_memberParameterTable[name] = types;
		}
		
		/**
		 *返回方法的参数 
		 * @param name
		 * @return 
		 * 
		 */
		public function getMethodParameters(name:String):Vector.<String>
		{
			return Vector.<String>(_memberParameterTable[name]);
		}
		
		public function setAccessor(name:String, type:String):void
		{
			_memberTypeTable[name] = TYPE_ACCESSOR;
			_memberParameterTable[name] = Vector.<String>([type]);
		}
		
		public function getAccessorType(name:String):String
		{
			return _memberParameterTable[name][0];
		}
		
		/**
		 *返回指定名称的成员是否存在。 
		 * @param name 成员名称
		 * @return 成员是否存在。若不存在，返回0；若成员是方法，返回TYPE_METHOD；若成员是变量/存取器，返回TYPE_ACCESSOR。
		 */
		public function getMemberType(name:String):int
		{
			return _memberTypeTable[name];
		}

		public function get className():String
		{
			return _className;
		}
		
		/**
		 * 返回成员类型表的副本
		 * @return 
		 * 
		 */
		public function get memberTypeTable():Object
		{
			function a():void{};
			a.prototype = _memberTypeTable;
			return new a();
		}
		
		/**构造方法类型*/
		public function get constructorTypes():Vector.<String>
		{
			return _constructorTypes;
		}

		public function set constructorTypes(value:Vector.<String>):void
		{
			_constructorTypes = value;
		}
		
		public function readExternal(input:IDataInput):void
		{
			_className = input.readUTF();
			_constructorTypes = Vector.<String>(input.readObject());//因为从序列化中恢复时，所有Vector会变为Vector.<Object>
			_memberTypeTable = input.readObject();
			_memberParameterTable = input.readObject();
			
		}
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeUTF(_className);
			output.writeObject(_constructorTypes);
			output.writeObject(_memberTypeTable);
			output.writeObject(_memberParameterTable);
		}
		
	}
}