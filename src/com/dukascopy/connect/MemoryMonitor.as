package com.dukascopy.connect{
	
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.telefision.sys.signals.Signal;
	import com.telefision.utils.Loop;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	/**
	 * ABC
	 * @author ...
	 */
	public class MemoryMonitor extends Sprite{
		private var tf:TextField;
		private var frames:int = 0;
		private var _width:int;
		private var ticks:int;
		private var fps:Number=0;
		private var last:Number = 0;
		private var minMem:Number=Number.MAX_VALUE;
		private var maxMem:Number=0;
		private var peaksHeight:int;
		private var oldStageWidth:int=0;
		private var oldStageHeight:int=0;
		private var inited:Boolean=false;
		private var btnShowImages:Sprite;
		private var mpt:Point = new Point(0, 0);
		private var btnRect:Rectangle = new Rectangle(0, 0, 20, 20);
		private var btnSignals:Rectangle = new Rectangle(22, 0, 20, 20);
		private var btnLoops:Rectangle = new Rectangle(44, 0, 20, 20);
		private var btnShowSignals:Sprite;
		private var btnShowLoops:Sprite;
		
		public function MemoryMonitor() {
			ImageBitmapData.isDebug = true;
			Signal.isDebug = true;
			
			addEventListener(Event.EXIT_FRAME, onExitFrame);
			tf = new TextField();
			tf.defaultTextFormat = new TextFormat('Arial', 20, 0xFFFFFF);
			tf.text = 'TOTAL:_10__10_MB';
			tf.height = (tf.textHeight + 4) * 8;
			tf.width = tf.textWidth + 4;
			tf.x = 10;
			tf.y = 10;
			tf.addEventListener(MouseEvent.CLICK, onClick);
			_width = tf.width + 10;
			
			graphics.beginFill(0, .7);
			graphics.drawRect(0, 0, _width, tf.height+20);
			addChild(tf);
			
			mouseChildren = false;
			mouseEnabled = false;
			tabEnabled = false;
			
			var fpsTimer:Timer = new Timer(1000,0);
			fpsTimer.addEventListener(TimerEvent.TIMER, onTimer);
			fpsTimer.start();
			setMonitor();
			
			btnShowImages = new Sprite();
			btnShowImages.graphics.clear();
			btnShowImages.graphics.beginFill(0xFF0000);
			btnShowImages.graphics.drawRect(0, 0, 20, 20);
			addChild(btnShowImages);
			
			btnShowSignals = new Sprite();
			btnShowSignals.graphics.clear();
			btnShowSignals.graphics.beginFill(0xFFCC00);
			btnShowSignals.graphics.drawRect(0, 0, 20, 20);
			btnShowSignals.x = btnSignals.x;
			addChild(btnShowSignals);
			
			btnShowLoops = new Sprite();
			btnShowLoops.graphics.clear();
			btnShowLoops.graphics.beginFill(0x1188FF);
			btnShowLoops.graphics.drawRect(0, 0, 20, 20);
			btnShowLoops.x = btnLoops.x;
			addChild(btnShowLoops);
		}
		
		private function onClick(e:MouseEvent):void{
			var li:int = (tf.getLineIndexAtPoint(tf.mouseX, tf.mouseY));
			if (li == 4)
				Signal.showNames();
		}
		
		private function onTimer(e:TimerEvent):void {
			fps = frames;
			frames = 0;
			setMonitor();
		}
		
		private function onExitFrame(e:Event):void {
			
			
			if (stage && (stage.stageWidth != oldStageWidth || stage.stageHeight != oldStageHeight)) {
				if (inited == false) {
					setEvents();
					inited = true;
				}
				oldStageHeight = stage.stageHeight;
				oldStageWidth = stage.stageWidth;
				reposition();
			}
			frames++;
		}
		
		private function setEvents():void{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		private function onMouseDown(e:MouseEvent):void {
		
			mpt.x = stage.mouseX;
			mpt.y = stage.mouseY;
			btnRect.x = x + btnShowImages.x;
			btnRect.y = y + btnShowImages.y;
			
			btnLoops.x = x + btnShowLoops.x;
			btnLoops.y = y + btnShowLoops.y;
			
			btnSignals.x = x + btnShowSignals.x;
			btnSignals.y = y + btnShowSignals.y;
			
			if (btnRect.containsPoint(mpt)) {
				e.preventDefault();
				e.stopImmediatePropagation();
				e.stopPropagation();
				ImageBitmapData.traceBitmaps();
			}
			
			if (btnLoops.containsPoint(mpt)) {
				e.preventDefault();
				e.stopImmediatePropagation();
				e.stopPropagation();
				Loop.showNames();
			}
			
			if (btnSignals.containsPoint(mpt)) {
				e.preventDefault();
				e.stopImmediatePropagation();
				e.stopPropagation();
				Signal.showNames();
			}
		}
		
		private function reposition():void{
			x = oldStageWidth - width;
			//y = oldStageHeight - height;
		}
		
		private function setMonitor():void{
			tf.text = "Total: " + Number(System.totalMemory / 1024 / 1024 ).toFixed( 2 ) + 'Mb\n';
			tf.appendText("Free: " + Number(System.freeMemory / 1024 / 1024 ).toFixed( 2 ) + 'Mb\n');
			tf.appendText("Private: " + Number(System.privateMemory / 1024 / 1024 ).toFixed( 2 ) + 'Mb\n');
			//tf.appendText("B.L.Users: " +BusinessListUser.count+'\n');
			tf.appendText("Signals: " +Signal.count+'\n');
			//tf.appendText("UserVO: " +UserVO.count+'\n');
			//tf.appendText("O.POOL: " +ObjectsPool.getCountOfAllObjects()+'\n');
			tf.appendText("Image Bitmaps: " +ImageBitmapData.activeBitmaps+'\n');
			//tf.appendText("Image Sizes: " +(ImageBitmapData.totalBitmapsSize()/1024/1024).toFixed( 2 )+'Mb\n');
			tf.appendText("Image loaders: " +ImageManager.imageLoadersCount+'\n');
			/*tf.appendText("Image Assets: " +ImageBitmapData.activeAssets+'\n');
			tf.appendText("Saving: " +ImageSaver.queueLength+'\n');*/
			tf.appendText("Loops: " +Loop.count+'\n');
			tf.appendText("FPS: " + fps.toFixed(1));
		}
	}
}