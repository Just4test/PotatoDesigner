package potato.designer.plugin.uidesigner
{
	import flash.geom.Matrix;
	
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

		
		protected static var _foldPath:Vector.<uint>;
		protected static var _focus:int;
		
		
		/**根组件替身*/
		protected static var _rootSubstitute:ComponentSubstitute
		/**根组件树*/
		protected static var _rootTree:TargetTree;
		
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
		public static function update(tree:TargetTree):void
		{
			//创建
		}
		
		/**
		 *设置展开路径以及焦点
		 * <br>展开路径和焦点的概念类似文件路径：可以打开任意文件夹，并选中其中的一个文件，或者不选中任何文件。
		 * @param foldPath 展开路径。
		 * @param focusIndex 焦点索引。如果指定为-1则说明没有选中任何对象。
		 * 
		 */
		public static function setFoldFocus(foldPath:Vector.<uint>, focusIndex:int):void
		{
			
		}
		
		
		
		protected static function buildSubstitute(tree:TargetTree, parrent:ComponentSubstitute = null):ComponentSubstitute
		{
			var ret:ComponentSubstitute = new ComponentSubstitute(tree.target, parrent);
			if(tree.children)
			{
				for each(var i:TargetTree in tree.children)
				{
					var iSubstitute:ComponentSubstitute = buildSubstitute(i, ret);
				}
			}
			return ret;
		}
	}
}