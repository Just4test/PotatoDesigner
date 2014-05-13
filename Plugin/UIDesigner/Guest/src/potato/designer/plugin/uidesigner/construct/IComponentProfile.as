package potato.designer.plugin.uidesigner.construct
{
	/**
	 *组件描述文件接口 
	 * @author Administrator
	 * 
	 */
	public interface IComponentProfile
	{
		/**组件名。此名称不应该和任何类的完全限定名相同。*/
		function get name():String;
		
		/**类的完全限定名*/
		function get className():String;
		
		/**获取子对象的描述文件*/
		function get childrenProfile():Vector.<IComponentProfile>;
	}
}