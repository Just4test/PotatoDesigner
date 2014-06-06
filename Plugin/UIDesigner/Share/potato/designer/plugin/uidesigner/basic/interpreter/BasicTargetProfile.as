package potato.designer.plugin.uidesigner.basic.interpreter
{	
	import potato.designer.plugin.uidesigner.ITargetProfile;

	/**
	 * 构建用组件描述文件
	 * <br>将json格式的组件描述转换为强类型。强类型在移动设备上具有更好的性能。
	 * <br>本类是动态类，因而可以自由的扩充您所需要的参数。
	 * @author Just4test
	 */
	public dynamic class BasicTargetProfile implements ITargetProfile
	{
		public var className:String;
		
		public const constructorParameters:Vector.<*> = new Vector.<*>;
		
		public const membersName:Vector.<String> = new Vector.<String>;
		public const membersParam:Vector.<Vector.<*>> = new Vector.<Vector.<*>>;
		
		protected var _children:Vector.<BasicTargetProfile> = new Vector.<BasicTargetProfile>;
		
		public function get children():Vector.<ITargetProfile>
		{
			return _children as Vector.<ITargetProfile>;
		}
		
		
		

	}
}