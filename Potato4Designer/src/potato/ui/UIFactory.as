package potato.ui
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	import core.display.Image;
	import core.utils.WeakDictionary;
	
	import potato.res.Res;
	
	/**
	 * UIFactory 是为 UI 体系设立的工厂服务类
	 *
	 * 它的主要功能是从一段特写的 XML 代码组装出完整的 UIComponent 族，
	 * 以便于代码后期绑定和使用。
	 */
	public class UIFactory
	{
		/**可通过 XML 配置的 UI 类注册映射**/
		private static var _map:Object = {
			"UIComponent":     UIComponent,
			"Button":           Button,
			"Label":            Label,
			"TextInput":       TextInput,
			"Bitmap":          Bitmap,
			"Grid3":            Grid3,
			"Grid9":            Grid9,
			"ButtonBar":        ButtonBar,
			"Panel":            Panel,
			"Box":              Box,
			'NumRoll':          NumRoll
		};
		
		/**每个XML维护一个字典**/
		public static var roots:Dictionary = new Dictionary();
		/**根**/
		protected static var _root:UIComponent;
		
		/**
		 * XML创建对象接口
		 */
		public static function createUI(xml:XML):DisplayObject
		{
			var cls:String = String(xml.localName());
			var result:DisplayObject = new _map[cls]();
			
			if(result)
			{
				/*var value:*;
				var prop:String;
				for each(value in xml.@*)
				{
				prop = String(value.name());
				switch(prop)
				{
				case "width":
				result["expectWidth"] = value;
				break;
				case "height":
				result["expectHeight"] = value;
				break;
				default:
				result[prop] = value;
				}
				}*/
				settingPropertiesFromXml(xml,  result);
			}
			
			if(result == null || !(result is UIComponent))return result;
			
			_root = UIComponent(result);
			_root.setRoot(true);
			parseXML(xml.children(), _root, _root);
			
			UIFactory.render(_root);
			
			return _root;
		}
		
		/**
		 * 解析XML布局
		 */
		public static function parseXML(list:XMLList, parent:UIComponent, root:UIComponent):void
		{
			var xml:XML;
			for each(xml in list)
			{
				var cls:String = String(xml.localName());
				if (cls != 'Image')
				{
					var class1:Class = _map[cls] as Class;
					var result:DisplayObject = new class1();
					if(result)
					{
						settingPropertiesFromXml(xml, result);
						parent.addElement(result);
						
						if (result is UIComponent)
						{
							UIComponent(result).UIRoot = root;
							
							var __root:UIComponent;
							if (UIComponent(result).isRoot())
							{
								__root = UIComponent(result);
							} else
							{
								__root = root;
							}
							
							parseXML(xml.children(), UIComponent(result), __root);
						}
					}
				}
				else
				{
					var propertyNode:XML;
					const propertyList:XMLList = xml.@*;
					var propertyName:String;
					var propertyValue:*;
					
					var imgX:Number, imgY:Number;
					var imgSrc:String;
					for each (propertyNode in propertyList)
					{
						propertyName = String(propertyNode.name());
						propertyValue = propertyNode;
						
						switch (propertyName)
						{
							case 'x':
								imgX = propertyValue;
								break;
							
							case 'y':
								imgY = propertyValue;
								break;
							
							case 'source':
								imgSrc = propertyValue;
								break;
						}
					}
					
					var img:Image = Res.getImage(imgSrc);
					img.x = imgX;
					img.y = imgY;
					
					parent.addElement(img);
				}
			}
		}
		
		/**
		 * 根据 XML 内的属性为显示对象属性赋值
		 * @param xml               XML 组件列表
		 * @param instance          将被赋值的显示对象实例
		 */
		private static function settingPropertiesFromXml(xml:XML, instance:DisplayObject):void
		{
			var propertyNode:XML;
			const propertyList:XMLList = xml.@*;
			var propertyName:String;
			var propertyValue:*;
			for each(propertyNode in propertyList)
			{
				propertyName = String(propertyNode.name());
				propertyValue = propertyNode;
				if (propertyValue == 'true')
					propertyValue = true;
				else if (propertyValue == 'false')
					propertyValue = false;
				
				switch (propertyName)
				{
					case "width":
						instance["expectWidth"] = propertyValue;
						break;
					case "height":
						instance["expectHeight"] = propertyValue;
						break;
					case 'id':
					case 'x':
					case 'y':
						instance[propertyName] = propertyValue;
						break;
					
					default:
						var propertyStringValue:String = String(propertyValue);
						
						if (propertyStringValue.charAt(0) == '*')
							propertyValue = _root.findViewById(propertyStringValue.substr(1));
						
						instance[propertyName] = propertyValue;
						
						break;
				}
			}
		}
		
		/**
		 * 渲染整个容器的子对象图片
		 */
		public static function render(_container:UIComponent):void
		{
			if(!_container)return;
			_container.render();
			
			var _ch:DisplayObject;
			var _i:int = _container.numChildren;
			while(_container.isContainer && _i > 0)
			{
				_ch = _container.getChildAt(_i - 1);
				if(_ch is UIComponent)
				{
					UIFactory.render(UIComponent(_ch));
				}
				_i--;
			}
		}
		
		/**
		 * 获取类映射
		 */
		public static function getClassMap():Object
		{
			return _map;
		}
		/**
		 * 添加类映射
		 */
		public static function registerClass(key:String, value:Class):void
		{
			_map[key] = value;
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		Grid9Image;Button;
		//弱值引用
		private static var name_obj:WeakDictionary = new WeakDictionary();
		//弱键引用
		private static var obj_name:Dictionary = new Dictionary(true);
		
		public static function create(data:Object, regist:IRegist):DisplayObject
		{
			var display:DisplayObject = createI(data, regist, null);
			regist.createComplete();
			regist.root = display;
			return display;
		}
		
		private static function createI(data:Object, regist:IRegist, parent:DisplayObjectContainer = null):DisplayObject
		{
			var classType:String = data.classType;
			var children:Array = data["children"];
			var listeners:Array = data["listeners"];
			var name:String = data["name"];
			
			delete data["classType"];
			delete data["children"];
			delete data["listeners"];
			delete data["name"];
			
			var obj:DisplayObject;
			if (classType == "Image")
			{
				obj = Res.getImage(data.source);
				delete data["source"];
			}
			else
			{
				var cls:Class = getDefinitionByName(classType) as Class;
				obj = new cls();
			}
			
			if(parent)
				name = obj_name[parent] + "." + name;
			
			obj_name[obj] = name;
			name_obj[name] = obj;
			
			for (var qname:String in data)
			{
				if(obj[qname] is Function)
					obj[qname].apply(null, data[qname]);
				else
					obj[qname] = data[qname];
			}
			
			var length:int;
			if (listeners && (length = listeners.length) > 0)
			{
				for (var j:int = 0; j < length; j+=2) 
				{
					obj.addEventListener(listeners[j], regist[listeners[j+1]]);
				}
			}
			
			if (parent)
				parent.addChild(obj);
			
			var cl:int = children ? children.length : 0;
			for (var i:int = 0; i < cl; i++) 
			{
				createI(children[i], regist, DisplayObjectContainer(obj));
			}
			return obj;
		}
		
		public static function getObject(name:String):*
		{
			return name_obj[name];
		}
		
		public static function getName(obj:DisplayObject):String
		{
			return obj_name[obj];
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
	}
}