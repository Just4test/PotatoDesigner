/**
 * Created by just4test on 13-12-16.
 */
package potato.designer.plugin.uidesigner.classdescribe{

public class PropertyProfile {


 
    protected var _name:String;

    protected var _visible:Boolean;
    protected var _access:int;
    protected var _type:int;

    public function PropertyProfile(xml:XML){
        initByXML(xml);
    }

    public function initByXML(xml:XML):void
    {
        _name = xml.@name;

        switch(xml.name())
        {
            case "accessor":
                _access = Const.ACCESS_MAP[xml.access];
                break;
            case "variable":
                _type = Const.TYPE_MAP[xml.type];
                break;
            case "constructor":

                break;
            case "method":
                break;
            default:
                break;
        }

        if("false" == xml.@visible)
            _visible = false;
        else
            _visible = true;
    }
}
}
