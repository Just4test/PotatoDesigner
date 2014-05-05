package potato.designer.plugin.uidesigner.classdescribe
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
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
		
		
		/**建议属性/方法映射表*/
		protected static var _suggestMap:Object;
		
		
//		protected var parameters:Vector.<SuggestParameterProfile>;
//		
//		/**如果指向属性/存取器，用该值获得属性的类型。*/
//		public function get type():String
//		{
//			return parameters[0].type;
//		}
//		
//		/**如果指向属性/存取器，用该值获得属性的默认值。*/
//		public function get value():String
//		{
//			return parameters[0].value;
//		}
		
		public static function loadSuggestFile(filePath:String, isAppend:Boolean = false):void
		{
			try
			{
				var file:File = new File(filePath);
				var fileStream:FileStream = new FileStream;
				fileStream.open(file, FileMode.READ);
				var str:String = fileStream.readMultiByte(fileStream.bytesAvailable, File.systemCharset);
				fileStream.close();
				var obj:Object = JSON.parse(str);
			
				if(!isAppend || !_suggestMap)
				{
					_suggestMap = {};
				}
				
				for(var className:String in obj) 
				{
					var classObj:Object = obj[className];
					
					var sc:SuggestClass = new SuggestClass;
					sc.name = className;
					
					for(var memberName:String in classObj) 
					{
						var memberObj:Object = classObj[memberName];
						var memberArray:Array = memberObj as Array;
						
						var sm:SuggestMember = new SuggestMember;
						sc.memberMap[memberName] = sm;
						sc.members.push(sm);
						
						var sp:SuggestParameter;
						if(memberArray)
						{
							for each(var parameterObj:Object in memberArray) 
							{
								sp = new SuggestParameter;
								sm.parameters.push(sp);
								sp.type = parameterObj.type;
								sp.value = parameterObj.value;
							}
							
						}
						else if(memberObj && memberObj.type)
						{
							sp = new SuggestParameter;
							sp.type = memberObj.type;
							sp.value = memberObj.value;
						}
					}
				}
			
			} 
			catch(error:Error) 
			{
				log("[Suggest] 读取Suggest文件" + filePath + "时出错。\n" + error);
				return;
			}
			
		}
		
		/**
		 *从根据元数据创建建议值。
		 * @param xml 类的xml描述
		 * @return 类的建议值，包含所有父类和接口的建议。
		 * 
		 */
		public static function parseMetadata(xml:XML):SuggestClass
		{
			
//			var metadatas:XMLList = xml.factory[0]..metadata.(METADATA_TAG == @name);
			
			var ret:SuggestClass = new SuggestClass;
			
			for each(var metaXml:XML in xml.factory[0]..metadata.(METADATA_TAG == @name))
			{
				var memberXml:XML = metaXml.parent();
				
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
							log("[Suggest] 无法理解的元数据\n", metaXml);
							continue;
						}
					}
				}
				
				if(values.length > types.length)
				{
					log("[Suggest] 指定的value个数比type多\n", metaXml);
					continue;
				}
				
				var sm:SuggestMember = new SuggestMember;
				sm.name = memberXml.@name;
				
				values.length = types.length;
				for (var i:int = 0; i < types.length; i++) 
				{
					var sp:SuggestParameter = new SuggestParameter;
					sp.type = types[i];
					sp.value = values[i];
					
					sm.parameters.push(sp);
				}
				
				ret.memberMap[sm.name] = sm;
			}
			
			return ret;
		}
		
		
		/**
		 *创建并应用建议配置
		 * 从[Suggest]元数据标签和suggest文件读出。
		 * @param classProfile
		 * 
		 */
		public static function applySuggest(classProfile:ClassProfile):void
		{
			_suggestMap ||= {};
			
			//由[Suggest]元数据标签指定的建议值
			var suggest:SuggestClass = parseMetadata(classProfile.xml);
			
			//填充由suggest文件指定的建议值
			for each(var i:String in classProfile.isList)
			{
				var suggestInFile:SuggestClass = _suggestMap[i];
				if(suggestInFile)
				{
					for each(var sm:SuggestMember in suggestInFile)
					{
						suggest[sm.name] ||= sm;
					}
				}
			}
			
			//使用建议值设定classProfile
			for each(sm in suggest.memberMap)
			{
				var member:IMemberProfile = classProfile.getMember(sm.name);
				if(!member)
				{
					log("[Suggest] 指定了[" + sm.name + "]的建议值，但是无法找到对应的成员");
					continue;
				}
				
				applySuggestMember(member, sm);
			}
		}
		
		protected static function applySuggestMember(member:IMemberProfile, suggest:SuggestMember):Boolean
		{
			var length:uint = suggest.parameters.length;
			if(member is AccessorProfile)
			{
				if(length > 1)
				{
					log("[Suggest] 指定的参数数量比需要的多。");
					return false;
				}
				
				member.enable = true;
				if(1 == length)
				{
					(member as AccessorProfile).type = suggest.parameters[0].type;
				}
			}
			else if(member is MethodProfile)
			{
				if(length > (member as MethodProfile).numParameter)
				{
					log("[Suggest] 指定的参数数量比需要的多。");
					return false;
				}
				if(length > 0 && length < (member as MethodProfile).numParameterMin)
				{
					log("[Suggest] 指定的参数数量比需要的少。");
					return false;
				}
				member.enable = true;
				
				var parameters:Vector.<ParameterProfile> = (member as MethodProfile).parameters;
				for (var i:int = 0; i < length; i++) 
				{
					parameters[i].type = suggest.parameters[i].type;
				}
			}
			else
			{
				return false;
			}
			
			return true;
		}
		
		
		
		/**
		 *根据[Suggest]元数据标签创建建议配置文件 
		 * @param member 要创建建议的成员对象
		 * @param xml 包含元数据标签的xml
		 * @return 如果元数据与成员对象格式匹配，返回建议配置文件。否则返回null
		 */
		public static function makeSuggestByXml(member:IMemberProfile, xml:XML):SuggestMember
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
			
			var parameters:Vector.<SuggestParameter> = new Vector.<SuggestParameter>;
			
			if(member is AccessorProfile)
			{
				if(types.length > 1 || values.length > 1)
				{
					log("[SuggestProfile] 指定的类型数或默认值数比需要的多。");
					return null;
				}
				var para:SuggestParameter = getParameter(0, (member as AccessorProfile).className);
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
			
			var ret:SuggestMember = new SuggestMember;
			ret.parameters = parameters;
			return ret;
			
			function getParameter(p:int, className:String):SuggestParameter
			{
				var ret:SuggestParameter = new SuggestParameter;
				
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

class SuggestClass
{
	public var name:String;
	public var members:Vector.<SuggestMember>;
	public var memberMap:Object;
	
	public function SuggestClass()
	{
		members = new Vector.<SuggestMember>;
		memberMap = {};
	}
}

/**成员对象建议值数据结构*/
class SuggestMember
{
	public var name:String;
	public var parameters:Vector.<SuggestParameter>;
	
	public function SuggestMember()
	{
		parameters = new Vector.<SuggestParameter>;
	}
}

/**参数建议值数据结构*/
class SuggestParameter
{
	public var type:String;
	public var value:String;
}