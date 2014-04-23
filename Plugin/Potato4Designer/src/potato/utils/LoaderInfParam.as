package potato.utils
{
	import flash.utils.Dictionary;

	/**
	 * 模拟 loaderInfo.parameters 
	 */	
	public class LoaderInfParam
	{
		private static var dic:Dictionary = new Dictionary();
		
		public function LoaderInfParam()
		{
		}
		
		public static function put(key:String, val:String):void {
			dic[key] = val;
		}
		
		public static function get(key:String):String {
			return dic[key];
		}

		public static function toString():String {
			var s:String = "[";
			var isCut:Boolean = false;
			for (var k:String in dic) {
				s += k + ":" + dic[k] + ",";
				isCut = true;
			}
			if (isCut) s = s.substr(0, s.length-1);
			s += "]";
			return s;
		}
	}
}