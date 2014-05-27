package potato.designer.plugin.uidesigner.basic.constructor
{
	import potato.designer.plugin.uidesigner.construct.IComponentProfile;

	/**
	 * 构建用组件描述文件
	 * <br>将json格式的组件描述转换为强类型。强类型在移动设备上具有更好的性能。
	 * <br>本类是动态类，因而可以自由的扩充您所需要的参数。
	 * @author Just4test
	 */
	public dynamic class BasicComponentProfile implements IComponentProfile
	{
		protected var _className:String;
		
		protected var _constructorParameters:Vector.<String>;
		
//		protected var _memberTable:Object = {};
		protected var _members:Vector.<BasicComponentMemberProfile>;
		
		protected var _children:Vector.<BasicComponentProfile>;
		
		public static const CLASS_NAME:String = "className";
		public static const CONSTRUCTOR:String = "constructor";
		public static const MEMBERS:String = "members";
		public static const MEMBER_NAME:String = "name";
		public static const MEMBER_VALUES:String = "values";
		public static const CHILDREN:String = "children";
		
		/**
		 *由JSON构建一个组件描述文件 
		 * @param json
		 * @return 
		 * 
		 */
		public static function MakeProfile(json:String):BasicComponentProfile
		{
			try
			{
				return BasicComponentProfile(JSON.parse(json));
			} 
			catch(error:Error) 
			{
				log("[UIDesigner] 内部错误：无法将组件的JSON描述转换为组件描述文件\n", error);
			}
			return null;
		}

		
		public function BasicComponentProfile(obj:Object)
		{
			_className = obj[CLASS_NAME];
			
			var array:Array;
			array = obj[MEMBERS];
			_members = new Vector.<BasicComponentMemberProfile>;
			for (i = 0; i < array.length; i++) 
			{
				_members.push(new BasicComponentMemberProfile(array[i][MEMBER_NAME],  array[i][MEMBER_VALUES]));
			}
			
			array = obj[CHILDREN];
			_children = new Vector.<BasicComponentProfile>(array.length);
			for (var i:int = 0; i < array.length; i++) 
			{
				_children[i] = new BasicComponentProfile(array[i]);
			}
			
			
			for(var key:String in obj) 
			{
				if(CLASS_NAME == key || MEMBERS == key || CHILDREN == key)
				{
					continue;
				}
				
				this[key] = obj[key];
			}
		}
		
		
		/**
		 *获取构造方法的参数类型列表
		 * @return 
		 * 
		 */
		public function getConstructor():Vector.<String>
		{
			return _constructorParameters;
		}
		
		public function get children():Vector.<IComponentProfile>
		{
			return _children as Vector.<IComponentProfile>;
		}
		
		/**
		 *获取类的完全限定名 
		 * @return 
		 * 
		 */
		public function get className():String
		{
			return _className;
		}
		

		/**
		 *生成members的副本 
		 * @return 
		 * 
		 */
		public function get members():Vector.<BasicComponentMemberProfile>
		{
			return _members.concat();
		}

	}
}