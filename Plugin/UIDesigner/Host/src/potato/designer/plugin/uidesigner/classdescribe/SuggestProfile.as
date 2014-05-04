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
					
					var cp:SuggestClassProfile = new SuggestClassProfile;
					cp.name = className;
					
					for(var memberName:String in classObj) 
					{
						var memberObj:Object = classObj[memberName];
						var memberArray:Array = memberObj as Array;
						
						var mp:SuggestMemberProfile = new SuggestMemberProfile;
						cp.memberMap[memberName] = mp;
						cp.members.push(mp);
						
						var pp:SuggestParameterProfile;
						if(memberArray)
						{
							for each(var parameterObj:Object in memberArray) 
							{
								pp = new SuggestParameterProfile;
								mp.parameters.push(pp);
								pp.type = parameterObj.type;
								pp.value = parameterObj.value;
							}
							
						}
						else if(memberObj && memberObj.type)
						{
							pp = new SuggestParameterProfile;
							pp.type = memberObj.type;
							pp.value = memberObj.value;
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
		public static function parseMetadata(xml:XML):SuggestClassProfile
		{
			
//			var metadatas:XMLList = xml.factory[0]..metadata.(METADATA_TAG == @name);
			
			var ret:SuggestClassProfile = new SuggestClassProfile;
			
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
				
				var mp:SuggestMemberProfile = new SuggestMemberProfile;
				mp.name = memberXml.@name;
				
				values.length = types.length;
				for (var i:int = 0; i < types.length; i++) 
				{
					var pp:SuggestParameterProfile = new SuggestParameterProfile;
					pp.type = types[i];
					pp.value = values[i];
					
					mp.parameters.push(pp);
				}
				
				ret.memberMap[mp.name] = mp;
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
			var suggest:SuggestClassProfile = parseMetadata(classProfile.xml);
			
			//填充由suggest文件指定的建议值
			for each(var i:String in classProfile.isList)
			{
				var tempCp:SuggestClassProfile = _suggestMap[i];
				if(tempCp)
				{
					for each(var mp:SuggestMemberProfile in tempCp)
					{
						suggest[mp.name] ||= mp;
					}
				}
			}
			
			//使用建议值设定classProfile
			
			for each(mp in suggest.memberMap)
			{
				var member:IMemberProfile = classProfile.getMember(mp.name);
				//TODO
			}
		}
		
		
		
		/**
		 *根据[Suggest]元数据标签创建建议配置文件 
		 * @param member 要创建建议的成员对象
		 * @param xml 包含元数据标签的xml
		 * @return 如果元数据与成员对象格式匹配，返回建议配置文件。否则返回null
		 */
		public static function makeSuggestByXml(member:IMemberProfile, xml:XML):SuggestMemberProfile
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
			
			var ret:SuggestMemberProfile = new SuggestMemberProfile;
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

class SuggestClassProfile
{
	public var name:String;
	public var members:Vector.<SuggestMemberProfile>;
	public var memberMap:Object;
	
	public function SuggestClassProfile()
	{
		members = new Vector.<SuggestMemberProfile>;
		memberMap = {};
	}
}

/**成员对象建议值数据结构*/
class SuggestMemberProfile
{
	public var name:String;
	public var parameters:Vector.<SuggestParameterProfile>;
	
	public function SuggestMemberProfile()
	{
		parameters = new Vector.<SuggestParameterProfile>;
	}
}

/**参数建议值数据结构*/
class SuggestParameterProfile
{
	public var type:String;
	public var value:String;
}