package 
{
	/**
	 *格式化字符串。
	 *<br>format("我叫{0}。","just4test") = "我叫just4test。" 
	 *<br>抄袭自Flex里面的 mx.utils.StringUtil.substitute
	 */
	public function formatStr(str:String, ... rest):String
	{
		if (str == null) return '';
		
		// Replace all of the parameters in the msg string.
		var len:uint = rest.length;
		var args:Array;
		if (len == 1 && rest[0] is Array)
		{
			args = rest[0] as Array;
			len = args.length;
		}
		else
		{
			args = rest;
		}
		
		for (var i:int = 0; i < len; i++)
		{
			str = str.replace(new RegExp("\\{"+i+"\\}", "g"), args[i]);
		}
		
		return str;
	}
}