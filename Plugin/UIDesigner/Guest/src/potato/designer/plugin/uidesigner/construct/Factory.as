package potato.designer.plugin.uidesigner.construct
{

	/**
	 *组件工厂
	 * <br>将Host传过来的描述文件构建为组件
	 * <br>工厂会以以下顺序进行构建：
	 * <br>1.调用IConstructor.construct()构建组件本身
	 * <br>2.依次构建组件的所有子组件
	 * <br>3.调用IConstructor.addChildren()将构建完成的子组件安装在当前组件上
	 * <br>4.返回当前组件
	 * <br>构建为深度优先遍历。
	 * @author Administrator
	 * 
	 */
	public class Factory
	{	
		protected static var componentTable:Object = {};
		
		/**
		 *构建器链
		 * <br>构建过程会从构建器链的0号构建器开始依次调用。
		 * <br>每一个构建器可以选择跳过其后的所有构建器。
		 */
		public static const constructorList:Vector.<IConstructor> = new Vector.<IConstructor>;
		
		{
			constructorList.push(BasicConstructor.instance);
		}
		/**
		 *设置数据 
		 * <br>不同的构建器需要不同格式的数据。数据被组织为一个Object对象，内部包含了各种对象：构建配置文件或其他。
		 * <br>构建器尝试从数据中提取自己能够理解的对象并将其保存下来，以便稍后使用。
		 * <br>约定：如果传入null，则清理所有已设置数据。
		 * @param data
		 */ 
		public static function setData(data:Object):void
		{
			for (var i:int = 0; i < constructorList.length; i++) 
			{
				if(constructorList[i].setData(data))
					break;
			}
		}
		
		/**
		 *设置组件描述文件
		 * <br>使用组件描述文件来让构建器获取构建组件的参数。
		 */
		public static function setComponentProfile(profile:IComponentProfile, name:String):void
		{
			componentTable[name] = profile;
		}
		/**
		 *获取组件描述文件
		 * <br>使用组件描述文件来让构建器获取构建组件的参数。
		 */
		public static function getComponentProfile(name:String):IComponentProfile
		{
			return componentTable[name];
		}
		/**
		 *清除所有已设置的组件描述文件
		 */
		public static function clearComponentProfile():void
		{
			componentTable = {};
		}
		
		/**
		 *编译一个已经设置了描述文件的组件。 
		 * @param name
		 * @return 
		 * 
		 */
		public static function compile(name:String):ComponentTree
		{
			return compileProfile(getComponentProfile(name));
		}
		
		/**
		 *编译组件描述文件 
		 * @param profile
		 * @return 
		 * 
		 */		
		public static function compileProfile(profile:IComponentProfile):ComponentTree
		{
			var tree:ComponentTree = new ComponentTree;
			
			//构建组件自身
			for (var i:int = 0; i < constructorList.length; i++) 
			{
				if(constructorList[i].construct(profile, tree))
					break;
			}
			
			//构建子组件
			if(profile.children)
			{
				tree.children = new Vector.<ComponentTree>;
				for (i = 0; i < profile.children.length; i++) 
				{
					tree.children[i] = compileProfile(profile.children[i]);
				}
			}
			
			//安装子组件
			for (i = 0; i < constructorList.length; i++) 
			{
				if(constructorList[i].addChildren(profile, tree))
					break;
			}
			
			
			return tree;
		}
	}
}