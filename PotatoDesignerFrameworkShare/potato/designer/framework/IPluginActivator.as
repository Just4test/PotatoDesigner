package potato.designer.framework
{
	/**
	 *插件启动接口
	 * @author Administrator
	 * 
	 */
	public interface IPluginActivator
	{
		/**
		 * 启动该插件
		 */
		function start(info:PluginInfo):void;
	}
}