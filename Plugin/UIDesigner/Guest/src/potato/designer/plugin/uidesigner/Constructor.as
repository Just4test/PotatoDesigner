package potato.designer.plugin.uidesigner
{
	import flash.utils.getDefinitionByName;
	
	public class Constructor implements IConstructor
	{
		protected static const _nextConstructorTable:Object = new Object;
		
		public static const instance:Constructor = new Constructor;
		
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
		
		public function construct(profile:ConstructProfile, comp:* = null):*
		{
//			var className:String = profile.className;
			//如果没有传入组件，则创建组件
			comp ||= new getDefinitionByName(profile.className) as Class;
			
			for each (var member:ComponentMemberProfile in profile.member) 
			{
//				if()
//				{
//					
//				}
			}
			
			
			
			//如果注册了次级构建处理器，则调用之。
			var nextConstructor:IConstructor = _nextConstructorTable[profile.className];
			if(nextConstructor)
			{
				return nextConstructor.construct(profile, comp);
			}
			else
			{
				return comp;
			}
		}
	}
}