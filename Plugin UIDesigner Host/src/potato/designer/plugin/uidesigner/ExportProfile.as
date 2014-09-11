package potato.designer.plugin.uidesigner
{
	/**
	 *导出配置文件
	 * @author Just4test
	 * 
	 */
	public class ExportProfile
	{
		protected var _fileName:String;
		
		protected var _environmentVar:Object = {}
		
		protected var _result:Object = {};
		
		
		public function get fileName():String
		{
			return _fileName;
		}

		/**
		 *导出的文件名。在确定导出目标阶段可写 
		 * @param value
		 * 
		 */
		public function set fileName(value:String):void
		{
			_fileName = value;
		}

		public function get environmentVar():Object
		{
			return _environmentVar;
		}

		/**
		 *导出的环境变量。在确定导出目标阶段可写
		 * @param value
		 */
		public function set environmentVar(value:Object):void
		{
			_environmentVar = value;
		}

		/**
		 * 导出结果，在导出目标阶段可写
		 */
		public function get result():Object
		{
			return _result;
		}

		/**
		 * @private
		 */
		public function set result(value:Object):void
		{
			_result = value;
		}


	}
}