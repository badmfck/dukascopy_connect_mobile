package com.dukascopy.connect.screens.dialogs.bottom {
	
	import assets.NewCopyIcon;
	import com.d_project.qrcode.ErrorCorrectLevel;
	import com.d_project.qrcode.QRCode;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.SaveImageAction;
	import com.dukascopy.connect.gui.components.QRCodeImage;
	import com.dukascopy.connect.gui.components.WhiteToastSmall;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.IBitmapProvider;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ShareLinkPopup extends AnimatedTitlePopup {
		private var subtitle:Bitmap;
		private var linkTimeText:Bitmap;
		private var copyButton:BitmapButton;
		private var shareButton:BitmapButton;
		private var saveCodeButton:BitmapButton;
		private var needCallback:Boolean;
		private var link:InputField;
		private var toast:WhiteToastSmall;
		private var code:Bitmap;
		
		public function ShareLinkPopup() { }
		
		override protected function createView():void {
			super.createView();
			
			subtitle = new Bitmap();
			container.addChild(subtitle);
			
			linkTimeText = new Bitmap();
			container.addChild(linkTimeText);
			
			shareButton = new BitmapButton();
			shareButton.setStandartButtonParams();
			shareButton.setDownColor(NaN);
			shareButton.setDownScale(1);
			shareButton.setOverlay(HitZoneType.BUTTON);
			shareButton.cancelOnVerticalMovement = true;
			shareButton.tapCallback = onButtonShareClick;
		//	container.addChild(shareButton);
			
			saveCodeButton = new BitmapButton();
			saveCodeButton.setStandartButtonParams();
			saveCodeButton.setDownColor(NaN);
			saveCodeButton.setDownScale(1);
			saveCodeButton.setOverlay(HitZoneType.BUTTON);
			saveCodeButton.cancelOnVerticalMovement = true;
			saveCodeButton.tapCallback = onButtonSaveCodeClick;
			container.addChild(saveCodeButton);
			
			copyButton = new BitmapButton();
			copyButton.setStandartButtonParams();
			copyButton.setDownColor(NaN);
			copyButton.setDownScale(0.7);
			copyButton.setOverlay(HitZoneType.CIRCLE);
			copyButton.cancelOnVerticalMovement = true;
			copyButton.tapCallback = onButtonCopyClick;
			copyButton.setOverlayPadding(Config.FINGER_SIZE * .2);
			container.addChild(copyButton);
			
			var icon:NewCopyIcon = new NewCopyIcon();
			UI.scaleToFit(icon, int(Config.FINGER_SIZE * .4), int(Config.FINGER_SIZE * .4));
			copyButton.setBitmapData(UI.getSnapshot(UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS))));
			UI.destroy(icon);
			
			var tf:TextFormat = new TextFormat();
			tf.size = FontSize.BODY;
			tf.color = Style.color(Style.COLOR_SUBTITLE);
			tf.font = Config.defaultFontName;
			
			link = new InputField( -1, Input.MODE_INPUT);
			link.setPadding(0);
			container.addChild(link);
			link.updateTextFormat(tf);
			
			code = new Bitmap();
			container.addChild(code);
		}
		
		private function onButtonSaveCodeClick():void 
		{
			var drawable:IBitmapProvider = new QRCodeImage(getLink(), getDescription(), _width, _height);
			
			var saveImageAction:SaveImageAction = new SaveImageAction(drawable, getFilename());
			saveImageAction.getSuccessSignal().add(onImageSaved);
			saveImageAction.getFailSignal().add(onImageSaveError);
			
			saveImageAction.execute();
			
			/*var dukascopyFolderPath:String = "temp/";
			var fl:File = File.applicationStorageDirectory.resolvePath(dukascopyFolderPath);
			if (fl.exists == false)
			{
				fl.createDirectory();
			}
			var filename:String = "qr_invoice.png"
			fl = File.applicationStorageDirectory.resolvePath(dukascopyFolderPath + filename);
			
			var fs:FileStream = new FileStream();
			fs.open(fl, "write");
			fs.writeBytes(loaderData.data);
			fs.close();
			
			if (Config.PLATFORM_ANDROID == true)
			{
				NativeExtensionController.saveFileToDownloadFolder(fl.nativePath);
			}
			else if (Config.PLATFORM_APPLE == true)
			{
			//	var targetFile : File = File.documentsDirectory.resolvePath('test.jpg');
				navigateToURL(new URLRequest(fl.url));
			}
			else if (Config.PLATFORM_WINDOWS == true)
			{
				fl.openWithDefaultApplication();
			//	var path:String = "file:///" + fl.url;
			//	navigateToURL(new URLRequest(path));
			}
			
			fl = null;*/
		}
		
		private function getFilename():String 
		{
			var result:String = "invoice";
			if (data != null && "filename" in data && data.filename != null)
			{
				result += " " + data.filename;
			}
			result += ".png";
			return result;
		}
		
		private function getDescription():String 
		{
			if (data != null && "description" in data && data.description != null)
			{
				return data.description;
			}
			return null;
		}
		
		private function onImageSaveError():void 
		{
			
		}
		
		private function onImageSaved():void 
		{
			
		}
		
		private function onButtonCopyClick():void {
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, getLink());
			
			if (toast == null)
			{
				toast = new WhiteToastSmall(Lang.copied, _width, _height, onMessageShown, 1);
				view.addChild(toast);
			}
		}
		
		private function onMessageShown():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			if (toast != null)
			{
				if (view.contains(toast) == true)
				{
					view.removeChild(toast);
				}
				toast.dispose();
				toast = null;
			}
		}
		
		private function onButtonShareClick():void {
			if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 1) {
				data.callback(getLink());
			}
			var res:String = "";
			if (data != null && "sharetitle" in data && data.sharetitle != null && data.sharetitle.length != 0)
				res = data.sharetitle;
			res += "\n" + getLink();
			GD.S_REQUEST_SHARE_TEXT.invoke(res);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			drawShareButton();
			drawSaveCodeButton();
			
			if (data != null && "subtitle" in data && data.subtitle != null) {
				subtitle.bitmapData = TextUtils.createTextFieldData(
					data.subtitle,
					_width - contentPadding * 2,
					10,
					true,
					TextFormatAlign.CENTER,
					TextFieldAutoSize.LEFT,
					FontSize.SUBHEAD,
					true,
					Style.color(Style.COLOR_TEXT),
					Style.color(Style.COLOR_BACKGROUND),
					false
				);
			}
			
			linkTimeText.bitmapData = TextUtils.createTextFieldData(Lang.shereLinkLifeTime, _width - contentPadding*2, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false);
			
			var position:int = headerHeight + Config.FINGER_SIZE * .4;
			subtitle.y = position;
			subtitle.x = int(_width * .5 - subtitle.width * .5);
			position += subtitle.height + Config.FINGER_SIZE * .4;
			
			link.draw(_width - contentPadding * 2 - copyButton.width - Config.FINGER_SIZE * .2, null, null, null, null, Style.color(Style.COLOR_BACKGROUND));
			link.valueString = getLink();
			link.x = contentPadding;
			link.y = position;
			position += link.height + Config.FINGER_SIZE * .1;
			copyButton.x = int(_width - copyButton.width - contentPadding);
			copyButton.y = int(link.y + link.height * .5 - copyButton.height * .5);
			
			linkTimeText.y = position;
			linkTimeText.x = int(_width * .5 - linkTimeText.width * .5);
			position += linkTimeText.height + Config.FINGER_SIZE * .4;
			
			shareButton.y = position;
			shareButton.x = int(_width * .5 - shareButton.width * .5);
			position += shareButton.height + Config.FINGER_SIZE * .4;
			
			position += Config.FINGER_SIZE * 0.6;
			drawCode(_height - position - Config.FINGER_SIZE * 1.3 - saveCodeButton.height - Config.DOUBLE_MARGIN);
			code.x = int(_width * .5 - code.width * .5);
			code.y = position;
			position += code.height + Config.FINGER_SIZE * .5;
			saveCodeButton.x = int(_width * .5 - saveCodeButton.width * .5);
			saveCodeButton.y = position;
		}
		
		private function drawCode(maxHeight:int):void 
		{
			var link:String = getLink();
			if (link != null)
			{
				if (code.bitmapData != null)
				{
					code.bitmapData.dispose();
					code.bitmapData = null;
				}
				
				var size:int = Math.min(_width - Config.FINGER_SIZE * 3, maxHeight);
				size = Math.max(size, Config.FINGER_SIZE * 2);
				var qr : QRCode = QRCode.getMinimumQRCode(link, ErrorCorrectLevel.L);
				var cs : Number = size / qr.getModuleCount();
				
				var target:Sprite = new Sprite();
				var g : Graphics = target.graphics;
				
				for (var row : int = 0; row < qr.getModuleCount(); row++) {
					for (var col : int = 0; col < qr.getModuleCount(); col++) {
						g.beginFill( (qr.isDark(row, col)? Color.GREY_DARK : 0xffffff) );
						g.drawRect(cs * col, cs * row,  cs, cs);
						g.endFill();
					}
				}
				code.bitmapData = new ImageBitmapData("QRCode", size, size);
				code.bitmapData.draw(target);
				UI.destroy(target);
			}
		}
		
		private function drawShareButton():void 
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textShare, Style.color(Style.COLOR_BACKGROUND), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, -1, -1, Style.size(Style.SIZE_BUTTON_CORNER));
			shareButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawSaveCodeButton():void 
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.saveToGallery, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_LINE_LIGHT), -1, -1, Style.size(Style.SIZE_BUTTON_CORNER));
			saveCodeButton.setBitmapData(buttonBitmap, true);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			copyButton.activate();
			shareButton.activate();
			saveCodeButton.activate();
			link.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			copyButton.deactivate();
			shareButton.deactivate();
			saveCodeButton.deactivate();
			link.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 1)
				{
					data.callback(getLink());
				}
			}
		}
		
		private function getLink():String 
		{
			if (data != null && "url" in data)
			{
				return data.url;
			}
			return "";
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (subtitle != null)
			{
				UI.destroy(subtitle);
				subtitle = null;
			}
			if (linkTimeText != null)
			{
				UI.destroy(linkTimeText);
				linkTimeText = null;
			}
			if (code != null)
			{
				UI.destroy(code);
				code = null;
			}
			if (copyButton != null)
			{
				copyButton.dispose();
				copyButton = null;
			}
			if (shareButton != null)
			{
				shareButton.dispose();
				shareButton = null;
			}
			if (saveCodeButton != null)
			{
				saveCodeButton.dispose();
				saveCodeButton = null;
			}
			if (toast != null)
			{
				toast.dispose();
				toast = null;
			}
			if (link != null)
			{
				link.dispose();
				link = null;
			}
		}
	}
}