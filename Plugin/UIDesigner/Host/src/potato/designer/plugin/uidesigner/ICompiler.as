package potato.designer.plugin.uidesigner
{
	import potato.designer.plugin.guestManager.Guest;
	import potato.designer.utils.MultiLock;

	/**
	 *编译器接口
	 * <br>编译器创建目标配置文件，由编译器进行构建。
	 * <br>编译器管理器将多个编译器组织成一个编译器序列。依次调用每一个编译器以创建目标配置文件。序列中靠前的编译器先被执行，并且允许跳过之后所有编译器。
	 * <br>编译器接口包含多个方法。每个编译器未必需要实现所有这些方法：其他不关心的方法给予空实现：返回false。
	 * @author Administrator
	 * 
	 */
	public interface ICompiler
	{
		/**
		 * 添加一个目标对象。
		 * @param targetType 目标对象的类型
		 * @param profile 编译器配置文件。
		 * <br>创建或修改profile.targetProfile。如果需要的话，修改profile.name（初始值被设为targetType）。
		 * <br>此时profile还没有parent。
		 * @return 返回true则跳过后面的编译器。通常返回false。
		 * 
		 */
		function addTarget(profile:CompilerProfile):Boolean;
		
		
		/**
		 * 更新targetProfile
		 * <br>调用时，所有子代DesignerProfile已经完成refresh。
		 * @param profile
		 * @return 返回true则跳过后面的编译器。通常返回false。
		 */
		function update(profile:CompilerProfile):Boolean;
		
		
		/**
		 * 导出为运行时优化过的打包文件。
		 * <br>该文件应该包含所有ITargetProfile，以及任何需要的环境变量等。导出的目标对象会由IConstructor.setData处理。
		 * <br>将导出结果写入UIDesignerHost.exportResult的属性。必须导出可以序列化的对象。
		 * @param lock 一个众锁。如果导出工作不能同步完成，请锁定众锁。
		 * @return 返回true则跳过后面的编译器。通常返回false。
		 * <br>我实在不知道跳过后面的编译器有什么用。实际上我很想把这个接口设计为事件，但我真的希望显式要求编译器响应它。
		 * 
		 */		
		function export(lock:MultiLock):Boolean;
		
		/**
		 * 初始化客户端
		 * <br>当一个启动了UIDesignerGuest的客户端连接到主机时，使用此方法初始化它。初始化完毕后，客户端才能进行正常操作。
		 * @param guest 客户端对象
		 * @param lock 一个众锁。如果初始化工作不能同步完成，请锁定众锁。
		 * @return 返回true则跳过后面的编译器。通常返回false。
		 * 
		 */
		function initGuest(guest:Guest, lock:MultiLock):Boolean;
		
		
//		/**
//		 * 载入编译器信息以便继续之前的设计过程。
//		 */
//		function load():Boolean;
//		
//		/**
//		 * 保存编译器信息。
//		 */
//		function save():Boolean;
			
	}
}