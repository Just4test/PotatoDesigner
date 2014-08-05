package UIAdjuster
{
	import flash.utils.Dictionary;
	
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	import core.display.Stage;

	/**
	 * 运行时,调整界面里元素的坐标(安装?文件夹拷入src即可):
	 * 1.UIEditorManager.init 用前初始化,在显示列表中的可编辑
	 * 
	 * 2.UIEditorManager.regAllChild(this) 注册当前窗体,在显示列表中的,所有都可拖(除自己)
	 * 
	 * 3.UIEditorManager.reg 单独某个显示对象,注册时不在显示列表中,addChild后需点击[刷新]
	 *   高级用法:Button基类添加注册,通过上下级关系编辑,可省略第2步的在每个窗体内注册
	 * 
	 * 4.按住坐标处(黄色的那个xxx,xxx)文本,可以拖动了
	 * 
	 * 5.用完[清理],下次创建窗体走到注册代码 还可以再出来
	 * 
	 * 6.UIEditorManager.addExpandItem 自定义扩展功能
	 * 
	 * @author sheep v1.01 1.修复 向上一层的bug 2.新增 拖动时显示详细信息
	 * @author sheep v1.00
	 * 
	 */
	public class UIAdjusterManager
	{
		/**
		 * 源显示对象列表 依靠这个生产拖动
		 */
		private static var dicTargets:Dictionary = new Dictionary;
		/**
		 *  UIEditorManager的显示层
		 */
		private static var _stage:DisplayObjectContainer;
		/**
		 * 主菜单,在屏幕的右上方 
		 */
		private static var _tool:UIAdjusterMenu;
		/**
		 * 如果使用 需先初始化 
		 * 
		 */
		public static function init():void{
			if(!_stage){
				_stage = new DisplayObjectContainer;
				_tool = new UIAdjusterMenu;
				_tool.x = Stage.getStage().stageWidth - _tool.width;;
				_tool.y = 50;
			}
			toTop();
		}

		/**
		 * 注册单个,拖动
		 * @param disp DisplayObject
		 * 
		 */
		public static function reg(disp:DisplayObject):void{
			if(!_stage) return;
			if(dicTargets[disp]) return;
			dicTargets[disp] = new UIAdjusterItem(disp)
			_stage.addChild(dicTargets[disp]);
		}
		/**
		 * 注册一层里面,所有的拖动
		 * @param disp
		 * @param onlyChild 只注册child,自己本身不会被编辑
		 */
		public static function regAllChild(disp:DisplayObject,onlyChild:Boolean = true):void{
			if(!_stage) return;
			var panel:DisplayObjectContainer = disp as DisplayObjectContainer;
			// 注册所有child
			if(panel){
				var regCount:int = panel.numChildren;
				while(regCount){
					reg(panel.getChildAt(--regCount));
				}
			}
			if(!onlyChild) reg(disp);
		}
		
		/**
		 * 重新刷新一下
		 * 源对象的坐标改变,不通知管理器,所以 你需要自己刷一下
		 * 
		 */
		public static function refresh():void{
			var item:UIAdjusterItem;
			for each(item in dicTargets){
				item.resetDrag();
			}
		}
		/**
		 * 工具在Stage上置顶
		 * 
		 */
		public static function toTop():void{
			if(!_stage) return;
			Stage.getStage().addChild(_stage);
			Stage.getStage().addChild(_tool)
		}
		
		/**
		 * 清除所有 或 指定某个
		 * @param item 不填,则全部
		 * 
		 */
		public static function clear(item:UIAdjusterItem = null):void{
			if(!_stage) return;
			if(item){
				item.dispose();
				item.parent.removeChild(item);
				delete dicTargets[item.res];
				return;
			}
			for each(item in dicTargets){
				item.dispose();
				item.parent.removeChild(item);
			}
			dicTargets = new Dictionary;
		}
		
		/**
		 * 显示/隐藏 坐标旁边的扩展菜单(in out undo ...)
		 * Ps:
		 *  1.容器有[In]选项.
		 *  2.拖动后有[undo]选项
		 */
		public static function itemMore():void{
			var item:UIAdjusterItem;
			for each(item in dicTargets){
				item.menuVisibleChange();
			}
		}
		
		/**
		 * 自定义扩展功能 会显示在菜单里 
		 * @param name
		 * @param func
		 * 
		 */
		public static function addExpandItem(name:String,func:Function):void{
			_tool.addBtn(name,func);
		}
	}
}