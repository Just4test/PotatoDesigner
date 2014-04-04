package potato.designer.framework
{

	CONFIG::HOST
	{
		import flash.system.ApplicationDomain;
	}

	public class PluginInfo
	{
		protected var _state:String;
		
		protected var _id:String;
		protected var _version:int;
		protected var _depend:Vector.<String>;
		protected var _startLevel:int;
		protected var _path:String;
		protected var _hostFile:String;
		protected var _hostClass:String;
		protected var _ghostFile:String;
		protected var _ghostEncryptionFile:String;
		protected var _ghostClass:String;
		
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
				_state = STATE_LOADING;
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
			_manifestStr = _manifestStr;
			
			CONFIG::HOST
			{
				_state = STATE_LOADING;
			}
			CONFIG::GHOST
			{
				_state = STATE_STOP;
			}
			
			var manifest:Object = JSON.parse(_manifestStr);
			_id = manifest.id;
			_version = manifest.version;
			_depend = Vector.<String>(manifest.depend);
		}
		
		/**
		 *由插件自身调用，标记自己已经完成了启动
		 */
		public function started():void
		{
			if(STATE_INITING == _state)
			{
				_state = STATE_RUNNING;
				
			}
			throw new Error("插件[" + _id + "]于" + _state + "状态下尝试报告其启动完成");
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
				throw new Error("尝试启动未满足依赖的插件[" + _id + "]");
			}
			
			var activator:IPluginActivator;
			try
			{
				CONFIG::HOST
				{
					//从Manager的domain创建启动类实例
					var activatorClass:Class = _domain.getDefinition(startClass) as Class;
					activator = new activatorClass();
				}
				
				CONFIG::GHOST
				{
					;//TODO
				}
				
			}
			catch(error:Error)
			{
				log("启动插件[" + _id + "]时发生错误，\n" + error);
			}
			
			_state = STATE_INITING;
			activator.start(this);
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
		
		/**该插件在当前环境下的文件路径*/
		public function get filePath():String
		{
			CONFIG::HOST
			{
				return _path + "/" + _hostFile;
			}
			
			CONFIG::GHOST
			{
				//TODO
			}
		}
		
		/**该插件在当前环境下的启动类名*/
		public function get startClass():String
		{
			CONFIG::HOST
			{
				return _hostClass;
			}
			
			CONFIG::GHOST
			{
				//TODO
			}
		}

		public function get startLevel():int
		{
			return _startLevel;
		}


	}
}