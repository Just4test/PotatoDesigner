package potato.designer.plugin.uidesigner.factory
{
	import potato.designer.plugin.uidesigner.ITargetProfile;

	/**
	 *编译器接口
	 * <br>编译器能够理解构建配置文件，并利用它真正的构建目标组件。
	 * <br>工厂将多个编译器组织成一个编译器序列。依次调用每一个编译器以构建组件。序列中靠前的编译器先被执行，并且允许跳过之后所有编译器。
	 * <br>编译器接口包含三个方法。每个编译器未必需要实现所有这些方法：他们可以只实现一两个，其他不关心的则给予空实现：返回false。
	 * @author Administrator
	 * 
	 */
	public interface IInterpreter
	{
		/**
		 * 构建组件
		 * <br>通常，编译器只需要关心如何构建组件自身。工厂会稍后遍历构建组件的子对象。
		 * @param profile 构建配置文件
		 * @param tree 组件树。tree.component为目标组件。
		 * <br>如果目标组件不为null，则应该使用此组件进行构建。
		 * @return 返回true则跳过后面的编译器。通常返回false。
		 */
		function construct(profile:ITargetProfile, tree:TargetTree):Boolean;
		
		/**
		 * 安装子对象
		 * @param profile 构建配置文件
		 * @param tree 组件树。tree.component为目标组件，tree.children列出了子组件。
		 * @return 返回true则跳过后面的编译器。通常返回false。
		 */
		function addChildren(profile:ITargetProfile, tree:TargetTree):Boolean;
		
		
		/**
		 * 设置数据
		 * <br>不同的编译器需要不同格式的数据。数据被组织为一个Object对象，内部包含了各种对象：构建配置文件或其他。
		 * <br>编译器尝试从数据中提取自己能够理解的对象并将其保存下来，以便稍后使用。
		 * <br><b>约定</b>：如果传入null，则清理所有已设置数据。
		 * @param data
		 * @return 返回true则跳过后面的编译器。通常返回false。
		 * 
		 */
		function setData(data:Object):Boolean;
	}
}