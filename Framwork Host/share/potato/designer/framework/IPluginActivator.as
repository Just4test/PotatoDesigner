package potato.designer.framework
{
	/**
	 *插件启动接口。该接口的对象必须具有无参构造方法。
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