package potato.designer.plugin.uidesigner
{
	/**
	 *设计器接口
	 * <br>设计器创建目标配置文件，由构建器进行构建。
	 * <br>设计器管理器将多个设计器组织成一个设计器序列。依次调用每一个设计器以创建目标配置文件。序列中靠前的设计器先被执行，并且允许跳过之后所有设计器。
	 * <br>设计器接口包含三个方法。每个设计器未必需要实现所有这些方法：他们可以只实现一两个，其他不关心的则给予空实现：返回false。
	 * @author Administrator
	 * 
	 */
	public interface IDesigner
	{
		/**
		 * 添加一个目标对象。
		 * @param targetType 目标对象的类型
		 * @param profile 设计器配置文件。创建profile.targetProfile
		 * @return 返回true则跳过后面的设计器。通常返回false。
		 * 
		 */
		function addTarget(targetType:String, profile:DesignerProfile):Boolean;
	}
}