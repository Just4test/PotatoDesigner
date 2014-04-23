/**
 * Created by just4test on 13-12-16.
 */
package potato.designer.plugin.uidesigner.classdescribe{

public class tempMail
{

    public const xml:XML =
            <type name="core.display::Image" base="core.display::DisplayObject" isDynamic="false" isFinal="false" isStatic="false">
                <extendsClass type="core.display::DisplayObject"/>
                <extendsClass type="core.events::EventDispatcher"/>
                <extendsClass type="Object"/>
                <constructor>
                    <parameter index="1" type="core.display::Texture" optional="false"/>
                </constructor>
                <accessor name="texture" access="readwrite" type="core.display::Texture" declaredBy="core.display::Image"/>
                <accessor name="parent" access="readonly" type="core.display::DisplayObjectContainer" declaredBy="core.display::DisplayObject"/>
                <accessor name="visible" access="readwrite" type="Boolean" declaredBy="core.display::DisplayObject"/>
                <accessor name="pivotX" access="readwrite" type="Number" declaredBy="core.display::DisplayObject"/>
                <accessor name="width" access="readonly" type="Number" declaredBy="core.display::DisplayObject"/>
                <accessor name="pivotY" access="readwrite" type="Number" declaredBy="core.display::DisplayObject"/>
                <accessor name="height" access="readonly" type="Number" declaredBy="core.display::DisplayObject"/>
                <accessor name="scaleX" access="readwrite" type="Number" declaredBy="core.display::DisplayObject"/>
                <accessor name="root" access="readonly" type="core.display::DisplayObject" declaredBy="core.display::DisplayObject"/>
                <accessor name="scaleY" access="readwrite" type="Number" declaredBy="core.display::DisplayObject"/>
                <accessor name="stage" access="readonly" type="core.display::Stage" declaredBy="core.display::DisplayObject"/>
                <accessor name="rotation" access="readwrite" type="Number" declaredBy="core.display::DisplayObject"/>
                <accessor name="mouseEnabled" access="readwrite" type="Boolean" declaredBy="core.display::DisplayObject"/>
                <accessor name="alpha" access="readwrite" type="Number" declaredBy="core.display::DisplayObject"/>
                <accessor name="x" access="readwrite" type="Number" declaredBy="core.display::DisplayObject"/>
                <accessor name="exactHitTest" access="readwrite" type="Boolean" declaredBy="core.display::DisplayObject"/>
                <accessor name="filter" access="readwrite" type="core.filters::Filter" declaredBy="core.display::DisplayObject"/>
                <accessor name="y" access="readwrite" type="Number" declaredBy="core.display::DisplayObject"/>
                <method name="removeEventListeners" declaredBy="core.events::EventDispatcher" returnType="void">
                    <parameter index="1" type="String" optional="true"/>
                </method>
                <method name="addEventListener" declaredBy="core.events::EventDispatcher" returnType="void">
                    <parameter index="1" type="String" optional="false"/>
                    <parameter index="2" type="Function" optional="false"/>
                </method>
                <method name="removeEventListener" declaredBy="core.events::EventDispatcher" returnType="void">
                    <parameter index="1" type="String" optional="false"/>
                    <parameter index="2" type="Function" optional="false"/>
                </method>
                <method name="dispose" declaredBy="core.events::EventDispatcher" returnType="void"/>
                <method name="dispatchEvent" declaredBy="core.events::EventDispatcher" returnType="Boolean">
                    <parameter index="1" type="core.events::Event" optional="false"/>
                </method>
                <method name="hasEventListener" declaredBy="core.events::EventDispatcher" returnType="Boolean">
                    <parameter index="1" type="String" optional="false"/>
                </method>
                <method name="getPixel" declaredBy="core.display::DisplayObject" returnType="uint">
                    <parameter index="1" type="int" optional="false"/>
                    <parameter index="2" type="int" optional="false"/>
                </method>
                <method name="globalToLocal" declaredBy="core.display::DisplayObject" returnType="flash.geom::Point">
                    <parameter index="1" type="flash.geom::Point" optional="false"/>
                </method>
                <method name="localToGlobal" declaredBy="core.display::DisplayObject" returnType="flash.geom::Point">
                    <parameter index="1" type="flash.geom::Point" optional="false"/>
                </method>
                <method name="getBounds" declaredBy="core.display::DisplayObject" returnType="flash.geom::Rectangle">
                    <parameter index="1" type="core.display::DisplayObject" optional="false"/>
                </method>
            </type>
}
}
