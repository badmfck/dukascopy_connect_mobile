package com.dukascopy.connect.gui.button 
{
	import assets.ArrowStep;
	import assets.WhiteLoadShape;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.roadMap.RoadmapStepClip;
	import com.dukascopy.connect.screens.roadMap.RoadmapStepData;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class LoadingRectangleButton extends RectangleButton
	{
		private var animation:Preloader;
		private var _type:String;
		
		public function LoadingRectangleButton(value:String, color:Number, type:String) 
		{
			this._type = type;
			super(value, color);
		}
		
		public function get type():String 
		{
			return _type;
		}
		
		public function set type(value:String):void 
		{
			_type = value;
			trace("TYPE", _type);
		}
		
		override public function draw():void
		{
			if (!changed)
			{
				return;
			}
			changed = false;
			
			tf.text = value;
			
			
			var textWidth:int = w - Config.MARGIN * 2;
			var buttonWidth:int = w;
			var textFormat:TextFormat = new TextFormat();
				textFormat.align = TextFormatAlign.CENTER;
				tf.setTextFormat(textFormat);
			if (_type == "suspend")
			{
				textWidth = (w - Config.MARGIN * 4) / 2;
				textFormat.size = FontSize.BODY;
				tf.setTextFormat(textFormat);
				buttonWidth = w / 2;
			}
			
			
			tf.width = textWidth
			tf.height = tf.textHeight + 4;
			tf.y = int(Config.MARGIN * 1.3);
			tf.x = int(buttonWidth * .5 - tf.width * .5);
			
			var itemHeight:int = int(Config.MARGIN * 2.6 + tf.height);
			
			var padding:int = Config.FINGER_SIZE * .1;
			box.graphics.clear();
			box.graphics.beginFill(color, 1);
			box.graphics.drawRoundRect(padding, padding, buttonWidth - padding * 2, itemHeight - padding * 2, Style.size(Style.SIZE_BUTTON_CORNER), Style.size(Style.SIZE_BUTTON_CORNER));
			box.graphics.endFill();
			
			if (generatedBitmap == null || generatedBitmap.isDisposed == true || generatedBitmap.width != buttonWidth || generatedBitmap.height != itemHeight) {
				
				UI.disposeBMD(generatedBitmap);
				
				generatedBitmap = new ImageBitmapData("RectangleButton.generatedBitmap", buttonWidth, itemHeight, true, 0);
			}else {
				generatedBitmap.fillRect(generatedBitmap.rect, 0);	
			}
			
			generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);
			
			setBitmapData(generatedBitmap);
			setHitZone(buttonWidth, itemHeight);
		}
		
		public function animateProgress():void 
		{
			if (animation == null)
			{
				animation = new Preloader(Config.FINGER_SIZE * .5, WhiteLoadShape);
			}
			animation.visible = true;
			animation.show();
			animation.y = int(height * .5 - animation.height * .5);
			animation.x = 0;
			addChild(animation);
			
			var animationTime:Number = 0.3;
			TweenMax.to(animation, animationTime, {x:Config.DOUBLE_MARGIN + Config.DOUBLE_MARGIN});
			if (tf.x < animation.x + animation.width*2 + Config.DOUBLE_MARGIN*2.5)
			{
			//	TweenMax.killTweensOf(tf);
				var dist:int = (animation.x + Config.FINGER_SIZE);
				TweenMax.to(tf, animationTime, {x:dist, onUpdate:render});
			}
		}
		
		override public function setValue(value:String = null):void
		{
			super.setValue(value);
			hideAnimation();
		}
		
		private function render():void 
		{
			var itemHeight:int = int(Config.MARGIN * 2.6 + tf.height);
			var needDispose:Boolean = false;
			var buttonWidth:int = w;
				if (_type == "suspend")
				{
					buttonWidth = w / 2;
				}
			if (generatedBitmap == null || generatedBitmap.isDisposed == true || generatedBitmap.width != buttonWidth || generatedBitmap.height != itemHeight) {
				
				UI.disposeBMD(generatedBitmap);
				
				generatedBitmap = new ImageBitmapData("RectangleButton.generatedBitmap", w, itemHeight, true, 0);
				needDispose = true;
			}else {
				generatedBitmap.fillRect(generatedBitmap.rect, 0);	
			}
			
			setHitZone(buttonWidth, itemHeight);
			generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);
			
			setBitmapData(generatedBitmap, needDispose);
		}
		
		private function hideAnimation():void
		{
			if (animation != null)
			{
				var buttonWidth:int = w;
				if (_type == "suspend")
				{
					buttonWidth = w / 2;
				}
				
				TweenMax.killChildTweensOf(animation);
				TweenMax.killTweensOf(animation);
				TweenMax.to(animation, 0.3, {x:0});
			//	TweenMax.killTweensOf(tf);
				var dist:int = int(buttonWidth * .5 - tf.width * .5);
				if (dist > 0)
				{
					TweenMax.to(tf, 0.3, {x:dist, onUpdate:render, onComplete:removeAnimation});
				}
				animation.hide();
			}
			
			setHitZone(buttonWidth, height);
		}
		
		override public function dispose():void
		{
			if (tf != null)
			{
				TweenMax.killTweensOf(tf);
			}
			super.dispose();
			removeAnimation();
		}
		
		public function setColor(value:Number):void 
		{
			color = value;
		}
		
		public function showPhaze(phase:String):void 
		{
			TweenMax.killChildTweensOf(animation);
			TweenMax.killTweensOf(tf);
			TweenMax.killTweensOf(animation);
			
			var clip:Sprite = new Sprite();
			var renderer:RoadmapStepClip = new RoadmapStepClip();
			
			var clipData:RoadmapStepData;
			
			switch(phase)
			{
				case BankPhaze.CARD:
				{
					clipData = new RoadmapStepData(RoadmapStepData.STEP_SELECT_CARD,         Lang.roadmap_selectCard);
					break;
				}
				case BankPhaze.EMPTY:
				case BankPhaze.RTO_STARTED:
				{
					clipData = new RoadmapStepData(RoadmapStepData.STEP_REGISTRATION_FORM,   Lang.roadmap_fillRegistrationForm);
					break;
				}
				case BankPhaze.ZBX:
				case BankPhaze.SOLVENCY_CHECK:
				case BankPhaze.DONATE:
				{
					clipData = new RoadmapStepData(RoadmapStepData.STEP_SOLVENCY_CHECK,      Lang.roadmap_solvencyCheck);
					break;
				}
				case BankPhaze.NOTARY:
				{
					clipData = new RoadmapStepData(RoadmapStepData.STEP_DEPOSIT,             Lang.roadmap_initialDeposit);
					break;
				}
				case BankPhaze.WIRE_DEPOSIT:
				{
					clipData = new RoadmapStepData(RoadmapStepData.STEP_DEPOSIT,             Lang.roadmap_initialDeposit);
					break;
				}
				case BankPhaze.DOCUMENT_SCAN:
				{
					clipData = new RoadmapStepData(RoadmapStepData.STEP_DOCUMENT_SCAN,       Lang.roadmap_documentScan);
					break;
				}
			}
			if (clipData != null)
			{
				var arrow:Sprite = new ArrowStep();
				UI.scaleToFit(arrow, Config.FINGER_SIZE * .35, Config.FINGER_SIZE * .35);
				var arrowX:int=int(w - Config.FINGER_SIZE * .3 - arrow.width);

				renderer.x = int(Config.FINGER_SIZE * .4);

				clipData.status = RoadmapStepData.STATE_ACTIVE;
				//renderer.setData(clipData, w - Config.FINGER_SIZE, Color.WHITE);
				renderer.setData(clipData, arrowX-renderer.x*2, Color.WHITE);

				clip.addChild(renderer);

				
			//	UI.colorize(renderer, Color.WHITE);
				clip.graphics.beginFill(Color.GREY);
				clip.graphics.drawRect(0, 0, w, int(renderer.height + Config.FINGER_SIZE * .5));
				clip.graphics.endFill();
				
				renderer.y = int((renderer.height + Config.FINGER_SIZE * .5) * .5 - renderer.getHeight() * .5);
				


				clip.addChild(arrow);
				arrow.x = arrowX;
				arrow.y = int(clip.height * .5 - arrow.height * .5);
				setBitmapData(UI.getSnapshot(clip), true);
				UI.destroy(clip);
				renderer.dispose();
				UI.destroy(arrow);
			}
		}
		
		private function removeAnimation():void 
		{
			if (animation != null)
			{
				if (contains(animation))
				{
					removeChild(animation);
				}
				TweenMax.killTweensOf(animation);
				TweenMax.killChildTweensOf(animation);
				UI.destroy(animation);
				animation = null;
			}
		}
	}
}