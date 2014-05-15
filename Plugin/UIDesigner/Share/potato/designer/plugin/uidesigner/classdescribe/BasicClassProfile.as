package potato.designer.plugin.uidesigner.classdescribe
{
	public class BasicClassProfile
	{
		public static const TYPE_ACCESSOR:int = 1;
		public static const TYPE_METHOD:int = 2;
		
		protected var _className:String;
		
		protected var _constructorTypes:Vector.<String>;
		
		protected var _memberTypeTable:Object = {};
		protected var _memberParameterTable:Object = {};
		
		public function BasicClassProfile(className:String)
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
			_memberTypeTable[name] = TYPE_ACCESSOR;
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
			return _memberParameterTable[name];
		}
		
		public function setAccessor(name:String, type:String):void
		{
			_memberTypeTable[name] = TYPE_ACCESSOR;
			_memberParameterTable[name] = type;
		}
		
		public function getAccessorType(name:String):String
		{
			return _memberParameterTable[name];
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
		 * 返回memberTypeTable的副本
		 * @return 
		 * 
		 */
		public function get memberTypeTable():Object
		{
			function a():void{};
			a.prototype = _memberTypeTable;
			return new a();
		}

		public function get constructorTypes():Vector.<String>
		{
			return _constructorTypes;
		}

		public function set constructorTypes(value:Vector.<String>):void
		{
			_constructorTypes = value;
		}

	}
}