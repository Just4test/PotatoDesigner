/**
 * Created by just4test on 13-12-16.
 */
package potato.designer.plugin.uidesigner.classdescribe{
	import flash.filesystem.File;

/**
 *类配置文件
 * <br>通过对应类的描述XML初始化。其中包含了该类的构造方法、实例方法与变量和存取器。
 */
public class ClassProfile {

    protected var _xml:XML;
	protected var _availability:Boolean;
    protected var _className:String;
    protected var _nickName:String;
    protected var _propMap:Object;
	/**构造方法*/
	protected var _constructor:MethodProfile;
	/**成员变量和存取器数组*/
	protected var _accessors:Vector.<AccessorProfile>;
	/**成员方法数组*/
	protected var _methods:Vector.<MethodProfile>;
	
	/**实现映射表*/
	protected var _isMap:Object;
	/**建议属性/方法映射表*/
	protected var _suggestMap:Object;
	
	protected static var _suggest:Object = {};

    public function ClassProfile(xml:XML)
	{
        initByXML(xml);
    }
	
	public static function loadSuggest(json:String):void
	{
		try
		{
			_suggest = JSON.parse(json);
		} 
		catch(error:Error) 
		{
			_suggest = {};
		}
		
		var map:Object = {};
		var temp:Object = JSON.parse(json);
		for each (var iObj:Object in temp)//分离单个类的建议
		{
			for each (var jObj:int in iObj)//单个建议
			{
				
			}
			
		}
		
		
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
		
		var suggest:Object;
		try
		{
			var file:File = new File()
		} 
		catch(error:Error) 
		{
			suggest = {};
		}
		
		var iXml:XML;
		
		_availability = true;
		var constructorXmlList:XMLList = factoryXml.constructor;
		if(!constructorXmlList.length())
		{
			//没有定义构造方法。
			_constructor = null;
		}
		else
		{
			_constructor = new MethodProfile(constructorXmlList[0]);
			if(!_constructor.availability)
			{
				_availability = false;
				return;
			}
		}
		
		var member:IMemberProfile
		_accessors = new Vector.<AccessorProfile>;
		for each(iXml in factoryXml.accessor)
		{
			member = new AccessorProfile(iXml);
			if(member.availability)
			{
				_accessors.push(member);
			}
		}
		for each(iXml in factoryXml.variable)
		{
			member = new AccessorProfile(iXml);
			if(member.availability)
			{
				_accessors.push(member);
			}
		}
		
		_methods = new Vector.<MethodProfile>;
		for each(iXml in factoryXml.method)
		{
			member = new MethodProfile(iXml);
			if(member.availability)
			{
				_methods.push(member);
			}
		}
		
		
		
		//检查类型
		_isMap = {};
		addIs(_xml.@name);
		var i:int;
		for each (iXml in factoryXml.extendsClass)//优先遍历子类
		{
			iXml = factoryXml.extendsClass[i];
			addIs(iXml.@type);
		}
		for each (iXml in factoryXml.implementsInterface) 
		{
			addIs(iXml.@type);
		}
		
		function addIs(name:String):void
		{
			_isMap[name] = true;
			var a:Array = name.split("::");
			if(2 == a.length)
			{
				_isMap[a[0] + "." + a[1]] = true;
			}
		}



    }
	
	public function get availability():Boolean
	{
		return _availability;
	}
	
	public function isClass(className:String):Boolean
	{
		return _isMap[className];
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


}
}
