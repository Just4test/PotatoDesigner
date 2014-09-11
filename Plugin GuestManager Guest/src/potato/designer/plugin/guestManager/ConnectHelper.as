package potato.designer.plugin.guestManager
{
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	import core.display.Image;
	import core.display.Quad;
	import core.display.Stage;
	import core.text.TextField;
	
	import potato.designer.framework.DataCenter;
	import potato.designer.framework.DesignerEvent;
	import potato.designer.framework.EventCenter;

	/**
	 * 提供UI以便用户决定要连接到哪个主机。
	 * @author Administrator
	 * 
	 */
	public class ConnectHelper extends DisplayObjectContainer
	{
		protected static const COLOR:uint = 0xFF10F9B7;
		protected static const BG_COLOR:uint = 0xFF2D3036;
		protected static const FONT_SIZE:int = 30;
		protected static const FONT_COLOR:uint = 0xFFFFFFFF;
		
		/**当连接助手关闭时派发*/
		public static const EVENT_CLOSED:String = "CONNECT_HELPER_CLOSED"
		
		protected static var instance:ConnectHelper;
		
		
		protected var input:TextField;
		
		protected var buttons:Vector.<DisplayObject>
		
		protected var closeButton:CloseButton
		
		
		protected var returnIfSuccess:Boolean;
		
		public static function show():void
		{
			instance ||= new ConnectHelper;
			instance.x = (Stage.getStage().width - instance.width) / 2;
			instance.y = (Stage.getStage().height - instance.height) / 2;
			
			Stage.getStage().addChildAt(instance, Stage.getStage().numChildren);
		}
		
		public static function close():void
		{
			instance && instance.closeThis();
		}
		
		public function ConnectHelper()
		{
			//初始化UI
			
			//背景
			var bg:Quad = new Quad(350, 500, BG_COLOR);
			addChild(bg);
			//关闭按钮
			closeButton = new CloseButton(closeThis);
			closeButton.x = width - closeButton.width - 10;
			closeButton.y = 10;
			addChild(closeButton);
			//输入文本图标
			var img:Image = getImg("search.png");
			img.x = 30;
			img.y = 50;
			addChild(img);
			//输入文本
			input = new TextField("XXX.XXX.XXX.XXX", 400, FONT_SIZE + 2, DataCenter.DEFAULT_FONT, FONT_SIZE, COLOR);
			input.x = img.x + img.width + 10;
			input.y = img.y + (img.height - input.textHeight) / 2;
			addChild(input);
			
			//主机发现
			GuestManagerGuest.startHostDiscovery();
			EventCenter.addEventListener(GuestManagerGuest.EVENT_HOST_DISCOVERED, hostDiscoverdHandler);
			
			//成功连接时关闭
			EventCenter.addEventListener(GuestManagerGuest.EVENT_HOST_CONNECTED, closeThis);
			
		}
		
		
		
		protected function closeThis(argu:* = null):void
		{
			GuestManagerGuest.stopHostDiscovery();
			instance = null;
			parent && parent.removeChild(this);			
			EventCenter.dispatchEvent(new DesignerEvent(EVENT_CLOSED, null));
		}
		
		protected function hostDiscoverdHandler(event:DesignerEvent):void
		{
			while(numChildren > 4)
				removeChildAt(4);
			
			var hosts:Vector.<String> = event.data;
			for each(var host:String in hosts)
			{
				var ipBtn:IPButton = new IPButton(host, hostButtonHandler);
				ipBtn.x = 50;
				ipBtn.y = 100;
				addChild(ipBtn);
			}
		}
		
		protected function hostButtonHandler(btn:IPButton):void
		{
			GuestManagerGuest.tryConnect(btn.host);
		}
		
		protected function testIP(text:String):Boolean
		{
			if(!/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/.test(text))
			{
				return false;
			}
			
				
			for each (var s:String in text.split(".")) 
			{
				if(int(s) > 255)
				{
					return false;
				}
			}
			
			return true;
		}
		
		
		
	}
}

import core.display.DisplayObjectContainer;
import core.display.Image;
import core.display.Texture;
import core.display.TextureData;
import core.events.TouchEvent;
import core.filters.ColorMatrixFilter;
import core.text.TextField;

import potato.designer.framework.DataCenter;
import potato.designer.plugin.guestManager.GuestManagerGuest;

function getImg(name:String):Image
{
	return new Image(new Texture(TextureData.createWithFile(GuestManagerGuest.path + "/asset/" + name)));
}

class CloseButton extends DisplayObjectContainer
{
	static const touchFilter:ColorMatrixFilter = new ColorMatrixFilter(Vector.<Number>([
		0,1,0,0,0,
		1,0,0,0,0,
		0,0,1,0,0,
		0,0,0,1,0]));
	
	var img:Image;
	var callBack:Function;
	
	function CloseButton(callBack:Function)
	{
		this.callBack = callBack;
		initUI();
		addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
	}
	
	function initUI():void
	{
		img = getImg("close.png");
		addChild(img);
	}
	
	function touchBeginHandler(event:TouchEvent):void
	{
		img.filter = touchFilter;
		addEventListener(TouchEvent.TOUCH_END, touchEndHandler);
	}
	
	function touchEndHandler(event:TouchEvent):void
	{
		removeEventListener(TouchEvent.TOUCH_END, touchEndHandler);
		img.filter = null;
		callBack(this);
	}
}

class IPButton extends CloseButton
{
	var text:TextField;
	var host:String;
	
	static const COLOR:uint = 0xFF10F9B7;
	static const FONT_SIZE:int = 30;
	
	function IPButton(host:String, callBack:Function):void
	{
		this.host = host;
		super(callBack);
	}
	
	override function initUI():void
	{
		img = getImg("PC.png");
		addChild(img);
		
		text = new TextField(host, 250, FONT_SIZE + 2, DataCenter.DEFAULT_FONT, FONT_SIZE, COLOR);
		text.x = img.width + 10;
		text.y = (img.height - text.textHeight) / 2;
		addChild(text);
	}
	
	
	
	override function touchBeginHandler(event:TouchEvent):void
	{
		text.filter = touchFilter;
		super.touchBeginHandler(event);
	}
	
	override function touchEndHandler(event:TouchEvent):void
	{
		text.filter = null;
		super.touchEndHandler(event);
	}
}