package potato.designer.plugin.uidesigner
{
	
	/**
	 *组件类型 
	 * @author Administrator
	 * 
	 */
	public class ComponentType
	{
		public var name:String;
		public var isContainer:Boolean;
		public var icon:*;
		
		public function add():void
		{
			UIDesignerHost.addComponent(name);
		}
		
		public function ComponentType(name:String, isContainer:Boolean, icon:* = null)
		{
			this.name = name;
			this.isContainer = isContainer;
			this.icon = icon;
		}
	}
}