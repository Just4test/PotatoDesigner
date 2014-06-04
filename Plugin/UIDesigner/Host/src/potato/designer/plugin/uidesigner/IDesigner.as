package potato.designer.plugin.uidesigner
{
	import potato.designer.utils.MultiLock;

	/**
	 *设计器接口
	 * <br>设计器创建目标配置文件，由构建器进行构建。
	 * <br>设计器管理器将多个设计器组织成一个设计器序列。依次调用每一个设计器以创建目标配置文件。序列中靠前的设计器先被执行，并且允许跳过之后所有设计器。
	 * <br>设计器接口包含多个方法。每个设计器未必需要实现所有这些方法：其他不关心的方法给予空实现：返回false。
	 * @author Administrator
	 * 
	 */
	public interface IDesigner
	{
		/**
		 * 添加一个目标对象。
		 * @param targetType 目标对象的类型
		 * @param profile 设计器配置文件。
		 * <br>创建或修改profile.targetProfile。如果需要的话，修改profile.name（初始值被设为targetType）。
		 * <br>此时profile还没有parent。
		 * @return 返回true则跳过后面的设计器。通常返回false。
		 * 
		 */
		function addTarget(targetType:String, profile:DesignerProfile):Boolean;
		
		
		/**
		 *导出为运行时优化过的打包文件。
		 * <br>该文件应该包含所有ITargetProfile，以及任何需要的环境变量等。导出的目标对象会由IConstructor.setData处理。
		 * <br>将导出结果写入UIDesignerHost.exportResult的属性。必须导出可以序列化的对象。
		 * @param lock 一个众锁。如果导出工作不能同步完成，请锁定众锁。
		 * @return 返回true则跳过后面的设计器。通常返回false。
		 * <br>我实在不知道跳过后面的设计器有什么用。实际上我很想把这个接口设计为事件，但我真的希望显式要求设计器响应它。
		 * 
		 */		
		function export(lock:MultiLock):Boolean;
			
	}
}