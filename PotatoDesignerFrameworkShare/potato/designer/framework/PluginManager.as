package potato.designer.framework
{
	CONFIG::HOST
	{
		import flash.events.Event;
		import flash.filesystem.File;
		import flash.filesystem.FileMode;
		import flash.filesystem.FileStream;
		import flash.system.ApplicationDomain;
	}
	CONFIG::GHOST
	{
		
	}
	
	import core.filesystem.File;
	import core.filesystem.FileInfo;
	import core.system.Domain;

	public class PluginManager
	{
		/**当有一个新的插件被安装后派发此事件*/
		public static const EVENT_PLUGIN_INSTALLED:String = "EVENT_PLUGIN_INSTALLED";
		/**当有一个新的插件被激活后派发此事件*/
		public static const EVENT_PLUGIN_START:String = "EVENT_PLUGIN_START";
		/**指定清单文件的文件名*/
		public static const MANIFEST_FILE_NAME:String = "Manifest.json";
		
		public static const PLUGIN_FOLDER:String = "plugins";
		
		private static const _pluginList:Vector.<PluginInfo> = new Vector.<PluginInfo>;
		private static const _pluginMap:Object = new Object;
		
		
		
		CONFIG::HOST
		{
			/**
			 *宿主端所有插件共用的应用程序定义域 
			 */
			private static var _domain:ApplicationDomain;
			
			{
				_domain = new ApplicationDomain(ApplicationDomain.currentDomain);
			}
			
			private static function pluginLoadedHandler(e:Event):void
			{
				var pluginLoader:PluginLoader = e.target as PluginLoader;
				pluginLoader.removeEventListener(Event.COMPLETE, pluginLoadedHandler);
				pluginLoader.removeEventListener(PluginLoader.EVENT_FAIL, pluginLoadFailHandler);
				
				var pluginInfo:PluginInfo = pluginLoader.pluginInfo
				_pluginMap[pluginInfo.id] = pluginInfo;
				_pluginList.push(pluginInfo);
				pluginInfo.setDomain(pluginLoader.domain);
				EventCenter.dispatchEvent(new PluginEvent(EVENT_PLUGIN_INSTALLED, pluginInfo));
			}
			
			private static function pluginLoadFailHandler(e:Event):void
			{
				var pluginLoader:PluginLoader = e.target as PluginLoader;
				pluginLoader.removeEventListener(Event.COMPLETE, pluginLoadedHandler);
				pluginLoader.removeEventListener(PluginLoader.EVENT_FAIL, pluginLoadFailHandler);
				log("[Plugin] 载入插件失败");
			}
		}
		
		CONFIG::GHOST
		{
			//TODO
			private static var _domain:Domain;
		}
		
		/**清单文件内容示例*/
		private static const MANIFEST_FILE_EXAMPLE:Object = 
			{
//				id:"plugin1",					//指定插件id
//				version:1,						//指定插件版本。
				//depend:["GhostManager"],		//指定插件所依赖的其他插件id
//				startLevel:10,					//指定插件启动顺序。
//				hostFile:"plugin1Host.swf",	//指定宿主端类文件。
//				hostClass:"plugin1Host",		//指定宿主端启动类。该类具有无参构造方法，并且实现IPluginLoader
//				ghostFile:"plugin1Ghost.mbf",	//指定客户端类文件。通常在桌面上使用。
//				ghostEncryptionFile:
//						"plugin1GhostE.mbf",	//指定客户端加密类文件。在移动设备上使用。
				ghostClass:"plugin1Ghost"		//指定客户端启动类。该类具有无参构造方法，并且实现IPluginLoader
			};
		
		/**扫描 Plugin文件夹以便发现所有插件*/
		public static function scan():void
		{
			CONFIG::HOST
			{
				var fileStream:FileStream = new FileStream();
				
				//扫描程序安装目录
				trace(File.applicationDirectory.nativePath);
				scanThisDir(File.applicationDirectory.resolvePath(PLUGIN_FOLDER));
				//扫描工程目录
				//TODO
				
				function scanThisDir(dir:File):void
				{
					var nodes:Array = dir.getDirectoryListing();
					for (var i:uint = 0; i < nodes.length; i++)  
					{ 
						var file:File = nodes[i] as File;
						if (file.isDirectory)
						{
							var manifestFile:File = new File(file.nativePath + "/" + MANIFEST_FILE_NAME);
							if(manifestFile.exists)
							{
								fileStream.open(manifestFile, FileMode.READ);
								var str:String = fileStream.readMultiByte(fileStream.bytesAvailable, File.systemCharset);
								fileStream.close();
								
								try
								{
									var pluginInfo:PluginInfo = new PluginInfo(file.nativePath, str);
									var pluginLoader:PluginLoader = new PluginLoader(pluginInfo, _domain);
									pluginLoader.addEventListener(Event.COMPLETE, pluginLoadedHandler);
									pluginLoader.addEventListener(PluginLoader.EVENT_FAIL, pluginLoadFailHandler);
								}
								catch(error:Error)
								{
									log("加载位于", file.nativePath, "的插件时发生错误\n", error);
								}
								
							}
						}
						
						
					} 
				}
			}
				
			CONFIG::GHOST
			{
				//如果插件目录不存在或者不是目录则返回
				if(!File.exists(PLUGIN_FOLDER + "/."))
				{
					return;
				}
				
				var array:Array = File.getDirectoryListing(PLUGIN_FOLDER);
				
				for each(var i:FileInfo in array)
				{
					if(!i.isDirectory || "." == i.name || ".." == i.name)
					{
						continue;
					}
					
					var foldPath:String = PLUGIN_FOLDER + "/" + i.name;
					var filePath:String = foldPath + "/" + MANIFEST_FILE_NAME;
					if(File.exists(filePath))
					{	
						try
						{
							var pluginInfo:PluginInfo = new PluginInfo(foldPath, File.read(filePath));
							
						}
						catch(error:Error)
						{
							log("加载位于", foldPath, "的插件时发生错误\n", error);
						}
					}
				}
			}
		}
		
		/**
		 *尝试启动插件。这个方法只是表明一种意向，并不保证插件一定可以启动
		 * @param id 插件id
		 * @return 插件是否已经成功启动。
		 * <br>返回true说明插件早已启动或者在刚刚的操作中成功启动。
		 * <br>返回false说明插件尚未启动完成或者因为未满足依赖而延迟启动。
		 * 
		 */
		public static function startPlugin(id:String):Boolean
		{
			var plugin:PluginInfo = _pluginMap[id];
			
			if(!plugin)
			{
				throw new Error("尝试启动不存在的插件[" + id + "]");
			}
			
			switch(plugin.state)
			{
				case PluginInfo.STATE_RUNNING:
					return true;
				case PluginInfo.STATE_INITING:
					return false;
				case PluginInfo.STATE_STOP:
					if(plugin.isDependenciesMeet)
					{
						plugin.start();
						if(PluginInfo.STATE_RUNNING == plugin.state)
						{
							return true;
						}
						return false;
					}
				default:
					throw new Error("插件[" + id + "]的状态是非法值\"" + plugin.state + "\"");
			}
		}
		
		
		/**获得插件列表*/
		public static function get pluginList():Vector.<PluginInfo>
		{
			return _pluginList.concat();//返回副本
		}
		
		/**根据id获得插件*/
		public static function getPluginById(id:String):PluginInfo
		{
			return _pluginMap[id];
		}
		
		
		
		
	}
}