package potato.designer.classdescribe
{
	/**
	 * 方法描述
	 * @author Just4test
	 * 
	 */
	public class MethodProfile implements IMemberProfile
	{
		protected var _xml:XML;
		protected var _name:String;
		protected var _availability:Boolean;
		/**可用的参数个数。此值只有在方法可用时才有效*/
		protected var _availableLength:int;
		protected var _paras:Vector.<ParameterProfile>;
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
			_availability = true;
			_paras = new Vector.<ParameterProfile>;
			_availableLength = 0;
			for each(var paraXml:XML in xml.elements("parameter"))
			{
				var parameter:ParameterProfile = new ParameterProfile(paraXml);
				if(!parameter.typeCode)//不受支持的参数
				{
					if(parameter.optional)//此参数可选
					{
						break;
					}
					_availability = false;
					return;
				}
				_paras[parameter.index - 1] = parameter;
				_availableLength ++;
			}
			trace(this);
		}
		
		public function get visible():Boolean
		{
			return true;
		}
		
		public function set visible(value:Boolean):void
		{
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
			return _availability;
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
				tempStr = tempStr ? tempStr + ", " + p.type : p.type;
			}
//			var trmpArr:Array = getShortClassName(_xml.@returnType.toString()).split("::");
			
			return _name + "(" + (tempStr || "") + "):" + Const.getShortClassName(_xml.@returnType);
		}
	}
}