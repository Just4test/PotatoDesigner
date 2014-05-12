package potato.designer.plugin.uidesigner
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