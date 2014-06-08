package potato.designer.plugin.uidesigner.basic.interpreter
{	
	import potato.designer.plugin.uidesigner.ITargetProfile;
	
	CONFIG::HOST
	{
		import potato.designer.plugin.uidesigner.basic.compiler.BasicCompiler;
		import potato.designer.plugin.uidesigner.basic.compiler.classdescribe.AccessorProfile;
		import potato.designer.plugin.uidesigner.basic.compiler.classdescribe.ClassProfile;
	}

	/**
	 * 构建用组件描述文件
	 * <br>将json格式的组件描述转换为强类型。强类型在移动设备上具有更好的性能。
	 * <br>本类是动态类，因而可以自由的扩充您所需要的参数。
	 * @author Just4test
	 */
	public dynamic class BasicTargetProfile implements ITargetProfile
	{
		/**类全名*/
		public var className:String;
		
		/**构造方法参数
		 * 通常应存储字符串。在优化后可以传入其他类型的参数。
		 */
		public var constructorParam:Vector.<*>;
		
		/**
		 *成员名，包含方法和存取器/变量 
		 */
		public const membersName:Vector.<String> = new Vector.<String>;
		/**
		 *与成员名所对应的成员参数 
		 * 通常应存储字符串。在优化后可以传入其他类型的参数。
		 */
		public const membersParam:Vector.<Vector.<*>> = new Vector.<Vector.<*>>;
		
		protected const _children:Vector.<BasicTargetProfile> = new Vector.<BasicTargetProfile>;
		
		public function get children():Vector.<ITargetProfile>
		{
			return _children as Vector.<ITargetProfile>;
		}
		
		
		CONFIG::HOST
		{
			/**
			 *获取指定存取器的值。
			 * <br>首先尝试获取在members中指定的值。如果members中没有指定，则获取默认值。如果也没有指定默认值，返回null。
			 * @param name
			 * @return 
			 * 
			 */
			public function getValue(name:String):String
			{
				var cp:ClassProfile = BasicCompiler.getClassProfileByClassName(className);
				if(!cp)
				{
					throw new Error("找不到指定的类描述文件");
				}
				var ap:AccessorProfile = cp.getMember(name) as AccessorProfile;
				if(!ap)
				{
					throw new Error("指定的存取器不存在");
				}
				
				for(var i:int = 0; i < membersName.length; i++) 
				{
					if(name == membersName[i])
					{
						return membersParam[i][0];
					}
				}
				
				if(ap.hasDefaultValue)
				{
					return ap.defaultValue;
				}
				
				return null;
			}
			
			
			/**
			 *写入存取器 
			 * @param name
			 * @param value
			 * 
			 */
			public function setValue(name:String, value:String):void
			{
				var cp:ClassProfile = BasicCompiler.getClassProfileByClassName(className);
				if(!cp)
				{
					throw new Error("找不到指定的类描述文件");
				}
				var ap:AccessorProfile = cp.getMember(name) as AccessorProfile;
				if(!ap)
				{
					throw new Error("指定的存取器不存在");
				}
				
				for(var i:int = 0; i < membersName.length; i++) 
				{
					if(name == membersName[i])
					{
						membersParam[i][0] = value;
						return;
					}
				}
				
				membersName.push(name);
				membersParam.push(Vector.<*>([value]));
				
			}
		
		}
		
		

	}
}