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
	public class Suggest
	{
		public static const METADATA_TAG:String = "Suggest";
		
		
		/**建议属性/方法映射表*/
		protected static var _suggestMap:Object;
		
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
			}
			catch(error:Error) 
			{
				log("[Suggest] 读取Suggest文件" + filePath + "时出错。\n" + error);
				return;
			}
			
			if(!isAppend || !_suggestMap)
			{
				_suggestMap = {};
			}
			
			for(var className:String in obj) 
			{
				try
				{
					var classObj:Object = obj[className];
					
					var sc:SuggestClass = new SuggestClass;
					sc.name = className;
					
					for(var memberName:String in classObj) 
					{
						var memberObj:Object = classObj[memberName];
						var memberArray:Array = memberObj as Array;
						
						var sm:SuggestMember = new SuggestMember;
						sm.name = memberName;
						sc.memberMap[memberName] = sm;
						
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
							sm.parameters.push(sp);
							sp.type = memberObj.type;
							sp.value = memberObj.value;
						}
					}
					
					_suggestMap[className] = sc;
				} 
				catch(error:Error) 
				{
					log("[Suggest] 解析Suggest文件中的类[" + className + "]时出错。\n" + error);
					continue;
				}
			}
		}
		
		/**
		 *从根据元数据创建建议值。
		 * @param xml 类的xml描述
		 * @return 类的建议值，包含所有父类和接口的建议。
		 * 
		 */
		protected static function parseMetadata(xml:XML):SuggestClass
		{	
			var ret:SuggestClass = new SuggestClass;
			
			for each(var metaXml:XML in xml.factory[0]..metadata.(METADATA_TAG == @name))
			{
				var memberXml:XML = metaXml.parent();
				
				var types:Array = [];
				var values:Array = [];
				var current:uint;
				const IS_TYPE:uint = 1;
				const IS_VALUE:uint = 2;
				for each(var iXml:XML in metaXml.arg)
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
			//由[Suggest]元数据标签指定的建议值
			var suggest:SuggestClass = parseMetadata(classProfile.xml);
			
			//填充由suggest文件指定的建议值
			_suggestMap ||= {};
			for each(var i:String in classProfile.isList)
			{
				var suggestInFile:SuggestClass = _suggestMap[i];
				if(suggestInFile)
				{
					for each(var sm:SuggestMember in suggestInFile.memberMap)
					{
						suggest.memberMap[sm.name] ||= sm;
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
					log("[Suggest] 为成员[" + member.name + "]指定的参数数量比需要的多。");
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
					log("[Suggest] 为成员[" + member.name + "]指定的参数数量比需要的多。");
					return false;
				}
				if(length > 0 && length < (member as MethodProfile).numParameterMin)
				{
					log("[Suggest] 为成员[" + member.name + "]指定的参数数量比需要的少。");
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
	}
}

/**类建议值数据结构*/
class SuggestClass
{
	public var name:String;
	public var memberMap:Object;
	
	public function SuggestClass()
	{
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