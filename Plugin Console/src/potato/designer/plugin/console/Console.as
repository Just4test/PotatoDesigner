package potato.designer.plugin.console
{
	
	import flash.events.Event;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.collections.ArrayList;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;
	import potato.designer.framework.IPluginActivator;
	import potato.designer.framework.PluginInfo;
	import potato.designer.plugin.window.WindowManager;
	
	import spark.layouts.ConstraintLayout;
	import spark.layouts.HorizontalLayout;
	
	public class Console implements IPluginActivator
	{
		public static const EVENT_DIALOG_CLOSED:String = "CONSOLE_EVENT_DIALOG_CLOSED";
		
		public static const DEFAULT_TAB_NAME:String = "全部";
		
		protected static var viewInstance:ConsoleView;
		
		protected static const tabs:Vector.<TabData> = new Vector.<TabData>;
		
		public function Console()
		{
		}
		
		public function start(info:PluginInfo):void
		{
			EventCenter.addEventListener(EventCenter.EVENT_LOG, logHandler);
			
			viewInstance = new ConsoleView;
			viewInstance.tabProvider = new ArrayList;
			viewInstance.refreshHandler = function():void{
				viewInstance.text = viewInstance.selectedTabData.text
			};
			addTab(DEFAULT_TAB_NAME, null);
			addTab("插件", "[Plugin]");
			
			viewInstance.contextMenu = new ContextMenu;
			viewInstance.contextMenu.addEventListener("displaying", prepareMenuHandler);
			
			var closeTabItem:ContextMenuItem = new ContextMenuItem("关闭当前标签");
			closeTabItem.addEventListener(Event.SELECT, closeTabHandler);
			viewInstance.contextMenu.customItems.push(closeTabItem);
			
			var addTabItem:ContextMenuItem = new ContextMenuItem("以所选内容新建标签");
			addTabItem.addEventListener(Event.SELECT, addTabHandler);
			viewInstance.contextMenu.customItems.push(addTabItem);
			
			var clearCurrentItem:ContextMenuItem = new ContextMenuItem("清除当前标签内容");
			clearCurrentItem.addEventListener(Event.SELECT, clearCurrentHandler);
			viewInstance.contextMenu.customItems.push(clearCurrentItem);
			
			var clearAllItem:ContextMenuItem = new ContextMenuItem("清除所有标签内容");
			clearAllItem.addEventListener(Event.SELECT, clearAllHandler);
			viewInstance.contextMenu.customItems.push(clearAllItem);
			
			
			
			
			openAsWindow();
			
			info.started();
			
			
			
			////////////////////////////////
			
			
			function prepareMenuHandler(e:Event):void
			{
				closeTabItem.enabled = DEFAULT_TAB_NAME != viewInstance.selectedTabData.tabName;
				addTabItem.enabled = Boolean(viewInstance.selectedText);
				addTabItem.caption = viewInstance.selectedText ? "新建标签[" + viewInstance.selectedText.slice(0, 10) + "]" : "以所选内容新建标签";
			}
			
			function closeTabHandler(e:Event):void
			{
				removeTab(viewInstance.selectedTabData.tabName);
			}
			
			function addTabHandler(e:Event):void
			{
				addTab(viewInstance.selectedText.slice(0, 10), viewInstance.selectedText);
			}
			
			function clearCurrentHandler(e:Event):void
			{
				viewInstance.selectedTabData.text = "";
				viewInstance.text = "";
			}
			
			function clearAllHandler(e:Event):void
			{
				for each(var i:TabData in tabs)
				{
					i.text = "";
				}
				viewInstance.text = "";
			}
			
			
			
			
		}
		
		public static function openAsWindow():void
		{
			WindowManager.openWindow("控制台", Vector.<UIComponent>([viewInstance]), null, false, 480, 360);
		}
		
		protected static var _inputVisible:Boolean = true;

		public static function get inputVisible():Boolean
		{
			return _inputVisible;
		}

		public static function set inputVisible(value:Boolean):void
		{
			_inputVisible = value;
			viewInstance && (viewInstance.inputVisible = value);
		}
		
		
		/**
		 * 添加一个标签
		 * @param tabName 标签的显示文本
		 * @param keyWord 标签的关键字。log中如果出现标签关键字，本条log将过滤到此标签中。
		 * 
		 */
		public static function addTab(tabName:String, keyWord:String):Boolean
		{
			for each(var i:TabData in tabs)
			{
				if(i.tabName == tabName)
				{
					return false;
				}
			}
			var tabData:TabData = new TabData(tabName, keyWord)
			tabs.push(tabData);
			viewInstance.tabProvider.addItem(tabData);
			viewInstance.selectedTabData = tabData;
			viewInstance.text = "";
			return true;
		}
		
		public static function removeTab(tabName:String):Boolean
		{
			for(var i:int = 1; i < tabs.length; i++)
			{
				if(tabs[i].tabName == tabName)
				{
					viewInstance.tabProvider.removeItem(tabs[i]);
					tabs.splice(i, 1);
					return true;
				}
			}
			
			return false;
		}
		
		protected static function logHandler(e:DesignerEvent):void
		{
			if(viewInstance)
			{
				e.preventDefault();
				var s:String = e.data;
				var currentTabData:TabData =  viewInstance.selectedTabData;
				for each(var i:TabData in tabs)
				{
					if(!i.keyWord || -1 != s.indexOf(i.keyWord))
					{
						i.text += s + "\n";
						if(i == currentTabData)
						{
							viewInstance.text = i.text;
						}
					}
				}
			}
		}
	}
}