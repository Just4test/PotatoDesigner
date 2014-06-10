package potato.designer.framework
{
	

	CONFIG::HOST
	{
		import flash.system.ApplicationDomain;
	}
	CONFIG::GUEST
	{
		import core.system.Domain;
	}

	public class PluginInfo
	{
		internal var _state:String;
		
		protected var _id:String;
		protected var _version:int;
		protected var _depend:Vector.<String>;
		protected var _startLevel:int;
		protected var _path:String;
		protected var _hostFile:String;
		protected var _hostClass:String;
		protected var _guestFile:String;
		protected var _guestEncryptionFile:String;
		protected var _guestClass:String;
		
		protected var _manifestStr:String;
		/**为true说明依赖已经满足。为false说明上次检查时还未满足*/
		protected var _isDependenciesMeet:Boolean;
		
		/**插件还未初始化或已经停止*/
		public static const STATE_STOP:String = "STATE_STOP";
		
		/**插件正常工作中*/
		public static const STATE_RUNNING:String = "STATE_RUNNING";
		
		/**插件正在初始化*/
		public static const STATE_INITING:String = "STATE_INITING";
		
		CONFIG::HOST
		{
			/**插件还没有被载入。这是一个内部状态，此状态下的插件不应能被检索。*/
			public static const STATE_LOADING:String = "STATE_LOADING";
			
			protected var _domain:ApplicationDomain;
			
			internal function setDomain(domain:ApplicationDomain):void
			{
				_domain = domain;
				_state = STATE_STOP;
			}
		}
		
		CONFIG::GUEST
		{
			/**插件还没有被载入。这是一个内部状态，此状态下的插件不应能被检索。*/
			public static const STATE_LOADING:String = "STATE_LOADING";
			
			protected var _domain:Domain;
			
			internal function setDomain(domain:Domain):void
			{
				_domain = domain;
				_state = STATE_STOP;
			}
		}
		
		/**
		 *创建插件信息对象 
		 * @param path 插件文件夹路径
		 * @param manifestStr 插件清单文件内容
		 */
		public function PluginInfo(path:String, manifestStr:String)
		{
			_path = path;
			_manifestStr = manifestStr;
			
			CONFIG::HOST
			{
				_state = STATE_LOADING;
			}
			CONFIG::GUEST
			{
				_state = STATE_STOP;
			}
			
			var manifest:Object = JSON.parse(_manifestStr);
			_id = manifest.id;
			_version = manifest.version;
			_depend = Vector.<String>(manifest.depend);
			_startLevel = manifest.startLevel;
			_hostFile = manifest.hostFile;
			_hostClass = manifest.hostClass;
			_guestFile = manifest.guestFile;
			_guestEncryptionFile = manifest.guestEncryptionFile;
			_guestClass = manifest.guestClass;
		}
		
		/**
		 *由插件自身调用，标记自己已经完成了启动
		 */
		public function started():void
		{
			PluginManager.pluginStarted(this);
		}
		
		
		
		/**指示某个插件的依赖关系是否已经满足，可以启动*/
		public function get isDependenciesMeet():Boolean
		{
			if(_isDependenciesMeet)
				return true;
			
			for each(var id:String in _depend)
			{
				if(!PluginManager.getPluginById(id))
					return false;
			}
			
			_isDependenciesMeet = true;
			return true;
		}
		
		internal function start():void
		{
			if(!isDependenciesMeet)
			{
				throw new Error("[Plugin] 尝试启动未满足依赖的插件[" + _id + "]");
			}
			
			log("[Plugin] 插件[" + _id + "]正在启动");
			var activator:IPluginActivator;
//			try
//			{
				CONFIG::HOST
				{
					//从Manager的domain创建启动类实例
					var activatorClass:Class = _domain.getDefinition(startClassName) as Class;
				}
				
				CONFIG::GUEST
				{
					var activatorClass:Class = _domain.getClass(startClassName);
				}
				
				activator = new activatorClass();
				_state = STATE_INITING;
				activator.start(this);
				
//			}
//			catch(error:Error)
//			{
//				log("[Plugin] 启动插件[" + _id + "]时发生错误，\n" + error);
//			}
			
		}
		
		//////////////////////////////////////////
		
		
		/**插件的状态*/
		public function get state():String
		{
			return _state;
		}
		
		/**插件id*/
		public function get id():String
		{
			return _id;
		}

		/**该插件所依赖的其他插件的id表*/
		public function get depend():Vector.<String>
		{
			return _depend.concat();
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get startable():Boolean
		{
			
//			CONFIG::HOST{return }
			return false;
		}
		
		/**该插件的文件夹路径*/
		public function get path():String
		{
			return _path;
		}
		
		/**
		 * 获取插件文件夹中文件的绝对路径
		 * @param relativePath 文件于插件文件夹的相对路径
		 * @return 绝对路径
		 * 
		 */
		public function getAbsolutePath(relativePath:String):String
		{
			return _path + "/" + relativePath;
		}
		
		/**该插件在当前环境下的执行文件路径*/
		public function get startFilePath():String
		{
			CONFIG::HOST
			{
				return _path + "/" + _hostFile;
			}
			
			CONFIG::GUEST
			{
				return _path + "/" + _guestFile;
			}
		}
		
		/**该插件在当前环境下的启动类名*/
		public function get startClassName():String
		{
			CONFIG::HOST
			{
				return _hostClass;
			}
			
			CONFIG::GUEST
			{
				return _guestClass;
			}
		}

		public function get startLevel():int
		{
			return _startLevel;
		}


	}
}