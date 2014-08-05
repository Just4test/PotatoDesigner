package potato.utils
{
	/**
	 * language:
	 * Chinese	zh
	 * English	en
	 * Korean	ko
	 * 
	 * country:
	 * CN	CHINA
	 * KR	KOREA, REPUBLIC OF
	 * TW	TAIWAN, PROVINCE OF CHINA
	 */	
	public class Locale
	{
		public var language:String;
		public var country:String;
		
		//默认
		private static var defaultLocale:Locale = new Locale("zh", "CN");
		
		public function Locale(language:String = "zh", country:String = "CN")
		{
			this.language = language;
			this.country = country;
		}
		
		
		public function toString():String {
			return language + "_" + country;
		}
		
		
		/**
		 * 系统默认语言地区 
		 * @return 
		 */		
		public static function getDefault():Locale {
			return defaultLocale;		
		}
		public static function setDefault(locale:Locale):void {
			defaultLocale = locale;		
		}
	}
}