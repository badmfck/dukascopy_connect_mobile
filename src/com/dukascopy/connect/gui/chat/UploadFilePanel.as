package com.dukascopy.connect.gui.chat 
{
	import assets.NewCloseIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.FileUploadData;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.DocumentUploader;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class UploadFilePanel extends Sprite
	{
		private var stack:Vector.<FileUploadData>;
		private var currentUploader:FileUploadData;
		private var itemWidth:int;
		private var parentClip:Sprite;
		private var posX:int;
		private var posY:int;
		private var back:Sprite;
		private var titleUpload:Bitmap;
		private var titleCurrent:Bitmap;
		private var titleOther:Bitmap;
		private var preloader:CirclePreloader;
		private var cancelButton:BitmapButton;
		private var active:Boolean;
		private var disposed:Boolean;
		
		public function UploadFilePanel(parentClip:Sprite, posX:int, posY:int, itemWidth:int) 
		{
			this.parentClip = parentClip;
			this.posX = posX;
			this.posY = posY;
			this.itemWidth = itemWidth;
			
			back = new Sprite();
			addChild(back);
			back.graphics.beginFill(Style.color(Style.COLOR_TEXT), 0.9);
			back.graphics.drawRect(0, 0, itemWidth, 10);
			back.graphics.endFill();
			
			titleUpload = new Bitmap();
			addChild(titleUpload);
			
			titleCurrent = new Bitmap();
			addChild(titleCurrent);
			titleCurrent.alpha = 0.6;
			
			titleOther = new Bitmap();
			addChild(titleOther);
			titleOther.alpha = 0.6;
			
			preloader = new CirclePreloader(int(Config.FINGER_SIZE*.25), int(Config.FINGER_SIZE*.05), Style.color(Style.COLOR_BACKGROUND));
			addChild(preloader);
			
			cancelButton = new BitmapButton();
			cancelButton.setStandartButtonParams();
			cancelButton.setDownScale(1.3);
			cancelButton.setOverlay(HitZoneType.CIRCLE);
			
			cancelButton.tapCallback = onCancel;
			addChild(cancelButton);
			
			var icon:Sprite = new NewCloseIcon();
			var iconSize:int = Config.FINGER_SIZE * .3;
			UI.scaleToFit(icon, iconSize, iconSize);
			UI.colorize(icon, Style.color(Style.COLOR_BACKGROUND));
			cancelButton.setBitmapData(UI.getSnapshot(icon));
			cancelButton.show();
			UI.destroy(icon);
			
			titleUpload.x = int(Config.FINGER_SIZE * .2 + Config.FINGER_SIZE*.9);
			titleCurrent.x = int(Config.FINGER_SIZE * .2 + Config.FINGER_SIZE*.9);
			titleOther.x = int(Config.FINGER_SIZE * .2 + Config.FINGER_SIZE*.9);
			
			if (active)
			{
				cancelButton.activate();
			}
			
			preloader.x = int(Config.FINGER_SIZE * .2 + Config.FINGER_SIZE * .5 * .5);
			preloader.y = int(Config.FINGER_SIZE * .2 + Config.FINGER_SIZE * .5 * .5);
			
			cancelButton.x = itemWidth - Config.FINGER_SIZE * .3 - cancelButton.width;
			cancelButton.y = Config.FINGER_SIZE * .3;
			cancelButton.setOverflow(Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
			
			addListeners();
		}
		
		private function addListeners():void 
		{
			DocumentUploader.S_UPLOAD_STATUS.add(onStatus);
		}
		
		private function onStatus(uploadData:FileUploadData):void 
		{
			display(uploadData);
		}
		
		private function onCancel():void 
		{
			if (currentUploader != null)
			{
				DocumentUploader.cancelUpload(currentUploader.id);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		public function display(uploadData:FileUploadData):void
		{
			if (disposed)
			{
				return;
			}
			
			if (stack == null)
			{
				stack = new Vector.<FileUploadData>();
			}
			
			var exist:Boolean;
			for (var i:int = 0; i < stack.length; i++) 
			{
				if (stack[i].id == uploadData.id)
				{
					exist = true;
					break;
				}
			}
			if (currentUploader != null && currentUploader.id == uploadData.id)
			{
				exist = true;
			}
			
			if (!exist && uploadData.status != FileUploadData.FAIL && uploadData.status != FileUploadData.DONE && uploadData.status != FileUploadData.CANCEL)
			{
				if (currentUploader == null)
				{
					currentUploader = uploadData;
				}
				else
				{
					stack.push(uploadData);
				}
				redraw();
				addToStage();
			}
			else
			{
				if (uploadData.status == FileUploadData.FAIL)
				{
					removeUploader(uploadData);
				}
				else if (uploadData.status == FileUploadData.DONE)
				{
					removeUploader(uploadData);
				}
				else if (uploadData.status == FileUploadData.CANCEL)
				{
					removeUploader(uploadData);
				}
			}
		}
		
		private function addToStage():void 
		{
			if (parentClip != null)
			{
				parentClip.addChild(this);
				x = posX;
				y = posY;
			}
		}
		
		private function removeUploader(uploadData:FileUploadData):void 
		{
			if (stack.length > 0)
			{
				stack.removeAt(stack.indexOf(uploadData));
			}
			
			if (currentUploader != null && currentUploader.id == uploadData.id)
			{
				if (stack.length > 0)
				{
					currentUploader = stack.shift();
					redraw();
				}
				else
				{
					currentUploader = null;
					removeSromStage();
				}
			}
			else
			{
				redraw();
			}
		}
		
		private function redraw():void 
		{
			var position:int = Config.FINGER_SIZE * .2;
			if (currentUploader != null)
			{
				drawTitle(Lang.uploading);
				titleUpload.y = position;
				position += titleUpload.height + Config.FINGER_SIZE * .1;
				drawCurrent(currentUploader.fileName);
				titleCurrent.y = position;
				position += titleCurrent.height + Config.FINGER_SIZE * .1;
			}
			if (stack != null && stack.length > 0)
			{
				drawOthers("+ " + stack.length + " " + Lang.uploads);
				titleOther.y = position;
				position += titleOther.height + Config.FINGER_SIZE * .2;
			}
			else
			{
				if (titleOther.bitmapData != null)
				{
					titleOther.bitmapData.dispose();
					titleOther.bitmapData = null;
				}
			}
			back.height = position;
		}
		
		private function drawCurrent(text:String):void 
		{
			if (titleCurrent.bitmapData != null)
			{
				titleCurrent.bitmapData.dispose();
				titleCurrent.bitmapData = null;
			}
			
			titleCurrent.bitmapData = TextUtils.createTextFieldData(text, itemWidth - Config.FINGER_SIZE * 1.8 - cancelButton.width, 10, false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, FontSize.SUBHEAD, false, Style.color(Style.COLOR_BACKGROUND));
		}
		
		private function drawOthers(text:String):void 
		{
			if (titleOther.bitmapData != null)
			{
				titleOther.bitmapData.dispose();
				titleOther.bitmapData = null;
			}
			
			titleOther.bitmapData = TextUtils.createTextFieldData(text, itemWidth - Config.FINGER_SIZE * 1.8 - cancelButton.width, 10, false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, FontSize.SUBHEAD, false, Style.color(Style.COLOR_BACKGROUND));
		}
		
		private function drawTitle(text:String):void 
		{
			if (titleUpload.bitmapData != null)
			{
				titleUpload.bitmapData.dispose();
				titleUpload.bitmapData = null;
			}
			
			titleUpload.bitmapData = TextUtils.createTextFieldData(text, itemWidth - Config.FINGER_SIZE * 1.8 - cancelButton.width, 10, false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, FontSize.SUBHEAD, false, Style.color(Style.COLOR_BACKGROUND));
		}
		
		private function removeSromStage():void 
		{
			if (parentClip != null && parentClip.contains(this))
			{
				parentClip.removeChild(this);
			}
		}
		
		public function activate():void
		{
			active = true;
			cancelButton.activate();
		}
		
		public function deactivate():void
		{
			active = false;
			cancelButton.deactivate();
		}
		
		public function dispose():void
		{
			disposed = true;
			removeListeners();
			
			stack = null;
			currentUploader = null;
			parentClip = null;
			
			if (back != null)
			{
				UI.destroy(back);
				back = null;
			}
			if (titleUpload != null)
			{
				UI.destroy(titleUpload);
				titleUpload = null;
			}
			if (titleCurrent != null)
			{
				UI.destroy(titleCurrent);
				titleCurrent = null;
			}
			if (titleOther != null)
			{
				UI.destroy(titleOther);
				titleOther = null;
			}
			if (preloader != null)
			{
				UI.destroy(preloader);
				preloader = null;
			}
			if (cancelButton != null)
			{
				cancelButton.dispose();
				cancelButton = null;
			}
		}
		
		private function removeListeners():void 
		{
			DocumentUploader.S_UPLOAD_STATUS.remove(onStatus);
		}
	}
}