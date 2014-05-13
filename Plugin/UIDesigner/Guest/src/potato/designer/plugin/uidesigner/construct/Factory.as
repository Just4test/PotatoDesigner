package potato.designer.plugin.uidesigner.construct
{
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	

	/**
	 *组件工厂
	 * <br>将Host传过来的描述文件构建为组件 
	 * @author Administrator
	 * 
	 */
	public class Factory
	{
		protected static const CHILDREN:String = "children";
		
		protected static const classTable:Object = {};
		protected static const componentTable:Object = {};
		
		/**
		 *设置类描述文件
		 * <br>使用类描述文件来让构建器确定如何配合组件描述文件来构建组件。
		 * <br>部分构建器可能不需要类描述文件。
		 */
		public static function setClassProfile(profile:BasicClassProfile):void
		{
			classTable[profile.className] = profile;
		}
		
		/**
		 *获取类描述文件
		 * <br>使用类描述文件来让构建器确定如何配合组件描述文件来构建组件。
		 * <br>部分构建器可能不需要类描述文件。
		 */
		public static function getClassProfile(className:String):BasicClassProfile
		{
			return classTable[className];
		}
		
		/**
		 *设置组件描述文件
		 * <br>使用组件描述文件来让构建器获取构建组件的参数。
		 */
		public static function setComponentProfile(profile:IComponentProfile):void
		{
			componentTable[profile.className] = profile;
		}
		/**
		 *获取组件描述文件
		 * <br>使用组件描述文件来让构建器获取构建组件的参数。
		 */
		public static function getComponentProfile(className:String):IComponentProfile
		{
			return componentTable[className];
		}
		
		/**
		 *获取构建器
		 * <br>使用构建器构建组件
		 */
		public static function getConstructor(className:String):IConstructor
		{
			return classTable[className];
		}
		
		/**
		 *设置构建器
		 * <br>使用构建器构建组件
		 */
		public static function setConstructor(name:String, constructor:IConstructor):void
		{
			componentTable[name] = constructor;
		}
		
		public static function compile(profile:Object):ComponentTree
		{
			var comp:*;
			var children:Vector.<ComponentTree>;
			
			var childrenProfile:Array = profile[CHILDREN] as Array;
			delete profile[CHILDREN];
			
			comp = compileSingle(profile);
			
			if(childrenProfile)
			{
				children = new Vector.<ComponentTree>(childrenProfile.length);
				for (var i:int = 0; i < childrenProfile.length; i++) 
				{
					children[i] = compile(childrenProfile[i]);
				}
				
				if(comp is DisplayObjectContainer)
				{
					for (i = 0; i < childrenProfile.length; i++) 
					{
						if(children[i].comp is DisplayObject)
						{
							comp.addChild(children[i].comp);
						}
					}
				}
				
				
			}
			
			return new ComponentTree(comp, children);
		}
		
		/**
		 *构建单个对象 
		 * @param obj 
		 * @param parent 父对象
		 * @return 
		 */
		protected static function compileSingle(obj:Object):*
		{
			
		}
	}
}