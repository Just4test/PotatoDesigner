package potato.designer.plugin.uidesigner
{
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import potato.componentInterface.IComponentFactory;
import potato.componentInterface.IContainer;
import potato.componentInterface.ICreationComplete;
import potato.componentInterface.IFactoryHandle;
import potato.componentInterface.IInitialize;
import potato.componentInterface.IManagedProp;
import potato.componentInterface.IPackedProp;
import potato.componentInterface.IProxyConstructor;
import potato.componentInterface.ISelfXMLOverride;
import potato.display.ImageProxyConstructor;
import potato.error.Logger;
import potato.error.MyError;
import potato.factory.ComponentFactory;
import potato.factory.ComponentFactoryData;
import potato.factory.ComponentFactoryUtils;
import potato.factory.ComponentProfile;
import potato.factory.CopmonentClassProfile;

/**
 * 设计时XML-Object转换逻辑如下：
 * <br>1.根据XML转换为Obj。
 * <br>2.工厂使用Obj创建对象。
 * <br>3.调用对象的IIntialize接口。
 * <br>4.如果对象实现了ISelfSXMLOverride接口，调用之。否则，依次创建其子对象（跳转到2）
 * <br>5.如果ISelfSXMLOverride返回了XML，则抛弃当前对象的所有子对象（如果有的话），然后使用新的XML转换为Obj并依次创建其子对象。注意，当前对象本身不会被重新创建。所以，当前对象需要维护其自身的属性值，以使其与XML同步。如果（跳转到2）
 * <br>6.如果ISelfSXMLOverride返回了XMLList，则抛弃当前对象，将XMLList添加到原有的父级XML中；继续创建该XMLList指定的子对象。（跳转到2）
 * @author just4test
 *
 */
public class DesignerComponentFactory implements IComponentFactory
{
    /*编译器保留字*/

    /*ID。从根对象可以直接访问到其托管的具有id的子组件，无论该子组件被挂载在哪个层级。*/
    public static const RESERVED_WORD_ID:String = "ID";
    /*指定组件是否为根。根对象托管其所有子组件的id，除了被子级根对象托管的那些。*/
    public static const RESERVED_WORD_IS_ROOT:String = "isRoot";
    /*组件别名。用于为容器提供一个在构建期间快速访问其直接子级指定组件的方法*/
    public static const RESERVED_WORD_ALIAS:String = "__alias";

    protected static const reservedWord:Vector.<String> = new <String>[
        RESERVED_WORD_ID, RESERVED_WORD_IS_ROOT, RESERVED_WORD_ALIAS];

    /*自我XML覆写允许的最大嵌套次数*/
    public static const MAX_TIMES_SELF_XML_OVERRIDE:int = 2;

    protected static var _overrideCounter:int;

    protected static const classMap:Object = new Object;


    protected var _profile:ComponentProfile;
    protected var _alias:String;
    protected var _parent:IContainer;
    protected var _root:IContainer;
    protected var _component:*;

    protected var _subStructs:Vector.<CompileStruct>;

    /**
     * 一个回调函数，允许子组件工厂对其父工厂插入子节点。
     * <br>该回调函数的两个参数必须一个有效，另一个为null。
     * <br>insertSub(obj:*, xmlList:XMLList):void`
     * @param obj 如果对象被成功组装，则返回组装出的对象
     * @param xmlList 如果对象被覆写为一个xmlList，则返回该XMLList。
     */
//        protected var insertSub:Function;

    public function DesignerComponentFactory()
    {
    }

    public static function compile2Profile(xml:XML):ComponentProfile
    {
        ComponentFactoryUtils.MODE = ComponentFactoryUtils.MODE_RELEASE;
        return (new DesignerComponentFactory()).compile(xml).profile;
    }

    /**
     * 导出发行版
     * @param profile
     * @return
     *
     */
    public static function exportReleaseBuild(componentMappingTable:Object, supportLanguage:String, supportPlatform:String):ComponentFactoryData
    {
        ComponentFactoryUtils.MODE = ComponentFactoryUtils.MODE_RELEASE;

        var ret:ComponentFactoryData = new ComponentFactoryData() ;

        ret.supportLanguage = supportLanguage;
        ret.supportPlatform = supportPlatform;

        ret.componentProfileMappingTable = new Object();
        for each(var l:String in supportLanguage.split(","))
        {
            ret.componentProfileMappingTable[l] = new Object();
            ComponentFactoryUtils.LANGUAGE = l;
            for each(var p:String in supportPlatform.split(","))
            {
                ret.componentProfileMappingTable[l][p] = new Object();
                ComponentFactoryUtils.PLATFORM = p;

                for(var nickName:String in componentMappingTable)
                {
                    ret.componentProfileMappingTable[l][p][nickName] =
                            (new DesignerComponentFactory()).compile(componentMappingTable[nickName] as XML).profile;
                }
            }
        }

        ret.protoComponentArray = [];

        for(nickName in classMap)
        {
            ret.protoComponentArray.push({nickName:nickName, className:getQualifiedClassName(classMap[nickName].compClass)});
        }


        return ret;
    }


    /**
     * 装配组件
     * @param profile
     * @return
     *
     */
    public static function assemble(xml:XML):*
    {
        ComponentFactoryUtils.MODE = ComponentFactoryUtils.MODE_DESIGN;
        return (new DesignerComponentFactory()).compile(xml).component;
    }

    /**
     * 以设计模式编译
     */
    public static function designCompile(xml:XML):CompileResult
    {
        ComponentFactoryUtils.MODE = ComponentFactoryUtils.MODE_DESIGN;

        return new DesignerComponentFactory().compile(xml);

    }


    /**
     *编译，以XML进行编译，返回组建描述文件和生成的对象。
     * <br>可以以设计模式或编译模式执行。设计模式下不会进行自我XML覆写。
     * <br>转换逻辑如下：
     * <br>1.将XML转换为组件描述文件。
     * <br>2.将组件描述文件转换为组件实例。
     * <br>3.工厂询问组件以获取其托管属性表、打包属性表。
     * <br>4.如果处于编译模式并且组件具有自我XML覆写能力，则进行XML覆写并重新创建组件。
     * <br>    覆写是由父级到子级单向进行。父级无法探知子级的覆写。
     * <br>5.递归创建所有子级。
     * @see potato.factory.ComponentFactory#MODE_DESIGN 设计模式
     * @see potato.factory.ComponentFactory#MODE_COMPILE 编译模式
     * @see #CompileResult 编译结果
     * @param xml 源XML
     * @param parentFactory 父组件工厂。特别的，在此值为空时不会返回XMLList，即返回结果中组件、别名和描述文件总是有效的。
     * @return
     *
     */
    protected function compile(xml:XML, parentFactory:DesignerComponentFactory = null):CompileResult
    {
        var isMerged:Boolean;


        if(ComponentFactoryUtils.MODE_DESIGN != ComponentFactoryUtils.MODE && ComponentFactoryUtils.MODE_RELEASE != ComponentFactoryUtils.MODE)
        {
            throw new MyError(10106, ComponentFactoryUtils.MODE);//编译方法只能执行在设计模式或者编译模式下。
        }
        if(parentFactory)
        {
            _parent = parentFactory._component as IContainer;
            if(!_parent)
            {
                throw new MyError(10107, parentFactory._component);//指定的父组件不是容器
            }
            _root = parentFactory._profile.isRoot ? _parent : parentFactory._root;
        }

        //将XML转换为组件描述文件。忽略打包属性处理器。
        var propMap:Object = new Object;

        //保留字写入属性映射表
        makePropMap(propMap, reservedWord, PropertyProfile.PROCESSOR_RESERVED);
		//父对象的托管属性写入属性映射表
		if(_parent && _parent is IManagedProp)
		{
			makePropMap(propMap, (_parent as IManagedProp).managedPropList, PropertyProfile.PROCESSOR_MANAGED);
		}

        //根据描述文件创建对象，但暂时不推入属性。这里和potato.factory.ComponentFactory#creatComponent()代码基本相同
        var tempCPA:ComponentProfileWithAlias = SingleXML2Profile(xml, propMap);
        _profile = tempCPA.profile;
        _alias = tempCPA.alias;

        //创建组件
        with (classMap[_profile.classNickName] as CopmonentClassProfile)
        {

            if(constractorProxy)
            {
                _component = constractorProxy.constructor(compClass, _profile.packedProps);
                if(_component is IPackedProp)
                {
                    throw new MyError(10105, compClass, constractorProxy);//代理构造器与打包属性接口冲突报错
                }
            }
            else
            {
                _component = new compClass;
            }
        }

        var compIFactoryHandle:IFactoryHandle = _component as IFactoryHandle;
        var compIContainer:IContainer = _component as IContainer;
        var compIInitialize:IInitialize = _component as IInitialize;
        var compICreationComplete:ICreationComplete = _component as ICreationComplete;
        var compIManagedProp:IManagedProp = _component as IManagedProp;
        var compIPackedProp:IPackedProp = _component as IPackedProp;
        var compISelfXMLOverride:ISelfXMLOverride = _component as ISelfXMLOverride;

        //准备子对象数组。一旦推入工厂句柄，就意味着子对象可能开始生成了
        if(xml.children().length())
        {
            /**子组件XML*/
            _subStructs = new Vector.<CompileStruct>;
            for each(var iXml:XML in xml.children())
            {
                var tempStruct:CompileStruct = new CompileStruct();
                tempStruct.xml = iXml;
                var propMapWithReserved:Object = new Object;
                makePropMap(propMapWithReserved, reservedWord, PropertyProfile.PROCESSOR_RESERVED);
                tempStruct.alias = SingleXML2Profile(iXml, propMapWithReserved).alias;//只需要获取组件别名即可。
                _subStructs.push(tempStruct);
            }
        }



        //调用工厂句柄接口
        if(compIFactoryHandle)
        {
            compIFactoryHandle.setFactoryHandle(this);
        }

        //如果组件实现了打包属性接口则更新组件描述文件并推入打包属性
        if(compIPackedProp)
        {
            makePropMap(propMap, compIPackedProp.packedPropList, PropertyProfile.PROCESSOR_PACKED);
            //            tempProfileWithAlias = SingleXML2Profile(xml, propMap);
            //            _profile = tempProfileWithAlias.profile;
            _profile = SingleXML2Profile(xml, propMap).profile;
            compIPackedProp.packedPropProcessor(_profile.packedProps);
        }
		
        //推入直接赋值属性
		var directProps:Object = _profile.directProps;
		var directPropsV:Vector.<String> = new Vector.<String>;
        for(var prop:String in directProps)
        {
            _component[prop] = directProps[prop];
			directPropsV.push(prop);
        }
		makePropMap(propMap, directPropsV, PropertyProfile.PROCESSOR_DIRECT);
		_profile = SingleXML2Profile(xml, propMap).profile;

        //调用初始化接口
        if(compIInitialize)
        {
            compIInitialize.initialize();
        }

        //如果处于编译模式，调用自我XML覆写接口
        if(ComponentFactoryUtils.MODE_RELEASE == ComponentFactoryUtils.MODE && compISelfXMLOverride)
        {
            var xmlListEnabled:Boolean = _parent && !_profile.isRoot && !_alias && !_profile.ID;
            var newXml:* = compISelfXMLOverride.selfXMLOverride(xml.copy(), xmlListEnabled);

            if(newXml is XML)
            {
                _overrideCounter ++;
                if(MAX_TIMES_SELF_XML_OVERRIDE < _overrideCounter)
                {
                    throw new MyError(10109, newXml.toXMLString());//自我XML覆写的循环次数超过允许的最大动作次数
                }

                tempCPA = SingleXML2Profile(newXml as XML, propMapWithReserved);
                if(tempCPA.alias != _alias || tempCPA.profile.ID != _profile.ID)
                {
                    throw new MyError(10113, newXml.toXMLString());//自我XML覆写的返回值缺失了ID或别名。
                }


                var ret:CompileResult = (new DesignerComponentFactory()).compile(newXml as XML, parentFactory);
                _overrideCounter = 0;
                return ret;
            }
            else if(newXml is XMLList)
            {
                if(!xmlListEnabled)
                {
                    throw new MyError(10110, newXml);//自我XML覆写的返回值是XMLList，但其是根对象或顶级对象，或具有ID、别名。
                }
                return new CompileResult(null, null, null, null, newXml);
            }
            else if(newXml)
            {
                throw new MyError(10111, newXml);//自我XML覆写的返回值应为XML或者XMLList
            }
        }

        //处理子对象
        if(_subStructs)
        {
            if(!compIContainer)
            {
                throw new MyError(10108);//组件不是一个容器，但其XML描述指定了子组件。这有可能是自我XML覆写时产生的错误。
            }

            //创建子对象
            for(var i:int = 0; i < _subStructs.length; i++)
            {
                if(!_subStructs[i].profile)
                {
                    var result:CompileResult = (new DesignerComponentFactory()).compile(_subStructs[i].xml, this);

                    if(result.newXmlList)
                    {
                        _subStructs.splice(i, 1);
                        for each(iXml in result.newXmlList)
                        {
                            tempStruct = new CompileStruct();
                            tempStruct.xml = iXml;
                            tempStruct.alias = SingleXML2Profile(iXml, propMapWithReserved).alias;//只需要获取组件别名即可。
                            _subStructs.splice.apply(this, [i, 0].concat(tempStruct));
                        }
                        --i;
                    }
                    else
                    {
                        _subStructs[i].alias = result.alias;
                        _subStructs[i].component = result.component;
                        compIContainer.addSubObj(result.component);
                        _subStructs[i].profile = result.profile;
                        _subStructs[i].compileResult = result;

                    }
                }

            }

            //推入托管属性。创建完全部子对象才推入托管属性，可能对某些布局容器有利。
            if(compIManagedProp)
            {
                for(i = 0; i < _subStructs.length; i++)
                {
                    compIManagedProp.managedPropProcessor(_subStructs[i].component, _subStructs[i].profile.managedProps);
                }
            }
        }

        //调用创建完毕接口
        if(compICreationComplete)
        {
            (compICreationComplete).creationComplete();
        }

        var subCompileResult:Vector.<CompileResult> = new Vector.<CompileResult>;
		_profile.subProfile = new Vector.<ComponentProfile>;
        for each(var iStructs:CompileStruct in _subStructs)
        {
            subCompileResult.push(iStructs.compileResult);
			_profile.subProfile.push(iStructs.profile);;
        }

        return new CompileResult(_profile, _alias, _component, subCompileResult, null);
    }


    /**
     * 融合XML
     * <br>如果一个子组件已经使用XML存储了其结构描述,则进行XML融合.
     * <br>允许在组件的结构中使用另一个已经用XML描述过的组件.该子组件在编译时无法使用自我XML覆写,
     * @param componentXML 子组件的XML描述
     * @param profileXML 该组件的内部结构
     * @return 融合完毕的内部结构
     *
     */
    public static function merge():XML
    {
        return null;
    }

    /**
     * 写入属性配置文件映射表
     * @param propMap 属性配置文件映射表，将追加属性到此表中
     * @param propList 属性列表，可以是关键字表、托管属性表、打包属性表。
     * @param processor 属性的处理器
     *
     */
    public static function makePropMap(propMap:Object, propList:Vector.<String>, processor:int):void
    {
        if(PropertyProfile.PROCESSOR_RESERVED != processor
                && PropertyProfile.PROCESSOR_MANAGED != processor
                && PropertyProfile.PROCESSOR_PACKED != processor
                && PropertyProfile.PROCESSOR_DIRECT != processor)
        {

            throw new MyError(10002, processor);
        }

        for each(var i:String in propList)
        {
            var profile:PropertyProfile = propMap[i];
            if(profile)//如果已经有指定名称的属性，则根据其处理器进行冲突判断
            {
                if(profile.processor == processor)
                {
                    continue;
                }

                switch(profile.processor)
                {
                    case PropertyProfile.PROCESSOR_DIRECT: //直接赋值属性会被其他类型的属性覆盖
                        profile.processor = processor;
                        continue;
                        break;

                    case PropertyProfile.PROCESSOR_MANAGED: //托管属性的优先级高于打包属性，低于保留字
                        if(PropertyProfile.PROCESSOR_RESERVED == processor)
                        {
                            throw new MyError(10104, profile.processor, i);//级别为%0的处理器尝试覆盖保留字%1
                        }
                        if(PropertyProfile.PROCESSOR_PACKED == processor)
                        {
                            Logger.log(20001, i);//属性"%0"被同时声明为托管属性和打包属性。由于托管属性优先于打包属性，该对象的打包属性表中不会出现属性"%0"。
                        }
                        continue;
                        break;

                    case PropertyProfile.PROCESSOR_PACKED: //打包属性仅高于直接赋值属性
                        if(PropertyProfile.PROCESSOR_RESERVED == processor)
                        {
                            throw new MyError(10104, profile.processor, i);//级别为%0的处理器尝试覆盖保留字%1
                        }
                        if(PropertyProfile.PROCESSOR_MANAGED == processor)
                        {
                            Logger.log(20001, i);//属性"%0"被同时声明为托管属性和打包属性。由于托管属性优先于打包属性，该对象的打包属性表中不会出现属性"%0"。
                            profile.processor = PropertyProfile.PROCESSOR_PACKED;
                        }
                        continue;
                        break;

                    case PropertyProfile.PROCESSOR_RESERVED: //托管属性覆盖打包属性
                        throw new MyError(10104, processor, i);//级别为%0的处理器尝试覆盖保留字%1
                        break;

                    default:
                        throw new MyError(10002, processor);
                }
            }

            profile = new PropertyProfile(i);
            profile.processor = processor;
            propMap[i] = profile;
        }
    }


    /**
     * 转换XML到组件描述文件。忽略XML的任何子级。转换时不进行编译
     * @param xml 源XML
     * @param propMap 属性描述文件映射表
     * @return 组件描述文件与当前组件别名
     *
     */
    public static function SingleXML2Profile(xml:XML, propMap:Object):ComponentProfileWithAlias
    {
        var ret:ComponentProfileWithAlias = new ComponentProfileWithAlias;
        var profile:ComponentProfile = new ComponentProfile;
        ret.profile = profile;

        var nickName:String = xml.name();
        var classProfile:CopmonentClassProfile = classMap[nickName];
        if(!classProfile)
        {
            throw new MyError(10001, nickName);//该昵称未被注册到一个实体类
        }

        profile.classNickName = nickName;

        profile.ID = xml.@[RESERVED_WORD_ID];

        profile.isRoot = xml.@[RESERVED_WORD_IS_ROOT];

        var propertyList:XMLList = xml.attributes();
        for each(var i:XML in propertyList)
        {
            var property:String = i.name();
            var value:String = xml.attribute(property);
            var propProfile:PropertyProfile = propMap[property];

            //该属性没有对应的属性描述文件，视为直接赋值属性
            if(!propProfile)
            {
                profile.directProps[property] = typeConversion(value, PropertyProfile.TYPE_DEFULT);
                continue;
            }

            switch(propProfile.processor)
            {
                //直接赋值属性
                case PropertyProfile.PROCESSOR_DIRECT:
                    profile.directProps[property] = typeConversion(value, propProfile.type);
                    break;

                //托管属性
                case PropertyProfile.PROCESSOR_MANAGED:
                    profile.managedProps[property] = typeConversion(value, propProfile.type);
                    break;

                //打包属性
                case PropertyProfile.PROCESSOR_PACKED:
                    profile.packedProps[property] = typeConversion(value, propProfile.type);
                    break;

                //设计器保留字
                case PropertyProfile.PROCESSOR_RESERVED:
                    if(RESERVED_WORD_ID == property)
                    {
                        profile.ID = value;
                    }
                    else if(RESERVED_WORD_IS_ROOT == property)
                    {
                        profile.isRoot = Boolean(value);
                    }
                    else if(RESERVED_WORD_ALIAS == property)
                    {
                        //父对象的subAliasTable需要此属性
                        ret.alias = value;
                    }
                    break;

                default:
                    throw new MyError(10002, propProfile.processor);//属性描述文件的处理器非法
            }
        }

        return ret;
    }

    /**
     * 将String原始值转换为指定类型。
     * @param value 原始值
     * @param type 类型
     * @return 转换为指定类型的值
     *
     */
    protected static function typeConversion(value:String, type:int):*
    {
        switch(type)
        {
            //字符串类型
            case PropertyProfile.TYPE_STRING:
                return value;
                break;

            //默认类型，推测
            case PropertyProfile.TYPE_DEFULT:
                if(null == value)
                {
                    return null;
                }

                if("true" == value)
                {
                    return true;
                }

                if("false" == value)
                {
                    return false;
                }

                var tempNum:Number = Number(value);
                if(!isNaN(tempNum))
                {
                    if(int(tempNum) == tempNum)
                    {
                        return int(tempNum);
                    }else
                    {
                        return tempNum;
                    }
                }

                return value;
                break;

            case PropertyProfile.TYPE_INT:
                return int(value);
                break;

            case PropertyProfile.TYPE_NUMBER:
                return Number(value);
                break;

            case PropertyProfile.TYPE_BOOLEAN:
                return Boolean(value);
                break;

            //字符串数组。默认以","为分隔符，用户也可以指定"|"为分隔符，方法是将"|"作为字符串的第一个字符
            case PropertyProfile.TYPE_ARRAY:
                if(null == value)
                {
                    return null;
                }

                if("|" == value.charAt(0))
                    return value.slice(1).split("|");
                return value.split(",");
                break;

            default:
                throw new MyError(10003, type);//属性描述文件的属性类型非法
        }
    }

    /**
     * 注册组件类。
     * @param nickName 类昵称
     * @param compClass 类对象
     * @param proxy 代理构造器实例
     *
     */
    public static function registerComponentClass(nickName:String, className:String, proxy:IProxyConstructor = null):void
    {
        classMap[nickName] = new CopmonentClassProfile;
        classMap[nickName].compClass = getDefinitionByName(className) as Class;
        classMap[nickName].constractorProxy = proxy;
    }

    ////////////////以下是组件用到的方法///////////////////



    /**
     * 立即请求当前对象的一个子对象，该子对象必须指定了别名
     * <br>该子对象将于creationComplete后返回
     * @param __alias 子对象的别名
     * @return 创建完成的子对象。如果指定了一个不存在的别名，将返回null。
     */
    public function immediatelyGetSub(__alias:String):*
    {
        for each(var i:CompileStruct in _subStructs)
        {
            if(i.alias == __alias)
            {
                //创建子节点并返回
                var result:CompileResult = (new DesignerComponentFactory()).compile(i.xml, this);
                i.component = result.component;
                (_component as IContainer).addSubObj(result.component);
                i.profile = result.profile;
                i.compileResult = result;

                return result.component;
            }
        }

        return null;
    }

    /**
     * 请求当前对象的父容器。
     * @return 父容器。如果当前对象是组件工厂创建树的根，则返回null。
     */
    public function getParent():IContainer
    {
        return _parent;
    }

    /**
     * 获取组件属性。
     * <br>通常用于组件尚未推入属性，但被询问打包属性接口的情况。
     * <br>将以如下顺序查找属性：直接赋值属性-打包属性-托管属性。
     * @param prop 属性名。注意编译器保留字无法通过此方式查询。
     */
    public function getProp(prop:String):*
    {
        return _profile.directProps[prop] || _profile.packedProps[prop] || _profile.managedProps[prop];
    }




    /**绝不会运行的方法.仅用于引入类以便编译时使用getDefinitionByName获取对应类*/
    private function importClass():void
    {
        ImageProxyConstructor;
    }

}
}


import potato.designer.CompileResult;
import potato.factory.ComponentProfile;

/**用于将组件描述文件和别名同时返回…… */
class ComponentProfileWithAlias
{
    /**组件别名，仅用于父组件临时标记其子组件*/
    public var alias:String;
    /**组件描述文件*/
    public var profile:ComponentProfile;

    public function ComponentProfileWithAlias(profile:ComponentProfile = null, alias:String = null)
    {
        this.profile = profile;
        this.alias = alias;
    }
}

/**
 * 编译用结构体。打包了组件XML、组件描述文件、组件本身、组件别名
 * */
class CompileStruct
{
    public var xml:XML;
    public var profile:ComponentProfile;
    public var alias:String;
    public var component:*;
    public var compileResult:CompileResult;
}