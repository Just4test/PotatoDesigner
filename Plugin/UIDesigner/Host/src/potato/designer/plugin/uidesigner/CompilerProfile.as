package potato.designer.plugin.uidesigner
{
	import potato.designer.plugin.uidesigner.ITargetProfile;

	/**
	 * 编译器配置文件
	 * <br>UIDesignerHost通过编译器配置文件操作ITargetProfile树。
	 * <br>允许在ITargetProfile树中插入不受编译器配置文件管理的ITargetProfile。比如，为某个显示对象插入自动生成的布局对象。
	 * <br>但该ITargetProfile应该是由其父ITargetProfile管理的，而不是由其兄弟ITargetProfile管理。
	 * @author Administrator
	 * 
	 */
	public class CompilerProfile
	{
		protected var _type:ComponentType;
		protected var _parent:CompilerProfile;
		protected const _children:Vector.<CompilerProfile> = new Vector.<CompilerProfile>;
		
		[Bindable]
		/**
		 *目标名。这会显示在大纲视图中。
		 */
		public var name:String;
		
		/**
		 *目标配置文件 
		 */
		public var targetProfile:ITargetProfile;
		
		public function CompilerProfile(type:ComponentType)
		{
			_type = type;
			name = type.name;
		}
		
		
		/**
		 *目标类型
		 */
		public function get type():ComponentType
		{
			return _type;
		}
		
		
		public function get parent():CompilerProfile
		{
			return _parent;
		}
		
		/**
		 * Array形式的子代数组
		 *<br>为大纲视图作出的妥协，大纲视图中的Tree组件可以检查Object对象的children属性以确定树结构。使用这种结构可以大大简化大纲视图的实现逻辑
		 * <br>当不存在子代时返回null。
		 */
		public function get children():Array
		{
			if(!type.isContainer)
				return null;
			
			var arr:Array = [];
			for each(var i:CompilerProfile in _children)
			{
				arr.push(i);
			}
			return arr;
		}
		
		/**
		 * 子代数组
		 * <br/>无法直接在children数组上添加子代。使用addChild添加。
		 */
		public function get childrenVector():Vector.<CompilerProfile>
		{
			return _children.concat();
		}
		
		public function addChild(child:CompilerProfile):void
		{
			addChildAt(child, childrenVector.length)
		}
		
		public function addChildAt(child:CompilerProfile, index:uint):void
		{
			if(index > _children.length)
			{
				throw new Error("下标越界！");
			}
			
			if(child._parent)
			{
				child._parent.removeChild(child);
			}
			child._parent = this;
			
			_children.splice(index, 0, child);

			targetProfile.children.splice(index, 0, child.targetProfile);
		}
		
		
		public function removeChild(child:CompilerProfile):void
		{
			removeChildAt(_children.indexOf(child));
		}
		
		
		public function removeChildAt(index:uint):void
		{
			if(_children[index].targetProfile != targetProfile.children[index])
			{
				throw new Error("target不匹配");
			}
			
			_children.splice(index, 1);
			targetProfile.children.splice(index, 1);
		}
		
		public function getChildAt(index:uint):CompilerProfile
		{
			return _children[index];
		}
		
		public function getChildIndex(child:CompilerProfile):int
		{
			return _children.indexOf(child);
		}
		
		/**
		 *返回当前target于父target的子代中的index
		 */
		public function get index():int
		{
			if(!_parent)
				return -1;
			
			return _parent._children.indexOf(this);
		}
		
		public function get path():Vector.<uint>
		{
			if(!_parent)
				return Vector.<uint>([0]);
			
			var ret:Vector.<uint> = _parent.path;
			ret.push(index)
			return ret;
		}
		
		/**
		 *获取指定子路径上的子配置文件。
		 * @param path 子路径。不包含对象本身。
		 * @return 
		 * 
		 */
		public function getCompilerProfileByPath(path:Vector.<uint>):CompilerProfile
		{
			if(!path.length)
			{
				return this;
			}
			var child:CompilerProfile = _children[path.shift()];
			if(!path.length)
			{
				return child;
			}
			return child.getCompilerProfileByPath(path);
		}
		
		/**
		 * 应用TargetProfile树
		 */
		public function applyTargetProfile(value:ITargetProfile):void
		{
			if(_children.length > value.children.length)
			{
				throw new Error();
			}
			
			
			targetProfile = value;
			
			for (var i:int = 0; i < _children.length; i++) 
			{
				_children[i].applyTargetProfile(value.children[i]);
			}
		}
		
		
	}
}