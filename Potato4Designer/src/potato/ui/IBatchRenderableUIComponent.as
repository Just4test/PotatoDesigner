/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 12-11-16
 * Time: 上午9:25
 * To change this template use File | Settings | File Templates.
 */
package potato.ui
{
/**
 * 可批量渲染的 UIComponent 接口
 */
public interface IBatchRenderableUIComponent
{
	/**
	 * 渲染。
	 * 实际上它是一个请求渲染的指令，操作会被延后，
	 * 直到系统认为有必要时，再真正发出立即渲染的指令。
	 *
	 * 它同时是 UIComponet 组件基类内一个公开方法
	 */
	function render():void;

	/**
	 * 立即渲染，真实的渲染操作应该在这里被实现。
	 *
	 * 它应该被框架自身调用，用户代码中应该尽量避免直接调用该函数。
	 */
	function renderImmediately():void;
}
}
