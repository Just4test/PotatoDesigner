package potato.designer.plugin.uidesigner
{
	import potato.designer.plugin.uidesigner.construct.ITargetProfile;

	/**
	 * 设计器配置文件
	 * <br>UIDesignerHost通过设计器配置文件操作ITargetProfile树。
	 * <br>允许在ITargetProfile树中插入不受设计器配置文件管理的ITargetProfile。比如，为某个显示对象插入自动生成的布局对象。
	 * <br>但该ITargetProfile应该是由其父ITargetProfile管理的，而不是由其兄弟ITargetProfile管理。
	 * @author Administrator
	 * 
	 */
	public class DesignerProfile
	{
		protected var _type:String;
		protected var _parent:DesignerProfile;
		protected const _children:Vector.<DesignerProfile> = new Vector.<DesignerProfile>;
		
		/**
		 *目标名。这会显示在大纲视图中。
		 */
		public var name:String;
		
		/**
		 *目标配置文件 
		 */
		public var targetProfile:ITargetProfile;
		
		public function DesignerProfile(type:String)
		{
			_type = type;
		}
		
		
		/**
		 *目标类型
		 */
		public function get type():String
		{
			return _type;
		}
		
		
		public function get parent():DesignerProfile
		{
			return _parent;
		}
		
		public function get children():Vector.<DesignerProfile>
		{
			return _children.concat();
		}
		
		public function addChild(child:DesignerProfile):void
		{
			addChildAt(child, children.length)
		}
		
		public function addChildAt(child:DesignerProfile, index:uint):void
		{
			if(index > _children.length)
			{
				throw new Error("下标越界！");
			}
			
			if(child._parent)
			{
				child._parent.removeChild(child);
			}
			
			_children.splice(index, 0, child);
			targetProfile.children.splice(index, 0, child.targetProfile);
		}
		
		
		public function removeChild(child:DesignerProfile):void
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
		
		public function getChildAt(index:uint):DesignerProfile
		{
			return _children[index];
		}
		
		public function getChildIndex(child:DesignerProfile):int
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
		
		
	}
}