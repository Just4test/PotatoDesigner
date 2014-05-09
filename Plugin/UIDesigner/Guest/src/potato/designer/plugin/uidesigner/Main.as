package potato.designer.plugin.uidesigner
{
import flash.display.Sprite;

import core.display.DisplayObject;
import core.text.TextField;

import potato.designer.framework.DesignerEvent;
import potato.designer.framework.EventCenter;
import potato.ui.UIComponent;

public class Main extends Sprite
{
	
	/**组件类映射表*/
	protected static const componentClassMap:Object = new Object();
	/**组件视图的数据提供程序*/
	protected static const componentViewDataProvider:ArrayCollection = new ArrayCollection;
	/**属性视图的数据提供程序*/
	protected static const propertyViewDataProvider:ArrayCollection = new ArrayCollection;

    /**设计舞台*/
    protected static var designStage:Group;
    /**组件视图*/
    protected static var componentsView:List;
    /**大纲视图*/
    protected static var outlineView:Tree;
    /**属性视图*/
    protected static var propertyView:List;
    /**设计舞台的根XML,同时也作为大纲视图事件源*/
    protected static var _rootXml:XML;
    /**根组件替身*/
    protected static var rootSubstitute:ComponentSubstitute
    /**根XML编译结果*/
    protected static var rootCompileResult:CompileResult
    /**根XML的展开路径*/
    protected static var foldPath:String;
    /**选中对象的路径*/
    protected static var focusPath:String;
    /**选中对象的属性表*/
    protected static var focusPropertyMap:Object;

    public static function initApp():void
    {

        designStage = FlexGlobals.topLevelApplication.designStage;
        componentsView = FlexGlobals.topLevelApplication.componentsView;
        outlineView = FlexGlobals.topLevelApplication.outlineView;
        propertyView = FlexGlobals.topLevelApplication.propertyView;
		
		componentsView.dataProvider = componentViewDataProvider;
		propertyView.dataProvider = propertyViewDataProvider;
		


        UIComponent;
        TextField;

        loadConfig();



        EventCenter.addEventListener(EventCenter.COMPONENT_VIEW_ITEM_CLICK, onComponentViewItemClick);
        EventCenter.addEventListener(EventCenter.OUTLINE_VIEW_ITEM_CLICK, onOutlineViewItemClick);
        EventCenter.addEventListener(EventCenter.OUTLINE_VIEW_ITEM_DOUBLE_CLICK, onOutlineViewItemDoubleClick);
        EventCenter.addEventListener(EventCenter.SUBSTITUTE_CLICK, onSubstituteClick);
        EventCenter.addEventListener(EventCenter.SUBSTITUTE_DOUBLE_CLICK, onSubstituteDoubleClick);
        EventCenter.addEventListener(EventCenter.SUBSTITUTE_MOUSE_DOWN, onSubstituteMouseDown);
        EventCenter.addEventListener(EventCenter.SUBSTITUTE_DRUG_END, onSubstituteDrugEnd);
        EventCenter.addEventListener(EventCenter.PROPERTY_VIEW_ITEM_DATA_CHANGE, onPropertyDataChange);
        EventCenter.addEventListener(EventCenter.UPDATE, onUpdate);


    }

    /**
     *载入配置文件
     * 包括组件描述文件、资源路径
     *
     */
    public static function loadConfig():void
    {


        var fileStream:FileStream = new FileStream();
        var file:File;

        //载入组件类描述文件
        file = new File("app:/assets/ComponentClassProfile.xml");
        if(file.exists)
        {
            fileStream.open(file, FileMode.READ);
            var classXML:XML = new XML(fileStream.readMultiByte(fileStream.bytesAvailable, File.systemCharset));
            fileStream.close();


            for each(var iXml:XML in classXML.component)
            {
                var tempProps:Vector.<PropertyProfile> = new <PropertyProfile>[];
                for each(var jXml:XML in iXml.property)
                {
                    var tempSingProp:PropertyProfile = new PropertyProfile(jXml.@name);
                    jXml.@type && (tempSingProp.type = jXml.@type);
                    jXml.@defultValue && (tempSingProp.defultValue = jXml.@defultValue);
                    jXml.@nickName && (tempSingProp.nickName = jXml.@nickName);
                    jXml.@processor && (tempSingProp.processor = jXml.@processor);

                    tempProps.push(tempSingProp);

                }
                var tempPrefile:DesignerComponentClassProfile =
                        new DesignerComponentClassProfile(iXml.@nickName, iXml.@className, tempProps);

                componentClassMap[iXml.@nickName] = tempPrefile;
	            DesignerComponentFactory.registerComponentClass(tempPrefile.nickName, tempPrefile.className);
				componentViewDataProvider.addItem(tempPrefile);
            }
        }

        _rootXml = <root/>;
        outlineView.dataProvider = _rootXml;
        foldPath = "0";
        focusPath = "0";


        EventCenter.dispatchEvent(new DesignerEvent(EventCenter.UPDATE,null));


    }


    /**
     * 以默认设置创建组件XML
     * @param nickName 组件类昵称
     * @return 默认XML
     *
     */
    public static function creatDefaultComponentXml(nickName:String):XML
    {
        var classProfile:DesignerComponentClassProfile = componentClassMap[nickName];
        if(!classProfile)
            return null;

        //根据属性默认值创建组件XML
        var xml:XML = <{nickName}></{nickName}>;
        for each(var p:PropertyProfile in classProfile.propertys)
        {
            xml.@[p.name] = p.defultValue;
        }
        return xml;
    }
	
    /**
     * 根据路径获取子XML.路径中的第一个节点应该始终为0.
     */
    public static function getSubXml(xml:XML, path:String):XML
    {
        /**展开路径*/
        var indexArray:Array = path.split(".");
        indexArray.shift();
        while(indexArray.length)
        {
            xml = xml.children()[int(indexArray.shift())];
        }
        return xml;
    }

    /**
     * 根据子XML获取路径
     */
    public static function getPath(xml:XML):String
    {
        if(!xml.parent())
        {
            return "0";
        }
        return getPath(xml.parent() as XML) + "." + xml.childIndex().toString();
    }

    /**
     * 根据路径获取子组件替身,注意如果该替身不处于展开路径内是无法获取的
     */
    public static function getSubSubstitute(substitute:ComponentSubstitute, path:String):ComponentSubstitute
    {
        var indexArray:Array = path.split(".");
        indexArray.shift();
        while(indexArray.length)
        {
            if(!substitute.subSubstitutes.length)
            {
                return null;
            }
            substitute = substitute.subSubstitutes[int(indexArray.shift())];
        }
        return substitute;
    }

    /**
     * 根据路径获取子组件编译结果
     */
    public static function getSubCompileResult(result:CompileResult, path:String):CompileResult
    {
        var indexArray:Array = path.split(".");
        indexArray.shift();
        while(indexArray.length)
        {
            result = result.subCompileResult[int(indexArray.shift())];
        }
        return result;
    }


    /**
     * 定位视图焦点.
     * <br>如果展开路径不是焦点自身或者焦点的父节点,将重新定位展开路径至:焦点自身(如果焦点没有父节点)或者焦点的父节点.
     * <br>还将设置设计舞台上替身的选中效果,以及大纲视图的选中效果.
     * <br>如果焦点为空,则.
     */
    public static function setFocusPath(path:String):void
    {
        focusPath = path;
        trace("焦点路径", focusPath);

        //检查展开路径是否需要重设
        var parentIndexArray:Array = focusPath.split(".");
        parentIndexArray.pop();
        if(0 != focusPath.indexOf(foldPath) || parentIndexArray.length > foldPath.split(".").length)
        {
            setFoldPath(parentIndexArray.length ? parentIndexArray.join(".") : "0");
        }

        //设置替身的选中效果及遮盖效果(,)
        var overFocus:Boolean = false;
        for(var i:int = 0; i < designStage.numElements; i++)
        {
            var substitute:ComponentSubstitute = designStage.getElementAt(i) as ComponentSubstitute;
            if(!substitute)
            {
                continue;
            }
            substitute.alpha = overFocus ? 0.5 : 1;//如果焦点不是展开路径,高于焦点的同层替身都会被设为半透明
            substitute.visible = overFocus ? 0 == substitute.getPath().indexOf(foldPath) : true;//高于焦点的非同层替身都会被设为隐藏
            (substitute.selected = substitute.getPath() == focusPath) && (overFocus = true);
        }




        //设置大纲视图的选中效果
        var focusXml:XML = getSubXml(_rootXml, focusPath);
        outlineView.selectedItem = focusXml;
		
		//设置属性视图
        focusPropertyMap = new Object();
        var tempP:PropertyProfile;
        //添加自身属性
        var propertys:Vector.<PropertyProfile> = (componentClassMap[focusXml.name()] as DesignerComponentClassProfile).propertys;
        for each(var p:PropertyProfile in propertys)
        {
            tempP = p.copy();
            tempP.value = focusXml.@[p.name].length ? focusXml.@[p.name].toString() : null;
            focusPropertyMap[p.name] = tempP;
        }
        //添加托管属性
        if(parentIndexArray.length)
        {
            var parentIManagedProp:IManagedProp = getSubCompileResult(rootCompileResult, parentIndexArray.join(".")).component as IManagedProp;
            if(parentIManagedProp)
            {
                for each(var iString:String in parentIManagedProp.managedPropList)
                {
                    if(!focusPropertyMap[iString])//如果没有指定此属性,则新建属性.
                    {
                        tempP = p.copy();
                        tempP.value = focusXml.@[iString].length ? focusXml.@[iString].toString() : null;
                        focusPropertyMap[iString] = tempP;
                    }
                }
            }
        }
        //如果是DisplayObject对象,自动添加x y width height. 这一步骤在添加托管属性之后,因此如果托管属性中指定了值,则不会被DisplayObject对象的默认值所覆盖.
        var displayObject:DisplayObject = getSubCompileResult(rootCompileResult, focusPath).component as DisplayObject;
        if(displayObject)
        {
            if(!focusPropertyMap["x"])
            {
                tempP = new PropertyProfile("x", PropertyProfile.TYPE_INT);
                tempP.value = int(displayObject.x).toString();
                focusPropertyMap["x"] = tempP;
            }
            if(!focusPropertyMap["y"])
            {
                tempP = new PropertyProfile("y", PropertyProfile.TYPE_INT);
                tempP.value = int(displayObject.y).toString();
                focusPropertyMap["y"] = tempP;
            }
        }

        propertyViewDataProvider.removeAll();
        for each(var iProfile:PropertyProfile in focusPropertyMap)
        {
            propertyViewDataProvider.addItem(iProfile);
        }


    }


    /**
     * 定位展开路径.
     * <br>如果展开路径不是焦点自身或者焦点的父节点,焦点将被设置为与展开路径相同.
     * <br>将展开大纲视图的对应路径,展开舞台替身的路径.
     */
    public static function setFoldPath(path:String):void
    {
        foldPath = path;
        trace("展开路径", foldPath);

        //重新创建替身树并展开至对应路径
        designStage.removeAllElements();
        rootSubstitute = creat(rootCompileResult, null, 0, foldPath.split("."), _rootXml);

        function creat(compileResult:CompileResult, parrent:ComponentSubstitute, index:int, indexArray:Array, xml:XML):ComponentSubstitute
        {

            //创建当前替身
            var ret:ComponentSubstitute = new ComponentSubstitute(compileResult.component, parrent);
            designStage.addElement(ret);



            if(indexArray.length && index == indexArray.shift())
            {
                //展开大纲视图对应节点
                outlineView.expandItem(xml ,true);
                //展开目标层
                ret.unfolded = true;
                for(var i:int = 0; i <  compileResult.subCompileResult.length; i++)
                {
                    ret.subSubstitute[i] = creat(compileResult.subCompileResult[i], ret, int(i), indexArray, xml.children()[i]);
//                    if(ret.subSubstitute[i].subSubstitute.length)//不渲染展开路径以上的节点
//                    {
//                        break;
//                    }
                }
            }
            return ret;
        }



        //检查焦点是否需要重设
        if(0 != focusPath.indexOf(foldPath) || focusPath.split(".").length > foldPath.split(".").length + 1)
        {
            setFocusPath(foldPath);
        }

    }

    /////////////////////////操作响应/////////////////


    /**
     * 组件视图item的点击响应:于当前父节点追加指定组件
     */
    public static function onComponentViewItemClick(e:DesignerEvent):void
    {
        //追加组件XML
        getSubXml(_rootXml, foldPath).appendChild(creatDefaultComponentXml(e.data.nickName));


        EventCenter.dispatchEvent(new DesignerEvent(EventCenter.UPDATE,null));
    }

    /**
     * 大纲视图item的点击响应:选中指定组件
     */
    public static function onOutlineViewItemClick(e:DesignerEvent):void
    {
        setFocusPath(getPath(e.data as XML));
    }


    /**
     * 大纲视图item的双击响应:展开指定组件
     */
    public static function onOutlineViewItemDoubleClick(e:DesignerEvent):void
    {
        if(getSubCompileResult(rootCompileResult, getPath(e.data as XML)).component is IContainer)
        {
            setFoldPath(getPath(e.data as XML));
        }
    }

    /**
     * 组件替身点击响应:选中指定组件
     */
    public static function onSubstituteClick(e:DesignerEvent):void
    {
        setFocusPath(e.data as String);
    }

    /**
     * 组件替身双击响应:展开/折叠指定组件
     */
    public static function onSubstituteDoubleClick(e:DesignerEvent):void
    {
        if(getSubCompileResult(rootCompileResult, e.data as String).component is IContainer)
        {
            if(e.data as String != foldPath)
            {
                setFoldPath(e.data as String);
            }
            else
            {
                //双击了当前展开的组件。则如果它不是根组件则折叠
                if(foldPath != "0")
                {
                    var a:Array = foldPath.split(".");
                    a.pop();
                    setFoldPath(a.join("."));
                }
            }
        }
    }

    /**
     * 组件替身鼠标按下响应:检查是否开始拖拽
     */
    public static function onSubstituteMouseDown(e:DesignerEvent):void
    {
        var c:ComponentSubstitute = e.data as ComponentSubstitute;
        var path:String = c.getPath();
        if(path != "0" && path == focusPath && path != foldPath && c.prototype is DisplayObject)
        {
            c.startDrug();
        }
    }

    /**
     * 组件替身拖拽结束响应:改变X与Y
     */
    public static function onSubstituteDrugEnd(e:DesignerEvent):void
    {
        var c:ComponentSubstitute = e.data as ComponentSubstitute;
        var xml:XML = getSubXml(_rootXml, focusPath);
        xml.@x = c.x;
        xml.@y = c.y;

        EventCenter.dispatchEvent(new DesignerEvent(EventCenter.UPDATE,null));
    }

    /**
     * 属性组件请求改变属性值
     */
    public static function onPropertyDataChange(e:DesignerEvent):void
    {
        var xml:XML = getSubXml(_rootXml, focusPath);
        xml.@[e.data.name] = e.data.value;

        EventCenter.dispatchEvent(new DesignerEvent(EventCenter.UPDATE,null));

    }




    /**
     * XML更新
     */
    public static function onUpdate(e:DesignerEvent):void
    {
        //设计编译
        rootCompileResult = DesignerComponentFactory.designCompile(_rootXml);
        //重新生成组件替身
        setFoldPath(foldPath);
        setFocusPath(focusPath);
        PreviewServer.push();
    }


    public static function get rootXml():XML {
        return _rootXml;
    }
}
}












