package potato.designer.plugin.uidesigner.basic.compiler.classdescribe
{
	import potato.designer.plugin.uidesigner.DesignerConst;

	/**
	 * 方法描述
	 * @author Just4test
	 * 
	 */
	public class MethodProfile implements IMemberProfile
	{
		protected var _xml:XML;
		protected var _name:String;
		protected var _enable:Boolean;
		/**可用的参数个数。此值只有在方法可用时才有效*/
		protected var _availableLength:int;
		protected var _paras:Vector.<ParameterProfile>;
		
//		protected var _suggest:*;
		protected var _numParameterMin:uint;

//		public function get suggest():*
//		{
//			return _suggest;
//		}
//		
//		public function set suggest(value:*):void
//		{
//			_suggest = value;
//		}
		
		
		/**参数的总个数*/
		public function get numParameter():uint
		{
			return _paras.length;
		}
		
		
		/**必须的参数个数*/
		public function get numParameterMin():uint
		{
			return _numParameterMin;
		}

		
		public function MethodProfile(xml:XML)
		{
			initByXML(xml);
		}
		
		public function initByXML(xml:XML):void
		{
			_xml = xml;
//			xml = <method name="removeEventListeners" declaredBy="core.events::EventDispatcher" returnType="void">
//                    <parameter index="1" type="String" optional="true"/>
//				</method>;
			if("method" == xml.name())
			{
				_name = xml.@name;
			}
			else//构造XML是constructor
			{
				_name = "构造方法";
			}
			
			//检查并填充参数。
			_paras = new Vector.<ParameterProfile>;
			_availableLength = 0;
			_numParameterMin = 0;
			for each(var paraXml:XML in xml.elements("parameter"))
			{
				var parameter:ParameterProfile = new ParameterProfile(paraXml);
				_paras.push(parameter);
				_availableLength ++;
				_numParameterMin += parameter.optional ? 0 : 1;
			}
		}
		
		public function get enable():Boolean
		{
			return _enable;
		}
		
		public function set enable(value:Boolean):void
		{
			_enable = value;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get typeCode():int
		{
			return 0;
		}
		
		public function get availability():Boolean
		{
			for(var i:int = 0; i < _numParameterMin; i++)
			{
				if(null == _paras[i].type)
				{
					return false;
				}
			}
			return true;
		}
		
		/**
		 *返回参数表的副本。
		 * 参数表仅包含支持的参数 
		 * @return 
		 * 
		 */
		public function get parameters():Vector.<ParameterProfile>
		{
			return _paras.concat();
		}
		
		public function toString():String
		{
			var tempStr:String;
			for each(var p:ParameterProfile in _paras)
			{
				tempStr = tempStr ? tempStr + ", " + DesignerConst.getShortClassName(p.className) : DesignerConst.getShortClassName(p.className);
			}
//			var trmpArr:Array = getShortClassName(_xml.@returnType.toString()).split("::");
			
			return _name + "(" + (tempStr || "") + "):" + DesignerConst.getShortClassName(_xml.@returnType);
		}
		
		
		
		public function get hasDefaultValue():Boolean
		{
			for(var i:int = 0; i < _numParameterMin; i++)
			{
				if(!_paras[i].hasDefaultValue)
				{
					return false;
				}
			}
			return true;
		}
		
		public function get defaultValue():Vector.<String>
		{
			var ret:Vector.<String> = new Vector.<String>;
			for(var i:int = 0; i < _paras.length; i++)
			{
				if(!_paras[i].hasDefaultValue)
				{
					return ret;
				}
				ret.push(_paras[i].defaultValue);
			}
			return ret;
		}
		
		public function set defaultValue(value:Vector.<String>):void
		{
			for(var i:int = 0; i < value.length; i++)
			{
				_paras[i].defaultValue = value[i];
			}
		}
	}
}