package potato.designer.plugin.uidesigner.construct
{

	/**
	 * 构建用组件描述文件
	 * <br>将json格式的组件描述转换为强类型。强类型在移动设备上具有更好的性能。
	 * <br>本类是动态类，因而可以自由的扩充您所需要的参数。
	 * @author Just4test
	 */
	public dynamic class BasicComponentProfile implements IComponentProfile
	{
		protected var _className:String;
		
		protected var _constructorPatameters:Vector.<String>;
		
		protected var _memberTable:Object = {};
		
		protected var _children:Vector.<BasicComponentProfile>;
//		protected var _member:Vector.<BasicComponentMemberProfile>;
		
		public static const CLASS_NAME:String = "className";
		public static const CONSTRUCTOR:String = "constructor";
		public static const MEMBERS:String = "members";
		public static const MEMBER_NAME:String = "name";
		public static const MEMBER_VALUES:String = "values";
		public static const CHILDREN:String = "children";
		
		public static function MakeProfile(json:String):BasicComponentProfile
		{
			try
			{
				return BasicComponentProfile(JSON.parse(json));
			} 
			catch(error:Error) 
			{
				log("[UIDesigner] 内部错误：无法将组件的JSON描述转换为组件描述文件\n", error);
				return null;
			}
		}

		
		public function BasicComponentProfile(obj:Object)
		{
			_className = obj[CLASS_NAME];
			
			var array:Array;
			array = obj[MEMBERS];
			_memberTable = {};
			for (i = 0; i < array.length; i++) 
			{
				_memberTable[array[i][MEMBER_NAME]] = Vector.<String>(array[i][MEMBER_VALUES]);
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
		
		
		
		public function getMember(name:String):Vector.<String>
		{
			return _memberTable[name];
		}
		public function getConstructor():Vector.<String>
		{
			return _constructorPatameters;
		}
		
		public function get children():Vector.<IComponentProfile>
		{
			return _children as Vector.<IComponentProfile>;
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
		public function get memberTable():Object
		{
			function a():void{};
			a.prototype = _memberTable;
			return new a();
		}
	}
}