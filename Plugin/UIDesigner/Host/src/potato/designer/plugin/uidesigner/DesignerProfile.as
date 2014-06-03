package potato.designer.plugin.uidesigner
{
	import potato.designer.plugin.uidesigner.construct.ITargetProfile;

	/**
	 * 设计器配置文件
	 * @author Administrator
	 * 
	 */
	public class DesignerProfile
	{
		protected var _type:String;
		
		public function DesignerProfile(type:String)
		{
			_type = type;
		}
		
		
		/**
		 *目标名。这会显示在大纲视图中。 
		 */
		public var name:String;
		
		/**
		 *目标配置文件 
		 */
		public var profile:ITargetProfile;
		
		/**
		 *目标类型
		 */
		public function get type():String
		{
			return _type;
		}
		
		
	}
}