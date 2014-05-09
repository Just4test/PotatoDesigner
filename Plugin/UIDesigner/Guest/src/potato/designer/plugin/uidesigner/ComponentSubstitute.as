package potato.designer.plugin.uidesigner
{
import flash.geom.Matrix;
import flash.geom.Rectangle;

import core.display.DisplayObject;
import core.display.Image;
import core.display.RenderTexture;
import core.events.Event;
import core.events.TouchEvent;
import core.filters.BorderFilter;
import core.filters.Filter;

import potato.designer.framework.DesignerEvent;
import potato.designer.framework.EventCenter;
import potato.designer.plugin.guestManager.GuestManagerGuest;
import potato.events.GestureEvent;
import potato.ui.UIComponent;

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
    /**替身的原形*/
    protected var _prototype:*;
    protected const _subSubstitutes:Vector.<ComponentSubstitute> = new <ComponentSubstitute>[];
    protected var _parrentSubstitute:ComponentSubstitute;
    protected var _selected:Boolean;
	protected var _unfolded:Boolean;
	protected var _image:Image;
	
	protected var isDrugging:Boolean;
	protected var isDrugEnable:Boolean;
	protected var startDrugX:int;
	protected var startDrugY:int;
	
	protected static const SELECTED_FILTER:Filter = new BorderFilter();
	protected static const UNFOLD_FILTER:Filter = new BorderFilter(0xff0000ff, 2, true);
	
	

    public function get parrentSubstitute():ComponentSubstitute {
        return _parrentSubstitute;
    }

    public function get subSubstitutes():Vector.<ComponentSubstitute> {
        return _subSubstitutes;
    }

    public function ComponentSubstitute(prototype:*, parrent:ComponentSubstitute = null)
    {
        _prototype = prototype;
        _parrentSubstitute = parrent;
        refresh();
		
		/**单击选中组件*/
		addEventListener(GestureEvent.GESTURE_CLICK, selectHandler);
		/**长按执行默认操作*/
		addEventListener(GestureEvent.GESTURE_LONG_PRESS, operationHandler);
		/**拖动以移动组件*/
		addEventListener(GestureEvent.GESTURE_MOVE, drugingHandler);
    }

	
	
	/**
	 * 原型组件
	 * */
	public function get prototype():*
	{
		return _prototype;
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
        refresh();
    }

    /**
     * 展开效果
     * <br>此效果不能与选中效果同时触发
     * <br>双击一个折叠的组件替身时，如果该替身对应的组件是容器，则该替身取消选中效果并展开。双击展开状态外围，该组件替身折叠。
     * <br>展开状态下的组件替身呈现该组件中所有子组件隐藏后的外观。展开的组件无法移动或被选中直至被折叠。
     * <br>展开动作时，所有直接子组件被放入新的替身中呈现。与展开组件同层且叠放次序在展开的组件上方的替身被隐藏。
     * <br>双击展开状态的容器外围，该容器折叠。
     * <br>折叠状态下的组件替身呈现该组件的完整外观。
     * <br>折叠动作时，所有直接子组件所对应的替身被销毁。与被折叠组件同层且叠放次序在被折叠的组件上方的替身重新显示。
     * */
    public function get unfolded():Boolean {
        return _unfolded;
    }

    public function set unfolded(value:Boolean):void {
        _unfolded = value;
        refresh();
    }


    /**
     *重绘，当原形因为任何原因导致显示改变时调用此方法
     *
     */
    public function refresh():void
    {
        addEventListener(Event.ENTER_FRAME, actualRefersh);
    }

    protected function actualRefersh(e:Event):void
    {
        removeEventListener(Event.ENTER_FRAME, actualRefersh);

		_image ||= new Image(null);
		
        var displayObj:DisplayObject = _prototype as DisplayObject;
        if(!displayObj)
        {
            return;
        }

        x = displayObj.x;
        y = displayObj.y;

		
//        graphics.clear();
		var bounes:Rectangle = displayObj.getBounds(displayObj);
		



        if(bounes.width && bounes.height)
        {
            //绘制原型自身
            if(_unfolded)//暂时隐藏所有子节点
            {
                var hidden:Array = new Array;
                for each(var iSubstitute:ComponentSubstitute in subSubstitutes)
                {
                    var subDisplayObject:DisplayObject = iSubstitute._prototype as DisplayObject;
                    if(subDisplayObject && subDisplayObject.visible)
                    {
                        hidden.push(subDisplayObject);
                        subDisplayObject.visible = false
                    }
                }
            }
			
			var renderTexture:RenderTexture = new RenderTexture(bounes.width || 1, bounes.height || 1);//防止显示对象尺寸为0
			renderTexture.draw(displayObj);
			
            if(_unfolded)//重新显示隐藏的子节点
            {
                while(hidden.length)
                {
                    hidden.pop().visible = true;
                }
            }

        }
		
		
		
		if(_unfolded)//绘制展开效果
		{
			_image.filter = UNFOLD_FILTER;
		}
		else if(_selected)//绘制选中效果
        {
			_image.filter = SELECTED_FILTER;
        }
		
		_image.texture = renderTexture;
    }

    /**
     * 返回当前组件在组件树中的路径
     * <br>形如"0.1.4"表示当前组件是根组件的第二个子组件的第五个子组件
     * */
    public function getPath():String
    {
        if(!_parrentSubstitute)
        {
            return "0";
        }
        return _parrentSubstitute.getPath() + "." + _parrentSubstitute._subSubstitutes.indexOf(this);
    }

////////////////////////////////////////////////////////////////////////////////////////
	
	/**选中组件的回调*/
	protected function selectHandler(e:GestureEvent):void
	{
		var controlEvent:DesignerEvent = new DesignerEvent(Const.SUBSTITUTE_CLICK, this);
		EventCenter.dispatchEvent(controlEvent);
		if(!controlEvent.isDefaultPrevented())
		{
			GuestManagerGuest.send(Const.SUBSTITUTE_CLICK, getPath());
		}
	}
	
	/**执行默认操作的回调*/
	protected function operationHandler(e:GestureEvent):void
	{
		var controlEvent:DesignerEvent = new DesignerEvent(Const.SUBSTITUTE_LONG_PRESS, this);
		EventCenter.dispatchEvent(controlEvent);
		if(!controlEvent.isDefaultPrevented())
		{
			GuestManagerGuest.send(Const.SUBSTITUTE_LONG_PRESS, getPath());
		}
	}
	
	/**拖动组件的回调*/
	protected function drugingHandler(e:GestureEvent):void
	{
		if(isDrugging)
		{
			if(isDrugEnable)
			{
				x += e.stageX - startDrugX;
				y += e.stageY - startDrugY;
			}
		}
		else
		{
			isDrugging = true;
			addEventListener(GestureEvent.GESTURE_UP, drugEndHandler);
			startDrugX = e.stageX;
			startDrugY = e.stageY;
			var controlEvent:DesignerEvent = new DesignerEvent(Const.SUBSTITUTE_MOVE_START, this);
			EventCenter.dispatchEvent(controlEvent);
			if(!controlEvent.isDefaultPrevented())
			{
				GuestManagerGuest.send(Const.SUBSTITUTE_MOVE_START, getPath());
			}
		}
		
	}

	protected function drugEndHandler(e:GestureEvent):void
	{
		isDrugging = false;
		isDrugEnable = false;
		removeEventListener(GestureEvent.GESTURE_UP, drugEndHandler);
		
		var controlEvent:DesignerEvent = new DesignerEvent(Const.SUBSTITUTE_MOVE_END, this);
		EventCenter.dispatchEvent(controlEvent);
		if(!controlEvent.isDefaultPrevented())
		{
			GuestManagerGuest.send(Const.SUBSTITUTE_MOVE_END, getPath());
		}
	}
	
	public function startDrug():void
	{
		if(isDrugging)
		{
			isDrugEnable = true;
		}
	}


}
}