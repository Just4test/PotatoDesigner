package potato.res
{
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import core.display.Image;
	import core.display.SubTexture;
	import core.display.Texture;
	import core.display.TextureData;
	import core.events.EventDispatcher;
	import core.filesystem.File;
	import core.media.Sound;
	import core.system.System;
	import core.utils.WeakDictionary;
	
	import potato.display.AsyncImage;
	import potato.events.HttpEvent;
	import potato.logger.Logger;
	import potato.net.MultiLoader;
	import potato.utils.Utils;

	registerClassAlias("sf.res.ResBean", ResBean);
	registerClassAlias("sf.res.SubBean", SubBean);
	
	/**
	 * 资源管理核心类.  
	 * 获取资源使用Res的静态方法，res实例只是用来附加资源配置和下载资源使用，
	 * 也可以在res实例上添加HttpEvent来监听下载进度。
	 * 该类在发布环境里需要配合pvrtool和versiontool两个外部工具使用。
	 * pvrtool是把图片和声音资源压缩为指定格式，并预处理配置文件；
	 * versiontool负责管理版本更新。
	 */	
	public final class Res extends EventDispatcher
	{
		/**名字-找到对应的配置对象*/
		private static var name_cfg:Object = new Object();
		/**子材质信息*/
		private static var subName_cfg:Object = new Object();

		/**名字_材质（弱引用）*/
		private static var name_texture_weak:WeakDictionary = new WeakDictionary();

		/**名字_材质（缓存）*/
		private static var name_texture_cache:Object = new Object();

		/**日志*/
		private static var log:Logger = Logger.getLog("Res");

		/**已经初始过的配置文件*/
		private static var initedConfig:Object = new Object();

		/**下载令牌_异步Image对象*/
		private static var loadingImage:Dictionary = new Dictionary();
		
		/**初始化配置文件路径*/
		public static var resourcePath:String;
		
		/**更新文件*/
		public static const UPDATE_FILE:String = "update.am";
		/**更新文件中的版本号*/
		public static var currVer:int;
		
		/**本地化语言字符串*/
		private static var localStrDic:Object = new Object();
		
		/**异步图片用下载，用在运行时加载*/
		private static var imageLoader:MultiLoader;
		
		/**声音，使用弱字典*/
		private static var soundDic:WeakDictionary = new WeakDictionary();

		/**普通文件资源，使用弱字典*/
		private static var commFileDic:WeakDictionary = new WeakDictionary();

		/**
		 * 用日志打印当前Res 里面所有存储的图片占用的内存 
		 */
		public static function testRAM():int
		{
			System.gc();
			var ram1:int,ram2:int;
			for each (var t:Texture in name_texture_cache) 
			{
				ram1 += t.width * t.height;
			}
			name_texture_weak.length;
			for each (var t1:Texture in name_texture_weak) 
			{
				ram2 += t1.width * t1.height;
			}
			log.debug("缓存资源/不缓存资源", ram1 / 1024 / 1024, ram2 / 1024 / 1024);
			return ram1+ram2;
		}
		
		/**
		 * 判断当前材质有没有存在 
		 * @param name		名字
		 * @return 			true=存在
		 */
		public static function testTexture(name:String):Boolean
		{
			return name_texture_weak[name];
		}
		
		public function Res()
		{
			versionInit();
			
			if (imageLoader == null) {
				imageLoader = new MultiLoader(currVer);
				imageLoader.addEventListener(HttpEvent.RES_LOAD_COMPLETE, imgComplete);
				imageLoader.addEventListener(HttpEvent.RES_LOAD_FAILED, imageFailed);
			}
		}
		
		/**配置文件和初始资源下载*/
		private var loader:MultiLoader;
		
		/**当前配置文件的完整路径*/
		private var cfgUrl:String;
		/**当前实例所有资源令牌*/
		private var tokens:Dictionary;
		/**错误列表*/
		private var _errors:Array = [];
		/**是否初始化资源*/
		private var _initRes:Boolean;
		
		private var _hasAppend:Boolean;
		
		
		private function processCfg(url:String, initRes:Boolean):void {
			if (!_hasAppend)
			{
				tokens = new Dictionary();
				cfgUrl = url;
				if (initedConfig[cfgUrl]) //配置文件已经初始过了
				{
					dispatchEvent(new HttpEvent(HttpEvent.RES_LOAD_COMPLETE, cfgUrl));
					return;
				}
				_initRes = initRes;
				loader = new MultiLoader(currVer);
				var md5:String = versionTest(cfgUrl);
				if (md5 || !File.exists(cfgUrl)) {
					loader.addEventListener(HttpEvent.RES_LOAD_FAILED, cfgLoadFailed);
					loader.addEventListener(HttpEvent.RES_LOAD_COMPLETE, cfgComplete);
					loader.push(cfgUrl, md5);
				} else {
					resLoad();
					versionSetNew(cfgUrl);
					readConfig();
				}
				_hasAppend = true;
				
				//todo 从Boot过来不用下载 配置文件
			}
			else
			{
//				log.debug("不能同时初始化2个");
			}
		}
		
		/**
		 * 使用配置文件中的key附加资源
		 * @param resKey
		 * @param initRes
		 */		
		public function appendCfgWithKey(resKey:String, initRes:Boolean = false):void
		{
			var b:ResBean = getResBean(resKey);
			if (b == null) log.debug(resKey, "找不到资源bean。");
			processCfg(b.path, initRes);
		}
		
		/**
		 * 添加配置文件
		 * @param path		配置文件路径，这个路径使用没有前缀的
		 * @param initRes	是否初始化资源
		 */
		public function appendCfg(cfgPath:String, initRes:Boolean = false):void
		{
			processCfg(Utils.getDefaultPath(cfgPath), initRes);
		}

		/**
		 * 加载完成
		 * @param e
		 */
		private function cfgComplete(e:HttpEvent):void
		{
			if (e.url == cfgUrl)
			{
				cleanLoad();
				resLoad();
				versionSetNew(cfgUrl);
				readConfig();
			}
		}

		/**
		 * 加载失败
		 * @param e
		 */
		private function cfgLoadFailed(e:HttpEvent):void
		{
			if (e.url == cfgUrl)
			{
				cleanLoad();
				dispatchEvent(e);
			}
		}

		/**
		 * 初始加载器清理
		 */
		private function cleanLoad():void
		{
//			loader.removeEventListener(HttpEvent.RES_LOAD_FAILED, cfgLoadFailed);
//			loader.removeEventListener(HttpEvent.RES_LOAD_COMPLETE, cfgComplete);
			loader.removeEventListeners();
		}
		
		
		/**
		 * 静态下载完成
		 * @param e
		 */		
		private static function imgComplete(e:HttpEvent):void
		{
			var ris:Array = loadingImage[e.url];
//			log.debug("+++++++++ imgCompleteimgCompleteimgComplete", e.url, ris.length);
//			if (ris == null) return;
			for each (var ri:ResInfoLoading in ris)
			{
				var img:AsyncImage = ri.img;
				var bean:ResBean = ri.bean;
				
				bean.isFileExist = 1;
				
				if (ri.img == null) {
//					log.debug("&&&&&&&&&&&&", ri.img);
					continue;
				}
				
				var texture:Texture = name_texture_weak[bean.id];
				if (!texture)
				{
					texture = new Texture(TextureData.createWithFile(bean.path));
					name_texture_weak[bean.id] = texture;
					
					if(bean.cache == 1)//强引用缓存
					{
						name_texture_cache[bean.id] = texture;
					}
				}
				
				if(img.rect1)//创建子材质的Image
				{
					img.texture = new SubTexture(texture, img.rect1, img.rect2);
				}
				else//创建大材质的Image
				{
					img.texture = texture;
				}
			}
//			else if(e.token.type == 1)
//			{
//				
//			}
			delete loadingImage[e.url];
		}
		
		/**
		 * 静态下载失败 
		 * @param e
		 */		
		private static function imageFailed(e:HttpEvent):void
		{
			//TODO 目前忽略
		}

		/**
		 * 加载资源监听
		 */
		private function resLoad():void
		{
			loader.addEventListener(HttpEvent.RES_LOAD_FAILED, resLoadField);
			loader.addEventListener(HttpEvent.RES_LOAD_COMPLETE, resLoadComplete);
			loader.addEventListener(HttpEvent.RES_LOAD_PROGRESS, resLoadProgress);
		}
		
		/**
		 * 清理当前类的资源下载监听 
		 */		
		private function cleanResLoad():void
		{
			loader.removeEventListener(HttpEvent.RES_LOAD_FAILED, resLoadField);
			loader.removeEventListener(HttpEvent.RES_LOAD_COMPLETE, resLoadComplete);
			loader.removeEventListener(HttpEvent.RES_LOAD_PROGRESS, resLoadProgress);
		}
		
		/**
		 * 读取配置文件
		 */
		private function readConfig():void
		{
			var plat:int = Utils.platformVer();
			var currObj:Object;
			//模拟测试环境
			if((plat == Utils.PV_DEV || plat == Utils.PV_WIN) && !Utils.testPVR)
			{
				currObj = CfgFileUtil.readTxt(File.read(cfgUrl), ResBean, "id", name_cfg);
			}
			else
			{
				currObj = CfgFileUtil.readObject(File.readByteArray(cfgUrl), name_cfg);
			}
//			var atlas:Boolean = false;
//			var res:Boolean;
			for each (var bean:Object in currObj)
			{
//				res = true;
				var md5:String = versionTest(bean.path);
				if( _initRes && (md5 || !File.exists(bean.path)) ) {
					//tokens[loader.push(getUrl(bean.path), reload)] = {path: bean.path, atlas: false};
					tokens[bean.path] = new ResInfoLoading(bean.path, false, null);
					loader.push(bean.path, md5);
//				} else {
//					parseAtlas(bean.path);
				}
				
				if (bean.atlas) {
					md5 = versionTest(bean.atlas);
					if (md5 || !File.exists(bean.atlas)) {
	//					tokens[loader.push(getUrl(bean.atlas), reload)] = {path: bean.atlas, atlas: true, parent: bean.id};
						tokens[bean.atlas] = new ResInfoLoading(bean.atlas, true, bean.id);
						loader.push(bean.atlas, md5);
//						atlas = true;
					} else {
						readAtlas(bean.atlas, bean.id);
						versionSetNew(bean.atlas);
					}
				}
			}
			
			resLoadEnd();
			
//			if((!atlas && !_initRes) || !res)
//			{
//				initedConfig[cfgSrcPath] = true;
//				dispatchEvent(new HttpEvent(HttpEvent.RES_LOAD_COMPLETE, cfgSrcPath));
//			}
//			log.debug("解析配置文件时间1", getTimer() - t);
		}

		/**
		 * 资源加载完成
		 * @param e
		 */
		private function resLoadComplete(e:HttpEvent):void
		{
			var path:String = e.url;
			var resInfo:ResInfoLoading = tokens[path]; 
			if (resInfo)
			{
//				var path:String = resInfo.path;
				var atlas:Boolean = resInfo.atlas;
				
				if (atlas)
					readAtlas(path, resInfo.parent);
				
				versionSetNew(path);
				delete tokens[path];
				
				resLoadEnd();
			}
		}
		
		private function resLoadEnd():void {
			for each (var obj:Object in tokens)
			{
				return;
			}
			
			cleanResLoad();
			
			if (_errors.length == 0)
			{
				initedConfig[cfgUrl] = true;
				dispatchEvent(new HttpEvent(HttpEvent.RES_LOAD_COMPLETE, cfgUrl));
			}
			else 
			{
				dispatchEvent(new HttpEvent(HttpEvent.RES_LOAD_FAILED, cfgUrl));
			}
		}
		
		/**预加载代码-------------－－－－－－－－－－－start ---*/
		/**是否正在后台加载**/
		private var _isBackLoader:Boolean;
		/**预加载数组**/
		private var _priorLoaderList:Array;
		private var _loadEndNum:int;
		/**
		 *添加要优先加载的资源列表
		 * 前提条件是，资源名称配置文件已加载
		 * 此方法会停止当前后台加载，然后把优先加载的添加到队列前，重新开始另载
		 * @param arr		资源名称数组
		 */		
		public function addPriorLoad(arr:Array,isProgress:Boolean):void
		{
			if(loader)
			{
				_isBackLoader = loader.loadingCnt()>0;
				if(_isBackLoader)
				{
					loader.stop();
					cleanResLoad();
				}
					
			}else
			{
				loader = new MultiLoader(currVer);
				tokens = new Dictionary();
			}
			loader.addEventListener(HttpEvent.RES_LOAD_COMPLETE,onLoaderPriorCompleteHanedler);
			_loadEndNum = 0;
			_priorLoaderList = arr;
			for(var i:int=0;i< _priorLoaderList.length;i++)
			{
				var name:String = _priorLoaderList[i];
				var subInfo:SubBean = subName_cfg[name];
				var bean:ResBean;
				if (subInfo) //子材质
				{
					if(!subInfo.rect1){
						subInfo.parentBean = bean = name_cfg[subInfo.parent];
					} else {
						bean = subInfo.parentBean;
					}
				}
				else if (name_cfg[name]) //大材质
				{
					bean = name_cfg[name];
				}
				if(bean == null)
				{
					_priorLoaderList.splice(i,1);
					i--;
					continue;
				}
					
				var srcPath:String = bean.path;
				var texturePath:String = srcPath;// getPath(bean.id);//材质资源路径
				var md5:String = versionTest(texturePath);
				if (bean.isFileExist == -1) {
					if(!File.exists(texturePath) || md5)
						bean.isFileExist = 0;
					else
						bean.isFileExist = 1;
				}
				
				if(bean.isFileExist ==0)
				{
					//需要下载
					trace("需要下载的战斗资源",bean.path);
					tokens[bean.path] = new ResInfoLoading(bean.path, false, null);
					loader.unShift(bean.path, md5);
				}
				else
				{
					trace("不需要下载的战斗资源",name);
					onLoaderPriorCompleteHanedler(null);
				}
			}
		}
		
		private function onLoaderPriorCompleteHanedler(e:HttpEvent):void
		{
			// TODO Auto Generated method stub
			_loadEndNum++;
			var len:int = _priorLoaderList.length;
			if(_loadEndNum == len)
			{
				loader.removeEventListener(HttpEvent.RES_LOAD_COMPLETE,onLoaderPriorCompleteHanedler);
				if(!_isBackLoader)
				{
					loader.stop();
				}else
				{
					resLoad();
				}
			}
			dispatchEvent(new HttpEvent(HttpEvent.RES_LOAD_COMPLETE, _loadEndNum/len+""));
			if(e)
				resLoadComplete(e);
		}
		
		/**预加载代码-------------－－－－－－－－－－－end ---*/
		
		/**
		 * 读取并解析图集
		 * @param path
		 */
		private function readAtlas(path:String, parent:String):void
		{
			var plat:int = Utils.platformVer();
			//模拟测试环境
			if((plat == Utils.PV_DEV || plat == Utils.PV_WIN) && !Utils.testPVR)
			{
				var xml:XML = new XML(File.read(path));
				for each (var subTexture:XML in xml.sprite)
				{
					var name:String = String(subTexture.attribute("n"));
					var info:SubBean = new SubBean();
					var x:int = int(subTexture.attribute("x"));
					var y:int = int(subTexture.attribute("y"));
					var width:int = int(subTexture.attribute("w"));
					var height:int = int(subTexture.attribute("h"));
					var px:int = int(subTexture.attribute("oX"));
					var py:int = int(subTexture.attribute("oY"));
					var pw:int = int(subTexture.attribute("oW"));
					var ph:int = int(subTexture.attribute("oH"));
					var rect1:Rectangle = new Rectangle(x, y, width, height);
					var rect2:Rectangle = null;
					if (px != 0 || py != 0 || pw != 0 || ph != 0)
						rect2 = new Rectangle(px, py, pw, ph);
					info.rect1 = rect1;
					info.rect2 = rect2;
					info.parent = parent;
					info.parentBean = name_cfg[parent];
					subName_cfg[name] = info;
				}
			}
			else
			{ 
				var tt:int = getTimer();
				CfgFileUtil.readObject(File.readByteArray(path), subName_cfg);
//				log.debug("解析配置文件时间2", getTimer() - t, " ", getTimer()-tt);
			}
		}


		/**
		 * 资源加载失败
		 * @param e
		 */
		private function resLoadField(e:HttpEvent):void
		{
			var resInfo:ResInfoLoading = tokens[e.url];
			if (resInfo)
			{
				_errors.push(resInfo.path);
				delete tokens[e.url];
				for each (var obj:Object in tokens)
				{
					return;
				}
				dispatchEvent(new HttpEvent(HttpEvent.RES_LOAD_FAILED, e.url));
			}
		}

		/**
		 * 资源加载进度
		 * @param e
		 */
		private function resLoadProgress(e:HttpEvent):void
		{
			//TODO 目前忽略
			dispatchEvent(new HttpEvent(HttpEvent.RES_LOAD_PROGRESS,e.url));
		}

		/**
		 * 下载错误的路径		 * @return
		 */
		public function get errors():Array
		{
			return _errors;
		}
		
//		//测试用
//		public static function getImageByName(__name:String):Image
//		{
//			return new Image(new Texture(TextureData.createWithFile(__name)));
//		}
//		
//		//测试用
//		public static function getTextureByName(__name:String):Texture
//		{
//			return new Texture(TextureData.createWithFile(__name));
//		}

		/**
		 * 获得一个Image对象. 对本地同步读取和网络异步下载图片进行了统一。
		 * @param name
		 */
		public static function getImage(name:String):Image
		{
//			log.debug("getImage", name);
			
			var bean:ResBean;
			var subInfo:SubBean = subName_cfg[name];
			if (subInfo) //子材质
			{
				if(!subInfo.rect1)
				{
					subInfo.rect1 = new Rectangle(subInfo.x1,subInfo.y1,subInfo.w1,subInfo.h1);
					if(subInfo.x2 > 0 || subInfo.y2 > 0 || subInfo.w2 > 0 || subInfo.h2 > 0)
					{
						subInfo.rect2 = new Rectangle(subInfo.x2,subInfo.y2,subInfo.w2,subInfo.h2);
					}
					subInfo.parentBean = bean = name_cfg[subInfo.parent];
				} else {
					bean = subInfo.parentBean;
				}
			}
			else if (name_cfg[name]) //大材质
			{
				bean = name_cfg[name];
			}

			if (!bean)
			{
//				log.error(name, "getImage(), 没有图片Bean");
				return new Image(null);
			}
			
			var srcPath:String = bean.path;
			var texturePath:String = srcPath;// getPath(bean.id);//材质资源路径
			var md5:String = versionTest(texturePath);
			if (bean.isFileExist == -1) {
				if(!File.exists(texturePath) || md5)
					bean.isFileExist = 0;
				else
					bean.isFileExist = 1;
			}
			
			//判断文件是否存在  && 需要更新（如果本地没有这个文件。缓存里面肯定没有这个文件的材质信息）
			if( bean.isFileExist == 0 )
			{
				return loadAsyncImage(srcPath, texturePath, md5, bean, subInfo);
			}
				
			var texture:Texture = name_texture_weak[bean.id];
			if (!texture)
			{
				//没有缓存，创建并且缓存
				texture = createTexture(srcPath);
				name_texture_weak[bean.id] = texture;
				
				if (bean.cache == 1) //当前资源需要缓存
				{
					name_texture_cache[bean.id] = texture;
				}
			}

			if (subInfo)
			{
				return new Image(new SubTexture(texture, subInfo.rect1, subInfo.rect2));
			}
			else
			{
				return new Image(texture);
			}

			return null;
		}
		
		private static function loadAsyncImage(srcPath:String, texturePath:String, md5:String,
											   bean:ResBean, subInfo:SubBean):AsyncImage {
			var arr:Array = loadingImage[srcPath];
			if (arr == null) {
				arr = (loadingImage[srcPath] = []);
				imageLoader.push(srcPath, md5);
			}
			
			var aimg:AsyncImage = new AsyncImage(null);
			if(subInfo)
			{
				aimg.rect1 = subInfo.rect1;
				aimg.rect2 = subInfo.rect2;
			}
			
			var ri:ResInfoLoading = new ResInfoLoading(srcPath, false, null);
//			ri.type = 0;
			ri.bean = bean;
			ri.img = aimg;
			
			arr.push(ri);
			return aimg;
		}
		
		/**
		 * 获得子材质Bean 
		 * @return 
		 */		
		public static function getSubBean(name:String):SubBean
		{
			return subName_cfg[name];
		}
		
		private static function createTexture(path:String):Texture
		{
//			System.gc();
//			log.debug("创建材质", path);
			try
			{
				return new Texture(TextureData.createWithFile(path));
			}
			catch(e:Error)
			{
			}
			return null;
		}

		/**
		 * 根据名字获得图片路径
		 * @param name		名称
		 * @return 			图片路径
		 */
//		public static function getPath(name:String):String
//		{
//			return getUrl(name_cfg[name].path);
//		}
		
		/**
		 * 根据名字获得资源bean 
		 * @param name
		 * @return 
		 */
		public static function getResBean(name:String):ResBean
		{
			return name_cfg[name];
		}

		/**
		 * 根据名字获得图集配置路径
		 * @param name
		 * @return
		 */
		public static function getAtlas(name:String):String
		{
			return String(name_cfg[name].atlas);
		}

		/**
		 * 获得材质 
		 * @param name
		 * @return 当图片不存在时返回 null
		 */
		public static function getTexture(name:String):Texture
		{
//			log.debug("getTexture", name);
			
			var bean:ResBean;
			var subInfo:SubBean = subName_cfg[name];
			if (subInfo) //子材质
			{
				if(!subInfo.rect1)
				{
					subInfo.rect1 = new Rectangle(subInfo.x1,subInfo.y1,subInfo.w1,subInfo.h1);
					if(subInfo.x2 > 0 || subInfo.y2 > 0 || subInfo.w2 > 0 || subInfo.h2 > 0)
					{
						subInfo.rect2 = new Rectangle(subInfo.x2,subInfo.y2,subInfo.w2,subInfo.h2);
					}
					subInfo.parentBean = bean = name_cfg[subInfo.parent];
				} else {
					bean = subInfo.parentBean;
				}
			}
			else if (name_cfg[name]) //大材质
			{
				bean = name_cfg[name];
			}
			
			if (!bean)
			{
//				log.error(name, "getTexture(), 没有图片Bean");
				return null;
			}
				
			var texture:Texture = name_texture_weak[bean.id];
			if (!texture)
			{
				 //没有缓存，创建并且缓存
				var srcPath:String = bean.path;
				var texturePath:String = srcPath;
				texture = createTexture(texturePath);
				
				if(!texture)
				{ //下载
					var md5:String = versionTest(texturePath);
					if(!File.exists(texturePath) || md5) {
						var arr:Array = loadingImage[srcPath];
						if (arr == null) {
							arr = (loadingImage[srcPath] = []);
							imageLoader.push(srcPath, md5);
						}
						
						var ri:ResInfoLoading = new ResInfoLoading(srcPath, false, null);
//						ri.type = 1;
						ri.bean = bean;
						
						arr.push(ri);
					}
					
//					if (bean.isFileExist == -1) {
//						
//					}
					return null;
				}
				
				name_texture_weak[bean.id] = texture;
				
				if (bean.cache == 1) //当前资源需要缓存
				{
					name_texture_cache[bean.id] = texture;
				}
			}
			
			if(subInfo)
				return new SubTexture(texture, subInfo.rect1, subInfo.rect2);
			
			return texture;
		}
		
		
		/**
		 * 获取声音，目前不支持后下载，必须要确保声音文件在本地有
		 * @param resKey 资源配置中的id
		 * @return 
		 */		
		public static function getSound(resId:String):Sound {
			var snd:Sound = soundDic[resId];
			if (snd == null) {
				var b:ResBean = name_cfg[resId];
				if (!b || !File.exists(b.path)) {//path为空的判断已经在工具里做了，这里省掉
					return null;
				} else {
					snd = new Sound(b.path);
					soundDic[resId] = snd;
				}
			}
			return snd;
		}
		
		/**
		 * 获取一个文件的二进制内容，一般用在多次读取文件或文件需要升级的地方
		 * @param resId
		 * @return 
		 */		
		public static function getFile(resId:String):ByteArray {
			var ba:ByteArray = commFileDic[resId];
			if (ba == null) {
				var b:ResBean = name_cfg[resId];
				if (!b || !File.exists(b.path)) {
					return null;
				} else {
					ba = File.readByteArray(b.path);
					commFileDic[resId] = ba;
				}
			}
			return ba;
		}

		/////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////// i18n //////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////
		/**
		 * 获得语言相关的字符串资源。
		 * 通常情况下，应把语言配置文件配到资源配置文件中，而配置中的文件路径不应附加任何
		 * 地区和语言的字符串，参数base应该是配置中的资源id。
		 * @param base 字符串资源基名，一般是资源配置文件中的id
		 * @param key 字符串资源key
		 * @return 
		 */	
		public static function getString(base:String, key:String):String {
			var dic:Object = localStrDic[base];
			if (dic == null) {
				var fn:String = null;
				var bean:ResBean = getResBean(base);
				if (bean) {
					fn = bean.path;
					var ext:String = "";
					var ip:int = fn.indexOf(".");
					if (ip > 0) {
						ext = fn.substring(ip);
						fn = fn.substring(0, ip);
					}
					fn = fn + "_" + Utils.DEFAULTLOCALE + ext;
				}
				if (fn == null || !File.exists(fn)) {
					fn = "language/" + base + "_" + Utils.DEFAULTLOCALE + ".txt";
					if (!File.exists(fn)) {
						fn = "language/" + base + ".txt";
					}
				}
				
				dic = readLocaleStr(fn);
				localStrDic[base] = dic;
			}
			return dic[key];
		}
		
		private static function readLocaleStr(fileName:String):Object {
			var o:Object = new Object();
			if ((Utils.PV_DEV == Utils.platformVer() || Utils.PV_WIN == Utils.platformVer()) && !Utils.testPVR) {
				var cfg:String = File.read(fileName);
				var arr:Array = cfg.split(/\r\n|\r|\n/);
				var s:String;
				var i:int;
				var key:String, value:String;
				for each (s in arr) {
					if (s && s.indexOf("#") != 0)
					{
						i = s.indexOf("\t");
						if (i < 0) continue;
						key = s.substr(0, i);
						value = s.substr(i+1);
						o[key] = value;
					}
				}
			} else {
				var ba:ByteArray = File.readByteArray(fileName);
				ba.uncompress();
				o = ba.readObject();
			}
			
			return o;
		}
		/////////////////////////////////////////////////////////////////////////////

		//////////////////////////////////////////////////
		/**待更新资源表*/
		private static var versionOldList:Object;
		private static var version_LastVersion:int = 0;
		
		private static function get versionLastVersion():int
		{
			return version_LastVersion;
		}
		
		/**测试资源文件是否需要更新。需要更新的话返回文件的md5。*/
		public static function versionTest(path:String):String
		{
//			if (versionOldList[path]) return true; //此处需保证更新列表中所有文件都有md5值
//			if (!File.exists(path)) return true; //此文件本地没有
			return versionOldList[path];  //此处需保证更新列表中所有文件都有md5值
		}
		private static var _versionSetNewCont:int = 0;
		/**设置资源文件为最新。*/
		private static function versionSetNew(path:String):void
		{
			if(versionOldList[path])
			{
				delete versionOldList[path];
				versionSave();//很慢的赶脚！
			}
		}

		/**导入版本记录。必须在任何版本相关操作之前执行此操作。*/
		private static function versionInit():void
		{
			if(versionOldList)
			{
				return;
			}
			if(File.exists(UPDATE_FILE))
			{
				var bytes:ByteArray = File.readByteArray(UPDATE_FILE);
				currVer = bytes.readInt();
				versionOldList = bytes.readObject();
			}
			else
			{
				currVer = 1;
				versionOldList = new Object();
			}
		}
		
		private static function versionSave():void
		{
			var b:ByteArray = new ByteArray();
			b.writeInt(currVer);
			b.writeObject(versionOldList);
			File.writeByteArray(UPDATE_FILE, b); //保存到本地。最新更新列表
		}
		///////////////////////////////////////////////////

	}
}


import potato.display.AsyncImage;
import potato.res.ResBean;

class ResInfoLoading {
	public var path:String;
	public var atlas:Boolean;
	public var parent:String;
	
	public var bean:ResBean;
	public var img:AsyncImage;
	
	public function ResInfoLoading(path:String, atlas:Boolean, parent:String):void {
		this.path = path;
		this.atlas = atlas;
		this.parent = parent;
	}
}