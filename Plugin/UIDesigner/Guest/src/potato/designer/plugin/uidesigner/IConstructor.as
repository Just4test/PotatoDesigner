package potato.designer.plugin.uidesigner
{
	/**
	 *构建处理器接口 
	 * @author Administrator
	 * 
	 */
	public interface IConstructor
	{
		/**
		 *构建组件
		 * @param className 目标组件的完整类名
		 * @param profile 构建配置文件
		 * @param comp 组件实例。如果此值不为null，则直接使用此组件进行构建。
		 * <br>如果构建处理器是级联的，此属性可能有助
		 * @return 
		 * 
		 */
		function construct(profile:ConstructProfile, comp:* = null):*;
	}
}