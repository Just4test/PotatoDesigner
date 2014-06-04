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
			child._parent = this;
			
			//确定插入到什么位置。因为DesignerProfile的index和其target的index不一定相同。
			var childTargetIndex:int;
			if(index + 1 < _children.length)
			{
				childTargetIndex = getChildTargetIndex(_children[index + 1]);
			}
			else
			{
				childTargetIndex = targetProfile.children.length;
			}
			targetProfile.children.splice(childTargetIndex, 0, child);
		}
		
		
		public function removeChild(child:DesignerProfile):void
		{
			removeChildAt(_children.indexOf(child));
		}
		
		
		public function removeChildAt(index:uint):void
		{
			var child:DesignerProfile = _children[index];
			
			var childTargetIndex:int = targetProfile.children.indexOf(targetProfile);
			
			if(-1 == childTargetIndex)
			{
				throw new Error("子代的target不是当前target的子代");
			}
			
			_children.splice(index, 1);
			child._parent = null;
			
			targetProfile.children.splice(childTargetIndex, 1);
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
		 *返回目标子代的target在当前target的子代中的index。
		 * @param child
		 * @return -1，如果目标不是当前对象的子代
		 * 
		 */
		public function getChildTargetIndex(child:DesignerProfile):int
		{
			if(-1 == _children.indexOf(child))
			{
				return -1;
			}
			
			var index:int = targetProfile.children.indexOf(child.targetProfile);
			
			if(-1 == index)
			{
				throw new Error("子代的target不是当前target的子代");
			}
			
			return index;
		}
		
		/**
		 *返回当前target于父target的子代中的index
		 */
		public function get targetIndex():int
		{
			if(!_parent)
				return -1;
			
			return getChildTargetIndex(this);
		}
		
		public function get targetPath():Vector.<uint>
		{
			return null;
		}
		
		
	}
}