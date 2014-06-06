package potato.designer.plugin.uidesigner.basic.designer
{
	import potato.designer.framework.PluginInfo;
	import potato.designer.plugin.guestManager.Guest;
	import potato.designer.plugin.uidesigner.CompilerProfile;
	import potato.designer.plugin.uidesigner.ICompiler;
	import potato.designer.plugin.uidesigner.basic.BasicConst;
	import potato.designer.plugin.uidesigner.basic.designer.classdescribe.Suggest;
	import potato.designer.utils.MultiLock;

	public class BasicDesigner implements ICompiler
	{
		public function BasicDesigner()
		{
		}
		
		public static function init(info:PluginInfo):void
		{
			Suggest.loadSuggestFile(info.getAbsolutePath(BasicConst.SUGGEST_FILE_PATH));
		}
		
		public function addTarget(targetType:String, profile:CompilerProfile):Boolean
		{
//			if()
			// TODO Auto Generated method stub
			return false;
		}
		
		public function export(lock:MultiLock):Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		public function initGuest(guest:Guest, lock:MultiLock):Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		public function refresh(profile:CompilerProfile):Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		
	}
}