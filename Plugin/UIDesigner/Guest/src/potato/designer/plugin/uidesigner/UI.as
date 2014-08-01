package potato.designer.plugin.uidesigner
{
	import flash.geom.Matrix;
	
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	import core.display.Image;
	import core.display.Quad;
	import core.display.RenderTexture;
	import core.display.Stage;
	import core.display.SuperTexture;
	
	import potato.designer.plugin.uidesigner.factory.TargetTree;
	
	public class UI
	{
		
		public static const designerStage:DisplayObjectContainer = new DisplayObjectContainer;
		
		protected static var _stageWidth:int;
		protected static var _stageHeight:int;
		protected static var _stageBackground:Image;
		protected static var _stageContainer:DisplayObjectContainer;
		protected static var _containerMask:Quad;

		
//		protected static var _foldPath:Vector.<uint>;
//		protected static var _focusIndex:int;
//		
//		/**根组件树*/
//		protected static var _rootTargetTree:TargetTree;
		
		public static function init():void
		{
			_stageContainer = new DisplayObjectContainer;
			_stageBackground = new Image(null);
			_stageContainer.addChild(_stageBackground);
			_stageContainer.addChild(designerStage);
			
			setStageSize(480, 320);
			Stage.getStage().addChild(_stageContainer);
			
			_stageContainer.x = (Stage.getStage().stageWidth - _stageContainer.width) / 2;
			_stageContainer.y = (Stage.getStage().stageHeight - _stageContainer.height) / 2;
			
		}
		
		/**
		 *设置设计舞台的尺寸 
		 * @param width
		 * @param height
		 * 
		 */
		public static function setStageSize(width:int, height:int):void
		{
			const COLOR_WHITE:uint = 0xffffffff;
			const COLOR_GRAY:uint = 0xffcccccc;
			const BLOCK_SIZE:int = 10;
			
			_stageWidth = width;
			_stageHeight = height;
			
			//绘制舞台背景
			var parentTexture:RenderTexture = new RenderTexture(BLOCK_SIZE * 2, BLOCK_SIZE);
			var quad:Quad = new Quad(BLOCK_SIZE, BLOCK_SIZE, COLOR_WHITE);
			parentTexture.draw(quad);
			quad.color = COLOR_GRAY;
			parentTexture.draw(quad, new Matrix(1, 0, 0, 1, BLOCK_SIZE, 0));
			
			var texture:SuperTexture = new SuperTexture(parentTexture);
			texture.setSize(width, height);
			_stageBackground.texture = texture;
			
			var vertex:Vector.<Number> = new Vector.<Number>;
			var index:Vector.<int> = new Vector.<int>;
			var indexTable:Object = {};
			var counter:int = 0;
			for (var i:int = 0; i < width; i += BLOCK_SIZE) 
			{
				for (var j:int = 0; j < height; j += BLOCK_SIZE) 
				{
					var isGary:Boolean = (i + j) / BLOCK_SIZE % 2;
					var offset:int = isGary ? BLOCK_SIZE : 0;
					
					var leftTop:int = addPoint(i, j, offset, 0);
					addPoint(i + BLOCK_SIZE, j, BLOCK_SIZE + offset, 0);
					var rightBottom:int = addPoint(i + BLOCK_SIZE, j + BLOCK_SIZE, BLOCK_SIZE + offset, BLOCK_SIZE);
					index.push(leftTop);
					index.push(rightBottom);
					addPoint(i, j + BLOCK_SIZE, offset, BLOCK_SIZE);
				}
				
			}
			
			texture.addTriangles(vertex, index);
			
			function addPoint(x:int, y:int, parentX:int, parentY:int):int
			{
				vertex.push(x, y, parentX, parentY);
				index.push(counter);
				return counter++;
			}
		}
		
		
		/**
		 *更新组件树 
		 * @param tree
		 * 
		 */
		public static function update(tree:TargetTree, foldPath:Vector.<uint>, focusIndex:int):void
		{
//			_rootTargetTree = tree;sh
			
			makeSubstitute(tree, foldPath, focusIndex);
			
		}
		
		
		/**
		 *创建替身树
		 * <br>替身树和组件树不同，只有展开的容器及其所有直接子组件才会创建替身。
		 * 规则：
		 * 如果对象的父对象位于展开路径上，则为其创建替身。
		 * 具有三个替身队列：位于展开路径下方、位于展开路径上方、父对象是最终展开对象。这三个队列从底至顶排布。
		 */
		public static function makeSubstitute(rootTargetTree:TargetTree, fold:Vector.<uint>,
											  focus:int):void
		{
			const COLOR_MASK:uint = 0xc0cccccc;
			
			while(designerStage.numChildren)
				designerStage.removeChildAt(0);
			
			if(!rootTargetTree)
			{
				return;
			}
			
			var path:Vector.<uint> = new Vector.<uint>;
			var underFold:Vector.<ComponentSubstitute> = new Vector.<ComponentSubstitute>;
			var overFold:Vector.<ComponentSubstitute> = new Vector.<ComponentSubstitute>;
			var inFold:Vector.<ComponentSubstitute> = new Vector.<ComponentSubstitute>;
			
			if(rootTargetTree.target is DisplayObject)
			{
				var rootLayer:DisplayObjectContainer = new DisplayObjectContainer;
				rootLayer.addChild(rootTargetTree.target);
			}
			
			make(rootTargetTree, new <uint>[0], rootTargetTree.target is DisplayObject);
			
			
			
			for each (var i:ComponentSubstitute in underFold.concat(overFold))
			{
				designerStage.addChild(i);
				log("添加了", i.path);
			}
			
			if(!_containerMask)
			{
				_containerMask = new Quad(Stage.getStage().stageWidth, Stage.getStage().stageHeight, COLOR_MASK);
				_containerMask.x = - _stageContainer.x;
				_containerMask.y = - _stageContainer.y;
			}
			if(fold.length)
			{
				designerStage.addChild(_containerMask);
				log("添加了mask", _containerMask.x, _containerMask.y);
			}
			
			for each (i in inFold)
			{
				designerStage.addChild(i);
				log("添加了", i.path);
			}
			
			
			
			function make(targetTree:TargetTree, path:Vector.<uint>, inDisTree:Boolean):void
			{
				var substitute:ComponentSubstitute = new ComponentSubstitute(
					targetTree, path, inDisTree ? rootLayer : null);
				
				//由于所有替身对应的组件都在展开路径上，因此仅需要判断其路径的最后一位就可以了解应该放入哪个序列。
				var index:uint = path[path.length - 1];
				if(path.length > fold.length)
				{
					inFold.push(substitute);
					substitute.selected = index == focus;
				}
				else
				{
					var foldIndex:uint = fold[path.length - 1];
					if(index > foldIndex)
					{
						overFold.push(substitute);
					}
					else
					{
						underFold.push(substitute);
						if(index == foldIndex)
						{
							substitute.unfolded = true;
							var hidden:Vector.<DisplayObject> = new Vector.<DisplayObject>;
							for(var i:int = 0; i < targetTree.children.length; i++)
							{
								var childtt:TargetTree = targetTree.children[i];
								var displayObj:DisplayObject = childtt.target as DisplayObject;
								if(displayObj && displayObj.visible)
								{
									hidden.push(displayObj);
									displayObj.visible = false;
								}
							}
							for(i = 0; i < targetTree.children.length; i++)
							{
								childtt = targetTree.children[i];
								displayObj = childtt.target as DisplayObject;
								if(displayObj && -1 != hidden.indexOf(displayObj))
								{
									displayObj.visible = true;
								}
								make(childtt, path.concat(new <uint>[i]), inDisTree && displayObj && displayObj.root == rootLayer);
								displayObj.visible = false;
							}
							for each(displayObj in hidden)
							{
								displayObj.visible = true;
							}
							
						}
					}
				}
			}
		}
	}
}