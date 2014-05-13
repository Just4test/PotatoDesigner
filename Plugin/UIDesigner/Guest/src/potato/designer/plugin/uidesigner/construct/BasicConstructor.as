package potato.designer.plugin.uidesigner.construct
{
	import flash.utils.getDefinitionByName;
	
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	
	import potato.designer.plugin.uidesigner.ComponentMemberProfile;
	
	/**
	 *基础构建器
	 * <br>此构建器可以为变量和可写的存取器赋值，以及对象的调用成员方法。 
	 * @author Just4test
	 * 
	 */
	public class BasicConstructor implements IConstructor
	{
		protected static const _nextConstructorTable:Object = new Object;
		
		public static const instance:BasicConstructor = new BasicConstructor;
		
		/**
		 *注册次级构建器 
		 * @param className 类名
		 * @param next 次级处理器。当前构建器的构建结果会直接注入次级构建器的construct方法的第三个参数中
		 * 
		 */
		public static function regNextConstructor(className:String, next:IConstructor):void
		{
			_nextConstructorTable[className] = next;
		}
		
		public function construct(profile:IComponentProfile, tree:ComponentTree):Boolean
		{
			//如果配置文件不是所需要的格式则跳过本构建器
			var basicProfile:BasicComponentProfile = profile as BasicComponentProfile;
			if(!basicProfile)
			{
				return false;
			}
			
//			var className:String = profile.className;
			//如果没有传入组件，则创建组件
			tree.component ||= new getDefinitionByName(profile.className) as Class;
			
			for each (var member:ComponentMemberProfile in basicProfile.member) 
			{
//				if()
//				{
//					
//				}
			}
			
			
			
			return false;
		}
		
		public function addChildren(profile:IComponentProfile, tree:ComponentTree):Boolean
		{
			var container:DisplayObjectContainer = tree.component as DisplayObjectContainer;
			for (var i:int = 0; i < tree.children.length; i++) 
			{
				var disObj:DisplayObject = tree.children[i] as DisplayObject;
				if(disObj)
				{
					container.addChild(disObj);
				}
			}
			
			return false;
		}
	}
}