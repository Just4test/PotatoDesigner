/**
 * Created by just4test on 13-12-16.
 */
package potato.designer.plugin.uidesigner.classdescribe{
/**
 *类配置文件
 * <br>通过对应类的描述XML初始化。其中包含了该类的构造方法、实例方法与变量和存取器。
 */
public class ClassProfile {

    protected var _xml:XML;
	protected var _availability:Boolean;
    protected var _className:String;
    protected var _nickName:String;
	/***/
    protected var _properties:Vector.<PropertyProfile>;
    protected var _propMap:Object;
	/**构造方法*/
	protected var _constructor:MethodProfile;
	/**成员变量和存取器数组*/
	protected var _accessors:Vector.<AccessorProfile>;
	/**成员方法数组*/
	protected var _methods:Vector.<MethodProfile>;
	
	protected var _isDisplayObj:Boolean;
	protected var _isDisplayObjContainer:Boolean;

    public function ClassProfile(xml:XML) {
        initByXML(xml);
    }

    public function initByXML(xml:XML):void
    {
		_xml = xml;
        _className = xml.@name;
		
		if(xml.extendsClass.(@type="core.display::DisplayObject").length)
		{
			_isDisplayObj = true;
		}
		
		if(xml.extendsClass.(@type="core.display::DisplayObjectContainer").length)
		{
			_isDisplayObjContainer = true;
		}
		
		_availability = true;
		var constructorXmlList:XMLList = xml.factory.constructor;
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
		
		var mXml:XML;
		var member:IMemberProfile
		_accessors = new Vector.<AccessorProfile>;
		for each(mXml in xml.factory.accessor)
		{
			member = new AccessorProfile(mXml);
			if(member.availability)
			{
				_accessors.push(member);
			}
		}
		for each(mXml in xml.factory.variable)
		{
			member = new AccessorProfile(mXml);
			if(member.availability)
			{
				_accessors.push(member);
			}
		}
		
		_methods = new Vector.<MethodProfile>;
		for each(mXml in xml.factory.method)
		{
			member = new MethodProfile(mXml);
			if(member.availability)
			{
				_methods.push(member);
			}
		}



    }
	
	public function get availability():Boolean
	{
		return _availability;
	}

	/**指示此类是否是显示对象*/
    public function get isDisplayObj():Boolean
    {
        return _isDisplayObj;
    }
	
	/**指示此类是否是显示对象容器*/
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

	public function get isDisplayObjContainer():Boolean
	{
		return _isDisplayObjContainer;
	}


}
}
