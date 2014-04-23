package potato.ui
{
	import core.display.DisplayObject;
	import core.display.Quad;
	import core.media.Sound;
	
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import potato.events.GestureEvent;
	import potato.tweenlite.TweenLite;
	import potato.tweenlite.easeing.Expo;
	
	public class Carousel extends UIComponent
	{
		private var uiComponent:UIComponent;
		private var _width:int;
		private var _height:int;
		private var items:Array;
		
		private var tween:TweenLite;
		private var _r:Number = 0;
		private var samplePotins:Array;
		private var maxSample:int = 4;
		private var upMoveTime:int;
		private var index:int;
		private var upX:int;
		private var _radianSound:Sound;
		private var currentNum:int;

		public function Carousel(width:int,height:int,num:uint = 4)
		{
			_width = width;
			_height = height;
			maxSample = num;
			var q:Quad = new Quad(width*2,height*2,0);
			this.addChild(q);
			
			uiComponent = new UIComponent();
			this.addChild(uiComponent);
			uiComponent.x = width;
			uiComponent.y = height;
			
			items = [];
			
			addEventListener(GestureEvent.GESTURE_DOWN,onBegin);
			addEventListener(GestureEvent.GESTURE_UP,onEnd);
			
		}
		
		override public function set isMultiTouch(value:Boolean):void{
			
			super.isMultiTouch = value;
			
			removeEventListeners(GestureEvent.GESTURE_DOWN);
			removeEventListeners(GestureEvent.GESTURE_UP);
			
			addEventListener(GestureEvent.GESTURE_DOWN,onBegin);
			addEventListener(GestureEvent.GESTURE_UP,onEnd);
		}
		
		public function get radianSound():Sound
		{
			return _radianSound;
		}

		public function set radianSound(value:Sound):void
		{
			_radianSound = value;
		}

		public function get _rotation():Number
		{
			return _r;
		}

		public function set _rotation(value:Number):void
		{
			_r = value;
			
			var a:Number = 360 /items.length;
			for (var i:int = 0; i < items.length; i++)
			{
				var radian:Number = (a * i + 90 + _r) * Math.PI / 180;
				
				var c:int = _width - _height;
				var x1:Number = Math.cos(radian) * c;
				
				var x2:Number = Math.cos(radian) * _height;
				var y1:Number = Math.sin(radian) * _height;
				
				items[i].x = x1 + x2;
				items[i].y = y1;
				
				var scale:Number = (y1 + _height) / (_height * 2);
				scale = (scale * .6) + .4;
				items[i].scaleX = scale;
				items[i].scaleY = scale;
			}
			
			var list:Array = [];
			for (var j:int = 0; j < items.length; j++)
			{
				list.push(items[j]);
			}
			var aa:Array = list.sortOn("scaleX", 16);
			
			for (var k:int = 0; k < aa.length; k++)
			{
				uiComponent.addChild(aa[k]);
			}
			if(items.length > 0)
			{
				var cn:int = _r / (360 / items.length);
				if(cn != currentNum)
				{
					currentNum = cn;
					
					if(_radianSound)
						_radianSound.play();
				}
			}
			
		}

		private function onEnd(e:GestureEvent):void
		{
			onMove(e);
			removeEventListener(GestureEvent.GESTURE_MOVE,onMove);
			
			if(samplePotins.length > maxSample)
			{
				samplePotins = samplePotins.splice(samplePotins.length - maxSample);
			}
			
			var upTime:int = -1;
			var upx:int = -1;
			var speedy:Number;
			
			for (var i:int = 0; i < samplePotins.length; i++) 
			{
				if(samplePotins[i] is Point)
				{
					if(upx == -1)
					{
						upx = samplePotins[i].x;
						upTime = i * 30;
						i = samplePotins.length - 2;
						continue;
					}
					var csx:Number = samplePotins[i].x - upx;
					
					var t:int = i * 30 - upTime;
					
					speedy = csx / t ;
					upTime = i* 30;
				}
			}
			if((speedy > 0 || speedy < 0) && speedy != Infinity && speedy != -Infinity)
			{
				tween = TweenLite.to(this,1,{_rotation: _r + -speedy * _width,onComplete:complete,ease:Expo.easeOut});
			}
			
		}
		private function complete():void
		{
			tween = null
		}
		
		private function onBegin(e:GestureEvent):void
		{
			if(tween)
			{
				tween.kill();
				tween = null;
			}
			
			upX = e.stageX;
			addEventListener(GestureEvent.GESTURE_MOVE,onMove)
			samplePotins = [];
			upMoveTime = getTimer();
			index = 0;
			
			samplePotins[0] = new Point(e.stageX,e.stageY);
			
		}
		
		private function onMove(e:GestureEvent):void
		{
			var now:int = getTimer();
			var time:int = now - upMoveTime;
			if(time > 30)
				return;
			
			upMoveTime = now;
			
			index = index + int(time / 30);
			samplePotins[index] = new Point(e.stageX,e.stageY);
			
			var cx:int = e.stageX - upX;
			if(cx == 0)
				return
			_rotation = _r + -cx/2;
			upX = e.stageX;
		}
		public function addItem(item:DisplayObject,pivotX:int = 0,pivotY:int = 0):void
		{
			var itemsp:UIComponent = new UIComponent();
			item.x = -pivotX;
			item.y = -pivotY;
			itemsp.addChild(item);
			uiComponent.addChild(itemsp);
			
			items.push(itemsp);
			
		}
		public function test():void
		{
			var a:Number = 360/items.length;
			
			for (var i:int = 0; i < 360; i++) 
			{
				var q:Quad = new Quad(5,5,0xffff0000);
				var radian:Number = i * Math.PI * 180;
				
				var c:int = _width - _height;
				
				var x1:Number = Math.cos(radian) * c;
				var x2:Number = Math.cos(radian) * _height;
				
				var y1:Number = Math.sin(radian) * _height;
				
				q.x = x1 + x2 - 3 + _width;
				q.y = y1 - 3 + _height;
				
				addChild(q);
			}
		}
		
		override public function dispose():void
		{
			if(_radianSound)
			{
				_radianSound.stop();
				_radianSound = null;
			}
			super.dispose();
		}
		
	}
}