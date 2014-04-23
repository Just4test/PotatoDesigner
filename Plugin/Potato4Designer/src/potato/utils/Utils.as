package potato.utils
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	import core.display.Stage;
	import core.filesystem.File;
	import core.system.Capabilities;
	import core.system.System;
	import core.text.TextField;
	
	import ext.ui.LoadingMovie;
	
	import potato.logger.Logger;
	
	/**
	 * 工具
	 * Jun 19, 2012
	 */
	public class Utils
	{
		/**语言环境*/
		public static var DEFAULTLOCALE:String = Locale.getDefault().toString();
		
		/**用pvr资源在dev环境运行 设置为true即可*/
		public static var testPVR:Boolean = false;
		
		///////////// 配置文件里可用的文件路径常量 ///////////////
		private static const COMMON:RegExp = /@common/g;			//通用资源的文件夹，会被替换为 common
		private static const LANGUAGE:RegExp = /@language/g;		//语言地区，会被替换为 -l 参数传入的值
		private static const RESOURCE:RegExp = /@resource/g;		//资源格式，会被替换为 pvr, dxt, atc, png 中的一个

		public static const PV_DEV:int = 0;
		public static const PV_WIN:int = 1; //avm
			
		private static const _logger:Logger = Logger.getLog('potato.utils::Utils');
		
		/**
		 * 缓存弧度到角度转换的常量
		 */		
		public static const RadianToAngle:Number = 180 / Math.PI;
		
		private static var toolText:TextField = new TextField("", 2048, 2048);
		
		/**
		 * ASC II 字符在某些字体下的宽度系数（针对非等宽字体而设定）
		 */
		public static const AscIICharsWidthFactors:Object = {};
		
		public static var loadingMovie:LoadingMovie = new LoadingMovie();
		
		private static var isStartMovieBusy:Boolean = false;
		private static var isBusyMovieBusy:Boolean = false;
		/**
		 * 获取平台版本 
		 * @return 
		 */
		private static var platver:int = -1;
		public static function platformVer():int {
			if (platver >= 0) return platver;
			var s:String = Capabilities.version.toLowerCase();
			if (StringUtil.beginsWith(s, "win"))
			{
				platver = PV_WIN;
			}else if (StringUtil.beginsWith(s, "dev"))
			{
				platver = PV_DEV;
			}
			return platver;
		}
		
		/**
		 * 程序启动动画
		 */		
		public static function playStartMovie():void {
//			if(isStartMovieBusy) return;
			loadingMovie.start("LoadingAnimation.plist");
			isStartMovieBusy = true
		}
		
		public static function stopStartMovie():void {
//			if(!isStartMovieBusy) return;
			loadingMovie.stop();
			isStartMovieBusy = false;
		}
		
		/**
		 * 忙动画
		 */		
		public static function playBusyMovie():void {
			loadingMovie.start("BusyAnimation.plist");
		}
		public static function stopBusyMovie():void {
			loadingMovie.stop();
		}
		
		
		/**
		 * 根据路径创建文件夹 
		 * @param path
		 */		
		public static function createPathForder(path:String):void
		{
			var forders:Array = path.split("/");
			for (var i:int = 0; i < forders.length; i++)
			{
				if(forders[i].indexOf(".") == -1)
				{
					var forderPath:String = "";
					for (var j:int = 0; j < i + 1; j++) 
					{
						forderPath += forders[j] + "/";
					}
//					createForder(forderPath);
					File.createDirectory(forderPath);
				}
			}
		}
		
		
		/**
		 * 获得文本的渲染宽度
		 * @param txt
		 * @param fontName
		 * @param fontSize
		 * @return 
		 */		
		public static function getTextSize(txt:String, fontName:String, fontSize:int, isHtmlText:Boolean = false):Size {
			toolText.fontName = fontName;
			toolText.fontSize = fontSize;
			
			if (isHtmlText)
				toolText.htmlText = txt;
			else
			{
				toolText.text = txt;
				if (platformVer() != PV_DEV)
					toolText.htmlText = null;
			}
			return new Size(toolText.textWidth + 4, toolText.textHeight + 4);
		}
		
		
		private static var p:Point;
		public static var arr:Array;
		/**
		 * 判断一个对象是否能看见 //有bug
		 * @param dis
		 * @return 
		 */		
		public static function isSee(dis:DisplayObject):Boolean
		{
			var boo:Boolean = true;
			
			var rect:Rectangle = new Rectangle(0,0,Stage.getStage().stageWidth,Stage.getStage().stageHeight);
			arr = [];
			checkDisplay(dis, true);
//			if(boo)
//			{
//				for (var i:int = 1; i < arr.length; i++) 
//				{
//					if(arr[0].x < arr[i].x && arr[0].x >= arr[1].x + arr[1].width)//有bug
//						return false;
//					if(arr[0].y < arr[i].y && arr[0].y >= arr[1].y + arr[1].height)//有bug
//						return false;
//					/////
//					if(arr[0].x < arr[i].x || arr[0].x >= arr[1].x + arr[1].width)//有bug
//						return false;
//					if(arr[0].y < arr[i].y || arr[0].y >= arr[1].y + arr[1].height)//有bug
//						return false;
//				}
//			}
			return boo;
			
			function checkDisplay(dis:DisplayObject, frist:Boolean = false):void
			{
				if(dis.parent is Stage)
					return;
				
				if(dis.stage && dis.visible && dis.alpha > 0)
				{
					if(frist)
					{
						p = dis.localToGlobal(new Point(0, 0));
//						check(dis);
						arr.push(new Rectangle(p.x,p.y,dis.width,dis.height));
					}
					else
					{
						var rect:Rectangle = DisplayObjectContainer(dis).clipRect;
						if(rect)
						{
							p = dis.localToGlobal(new Point(0, 0));//new Point();
//							check(dis);
							var r:Rectangle = new Rectangle(rect.x,rect.y,rect.width, rect.height);
							r.x += p.x;
							r.y += p.y;
							arr.push(r);
						}
					}
					checkDisplay(dis.parent);
				}
				else
				{
					boo = false;
				}
			}
		}
		
		/**
		 * 比较两个对象谁在上面	第一个索引小 返回true 否则返回false
		 * @param dis1
		 * @param dis2
		 * @return 
		 */		
		public static function getDisplayIndex(dis1:DisplayObject, dis2:DisplayObject):Boolean
		{
			var index:int = 0;
			
			var count:int = 0;
			
			var arr1:Array = [];
			var arr2:Array = [];
			getParent(dis1,arr1);
			getParent(dis2,arr2);
			
			arr1 = arr1.reverse();
			arr2 = arr2.reverse();	
			
			for (var i:int = 0; i < arr1.length && i < arr2.length; i++) 
			{
				if(arr1[i] != arr2[i])
				{
					if(arr1[i] < arr2[i])
						return true;
					else
						return false;
				}
			}
			
			var len:int = arr2.length - 1;
			if(arr1.length > arr2.length)
			{
				len = arr2.length - 1;
			}
			else
			{
				len = arr1.length - 1;
			}
			
			if(arr1[len] > arr2[len])
			{
				return false;
			}
			else
			{
				return true;
			}
			
			function getParent(dis:DisplayObject, arr:Array):void
			{
				if(dis.parent is Stage)
					return;
				arr.push(dis.parent.getChildIndex(dis));
				getParent(dis.parent, arr);
			}
			return false;
		}
		
		/**
		 * 打开浏览器 
		 * @param url	浏览地址
		 * @param x		动画起始位置x
		 * @param y		动画其实位置y
		 */		
		public static function openBrowse(url:String, x:int, y:int):void
		{
			System.nativeCall("MobiFunAppWeb", [url, x, y]);
		}
		
		public static function parsePathInDev(path:String, language:String):String {
			path = StringUtil.trim(path);
			var s:String;
			if (path.indexOf("/") == 0) {
				s = path.substr(1);
				s = s.replace(COMMON, "common");
				s = s.replace(LANGUAGE, language);
				s = s.replace(RESOURCE, "pc");
			}
			else
			{
				s = language + "/pc/" + path;
			}
			return s;
		}
		
		private static var supportResStr:String;
		public static function getsupportResStr():String {
			if (supportResStr)
				return supportResStr;
			
			if(Utils.PV_DEV == Utils.platformVer() || Utils.PV_WIN == Utils.platformVer())
			{
				if (testPVR)
					return "pvr";
				return "pc";
			}
			
			if(File.exists("HD")){ //如果根目录中存在HD文件，表示使用png
				supportResStr = "png";
			}else{
				if (Capabilities.supportsPVRTC)
					supportResStr = "pvr";
				else if (Capabilities.supportsDXT3)
					supportResStr = "dxt";
				else if (Capabilities.supportsATC)
					supportResStr = "atc";
				else
					supportResStr = "png";
			}
			return supportResStr;
		}
		
		
		/**
		 * 计算并返回一个字符在指定字体和字号下的宽度
		 * 主要是在非等宽字体中需要使用该方法计算 ASCII 字符的真实宽度
		 * 该方法会到本地缓存的 ASCII 字体宽度系数池内查找对应的系数，
		 * 再与 fontSize 做乘法计算，以便计算 ASCII 字符在该字体下的真实宽度。
		 *
		 * 如果给出的字符是中文，则直接返回 fontSize。
		 *
		 * @param charCode          要测定的字符 cdoe
		 * @param fontName          要测定的字体名
		 * @param fontSize          要测定的字号
		 * @return                  该字符在当前设置下的真实宽度
		 */
		public static function calculateCharWidth(charCode:uint, fontName:String, fontSize:uint):uint
		{
			const asciiMaxCode:uint = 192;
			
			if (charCode <= asciiMaxCode)
			{
				// 如果是 ASCII 字符，则查找有没有对应该字体的宽度系数表
				var factors:Vector.<Number> = AscIICharsWidthFactors[fontName];
				
				// 如果还没有建立该字体对应的宽度系数表，则建立之
				if (!factors)
				{
					factors = new Vector.<Number>(asciiMaxCode);
					const toolFontSize:Number = 50;
					
					toolText.fontName = fontName;
					toolText.fontSize = toolFontSize;
					
					// AVM 里要清空 htmlText 才能得到正确的 textWidth 返回结果，如果有htmlText，会优先使用htmlText
					if (platformVer() != PV_DEV)
						toolText.htmlText = null;	
					
					for (var i:uint=0; i<asciiMaxCode; i++)
					{
						toolText.text = String.fromCharCode(i);
						factors[i] = toolText.textWidth / toolFontSize;
					}
					//					_logger.debug('Factors: ' + factors);
					AscIICharsWidthFactors[fontName] = factors;
				}
				
				// 查找并返回 AscII 字符的真实宽度
				return Math.round(factors[charCode] * fontSize);
			}
			else
				return fontSize;
		}
		
		/**
		 * 在路径不是以 / 开始时，使用的默认前缀
		 * @param path
		 * @return 
		 */		
		public static function getDefaultPath(path:String):String {
			path = StringUtil.trim(path);
			var s:String;
			if (path.indexOf("/") == 0) {
				s = path.substr(1);
			} else {
				s = DEFAULTLOCALE + "/" + Utils.getsupportResStr() + "/" + path;
			}
			return s;
		}
	}
}

