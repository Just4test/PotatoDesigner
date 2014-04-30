package potato.designer.plugin.uidesigner.classdescribe
{
	import potato.designer.plugin.uidesigner.TypeProfile;
	import potato.designer.plugin.uidesigner.TypeTransform;

	/**
	 *建议值配置文件
	 * @author Just4test
	 * 
	 */
	public class SuggestProfile
	{
		public static const METADATA_TAG:String = "Suggest";
		
		
		protected var parameters:Vector.<SuggestParameterProfile>;
		
		/**如果指向属性/存取器，用该值获得属性的类型。*/
		public function get type():String
		{
			return parameters[0].type;
		}
		
		/**如果指向属性/存取器，用该值获得属性的默认值。*/
		public function get value():String
		{
			return parameters[0].value;
		}
		
		
		
		
		/**
		 *根据[Suggest]元数据标签创建建议配置文件 
		 * @param member 要创建建议的成员对象
		 * @param xml 包含元数据标签的xml
		 * @return 如果元数据与成员对象格式匹配，返回建议配置文件。否则返回null
		 */
		public static function makeSuggestByXml(member:IMemberProfile, xml:XML):SuggestProfile
		{
			var xmlList:XMLList = xml.metadata.(METADATA_TAG == @name);
			if(1 != xmlList.length())
			{
				return null;
			}
			xml = xmlList[0];
			
			var types:Array = [];
			var values:Array = [];
			var current:uint;
			const IS_TYPE:uint = 1;
			const IS_VALUE:uint = 2;
			for each(var iXml:XML in xml.arg)
			{
				var k:String = iXml.@key.toString();
				var v:String = iXml.@value.toString();
				switch(k)
				{
					case "type":
					{
						current = IS_TYPE
						break;
					}
					case "value":
					{
						current = IS_VALUE
						break;
					}
				}
				
				switch(current)
				{
					case IS_TYPE:
					{
						types.push(v);
						break;
					}
					case IS_VALUE:
					{
						values.push(v);
						break;
					}
						
					default:
					{
						log("[SuggestProfile] 无法理解的元数据\n", xml);
						return null;
					}
				}
			}
			
			var parameters:Vector.<SuggestParameterProfile> = new Vector.<SuggestParameterProfile>;
			
			if(member is AccessorProfile)
			{
				if(types.length > 1 || values.length > 1)
				{
					log("[SuggestProfile] 指定的类型数或默认值数比需要的多。");
					return null;
				}
				var para:SuggestParameterProfile = getParameter(0, (member as AccessorProfile).className);
				if(!para)
				{
					log("[SuggestProfile] 无法将[" + (member as AccessorProfile).className + "]转换为类型");
					return null;
				}
				parameters.push(para);
			}
			else if(member is MethodProfile)
			{
				var memberParameters:Vector.<ParameterProfile> = (member as MethodProfile).parameters
				if(types.length > memberParameters.length || values.length > memberParameters.length)
				{
					log("[SuggestProfile] 指定的类型数或默认值数比需要的多。");
					return null;
				}
				if(types.length)
				{
					for (var i:int = 0; i < types.length; i++) 
					{
						para = getParameter(0, memberParameters[i].className);
						if(!para)
						{
							log("[SuggestProfile] 无法将[" + (member as AccessorProfile).className + "]转换为类型");
							return null;
						}
						parameters.push(para);
					}
				}
			}
			else
			{
				return null;
			}
			
			var ret:SuggestProfile = new SuggestProfile;
			ret.parameters = parameters;
			return ret;
			
			function getParameter(p:int, className:String):SuggestParameterProfile
			{
				var ret:SuggestParameterProfile = new SuggestParameterProfile;
				
				if(types.length >= p)
				{
					ret.type = types[p];
				}
				else
				{
					var typeProfiles:Vector.<TypeProfile> = TypeTransform.getTypesByClass(className);
					if(!typeProfiles)
					{
						return null;
					}
					ret.type = typeProfiles[0].name;
				}
				
				if(values.length >= p)
				{
					ret.value = values[p];
				}
				
				return ret;
			}
		}
		
		/**
		 *根据suggest文件创建建议配置文件 
		 * @param member 要创建建议的成员对象
		 * @param xml suggest文件的对应条目
		 * @return 如果suggest文件描述与成员对象格式匹配，返回建议配置文件。否则返回null
		 */
		public static function makeSuggestByObj(member:IMemberProfile, obj:Object):SuggestProfile
		{
			return null;
		}
	}
}