package potato.ui
{
	import core.display.DisplayObject;
	import core.display.Stage;

	/**
	 * 智能布局容器，不支持XML配置
	 * 布局优先顺序：hAlign,vAlign | 虚拟网格布局 > x,y
	 * <SmartLayout id="aa" percentWidth="0.8" percentHeight="0.8" rows="3" cols="3"></SmartLayout>
	 */
	public class SmartLayout extends UIComponent
	{		
		/**预期宽度相对舞台百分比**/
		private var _perwidth:Number;
		/**预期高度相对舞台百分比**/
		private var _perheight:Number;
		/**虚拟行数**/
		private var _rows:uint = 1;
		/**虚拟列数**/
		private var _cols:uint = 1;
		// 每一行的高度
		private var _rowHeight:Number;
		// 每一列的宽度
		private var _colWidth:Number;
		
		/**
		 * 构造函数，创建一个智能布局对象实例，并指定它自身宽、高度的百分比，和它内部空间的行列分区
		 *
		 * @param perwidth			相对舞台宽度百分比。值在 0~1 之间，0 表示没有宽度，1 表示最大宽度（相对于 stage 实例）
		 * @param perheight			相对舞台高度百分比。值在 0~1 之间，0 表示没有高度，1 表示最大高度（相对于 stage 实例）
		 * @param rows				该布局对象内部行数（内部空间会被平均分成这么多行）
		 * @param cols				该布局对象内部列数（内部空间会被平均分成这么多列）
		 */
		public function SmartLayout(perwidth:Number=0, perheight:Number=0, rows:uint=1, cols:uint=1)
		{
			super();

			percentWidth = perwidth;
			percentHeight = perheight;
			
			if(rows < 1 || cols < 1)
			{
				throw new Error("rows or cols param is invalid");
				return;
			}
			_rows = rows;
			_cols = cols;
		}
		
		/**
		 * 将显示对象添加到当前布局对象的虚拟网格内
		 *
		 * @parm obj	显示对象
		 * @parm row	该显示对象放入虚拟行。默认第一个格（第 0 行）。
		 * @parm col	该显示对象放入虚拟列。默认第一个格（第 0 列）。
		 */
		public function addElementInGrid(obj:UIComponent, row:uint=0, col:uint=0):DisplayObject
		{
			setChildInGrid(obj, row, col);
			super.addElement(obj);
			
			return obj;
		}
		
		/**
		 * 虚拟网格布局到指定的顺序位置（即 z-index）
		 * @parm obj	显示对象
		 * @parm index	显示对象在显示对象列表中索引位置
		 * @parm row	该显示对象放入虚拟行。默认第一个格（第 0 行）。
		 * @parm col	该显示对象放入虚拟列。默认第一个格（第 0 列）。
		 */
		public function addElementInGridAt(obj:UIComponent, index:int, row:uint=0, col:uint=0):DisplayObject
		{
			setChildInGrid(obj, row, col);
			super.addElementAt(obj, index);
			
			return obj;
		}

		private function setChildInGrid(child:UIComponent, row:uint, col:uint):void
		{
			if (row >= rows || col >= cols)
			{
				throw new Error('The row or col is over of.');
			}

			child.x = _rowHeight * row;
			child.y = _colWidth * col;
		}
		
		/**
		 * 添加子组件并按上下左右进行浮动布局
		 * @parm obj	显示对象
		 * @parm hAlign	显示对象居父容器左侧或右侧，默认为null，此时不做浮动定位处理
		 * @parm vAlign 显示对象居父容器上侧或下侧，默认为null，此时不做浮动定位处理
		 */
		public function addElementAndFloat(obj:UIComponent, hAlign:String=null, vAlign:String=null):DisplayObject
		{
			var component:UIComponent = obj as UIComponent;
			floatComponent(component, hAlign, vAlign);

			super.addElement(obj);

			return obj;
		}
		/**
		 * 添加子组件到指定索引，并按上下左右进行浮动布局
		 * @parm obj	显示对象
		 * @parm index	索引
		 * @parm hAlign	显示对象居父容器左侧或右侧，默认为null，此时不做浮动定位处理
		 * @parm vAlign 显示对象居父容器上侧或下侧，默认为null，此时不做浮动定位处理
		 */
		public function addElementAndFloatAt(obj:UIComponent, index:int, hAlign:String=null, vAlign:String=null):DisplayObject
		{
			var component:UIComponent = obj as UIComponent;
			floatComponent(component, hAlign, vAlign);

			super.addElementAt(obj, index);

			return obj;
		}

		/**
		 * 为指定了浮动方向（左、右、上、下）的组件进行坐标计算
		 * @param component			要浮动的组件
		 * @param hAlign			水平浮动方向（UIGlobal.LEFT、UIGlobal.RIGHT）
		 * @param vAlign			垂直浮动方向（UIGlobal.TOP, UIGlobal.BOTTOM）
		 */
		private function floatComponent(component:UIComponent, hAlign:String, vAlign:String):void
		{
			if(component)
			{
				if(hAlign == UIGlobal.LEFT)
				{
					component.x = 0;
				}
				else if(hAlign == UIGlobal.RIGHT)
				{
					component.x = this.expectWidth - component.expectWidth;
				}

				if(vAlign == UIGlobal.TOP)
				{
					component.y = 0;
				}
				else if(vAlign == UIGlobal.BOTTOM)
				{
					component.y = this.expectHeight - component.expectHeight;
				}
			}
		}
		
		/**
		 * 设置容器宽度相对舞台宽度百分比
		 */
		public function set percentWidth(value:Number):void
		{
			if(value < 0 || value > 1)
			{
				throw new Error("value is invalid");
				return;
			}
			_perwidth = value;
			this.expectWidth = Stage.getStage().stageWidth * value;
		}
		
		/**
		 * 获取容器宽度相对舞台宽度百分比
		 */
		public function get percentWidth():Number
		{
			return _perwidth;
		}
		
		/**
		 * 设置容器高度相对舞台高度百分比
		 */
		public function set percentHeight(value:Number):void
		{
			if(value < 0 || value > 1)
			{
				throw new Error("value is invalid");
				return;
			}
			_perheight = value;
			this.expectHeight = Stage.getStage().stageHeight * value;
		}
		
		/**
		 * 设置容器高度相对舞台高度百分比
		 */
		public function get percentHeight():Number
		{
			return _perheight;
		}
		
		/**
		 * 设置虚拟行数，供布局使用
		 * @parm value：必须大于1
		 */
		public function set rows(value:uint):void
		{
			if(value < 1)
			{
				throw new Error("lines is invalid");
				return;
			}
			_rows = value;

			if (expectHeight > 0)
				_rowHeight = expectHeight / rows;
		}
		
		/**
		 * 获取虚拟行数
		 */
		public function get rows():uint
		{
			return _rows;
		}
		
		/**
		 * 设置虚拟列数，供布局使用
		 * @parm value：必须大于1
		 */
		public function set cols(value:uint):void
		{
			if(value < 1)
			{
				throw new Error("cols is invalid");
				return;
			}
			_cols = value;

			if (expectWidth > 0)
				_colWidth = expectWidth / cols;
		}
		
		/**
		 * 获取虚拟列数
		 */
		public function get cols():uint
		{
			return _cols;
		}

		/**
		 * 重载 expectWidth 赋值属性，在赋值的同时，计算出平均列宽
		 * @param value
		 */
		override public function set expectWidth(value:Number):void
		{
			super.expectWidth = value;

			if (expectWidth > 0 && cols > 0)
				_colWidth = expectWidth / cols;
		}

		/**
		 * 重载 expectHeight 赋值属性，在赋值的同时，计算出平均行高
		 */
		override public function set expectHeight(value:Number):void
		{
			super.expectHeight = value;

			if (expectHeight > 0 && rows > 0)
				_rowHeight = expectHeight / rows;
		}
	}
}