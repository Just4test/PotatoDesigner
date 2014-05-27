package potato.designer.plugin.uidesigner.basic.designer
{
	/**
	 * 数据类型转换
	 *将文本转换为目标数据类型，或者从文本转换为可存储数据类型
	 * @author Just4test
	 * 
	 */
	public class TypeTransform
	{
		protected static var classMap:Object = new Object;
		protected static var typeMap:Object = new Object;
		/**类型的数组的数组*/
		protected static var typeVV:Vector.<Vector.<TypeProfile>> = new Vector.<Vector.<TypeProfile>>;
		
		
		/**
		 *注册类型
		 * @param className 指向的类的完全限定名
		 * @param nickName 类型名。类型名不得包含逗号。
		 * @return 类型的id
		 * 
		 */
		public static function regType(className:String, typeName:String):int
		{
			if(typeMap[typeName])
			{
				throw new Error("该类型名已经被注册");
			}
			/**类型数组。指向相同完全限定名的类型共享同一个数组*/
			var typeV:Vector.<TypeProfile> = classMap[className];
			
			if(!typeV)
			{
				typeV = new Vector.<TypeProfile>
				classMap[className] = typeV;
				typeVV.push(typeV);
			}
			
			var type:TypeProfile = new TypeProfile(typeName, typeVV.indexOf(typeV) * 1000 + typeV.length);
			typeV.push(type);
			typeMap[typeName] = type;
			return type.code;
		}
		
		/**
		 * 获取类型名所指定的类型
		 * @param name 类型名
		 * @return 类型描述文件。如果指定的类型名没有注册，则返回null
		 * 
		 */
		public static function getTypeByName(name:String):TypeProfile
		{
			return typeMap[name];
		}
		
		/**
		 *获取类型代码所指定的类型 
		 * @param code 类型代码
		 * @return 类型描述文件。如果指定的类型代码没有对应一个类型，则返回null
		 * 
		 */
		public static function getTypeByCode(code:uint):TypeProfile
		{
			if(code / 1000 >= typeVV.length)
			{
				return null;
			}
			var typeV:Vector.<TypeProfile> = typeVV[code / 1000];
			if(code % 1000 >= typeV.length)
			{
				return null;
			}
			return typeV[code % 1000];
		}
		
		/**
		 *获取指定类的类型列表 
		 * @param name class的完全限定名
		 * @return 注册到该类的类型列表
		 * 
		 */
		public static function getTypesByClass(name:String):Vector.<TypeProfile>
		{
			return classMap[name] && classMap[name].concat();
		}
		
		public static function getDefaultTypeByClass(name:String):TypeProfile
		{
			if(classMap[name])
			{
				return classMap[name][0]
			}
			else
				return null;
		}
		
		public static function getDefaultCodeByClass(name:String):uint
		{
			if(classMap[name])
			{
				return classMap[name][0].code
			}
			else
				return 0;
		}
	}
}