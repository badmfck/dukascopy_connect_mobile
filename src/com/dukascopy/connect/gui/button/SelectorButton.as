package com.dukascopy.connect.gui.button
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorButtonData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.dialogs.bottom.ListSelectionPopup;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SelectorButton extends BitmapButton
	{
		private var generatedBitmap:ImageBitmapData;
		
		private var box:Sprite;
		private var tf:Bitmap;
		
		static private var arrowHeight:int;
		static private var arrowCathetus:int;
		
		private var w:int = 0;
		private var h:int = 0;
		
		private var data:Vector.<SelectorButtonData>;
		private var defaultLabel:String = "";
		
		private var selectedIndex:int = -1;
		private var callBack:Function;
		private var titleTf:Bitmap;
		private var title:String;
		
		public function SelectorButton(callBack:Function, data:Vector.<SelectorButtonData>, title:String = null)
		{
			super();
			
			this.data = data;
			this.title = title;
			
			setStandartButtonParams();
			setDownScale(1);
			usePreventOnDown = true;
			cancelOnVerticalMovement = true;
			this.callBack = callBack;
			
			tf = new Bitmap();
			titleTf = new Bitmap();
			box = new Sprite();
			box.addChild(tf);
			box.addChild(titleTf);
			tapCallback = onSelect;
			setOverlay(HitZoneType.MENU_MIDDLE_ELEMENT);
			setOverflow(Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
		}
		
		private function onSelect():void 
		{
			DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:data,
						title:Lang.SPECIFY_PURPOSE_OF_MONEY_TRANSFER_TITLE,
						renderer:ListLink,
						callback:onSelection
					}, ServiceScreenManager.TYPE_SCREEN
				);
			
			
			/*DialogManager.showDialog(ScreenLinksDialog, { callback:function(selected:Object):void {
				selectedIndex = this.data.indexOf(selected);
				setSize(w);
				if (callBack != null)
				{
					callBack();
				}
			}, data:data, itemClass:ListLink, title:Lang.SPECIFY_PURPOSE_OF_MONEY_TRANSFER_TITLE, showFullTitle:true } );*/
		}
		
		private function onSelection(selected:SelectorButtonData):void
		{
			selectedIndex = this.data.indexOf(selected);
			setSize(w);
			if (callBack != null)
			{
				callBack();
			}
		}
		
		public function setSize(w:int):void
		{
			if (w < 1)
				return;
			
			this.w = w;
			this.h = Config.FINGER_SIZE * .7;
			
		//	var xOffset:int = w - Config.DOUBLE_MARGIN;
			var xOffset:int = w;
			
			if (generatedBitmap != null)
			{
				if (generatedBitmap.height != h || generatedBitmap.width != w)
				{
					generatedBitmap.dispose();
					generatedBitmap = null;
				}
			}
			
			var lineThickness:int = int(Math.max(1, Config.FINGER_SIZE * .03));
			
			var position:int = 0;
			
			if (titleTf.bitmapData != null)
			{
				titleTf.bitmapData.dispose();
				titleTf.bitmapData = null;
			}
			
			if (title != null)
			{
				titleTf.bitmapData = TextUtils.createTextFieldData(title, w, 10, true, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, Style.size(Style.CONTROL_TEXT_SMALL_SIZE), 
																	true, Style.color(Style.COLOR_SUBTITLE));
				titleTf.y = position;
				position += titleTf.height + Config.FINGER_SIZE * .0;
				h = h + position;
			}
			
			box.graphics.clear();
			box.graphics.beginFill(0xFFFFFF, 0);
			box.graphics.drawRect(1, 1, w, h);
			box.graphics.lineStyle(lineThickness, 0x78C043);
			box.graphics.moveTo(0, h - lineThickness / 2);
			box.graphics.lineTo(w, h - lineThickness / 2);
			box.graphics.lineStyle();
			
			// arrow
			arrowHeight = h * 0.15;
			arrowCathetus = h * 0.12;
			box.graphics.beginFill(Style.color(Style.COLOR_TEXT));
			box.graphics.moveTo(xOffset, int(position + (h -position - arrowHeight) * .5));
			box.graphics.lineTo(xOffset - arrowCathetus, int(position + (h - position + arrowHeight) * .5));
			box.graphics.lineTo(xOffset - arrowCathetus * 2, int(position + (h - position - arrowHeight) * .5));
			box.graphics.lineTo(xOffset, int(position + (h - position - arrowHeight) * .5));
			box.graphics.endFill();
			
			if (tf.bitmapData != null)
			{
				tf.bitmapData.dispose();
				tf.bitmapData = null;
			}
			tf.bitmapData = TextUtils.createTextFieldData(getCurrentValue(), xOffset - arrowHeight * 2 - (w - xOffset) * 2, 10, false, 
															TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
															Style.size(Style.CONTROL_TEXT_SIZE), false, Style.color(Style.COLOR_TEXT));
			tf.y = position + (h - position - tf.height) * .5;
			
			if (generatedBitmap == null)
			{
				generatedBitmap = new ImageBitmapData("SelectorButton.generatedBitmap", w, int(h), true, 0);
			}
			else
			{
				generatedBitmap.fillRect(generatedBitmap.rect, 0);
			}
			
			generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);
			
			setBitmapData(generatedBitmap);
		}
		
		private function getCurrentValue():String 
		{
			if (selectedIndex == -1)
			{
				return Lang.select;
			}
			else
			{
				return data[selectedIndex].label;
			}
		}
		
		override public function dispose():void
		{
			UI.safeRemoveChild(tf);
			tf = null;
			UI.safeRemoveChild(titleTf);
			titleTf = null;
			if (box != null)
			{
				box.graphics.clear();
				box = null;
			}
			this.data = null;
			if (generatedBitmap != null)
			{
				generatedBitmap.dispose();
				generatedBitmap = null;
			}
			callBack = null;
			TweenMax.killDelayedCallsTo(color);
			TweenMax.killDelayedCallsTo(uncolor);
			
			super.dispose();
		}
		
		public function getHeight():int 
		{
			if (box != null)
			{
				return box.y + box.height;
			}
			return height;
		}
		
		public function getSelected():String 
		{
			if (selectedIndex != -1)
			{
				return data[selectedIndex].data;
			}
			return null;
		}
		
		public function reset():void 
		{
			selectedIndex = -1;
			setSize(w);
		}
		
		public function error():void 
		{
			var redColor:Color = new Color();
			redColor.color = 0xCD3F43;
			transform.colorTransform = redColor;
			TweenMax.delayedCall(0.2, uncolor);
			TweenMax.delayedCall(0.4, color);
			TweenMax.delayedCall(0.6, uncolor);
		}
		
		private function color():void 
		{
			var redColor:Color = new Color();
			redColor.color = 0xCD3F43;
			transform.colorTransform = redColor;
		}
		
		private function uncolor():void 
		{
			transform.colorTransform = new ColorTransform();
		}
	}
}