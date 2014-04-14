package potato.designer.framework
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import potato.designer.utils.MultiLock;
	
	/**
	 * 
	 * @author Administrator
	 * 
	 */
	dynamic public class DataCenter extends Proxy
	{
		/**
		 *工作空间模板在应用程序安装目录中的路径 
		 */
		public static const WORKSPACE_TEMPLATE_FOLDER:String = "designer/workspaceTemplate";
		public static const WORKSPACE_FILE_NAME:String = "workspace.json";
		
		/**已经载入工作空间*/
		public static const EVENT_LOADED:String = "EVENT_LOADED";
		
		/**正在保存工作空间，等待所有插件响应
		 * <br>事件包含一个众锁，如果插件不能完成同步保存，请使用众锁保存。
		 */
		public static const EVENT_SAVING:String = "EVENT_SAVING";
		
		/**工作空间已经保存*/
		public static const EVENT_SAVED:String = "EVENT_SAVED";
		/**工作空间保存失败*/
		public static const EVENT_SAVE_FAIL:String = "EVENT_SAVE_FAIL";
		
		private static var _isWorkSpaceLoaded:Boolean;
		
		private static var _workSpaceFolderPath:String;
		
		private static var _multiLock:MultiLock;
		
		private static var _instance:DataCenter;
		
		/**属性对象*/
		private var _data:Object;
		/**属性注册表*/
		private var _regTable:Object;
		
		{
			_instance = new DataCenter;
		}
		
		
		public static function get instance():DataCenter
		{
			return _instance;
		}
		
		public static function get workSpaceFolderPath():String
		{
			return _workSpaceFolderPath;
		}
		
		/**
		 *载入或创建工作空间
		 * <br>必须在工作空间已经关闭的情况下执行。载入工作是同步的。
		 * @param path 工作空间的目录。如果指定目录下没有工作空间主文件，则以默认设置创建工作空间主文件并载入它。
		 * 
		 */
		public static function loadWorkSpace(path:String):Boolean
		{
			if(_isWorkSpaceLoaded)
			{
				throw new Error("工作空间未被关闭之前不得再次载入工作空间");
			}
			
			_workSpaceFolderPath = path;
			
			var folder:File = new File(_workSpaceFolderPath);
			if(folder.exists && !folder.isDirectory)
			{
				log("[DataCenter] 载入工作空间失败。路径是一个已经存在的文件\n", _workSpaceFolderPath);
				return false;
			}
			
			try
			{
				if(!folder.exists)
				{
					var template:File = File.applicationDirectory.resolvePath(WORKSPACE_TEMPLATE_FOLDER);
					template.copyTo(folder);
				}
			} 
			catch(error:Error) 
			{
				log("[DataCenter] 拷贝工作空间模板时发生错误：\n", error);
				return false;
			}
			
			try
			{
				var workspaceFile:File = folder.resolvePath(WORKSPACE_FILE_NAME);
				var fileStream:FileStream = new FileStream();
				fileStream.open(workspaceFile, FileMode.READ);
				var str:String = fileStream.readMultiByte(fileStream.bytesAvailable, File.systemCharset);
				fileStream.close();
				var data:Object = JSON.parse(str);
			} 
			catch(error:Error) 
			{
				log("[DataCenter] 载入工作空间时发生错误：\n", error);
				return false;
			}
			
			EventCenter.dispatchEvent(new Event(EVENT_LOADED));
			return true;
		}
		
		
		/**
		 *保存工作空间。将派发事件以便所有插件能够保存工作空间。 
		 * <br>保存工作不是同步的。保存完成后将派发事件。
		 */
		public static function saveWorkSpace():void
		{
			_multiLock = new MultiLock;
			EventCenter.dispatchEvent(new DesignerEvent(EVENT_SAVING, _multiLock));
			if(!_multiLock.isFree)
			{
				finishSave();
			}
			else
			{
				_multiLock.addEventListener(MultiLock.EVENT_DEAD, multiLockSaveHandler);
				_multiLock.addEventListener(MultiLock.EVENT_UNLOCKED, multiLockSaveHandler);
			}
		}
		
		private static function multiLockSaveHandler(event:Event):void
		{
			_multiLock.removeEventListener(MultiLock.EVENT_DEAD, multiLockSaveHandler);
			_multiLock.removeEventListener(MultiLock.EVENT_UNLOCKED, multiLockSaveHandler);
			
			switch(event.type)
			{
				case MultiLock.EVENT_DEAD:
				{
					finishSave();
					break;
				}
				case MultiLock.EVENT_UNLOCKED:
				{
					EventCenter.dispatchEvent(new Event(EVENT_SAVED));
					break;
				}
					
				default:
				{
					throw new Error("内部错误");
					break;
				}
			}
		}
		
		private static function finishSave():void
		{
			var data:Object = {};
			for(var i:String in instance._regTable)
			{
				var info:RegPropInfo = instance._regTable[i]
				if(info.needSave)
				{
					data[i] = instance._data[i];
				}
			}
			
			var jStr:String = JSON.stringify(data);
			
			var folder:File = new File(_workSpaceFolderPath);
			var workspaceFile:File = folder.resolvePath(WORKSPACE_FILE_NAME);
			var fileStream:FileStream = new FileStream();
			fileStream.open(workspaceFile, FileMode.WRITE);
			fileStream.writeMultiByte(jStr, File.systemCharset);
			fileStream.close();
			
			EventCenter.dispatchEvent(new Event(EVENT_SAVE_FAIL));
		}
		
		/**
		 *丢弃工作空间。将派发事件以便所有插件能够丢弃工作空间。
		 * <br>丢弃后将关闭工作空间，并且卸载所有插件。将派发工作空间关闭事件。请注意，任何插件都不能接收到工作空间关闭事件。
		 */
		public static function discardWorkSpace():void
		{
		}
		
		/**
		 *终止任何正在进行的工作
		 */
		public static function stop():void
		{
			if(!_multiLock)
				return;
			
			_multiLock.getLock("DataCenter::stop()").kill();
		}

		public static function get isWorkSpaceLoaded():Boolean
		{
			return _isWorkSpaceLoaded;
		}
		
		//////////////////////////////////////////////////////////
		
		public function DataCenter()
		{
			_data = new Object;
			_regTable = new Object;
		}
		
		
		
		override flash_proxy function callProperty(methodName:*, ... args):* {
			return _data[methodName].apply(_data, args);
		}
		
		override flash_proxy function getProperty(name:*):* {
			return _data[name];
		}
		
		override flash_proxy function setProperty(name:*, value:*):void {
			var regPropInfo:RegPropInfo = _regTable[name];
			if(regPropInfo)
			{
				if(!(value is regPropInfo.type))
				{
					throw new Error("属性[" + name + "]被设置为不相容的类型。预期类型为" + regPropInfo.type)
				}
				
				_data[name] = value;
				
				EventCenter.dispatchEvent(new DesignerEvent(regPropInfo.eventType, value));
			}
			else
			{
				_data[name] = value;
			}
		}
		
		/**
		 *注册属性。为属性指定数据类型和更改事件。
		 * <br>不预先注册也能使用属性存储值。并且如果在注册属性之前设置了不相容的数据类型，将不会报错。
		 * <br>示例：
		 * <br>DataCenter.instance.regProperty("mydata", int, "mydataChanged");
		 * <br>DataCenter.instance.mydata = 10; //EventCenter.dispatchEvent(new DesignerEvent("mydataChanged", 10));
		 * <br>DataCenter.instance.mydata = "10"; //throw new Error("属性[mydata]被设置为不相容的类型。预期类型为[class int]");
		 * @param name 属性名。
		 * @param type 属性的数据类型。如果在写属性时指定了不相容的数据类型将报错。
		 * @param value 属性的新值。为保证属性的值符合其数据类型，故要求重新赋值。
		 * @param save 指定该属性是否存储到工作空间。
		 * <br>&emsp;<b>注意</b>工作空间主配置文件使用json存储，所以请确保属性的数据类型可以被json化和反json化。仅仅建议使用字符串、数字、布尔值等基础类型。
		 * @param eventType 如果指定这个值，将在变量被set为新值时派发事件。
		 * 
		 */
		public function regProperty(name:String, type:Class, value:*, needSave:Boolean = false, eventType:String = null):void
		{
			_regTable[name] = new RegPropInfo(type, needSave, eventType);
			this[name] = value;
		}


	}
}

class RegPropInfo
{
	internal var type:Class;
	internal var needSave:Boolean;
	internal var eventType:String;
	
	function RegPropInfo(type:Class, needSave:Boolean, eventType:String)
	{
		this.type = type;
		this.needSave = needSave;
		this.eventType = eventType;
	}
}