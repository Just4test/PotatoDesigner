package potato.designer.plugin.uidesigner
{
	/**
	 * 构建描述文件
	 * <br>将json格式的组件描述转换为强类型。强类型在移动设备上具有更好的性能。
	 * <br>本类是动态类，因而可以自由的扩充您所需要的参数。
	 * @author Just4test
	 */
	public dynamic class ConstructProfile
	{
		protected var _className:String;
		protected var _children:Vector.<ConstructProfile>;
		protected var _member:Vector.<ComponentMemberProfile>;
		
		public static const CLASS_NAME:String = "className";
		public static const MEMBERS:String = "members";
		public static const MEMBER_NAME:String = "name";
		public static const MEMBER_VALUES:String = "values";
		public static const CHILDREN:String = "children";
		
		public static function MakeProfile(json:String):ConstructProfile
		{
			try
			{
				return ConstructProfile(JSON.parse(json));
			} 
			catch(error:Error) 
			{
				log("[UIDesigner] 内部错误：无法将组件的JSON描述转换为组件描述文件\n", error);
				return null;
			}
		}

		
		public function ConstructProfile(obj:Object)
		{
			_className = obj[CLASS_NAME];
			
			var array:Array;
			array = obj[MEMBERS];
			_member = new Vector.<ComponentMemberProfile>(array.length);
			for (i = 0; i < array.length; i++) 
			{
				_member[i] = new ComponentMemberProfile(array[i][MEMBER_NAME], array[i][MEMBER_VALUES])
			}
			
			array = obj[CHILDREN];
			_children = new Vector.<ConstructProfile>(array.length);
			for (var i:int = 0; i < array.length; i++) 
			{
				_children[i] = new ConstructProfile(array[i]);
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
		
		
		
		public function get member():Vector.<ComponentMemberProfile>
		{
			return _member;
		}
		
		public function get children():Vector.<ConstructProfile>
		{
			return _children;
		}
		
		public function get className():String
		{
			return _className;
		}
	}
}