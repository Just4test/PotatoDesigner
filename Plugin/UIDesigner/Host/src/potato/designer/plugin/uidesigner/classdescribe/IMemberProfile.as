/**
 * Created by just4test on 13-12-16.
 */
package potato.designer.plugin.uidesigner.classdescribe
{
    public interface IMemberProfile
	{
        function initByXML(xml:XML):void;
		
		/**指定该属性在设计器中是否可见*/
		function get enable():Boolean;
		function set enable(value:Boolean):void;
		
        function get name():String;
		
		/**
		 *可用性
		 * <br>对于属性来说，这取决于属性类型是否支持。支持返回true。
		 * <br>对于存取器来说，这取决于类型是否支持，以及是否可写。支持且可写返回true。
		 * <br>对于方法来说，这取决于该方法的所有必选参数是否支持。支持所有可选参数返回true。
		 * @return 
		 * 
		 */
		function get availability():Boolean;
    }
}
