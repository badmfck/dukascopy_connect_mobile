package com.dukascopy.connect.screens.dialogs.newDialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.screenAction.customActions.DownloadFileAction;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.localFiles.LocalFilesManager;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.BaseGraphicsUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.chat.FileMessageVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	
	/**
	 * @author Sergey Dobarin
	 */
	
	public class FileDownloadPopup extends BaseScreen {
		
		private var fileName:Bitmap;
		private var label:Bitmap;
		private var size:Bitmap;
		
		private var cancelButton:BitmapButton;
		private var container:Sprite;
		private var bg:Shape;
		private var icon:Sprite;
		private var fileData:FileMessageVO;
		private var preloader:CirclePreloader;
		private var loader:Sprite;
		private var loaderData:URLLoader;
		private var currentProgress:Number;
		private var progressAnimation:Object;
		private var loaded:Boolean;
		private var animationCpmplete:Boolean;
		private var urlRequest:URLRequest;
		private var fileType:String;
		
		public function FileDownloadPopup() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			container = new Sprite();
			view.addChild(container);
			
			bg = new Shape();
			container.addChild(bg);
			
			label = new Bitmap();
			container.addChild(label);
			
			fileName = new Bitmap();
			container.addChild(fileName);
			
			size = new Bitmap();
			container.addChild(size);
			
			cancelButton = new BitmapButton();
			cancelButton.setStandartButtonParams();
			cancelButton.cancelOnVerticalMovement = true;
			cancelButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			cancelButton.setDownScale(1);
			cancelButton.setDownColor(0);
			cancelButton.show();
			cancelButton.tapCallback = cancel;
			cancelButton.disposeBitmapOnDestroy = true;
			container.addChild(cancelButton);
		}
		
		private function cancel():void 
		{
			ServiceScreenManager.closeView();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			fileData = data.fileData as FileMessageVO;
			urlRequest = data.request as URLRequest;
			fileType = data.fileType as String;
			
			drawNextButton();
			
			drawIcon();
			drawName();
			drawLabel();
			drawSize();
			
			predownload();
		}
		
		private function predownload():void 
		{
			preloader = new CirclePreloader(Config.FINGER_SIZE * .25, Config.FINGER_SIZE * .05);
			container.addChild(preloader);
			
			TweenMax.delayedCall(1.5, download);
		}
		
		private function download():void 
		{
			if (_isDisposed == true)
			{
				return;
			}
			
			loader = new Sprite();
			container.addChild(loader);
			
			loader.x = int(_width - Config.DIALOG_MARGIN - Config.FINGER_SIZE * .25);
			loader.y = int(fileName.y + fileName.height * .5);
			
			startDownload();
		}
		
		private function startDownload():void 
		{
			currentProgress = 0;
			
			loaderData = new URLLoader();
			loaderData.dataFormat = URLLoaderDataFormat.BINARY;
			loaderData.addEventListener(Event.COMPLETE, onLoadComplete);
			loaderData.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loaderData.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loaderData.load(urlRequest);
		}
		
		private function onLoadComplete(e:Event):void 
		{
			if (loaderData != null && loaderData.data != null && loaderData.data is ByteArray)
			{
				if ((loaderData.data as ByteArray).length == 330)
				{
					onLoadError(null);
				}
				else
				{
					var fileData:ByteArray = (loaderData.data as ByteArray);
					if (fileData.length > 4)
					{
						if (fileType != null)
						{
							var header:String;
							for (var i:int = 0; i < 4; i++) 
							{
								try
								{
									header += fileData.readUTFBytes(1);
								}
								catch (e:Error)
								{
									onLoadError(null);
									break;
								}
							}
							if (header == fileType)
							{
								if (urlRequest != null && urlRequest.data != null)
								{
									if (fileType == DownloadFileAction.PDF)
									{
										urlRequest.data.asfile = "pdf";
									}
								}
								loaded = true;
								finishDownload();
							}
							else
							{
								if (fileData.length < 2000)
								{
									tryLoadAsText();
								}
								else
								{
									onLoadError(null);
								}
							}
						}
						else
						{
							loaded = true;
							finishDownload();
						}
					}
					else
					{
						onLoadError(null);
					}
				}
			}
			else
			{
				loaded = true;
				if (animationCpmplete == true)
				{
					finishDownload();
				}
			}
		}
		
		private function tryLoadAsText():void 
		{
			if (loaderData != null)
			{
				loaderData.removeEventListener(Event.COMPLETE, onLoadComplete);
				loaderData.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				loaderData.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				try{
					loaderData.close();
				}
				catch (e:Error)
				{
					
				}
			}
			
			loaderData = new URLLoader();
			loaderData.dataFormat = URLLoaderDataFormat.TEXT;
			loaderData.addEventListener(Event.COMPLETE, onLoadCompleteText);
			loaderData.addEventListener(IOErrorEvent.IO_ERROR, onLoadErrorText);
			loaderData.load(urlRequest);
		}
		
		private function onLoadErrorText(e:IOErrorEvent):void 
		{
			ToastMessage.display(Lang.fileLoadError);
			close();
		}
		
		private function close():void 
		{
			ServiceScreenManager.closeView();
		}
		
		private function onLoadCompleteText(e:Event):void 
		{
			if (loaderData != null && loaderData.data != null && loaderData.data is String)
			{
				var result:Object;
				try
				{
					result = JSON.parse(loaderData.data as String);
				}
				catch (e:Error)
				{
					
				}
				if (result != null && "error" in result && result.error != null)
				{
					ToastMessage.display(result.error as String);
					close();
				}
				else
				{
					onLoadError(null);
				}
			}
			else
			{
				onLoadError(null);
			}
		}
		
		private function finishDownload():void 
		{
			if (loaderData == null)
			{
				return;
			}
			
			var dukascopyFolderPath:String = "temp/";
			var fl:File = File.applicationStorageDirectory.resolvePath(dukascopyFolderPath);
			if (fl.exists == false)
			{
				fl.createDirectory();
			}
			
			var filename:String = "file";
			
			if (urlRequest != null && urlRequest.data != null)
			{
				if ("date_from" in urlRequest.data && "date_to" in urlRequest.data && "duid" in urlRequest.data)
				{
					filename = "report_" + urlRequest.data.date_from + "_" + urlRequest.data.date_to;
				}
				if ("asfile" in urlRequest.data)
				{
					filename += "." + urlRequest.data.asfile;
				}
			}
			
			if (filename == "file" && fileData != null && fileData.title != null && fileData.title != "")
			{
				filename = fileData.title;
			}
			fl = File.applicationStorageDirectory.resolvePath(dukascopyFolderPath + filename);
			if (fl.exists)
			{
				//!TODO:
				var fs:FileStream = new FileStream();
				fs.open(fl, "write");
				fs.writeBytes(loaderData.data);
				fs.close();
			}
			else
			{
				var fs2:FileStream = new FileStream();
				fs2.addEventListener(IOErrorEvent.IO_ERROR, onError);
				fs2.open(fl, "write");
				fs2.writeBytes(loaderData.data);
				fs2.close();
			}
			
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
				try
				{
					fl.openWithDefaultApplication();
				}
				catch (e:Error)
				{
					ToastMessage.display(e.message);
				}
				
			//	var path:String = "file:///" + fl.url;
			//	navigateToURL(new URLRequest(path));
			}
			
			fl = null;
			ServiceScreenManager.closeView();
		}
		
		private function onError(e:IOErrorEvent):void 
		{
			trace("123");
		}
		
		private function onLoadProgress(e:ProgressEvent):void {
			if (preloader != null) {
				if (container.contains(preloader) == true) {
					container.removeChild(preloader);
				}
				preloader.dispose();
				preloader = null;
			}
			if (progressAnimation != null) {
				currentProgress = progressAnimation.current;
				TweenMax.killTweensOf(progressAnimation);
			}
			//TweenMax.killAll(false, true, false);
			progressAnimation = new Object();
			progressAnimation.current = currentProgress;
			progressAnimation.target = e.bytesLoaded / e.bytesTotal;
		//	if (e.bytesTotal > 0)
		//	{
				TweenMax.to(progressAnimation, 1.2, {current:progressAnimation.target, onUpdate:drawProgress, onComplete:onAnimationComplete});
		//	}
			
			drawSize(e.bytesLoaded);
		}
		
		private function onAnimationComplete():void 
		{
			animationCpmplete = true;
			if (loaded == true)
			{
				finishDownload();
			}
		}
		
		private function drawProgress():void 
		{
			if (progressAnimation != null)
			{
				loader.graphics.clear();
				loader.graphics.lineStyle(Config.FINGER_SIZE * .05, 0x6AAAF1, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
				BaseGraphicsUtils.drawCircleSegment(loader.graphics, new Point(0, 0), 0 * Math.PI / 360, progressAnimation.current * 360 * Math.PI / 180, Config.FINGER_SIZE * .25, 1, 1);
			}
		}
		
		private function onLoadError(e:IOErrorEvent):void 
		{
			ToastMessage.display(Lang.fileLoadError);
		}
		
		private function drawSize(value:Number = 0):void 
		{
			if (size.bitmapData != null)
			{
				size.bitmapData.dispose();
				size.bitmapData = null;
			}
			if (fileData != null)
			{
				size.bitmapData = TextUtils.createTextFieldData(TextUtils.toReadbleFileSize(value) + " / " + TextUtils.toReadbleFileSize(fileData.size), (_width - Config.DIALOG_MARGIN * 2) * .5, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, true, 0x4F575E, 0xFFFFFF);
				size.x = int(_width - Config.DIALOG_MARGIN - size.width);
			}
		}
		
		private function drawName():void 
		{
			if (fileData != null)
			{
				fileName.bitmapData = TextUtils.createTextFieldData(fileData.title, _width - Config.DIALOG_MARGIN * 2 - Config.FINGER_SIZE, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, true, 0x4F575E, 0xFFFFFF);
			}
		}
		
		private function drawLabel():void 
		{
			label.bitmapData = TextUtils.createTextFieldData(Lang.downloading, (_width - Config.DIALOG_MARGIN * 2) * .5, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, true, 0x4F575E, 0xFFFFFF);
		}
		
		private function drawIcon():void 
		{
			if (fileData != null)
			{
				var fileNameValue:String = fileData.title;
				if (fileNameValue != null)
				{
					try
					{
						var iconClass:Class = LocalFilesManager.getFileIconClassByName(fileNameValue);
						
						if (iconClass != null)
							icon = new iconClass();
						
						if (icon != null) {
							var iconSize:int = Config.FINGER_SIZE * .35;
							UI.scaleToFit(icon, iconSize, iconSize);
							container.addChild(icon);
						}
					}
					catch (e:Error)
					{
						
					}
				}
			}
		}
		
		private function drawNextButton():void 
		{
			var textSettings_ok:TextFieldSettings = new TextFieldSettings(Lang.textCancel, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap_ok:ImageBitmapData = TextUtils.createbutton(textSettings_ok, Color.GREEN, 1);
			cancelButton.setBitmapData(buttonBitmap_ok, true);
			cancelButton.x = int(_width * .5 - cancelButton.width * .5);
		}
		
		override protected function drawView():void {
			super.drawView();
			view.graphics.clear();
			bg.graphics.clear();
			var position:int = Config.FINGER_SIZE * .4;
			
			if (icon != null)
			{
				icon.x = Config.DIALOG_MARGIN;
				icon.y = position;
			}
			
			fileName.x = Config.DIALOG_MARGIN;
			if (icon != null)
			{
				fileName.x += int(icon.width + Config.MARGIN * 1.5);
			}
			fileName.y = position;
			position += fileName.height + Config.FINGER_SIZE * .4;
			var linePosition:int = position;
			
			if (preloader != null)
			{
				preloader.x = int(_width - Config.DIALOG_MARGIN - Config.FINGER_SIZE * .25);
				preloader.y = int(fileName.y + fileName.height * .5);
			}
			
			position += Config.FINGER_SIZE * .5;
			
			label.x = Config.DIALOG_MARGIN;
			label.y = position;
			
			size.x = int(_width - Config.DIALOG_MARGIN - size.width);
			size.y = position;
			
			position += Math.max(label.height, size.height) + Config.FINGER_SIZE * .5;
			
			cancelButton.y = position;
			position += cancelButton.height + Config.FINGER_SIZE * .3;
			
			
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, 0, _width, position);
			bg.graphics.endFill();
			
			bg.graphics.lineStyle(1, 0xE0EDFA);
			bg.graphics.moveTo(0, linePosition);
			bg.graphics.lineTo(_width, linePosition);
			
			container.y = int(_height * .5 - position * .3);
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			cancelButton.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			cancelButton.deactivate();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (fileName != null)
			{
				UI.destroy(fileName);
				fileName = null;
			}
			if (label != null)
			{
				UI.destroy(label);
				label = null;
			}
			if (size != null)
			{
				UI.destroy(size);
				size = null;
			}
			if (cancelButton != null)
			{
				cancelButton.dispose();
				cancelButton = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (bg != null)
			{
				UI.destroy(bg);
				bg = null;
			}
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
			if (loader != null)
			{
				UI.destroy(loader);
				loader = null;
			}
			
			if (preloader != null)
			{
				preloader.dispose();
				preloader = null;
			}
			if (loaderData != null)
			{
				try
				{
					loaderData.close();
				}
				catch (e:Error)
				{
					
				}
				
				loaderData.removeEventListener(Event.COMPLETE, onLoadComplete);
				loaderData.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				loaderData.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				
				loaderData.removeEventListener(Event.COMPLETE, onLoadCompleteText);
				loaderData.removeEventListener(IOErrorEvent.IO_ERROR, onLoadErrorText);
				
				loaderData = null;
			}
			
			if (progressAnimation != null)
			{
				TweenMax.killTweensOf(progressAnimation);
				progressAnimation = null;
			}
		//	TweenMax.killAll(false, true, false);
			
			fileData = null;
		}
	}
}