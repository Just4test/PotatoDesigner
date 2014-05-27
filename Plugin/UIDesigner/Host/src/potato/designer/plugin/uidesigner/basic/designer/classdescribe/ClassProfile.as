/**
 * Created by just4test on 13-12-16.
 */
package potato.designer.plugin.uidesigner.basic.designer.classdescribe{
	import flash.filesystem.File;
	
	import potato.designer.plugin.uidesigner.DesignerConst;
	import potato.designer.plugin.uidesigner.basic.constructor.BasicClassProfile;

/**
 *类配置文件
 * <br>通过对应类的描述XML初始化。其中包含了该类的构造方法、实例方法与变量和存取器。
 */
public class ClassProfile {

    protected var _xml:XML;
//	protected var _availability:Boolean;
    protected var _className:String;
//    protected var _nickName:String;
//	protected var _propMap:Object;
	protected var _memberMap:Object;
	/**构造方法*/
	protected var _constructor:MethodProfile;
	/**成员变量和存取器数组*/
	protected var _accessors:Vector.<AccessorProfile>;
	/**成员方法数组*/
	protected var _methods:Vector.<MethodProfile>;
	
	/**实现映射表*/
	protected var _isMap:Object;
	protected var _isList:Vector.<String>;

    public function ClassProfile(xml:XML)
	{
        initByXML(xml);
    }

    public function initByXML(xml:XML):void
    {
		_xml = xml;
        
		if("Class" != _xml.@base)
		{
			throw new Error("这不是一个类对象");
		}
		
		_className = _xml.@name;
		
		var factoryXml:XML = _xml.factory[0];
		
		//填充构造方法
		_memberMap = {};
		var constructorXmlList:XMLList = factoryXml.constructor;
		if(!constructorXmlList.length())
		{
			_constructor = null;
		}
		else
		{
			_constructor = new MethodProfile(constructorXmlList[0]);
			_memberMap[DesignerConst.getShortClassName(_className)] = _constructor;
		}
		
		//填充存取器
		var member:IMemberProfile
		_accessors = new Vector.<AccessorProfile>;
		var iXml:XML;
		for each(iXml in factoryXml.accessor)
		{
			member = new AccessorProfile(iXml);
			_memberMap[member.name] = member;
			_accessors.push(member);
		}
		//填充变量
		for each(iXml in factoryXml.variable)
		{
			member = new AccessorProfile(iXml);
			_memberMap[member.name] = member;
			_accessors.push(member);
		}
		//填充方法
		_methods = new Vector.<MethodProfile>;
		for each(iXml in factoryXml.method)
		{
			member = new MethodProfile(iXml);
			_memberMap[member.name] = member;
			_methods.push(member);
		}
		
		
		
		//填充类型
		_isMap = {};
		_isList = new Vector.<String>;
		addIs(_xml.@name);
		for each (iXml in factoryXml.extendsClass)//优先遍历子类
		{
			addIs(iXml.@type);
		}
		for each (iXml in factoryXml.implementsInterface) 
		{
			addIs(iXml.@type);
		}
		
		function addIs(name:String):void
		{
			_isList.push(name);
			_isMap[name] = true;
			var a:Array = name.split("::");
			if(2 == a.length)
			{
				_isMap[a[0] + "." + a[1]] = true;
			}
		}

		Suggest.applySuggest(this);
    }
	
	public function get availability():Boolean
	{
		return !_constructor || _constructor.availability;
	}
	
	/**
	 *一个列表，其中的每一项都是该类继承的父类类名，或者实现的接口名。
	 * <br/>顺序依次是顶级父类，子级父类，接口。
	 */
	public function get isList():Vector.<String>
	{
		return _isList.concat();
	}

	/**
	 *检测类是否是指定类的子类，或者实现了指定的接口 
	 * @param name 类名或接口名
	 * @return 
	 * 
	 */
	public function testIs(name:String):Boolean
	{
		return _isMap[name];
	}
	
	/**指示此类是否是显示对象*/
	public function get isDisplayObj():Boolean
	{
		return _isMap["core.display::DisplayObject"];
	}
	
	/**指示此类是否是显示对象容器*/
	public function get isDisplayObjContainer():Boolean
	{
		return _isMap["core.display::DisplayObjectContainer"];
	}
	
	public function get constructor():MethodProfile
	{
		return _constructor;
	}

	public function get accessors():Vector.<AccessorProfile>
	{
		return _accessors;
	}

	public function get methods():Vector.<MethodProfile>
	{
		return _methods;
	}

	public function get xml():XML
	{
		return _xml;
	}
	
	public function getMember(name:String):IMemberProfile
	{
		return _memberMap[name];
	}
	
	public function getTypeProfile():BasicClassProfile
	{
		var ret:BasicClassProfile = new BasicClassProfile(_className);
		ret.constructorTypes = getTypes(_constructor);
		
		for each (var i:AccessorProfile in _accessors) 
		{
			if(i.availability)
			{
				ret.setAccessor(i.name, i.type);
			}
		}
		
		for each (var j:MethodProfile in _methods) 
		{
			if(j.availability)
			{
				ret.setMethod(j.name, getTypes(j));
			}
		}
		
		return ret; 
		
		function getTypes(method:MethodProfile):Vector.<String>
		{
			var ret:Vector.<String> = new Vector.<String>;
			if(method)
			{
				for (var i:int = 0; i < method.parameters.length; i++) 
				{
					ret[i] = method.parameters[i].type;
				}
				
			}
			return ret;
		}
	}


}
}
