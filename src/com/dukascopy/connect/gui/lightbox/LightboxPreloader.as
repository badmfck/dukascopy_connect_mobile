package com.dukascopy.connect.gui.lightbox 
{
	import com.dukascopy.connect.sys.assets.Assets;
	import com.telefision.utils.Loop;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexey
	 */
	public class LightboxPreloader extends Sprite 
	{
		
		[Embed(source = "lbpreloader.png")]public static var LIGHTBOX_PRELOADER:Class;
		private var bmp:Bitmap;
		
		
				
		private const RADIANS2DEGREE:Number = Math.PI / 180;
		private var ROTATION_SPEED:int = 5;
		private var rotationPoint:Point = new Point();
		private var inner:Sprite = new Sprite();
		
		public function LightboxPreloader() {
			addChild(inner);
			this.mouseChildren = this.mouseEnabled = false;
			bmp = new Bitmap(Assets.getAsset(LIGHTBOX_PRELOADER));
			bmp.x = -bmp.width * .5;
			bmp.y = -bmp.height * .5;
			inner.addChild(bmp);
			addChild(inner);

		}
		
		public function start():void {
			Loop.add(onLoop);
		}
		
		
		public function stop():void {
			Loop.remove(onLoop);
		}
		
			/** ROTATE PRELOADER */
		private function onLoop():void {
			inner.rotation += 10;
			//rotateAroundCenter(this,ROTATION_SPEED, rotationPoint);
		}
		
		private function rotateAroundCenter (ob:*, angleDegrees:Number, rotationPoint:Point) :void {
			rotationPoint.x = 0;// TelefisionMobile.stage.stage.stageWidth * .5;
			rotationPoint.y = 0;// TelefisionMobile.stage.stage.stageHeight * .5;
			var m:Matrix=ob.transform.matrix;
			m.tx -= rotationPoint.x;
			m.ty -= rotationPoint.y;
			m.rotate (angleDegrees * RADIANS2DEGREE);
			m.tx += rotationPoint.x;
			m.ty += rotationPoint.y;
			ob.transform.matrix = m;
		}
		
		
		
		
	}

}