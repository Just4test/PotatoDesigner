package potato.designer.plugin.uidesigner.basic.designer
{
	import potato.designer.framework.PluginInfo;
	import potato.designer.plugin.uidesigner.basic.BasicConst;
	import potato.designer.plugin.uidesigner.basic.designer.classdescribe.Suggest;

	public class BasicDesigner
	{
		public function BasicDesigner()
		{
		}
		
		public static function init(info:PluginInfo):void
		{
			Suggest.loadSuggestFile(info.getAbsolutePath(BasicConst.SUGGEST_FILE_PATH));
		}
		
	}
}