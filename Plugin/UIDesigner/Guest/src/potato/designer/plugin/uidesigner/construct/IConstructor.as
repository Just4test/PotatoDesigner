package potato.designer.plugin.uidesigner.construct
{

	/**
	 *构建器接口 
	 * @author Administrator
	 * 
	 */
	public interface IConstructor
	{
		/**
		 * 构建组件
		 * @param profile 构建配置文件
		 * @param tree 组件树。tree.component为目标组件。
		 * <br>如果目标组件不为null，则应该使用此组件进行构建。
		 * @return 返回true则跳过后面的构建器。通常返回false。
		 */
		function construct(profile:IComponentProfile, tree:ComponentTree):Boolean;
		
		/**
		 * 安装子对象
		 * @param profile 构建配置文件
		 * @param tree 组件树。tree.component为目标组件，tree.children列出了子组件。
		 * @return 返回true则跳过后面的构建器。通常返回false。
		 */
		function addChildren(profile:IComponentProfile, tree:ComponentTree):Boolean;
	}
}