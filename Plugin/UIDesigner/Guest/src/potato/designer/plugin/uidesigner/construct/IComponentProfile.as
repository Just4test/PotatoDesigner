package potato.designer.plugin.uidesigner.construct
{
	/**
	 *组件描述文件接口
	 * <br>组建描述文件接口是必要的，因为它定义了获取组件名以及访问子代描述文件的方法。
	 * <br>组建描述文件和构建器配套使用。如果您重新定义了本接口的一个实现，请确保您提供了能够理解它的构建器。
	 * @author Administrator
	 * 
	 */
	public interface IComponentProfile
	{
		/**组件名。此名称不应该和任何类的完全限定名相同。*/
//		function get name():String;
		
		/**类的完全限定名*/
//		function get className():String;
		
		/**获取子对象的描述文件*/
		function get children():Vector.<IComponentProfile>;
	}
}