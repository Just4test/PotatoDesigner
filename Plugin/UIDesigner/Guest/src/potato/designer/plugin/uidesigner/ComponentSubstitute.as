package potato.designer.plugin.uidesigner
{
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import core.display.DisplayObject;
import core.display.DisplayObjectContainer;
import core.display.Image;
import core.display.RenderTexture;
import core.filters.Filter;
import core.filters.ShadowFilter;
import core.text.TextField;

import potato.designer.framework.DesignerEvent;
import potato.designer.framework.EventCenter;
import potato.designer.plugin.guestManager.GuestManagerGuest;
import potato.designer.plugin.uidesigner.factory.TargetTree;
import potato.events.GestureEvent;
import potato.ui.UIComponent;
import potato.ui.UIGlobal;

/**
 * 组件替身，用于在编辑器中呈现组件外观，并与编辑器交互
 * <br>替身如果连接了一个显示组件DisplayObject,则他可以在设计舞台上呈现
 * <br>替身如果连接了一个容器,则它可以展开
 * <br>替身可以被选中，呈现高亮状态并且编辑器可以显示和编辑其对应的组件属性
 * <br>替身可以被拖拽并派发移动事件。编辑器会判断xy是否被托管，以决定是否允许组件被自由拖动。
 * @author just4test
 *
 */
public class ComponentSubstitute extends UIComponent
{
	/**替身对应的目标*/
	protected var _targetTree:TargetTree;
	
	protected var _path:Vector.<uint>;
	
	
	
	
//    /**替身的原形*/
//    protected var _prototype:*;
//	/**子替身列表*/
//    protected const _subSubstitutes:Vector.<ComponentSubstitute> = new <ComponentSubstitute>[];
//	/**父替身*/
//    protected var _parentSubstitute:ComponentSubstitute;
	/**指示该替身是否处于选中状态*/
    protected var _selected:Boolean;
	/**指示该替身是否处于展开状态*/
	protected var _unfolded:Boolean;
	/**替身的代图*/
	protected var _image:Image;
	
	protected var isDrugging:Boolean;
	protected var startDrugX:int;
	protected var startDrugY:int;
	
//	protected static const SELECTED_FILTER:Filter = new BorderFilter(0xffff0000, 2);
	protected static const SELECTED_FILTER:Filter = new ShadowFilter(0xd0000000, 4, 4);
//	protected static const UNFOLD_FILTER:Filter = new BorderFilter(0xff0000ff, 2, true);
	protected static const UNFOLD_FILTER:Filter = null;
	/**边缘宽度，以便显示滤镜*/
	protected static const BORDER_WIDTH:int = 5;
	
	

//    public function get parentSubstitute():ComponentSubstitute {
//        return _parentSubstitute;
//    }
//
//    public function get subSubstitutes():Vector.<ComponentSubstitute> {
//        return _subSubstitutes;
//    }

    public function ComponentSubstitute(targetTree:TargetTree, path:Vector.<uint>, rootLayer:DisplayObjectContainer = null)
    {
		_targetTree = targetTree;
		_path = path;
        draw(rootLayer);
		
		/**单击选中组件*/
		addEventListener(GestureEvent.GESTURE_CLICK, selectHandler);
		/**长按执行默认操作*/
		addEventListener(GestureEvent.GESTURE_LONG_PRESS, operationHandler);
		/**拖动以移动组件*/
		addEventListener(GestureEvent.GESTURE_MOVE, drugingHandler);
		addEventListener(GestureEvent.GESTURE_UP, drugEndHandler);
    }

	
	
	/**
	 * 原型组件
	 * */
	public function get prototype():*
	{
		return _targetTree.target;
	}

    /**
     * 选中效果
     * <br>此效果不能与展开效果同时触发
     * */
    public function get selected():Boolean {
        return _selected;
    }

    public function set selected(value:Boolean):void {
        _selected = value;
		setEffact();
    }

    /**
     * 展开效果
     * <br>此效果不能与选中效果同时触发
     * <br>双击一个折叠的组件替身时，如果该替身对应的组件是容器，则该替身取消选中效果并展开。双击展开状态外围，该组件替身折叠。
     * <br>展开状态下的组件替身呈现该组件中所有子组件隐藏后的外观。展开的组件无法移动或被选中直至被折叠。
     * <br>展开动作时，所有直接子组件被放入新的替身中呈现。与展开组件同层且叠放次序在展开的组件上方的替身被隐藏。
     * <br>双击展开状态的容器外围，该容器折叠。
     * <br>折叠状态下的组件替身呈现该组件的完整外观。
     * <br>折叠动作时，所有子组件所对应的替身被销毁。与被折叠组件同层且叠放次序在被折叠的组件上方的替身重新显示。
     * */
    public function get unfolded():Boolean {
        return _unfolded;
    }

    public function set unfolded(value:Boolean):void {
        _unfolded = value;
		setEffact();
    }
	
	protected function setEffact():void
	{
		if(!_image)
			return;
		
		_image.filter = _selected ? SELECTED_FILTER : (_unfolded ? UNFOLD_FILTER : null);
	}

	/**
	 *刷新显示，三种情况：
	 * 1.当前对象是DisplayObject，且指定根节点放置层。指定了放置层时，放置层中所有非当前对象的显示对象都已经被隐藏。
	 * 2.当前对象是DisplayObject，且未指定根节点放置层。将直接绘制当前对象。
	 * 3.当前对象不是显示对象。将绘制对象的toString文本。
	 * @param rootLayer 根节点放置层 
	 * 
	 */
    protected function draw(rootLayer:DisplayObjectContainer = null):void
    {
		var displayObj:DisplayObject;
		
		if(prototype is DisplayObject)
		{
			displayObj = prototype as DisplayObject;
		}
		else
		{
			displayObj = new TextField(prototype.toString(), 100, 100,  UIGlobal.defaultFont, 20, 0xffffffff);
		}

		var bounes:Rectangle = displayObj.getBounds(rootLayer || displayObj);
		
		x = bounes.x;
		y = bounes.y;
		
		//绘制原型自身
		if(_unfolded)//暂时隐藏所有子节点
		{
			var hidden:Vector.<DisplayObject> = new Vector.<DisplayObject>;
			for each(var sub:* in _targetTree.children)
			{
				var subDis:DisplayObject = sub as DisplayObject;
				if(subDis && subDis.visible)
				{
					hidden.push(subDis);
					subDis.visible = false
				}
			}
		}
		
		var renderTexture:RenderTexture = new RenderTexture(bounes.width + BORDER_WIDTH * 2, bounes.height + BORDER_WIDTH * 2);
		//设置转换矩阵。转换矩阵将对象放置在(BORDER_WIDTH, BORDER_WIDTH)点，以便留出边缘显示描边滤镜；
		var matrix:Matrix = new Matrix;
		matrix.tx = BORDER_WIDTH - bounes.x;
		matrix.ty = BORDER_WIDTH - bounes.y;
		log("创建替身", displayObj, displayObj.visible, bounes, matrix);
		renderTexture.draw(rootLayer || displayObj, matrix);
		
		if(_unfolded)//重新显示隐藏的子节点
		{
			while(hidden.length)
			{
				hidden.pop().visible = true;
			}
		}
		
		if(!_image)
		{
			_image = new Image(null);
			addChild(_image);
		}
		
		_image.x = _image.y = -BORDER_WIDTH;
		setEffact();
		
		_image.texture = renderTexture;
    }

    /**
     * 返回当前组件的路径
     * <br>形如"[0,1,4]"表示当前组件是根组件的第二个子组件的第五个子组件
     * */
    public function get path():Vector.<uint>
    {
//        if(!_parentSubstitute)
//        {
//            return new Vector.<uint>;
//        }
//		var ret:Vector.<uint> = _parentSubstitute.path;
//		ret.push(_parentSubstitute._subSubstitutes.indexOf(this))
        return _path.concat();
    }
	
	/**
	 *检查当前路径是否和目标路径相同，或者是目标路径的父路径。
	 */
	public function inPath(foldPath:Vector.<uint>):Boolean
	{
		if(_path.length > foldPath.length)
			return false;
		
		for (var i:int = 0; i < _path.length; i++) 
		{
			if(_path[i] != foldPath[i])
				return false;
		}
		
		return true;
	}

////////////////////////////////////////////////////////////////////////////////////////
	
	/**选中组件的回调*/
	protected function selectHandler(e:GestureEvent):void
	{
		log("点击", path);
		
		var foldPath:Vector.<uint> = path;
		var focusIndex:int = foldPath.pop();
		
		GuestManagerGuest.send(DesignerConst.C2S_SET_FOLD_FOCUS, [foldPath, focusIndex]);
		
		
		
//		var controlEvent:DesignerEvent = new DesignerEvent(DesignerConst.C2S_SET_FOLD_FOCUS, this);
//		EventCenter.dispatchEvent(controlEvent);
//		if(!controlEvent.isDefaultPrevented())
//		{
//			GuestManagerGuest.send(DesignerConst.C2S_SET_FOLD_FOCUS, [foldPath, focusIndex]);
//		}
	}
	
	/**执行默认操作的回调*/
	protected function operationHandler(e:GestureEvent):void
	{
//		log("长按", path);
//		var controlEvent:DesignerEvent = new DesignerEvent(DesignerConst.SUBSTITUTE_LONG_PRESS, this);
//		EventCenter.dispatchEvent(controlEvent);
//		if(!controlEvent.isDefaultPrevented())
//		{
//			GuestManagerGuest.send(DesignerConst.SUBSTITUTE_LONG_PRESS, path);
//		}
	}
	
	/**拖动组件的回调*/
	protected function drugingHandler(e:GestureEvent):void
	{
		if(isDrugging)
		{
			x = e.stageX - startDrugX;
			y = e.stageY - startDrugY;
		}
		else
		{
			if(!_selected)
				return;
			
			isDrugging = true;
			startDrugX = e.stageX - x;
			startDrugY = e.stageY - y;
		}
		
	}

	protected function drugEndHandler(e:GestureEvent):void
	{
		if(!isDrugging)
		{
			return;
		}
		isDrugging = false;

		var displayObj:DisplayObject = _targetTree.target as DisplayObject;
		var p:Point = displayObj.globalToLocal(new Point(x, y));
		p.x += displayObj.x;
		p.y += displayObj.y;
		var bounes:Rectangle = displayObj.getBounds(displayObj);
		p = new Point(p.x - bounes.x, p.y - bounes.y);
		
		GuestManagerGuest.send(DesignerConst.C2S_DISPLAYOBJ_MOVE, [path, p.x, p.y]);
	}
	
	///////////////////////////////////////////////////////////////////////////////
	
}
}