package potato.ui
{
	import potato.events.GestureEvent;
	import potato.events.UIEvent;
	
	/**
	 * 按钮组（单选、复选）
	 * &lt;ButtonBar id="aaa" isMultiSelectable="false" horizontal="true" spacing="10"&gt;&lt;/ButtonBar&gt;
	 *
	 * ChangeLog:
	 * 2012.12.10 ( jiangbo )
	 * 		重构属性 horizontal 为 isHorizontal
	 * 		重构属性 check 为 isMultiSelectable
	 *
	 * 
	 *  2013-06-17 （zw）
	 * 		优化原因：
	 * bug引路到此，有同事发现这个类的某接口逻辑有问题，
	 * 阅读期间发现可优化点相当多，我实在受不了内存与CPU的浪费，这才决定优化与重构，（该类比较简单，优化不会出现重大问题，也容易修复）；
	 * 大家使用期间发现问题，又一时间解决不了，或者不想解决，可花不到1分钟时间将此类还原至优化之前的最后一版；
	 * 		
	 * 		优化行为：
	 * 1、优化理由与部分说明皆已注释，以便大家批评指正；
	 * 2、接口与参数个数，参数类型悉数未变；
	 * 
	 * 		后记：
	 * 此次优化为第一阶段，还有部分可优化点有待此次版本稳定后再做计较；
	 * 		
	 */
	public class ButtonBar extends UIComponent
	{
		/**是否可以复选*/
		protected var _isMultiSelectable:Boolean = true;
		
		/**所有按钮*/
		protected var _btns:Vector.<Button>;
		
		/**
		 * 已经按下的按钮
		 * */
		protected var _selectedBtns:Vector.<Button>;
		
		
		/**
		 * key=Button，
		 * value=index
		 * 
		 * 去掉理由 ：
		 *		 1、被添加进来的按钮在该类有超过一个的引用，完全没有必要（_btns持有一个引用  _btnIdxDic又有一个），增加了引用计数，不方便回收（需要多次null）；
		 *		 2、_btnIdxDic该变量纵观全类起到的唯一作用是：记录被添加进来的按钮的先后顺序（第一个为0），这完全由_btns的索引轻松搞定。
		 * 代替：
		 * 		_btns的索引；
		 private var _btnIdxDic:Dictionary;
		 * */
		
		/**是否为横向排列按钮，默认横向*/
		protected var _isHorizontal:Boolean=true;
		
		/**
		 * 相邻两个按钮之间的间距（pixel）
		 * */
		protected var _spacing:int=1;
		
		/**
		 *下一个将要添加按钮的坐标；
		 * 去掉理由：
		 * 		1、少创建一个不必要的Point总是好事，Point创建挺慢；
		 *		2、int不需要注重释放，而Point就要注意其是否被引用，是否置null；
		 *		3、该变量仅仅是为了布局坐标，不参与业务逻辑；
		 * 
		 * 代替：
		 *		 _nextPosX,_nextPosY两个int变量，内存开销小，不会造成引用，不用担心开发端内存泄露；
		 //old:		private var _nextBtnPos:Point=new Point(0, 0);
		 */
		private var _nextPosX:int = 0;
		private var _nextPosY:int = 0;
		
		protected var _touchSelect:Boolean;
		
		/**
		 * 创建一个按钮集合
		 * @param check		可以复选？
		 * @param touchSelect	是否是按下选中，false=按下选中，true=click选中
		 * 
		 * <code>btn.addEventListener(touchSelect? GestureEvent.GESTURE_DOWN : GestureEvent.GESTURE_CLICK , onClickBtnHandler);</code>
		 */
		public function ButtonBar(isMultiSelectable:Boolean=true, touchSelect:Boolean=false)
		{
			_isMultiSelectable=isMultiSelectable;
			_touchSelect=touchSelect;
			
			_btns=new Vector.<Button>();
			_selectedBtns=new Vector.<Button>();
			
			//old:			_btnIdxDic=new Dictionary();
		}
		
		/**
		 * 向ButtonBar中添加按钮，新添加的按钮放在已添加按钮的后面（水平排列按钮）或者下面（垂直排列按钮）
		 *
		 * @param btn		按钮
		 * @param selected	是否为按下（选中）状态,如果该ButtonBar是单选的，并且在添加按钮的时候有>1的按钮被设为‘默认选中’，那么最终选中的是最后一个设置该参数为ture的按钮；
		 */
		public function addButton(btn:Button, selected:Boolean=false):void
		{
			//如果没有按钮，那就直接返回；
			if (btn == null)return;
			
			//old:			var idx:int=_btns.length;
			//old:			_btnIdxDic[btn]=idx;
			
			_btns.push(btn);
			addChild(btn);
			
			//old:			btn.x=_nextBtnPos.x;
			//old:			btn.y=_nextBtnPos.y;
			//old:			_isHorizontal ? _nextBtnPos.x+=btn.width + spacing : _nextBtnPos.y+=btn.height + spacing;
			setPosOfBtn(btn);
			
			
			//如果这个按钮默认是选中的状态，
			if (selected)
			{
				if (!_isMultiSelectable)
				{
					
					/**
					 * 去掉理由：
					 * 1、如果库设计严密、合理，此处不必有 try。。catch
					 * 2、耗时
					 * */
					//					try
					//					{
					if (_selectedBtns.length>0)
					{
						_selectedBtns[0].lock();
					}
					
					
					//					}
					//					catch (e:Error)
					//					{
					//
					//					}
					_selectedBtns[0]=btn;
				}
				else
				{
					_selectedBtns.push(btn);
				}
				btn.lock(2);
			}
			
			btn.addEventListener(_touchSelect? GestureEvent.GESTURE_DOWN : GestureEvent.GESTURE_CLICK , onClickBtnHandler);
		}
		
		
		/**
		 * 点击了按钮
		 * @param e
		 */
		protected function onClickBtnHandler(e:GestureEvent):void
		{
			e.stopPropagation();
			
			var btn:Button=e.currentTarget as Button;
			
			if (btn.enabled == false)
				return;
			if (btn.isLock) /*已经锁定*/
			{
				if (_isMultiSelectable) /*复选框*/
				{
					btn.lock();
					
					var index:int=_selectedBtns.indexOf(btn);
					if (index != -1)
					{
						_selectedBtns.splice(index, 1);
					}
				}
			}
			else
			{
				if (_isMultiSelectable)
				{
					_selectedBtns.push(btn);
				}
				else
				{
					
					/**
					 * 去掉理由：
					 * 1、如果库设计严密、合理，非异步代码不必有 try。。catch
					 * 2、耗时
					 * */
					//					try
					//					{
					if (_selectedBtns.length>0)
					{
						_selectedBtns[0].lock();
					}
					//					}
					//					catch (error:Error)
					//					{
					//
					//					}
					_selectedBtns[0]=btn;
				}
				btn.lock(2);
			}
			
			this.dispatchEvent(new UIEvent(UIEvent.CHANGE, false, e.localX, e.localY));
		}
		
		/**
		 * 移除按钮
		 * @param btn
		 */
		public function removeButton(btn:Button):void
		{
			
			if (!btn) return ;//降低堆栈使用；
			
			var index:int=getSelectIndex(btn);
			if (index != -1)
			{
				_btns.splice(index, 1);
				removeChild(btn);
				
				index=_selectedBtns.indexOf(btn);
				
				if (index != -1)
				{
					_selectedBtns.splice(index, 1);
					btn.lock();
				}
			}
			
			btn.removeEventListener(_touchSelect? GestureEvent.GESTURE_DOWN : GestureEvent.GESTURE_CLICK, onClickBtnHandler);
			
			//重新计算坐标;
			resetAllPosOfButton();
			
		}
		
		/**
		 * 选中哪个按钮
		 * @param index
		 */
		public function select(index:int=0):void
		{
			if (_btns.length > index && index > -1)
			{
				var btn:Button=_btns[index];
				
				if (!btn.isLock)
				{
					if (_isMultiSelectable)
					{
						var i:int=_selectedBtns.indexOf(btn);
						if (i == -1)
						{
							_selectedBtns.push(btn);
						}
					}
					else
					{
						//						try
						//						{
						if (_selectedBtns.length>0)
						{
							_selectedBtns[0].lock();
						}
						//						}
						//						catch (error:Error)
						//						{
						//							
						//						}
						_selectedBtns[0]=btn;
					}
					btn.lock(2);
				}
			}
		}
		
		/**
		 * 取消选中
		 * @param index
		 */
		public function unselect(index:int=0):void
		{
			var btn:Button=_btns[index];
			if (btn.isLock) /**已经锁定*/
			{
				if (_isMultiSelectable) /**复选框*/
				{
					btn.lock(); /**解除锁定*/
					
					index=_selectedBtns.indexOf(btn);
					if (index == -1)
					{
						_selectedBtns.splice(index, 1);
					}
				}
			}
		}
		
		/**
		 * 获得选中的按钮，如果是单选ButtonBar数组第一个就是选中的按钮引用。如果是复选ButtonBar，返回的是个数组
		 * @return
		 */
		public function get selectBtn():Vector.<Button>
		{
			return _selectedBtns;
		}
		
		
		/**
		 *单选状态得到选中按钮索引（-1为无选中按钮）
		 * Detail：
		 * 返回_selectedBtns：Vector.&lt;Button&gt;[0]与_btns:Vector.&lt;Button&gt;匹配时的索引号；
		 * 有效值：[0，_btns.length-1]闭区间的自然数；
		 * 多选情况下，仅返回-1；
		 * 任何_selectedBtns不存在或者不匹配的项以及不合法的其他变量皆返回-1（代表没有选中，不存在或其他合理的解释）；
		 *
		 * @return 		[0，_btns.length-1]闭区间的自然数	或	-1；
		 *
		 */
		public function get selectIndex():int
		{
			if (_isMultiSelectable || _selectedBtns.length<1)
				return -1;
			
			for (var i:int=0; i < _btns.length; i++)
			{
				
				if (_btns[i] == _selectedBtns[0])
					return i;
			}
			
			return -1;
			
		}
		
		protected function setPosOfBtn(btn:Button):void{
			//这里可以改为缓动;
			btn.x=_nextPosX;
			btn.y=_nextPosY;
			
			_isHorizontal ? _nextPosX+=btn.width + spacing : _nextPosY+=btn.height + spacing;
		}
		
		/**
		 *重新布局按钮的坐标；
		 * 比如spacing的值变化了。或者之前添加的某个按钮改变了等等；
		 *
		 */
		protected function setBtnsPos():void
		{
			//			var tmpNextBtnPos:Point=new Point(0, 0);
			_nextPosX=_nextPosY=0;
			
			for each(var btn:Button in _btns)
			{
				//old:				btn.x=tmpNextBtnPos.x;
				//old:				btn.y=tmpNextBtnPos.y;
				//old:				_isHorizontal ? tmpNextBtnPos.x+=btn.width + _spacing : tmpNextBtnPos.y+=btn.height + _spacing;
				setPosOfBtn(btn);
			}
			
			//			tmpNextBtnPos=null;
			
			
		}
		
		/**
		 * 是否为横向排列
		 */
		public function set isHorizontal(value:Boolean):void
		{
			
			if (_isHorizontal == value)return;
			
			_isHorizontal=value;
			setBtnsPos();
		}
		
		/**
		 * @private
		 * @return
		 */
		public function get isHorizontal():Boolean
		{
			return _isHorizontal;
		}
		
		/**
		 * 设置相邻两个按钮之间的间距（pixel）；
		 */
		public function set spacing(value:int):void
		{
			if (_spacing == value)return;
			
			_spacing=value;
			setBtnsPos();
		}
		
		/**
		 * 获取相邻两个按钮之间的间距（pixel）；
		 * @private
		 * @return
		 */
		public function get spacing():int
		{
			return _spacing;
		}
		
		/**
		 * 设置是否允许复选
		 */
		public function set isMultiSelectable(b:Boolean):void
		{
			if(_btns.length > 0)
			{
				throw new Error("can not use this function");
				return;
			}
			_isMultiSelectable = b;
		}
		
		/**
		 * 获取是否允许复选
		 */
		public function get isMultiSelectable():Boolean
		{
			return _isMultiSelectable;
		}
		
		/**
		 * 获得一个按钮的索引，该索引就是添加到该ButtonBar中的顺序，从0开始；
		 * 如果传入的按钮引用不是添加在该ButtonBar中的按钮，那么返回-1；
		 * @param btn		被添加到该ButtonBar中的按钮（合法按钮）
		 * @return	[0，_btns.length()-1] 或 -1
		 */
		public function getSelectIndex(btn:Button):int
		{
			//old:			return _btnIdxDic[btn];
			return _btns.indexOf(btn);
			
		}
		
		/**
		 *移除所有已添加的按钮
		 */
		public function removeAllBtns():void
		{
			
			removeChildren();
			
			//_btn.length = 0比new要快，因为new本身就是个耗时的一系列过程（内从申请，变量初始化等等）,详细原因及其工作过程询问老白、江波或者Adobe；
			//old:			_btns=new Vector.<Button>();
			_btns.length=0;
			
			//old:			_selectedBtns=new Vector.<Button>();
			_selectedBtns.length=0;
			
			//old:			_btnIdxDic=new Dictionary();
			
			//old:			_nextBtnPos=new Point(0, 0);
			
			//重置坐标;
			resetAllPosOfButton();
			
		}
		
		/**
		 *当移除一个Button后，需要重新计算Button的坐标，并正确摆放他们;
		 * 
		 */
		private function resetAllPosOfButton():void{
			_nextPosX=_nextPosY=0;
			for each (var btn:Button in _btns){
				setPosOfBtn(btn);
				
			}
		}
	}
}
