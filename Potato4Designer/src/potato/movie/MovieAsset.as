package potato.movie
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	import core.filesystem.File;
	
	import potato.movie.dragon.FrameData;
	import potato.res.Res;
	import potato.res.ResBean;
	

	/**
	 *
	 * Jun 5, 2012
	 */
	public class MovieAsset
	{
		/**资源列表*/
		private static var cfgList:Object = new Object();

		private static var dragonList:Object;
		
		private static var frameMovieCfg:Object;
		
		public function MovieAsset()
		{
		}
		
		/**
		 * 使用资源key附加动画配置 
		 * @param resKey
		 * @param dragon	default=false，是否是龙骨动画配置
		 */		
		public static function appendConfig(resKey:String, dragon:Boolean = false):void
		{
			var b:ResBean = Res.getResBean(resKey);
			
			if(dragon)
			{
				processDragonCfg(b.path);
			}
			else
			{
				processCfg(b.path);
			}
		}
		
		public static function appendFrameMovieConfig(resKey:String):void
		{
			var b:ResBean = Res.getResBean(resKey);
			processFrameMovieCfg(b.path);
		}
		
		public static function appendFrameMovieByUrl(url:String):void
		{
			processFrameMovieCfg(url);
		}

		/**
		 * 初始配置文件
		 * @param resName		资源名
		 * @param dragon	default=false，是否是龙骨动画配置
		 */
		public static function appendConfigByUrl(url:String, dragon:Boolean = false):void
		{
			if(dragon)
			{
				processDragonCfg(url);
			}
			else
			{
				processCfg(url);
			}
		}
		
		private static function processCfg(resPath:String):void {
			//模拟测试环境
//			if(Utils.platformVer() == Utils.PV_WIN || Utils.platformVer() == Utils.PV_DEV)
//			{
				parseCfg(resPath);
//			} else {
//				flash.net.registerClassAlias("potato.movie.MovieBean", MovieBean);
//				var ba:ByteArray = File.readByteArray(resPath);
//				ba.uncompress();
//				cfgList = ba.readObject();
//			}
		}
		
		private static function processFrameMovieCfg(path:String):void
		{
			registerClassAlias("data.FrameBean", FrameBean);
			
			var bytes:ByteArray = File.readByteArray(path);
			bytes.uncompress();
			if(frameMovieCfg)
			{
				var obj:Object = bytes.readObject();
				for (var name:String in obj) 
				{
					frameMovieCfg[name] = obj[name];
				}
			}
			else
			{
				frameMovieCfg = bytes.readObject();
			}
		}
		
		private static function parseCfg(resPath:String):void {
			var txt:String = File.read(resPath);
			
			/**分解出行数组*/
			var row:Array = txt.split(/\r\n|\r|\n/);
			/**解析列名数组*/
			var title:Array = String(row[0]).split("\t");
			/**分解行*/
			for (var i:int = 1; i < row.length; i++)
			{
				if (row[i] == "" || row[i].charAt(0) == "#")
					continue;
				
				var col:Array = row[i].split("\t");
				// 自动补全缺少的 \t 控制符号
				if (col.length < title.length)
				{
					for (var k:int = 0, o:int = title.length - col.length; k<o; k++)
						col.push('');
				}
				var frameStr:String;
				
				var bean:MovieBean = new MovieBean();
				for (var j:int = 0; j < title.length; j++)
				{
					if(title[j] == "frameArr")
					{
						frameStr = col[j];
						if (frameStr && frameStr.length > 0)
						{
							bean.frameArr = frameStr.split(",");
							bean.frameArr.fixed = true;
						}
					} else {
						bean[title[j]] = col[j];
					}
				}
				cfgList[bean.movieName] = bean;
				
				// 预计算帧延时和总帧数
				bean.allFrame = 0;
				if (bean.frameArr == null || bean.frameArr.length == 0)
				{
					var _frameArr:Array = new Array(bean.frameNumber, true);
					for (var m:uint = 0; m < bean.frameNumber; m++) {
						_frameArr[m] = bean.speed;
					}
					bean.allFrame = bean.frameNumber;
					bean.frameArr = _frameArr;
				}
				else
				{
					for (var n:int = 0; n < bean.frameNumber; n++)
					{
						var num:int = int(bean.frameArr[n]);
						bean.frameArr[n] = num;
						bean.allFrame += Math.abs(num);
						bean.frameArr[n] *= int(bean.speed);
					}
				}
			}
		}

		/**
		 * 获得动画配置
		 * @param movieName		动画名
		 * @return 				MovieBean
		 */
		public static function getConfig(movieName:String):MovieBean
		{
			return cfgList[movieName];
		}
		
		
		private static var registed:Boolean = false;
		/**
		 * 解析龙骨动画配置
		 * @param url
		 */
		private static function processDragonCfg(url:String):void
		{
			if(!registed)
			{
				registerClassAlias("data.FrameData", FrameData);
				registed = true;
			}
			
			var bytes:ByteArray = File.readByteArray(url);
			bytes.uncompress();
			var obj:Object = bytes.readObject();
			if(!dragonList)
			{
				dragonList = obj;
			}
			else
			{
				for (var key:String in obj) 
				{
					dragonList[key] = obj[key];
				}
			}
		}
		
		/**
		 * 获得龙骨动画配置 
		 * @param movieName
		 * @return 
		 */
		public static function getDragonConfig(movieName:String):Object
		{
			return dragonList[movieName];
		}
		
		public static function getFrameMovieConfig(movieName:String):Array
		{
			return frameMovieCfg[movieName];
		}
	}
}