package com.dukascopy.connect.screens.dialogs {
	
	import assets.MinimizeIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.ProgressBar;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.localFiles.LoadFileData;
	import com.dukascopy.connect.sys.localFiles.LocalFilesManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.LocalFileStatus;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ScreenLoadingDialog extends PopupDialogBase {
		
		public const BUTTONS_NO_LAYOUT:int = 0;
		public const BUTTONS_HORIZONTAL:int = 1;
		public const BUTTONS_VERTICAL:int = 2;
		
		static public const LOADING:String = "loading";
		static public const READY:String = "ready";
		static public const ERROR:String = "error";
		static public const SAVING:String = "saving";
		
		protected var currentLayout:int = 0;
		
		protected var button0:RoundedButton;
		protected var button1:RoundedButton;
		protected var button2:BitmapButton;
		
		protected var content:ScrollPanel;
		
		protected var callback:Function;
		protected var btnsCount:int;
		protected var buttons:Array;
		private var fileIcon:Bitmap;
		private var fileSize:Bitmap;
		private var fileName:Bitmap;
		private var progressBar:ProgressBar;
		private var percentLoaded:TextField;
		private var currentFileLoadProgress:Number = 0;
		private var _loadStatus:String;
		private var fileIconContainer:Sprite;
		private var fileNameContainer:Sprite;
		private var fileSizeContainer:Sprite;
		private var percentLoadedContainer:Sprite;
		private var progressBarContainer:Sprite;
		protected var contentBottomPadding:Number;
		protected var realContentHeight:Number;
		protected var buttonsAreaHeight:Number;
		
		public function ScreenLoadingDialog() {
			
			super();
		}
		
		override protected function getCloseButtonIcon():Sprite 
		{
			return new MinimizeIcon();
		}
		
		override public function onBack(e:Event = null):void
		{
			if (callback != null) {	
				fireCallbackFunctionWithValue(0);
			}
		}
		
		override protected function createView():void {
			super.createView();
			
			content = new ScrollPanel();
			content.backgroundColor = MainColors.WHITE;
			
			btnsCount = 1;						
			container.addChild(content.view);
			
			fileIcon = new Bitmap();
			fileIconContainer = new Sprite();
			fileIconContainer.addChild(fileIcon);
			content.addObject(fileIconContainer);
			
			fileName = new Bitmap();
			fileNameContainer = new Sprite();
			fileNameContainer.addChild(fileName);
			content.addObject(fileNameContainer);
			
			fileSize = new Bitmap();
			fileSizeContainer = new Sprite();
			fileSizeContainer.addChild(fileSize);
			content.addObject(fileSizeContainer);
			
			percentLoaded = UIFactory.createTextField(Config.FINGER_SIZE * .30, true);
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = AppTheme.RED_MEDIUM;
			percentLoaded.defaultTextFormat = textFormat;
			percentLoaded.autoSize = TextFieldAutoSize.LEFT;
			percentLoaded.multiline = false;
			percentLoaded.wordWrap = false;
			percentLoaded.text = "0%";
			percentLoadedContainer = new Sprite();
			percentLoadedContainer.addChild(percentLoaded);
			content.addObject(percentLoadedContainer);
			
			progressBar = new ProgressBar(AppTheme.GREY_MEDIUM, AppTheme.RED_MEDIUM);
			progressBarContainer = new Sprite();
			progressBarContainer.addChild(progressBar);
			content.addObject(progressBarContainer);
			
			_view.addChild(container);
		}
		
		override protected function onCloseButtonClick():void 
		{
			if (callback != null) {	
				fireCallbackFunctionWithValue(0);
			}
			DialogManager.closeDialog();
		}
		
		protected function fireCallbackFunctionWithValue(value:int):void 
		{
			var callBackFunction:Function = callback;
			callback = null;
			callBackFunction(value);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			callback = data.callBack;
			
			if (!("fileName" in data) || !data.fileName)
				data.fileName = Lang.textFile;
			
			data.buttonOk = Lang.textCancel.toUpperCase();
			
			buttons = new Array();
			
			createFirstButton();
			createSecondButton();
			createThirdButton();
			
			updateFileStatus();
		}
		
		private function updateFileStatus():void 
		{
			var fileStatus:String = LocalFilesManager.getFileStatus(data.fileId, data.fileName);
			
			if(fileStatus == LocalFileStatus.NOT_FOUND)
			{
				currentFileLoadProgress = 0;
				startLoadFile();
				loadStatus = LOADING;
			}
			else if (fileStatus == LocalFileStatus.LOADED)
			{
				loadStatus = READY;
			}
			else if (fileStatus == LocalFileStatus.LOAD_ERROR)
			{
				loadStatus = ERROR;
			}
		}
		
		private function createFirstButton():void 
		{
			var okButtonText:String = Lang.ok;
			if (data.buttonOk)
			{
				okButtonText = data.buttonOk.toUpperCase();
			}
			
			button0  = new RoundedButton(okButtonText, MainColors.RED, MainColors.RED_DARK, null);
			button0.setStandartButtonParams();
			button0.setDownScale(1);
			button0.cancelOnVerticalMovement = true;
			button0.tapCallback = btn0Clicked;
			_view.addChild(button0);
			buttons.push(button0);
		}
		
		private function startLoadFile():void 
		{
			LocalFilesManager.S_FILE_LOAD_STATUS.add(onFileLoadStatus);
			LocalFilesManager.loadFile(data.fileId, data.fileName);
		}
		
		private function onFileLoadStatus(fileStatus:LoadFileData):void 
		{
			if (isDisposed)
			{
				LocalFilesManager.S_FILE_LOAD_STATUS.remove(onFileLoadStatus);
				return;
			}
			
			if (!data || !data.fileId || data.fileId != fileStatus.fileId)
			{
				return;
			}
			
			if (fileStatus.status == LocalFileStatus.FILE_SIZE)
			{
				data.fileSize = fileStatus.data;
				var fileSizeBitmapData:BitmapData = TextUtils.createTextFieldData(TextUtils.toReadbleFileSize(fileStatus.data.toString()), 
																				_width - padding * 3 - fileIcon.width, 
																				10, true, 
																				TextFormatAlign.LEFT, 
																				TextFieldAutoSize.LEFT, 
																				Config.FINGER_SIZE * .3, 
																				true, 
																				AppTheme.GREY_MEDIUM,
																				MainColors.WHITE, 
																				true, false, false);
				
				fileSize.bitmapData = fileSizeBitmapData;
				fileSizeContainer.x = _width - padding * 2 - fileSize.width - 4;
				fileSizeContainer.y = progressBarContainer.y - fileSize.height - Config.MARGIN - 4;
				fileSizeBitmapData = null;
			}
			else if (fileStatus.status == LocalFileStatus.PROGRESS)
			{
				if (Number(fileStatus.data) == 100)
				{
					loadStatus = SAVING;
				}
				else {
					percentLoaded.text = fileStatus.data + "%";
					progressBar.setProgress(int(fileStatus.data));
				}
			}
			else if (fileStatus.status == LocalFileStatus.LOADED)
			{
				LocalFilesManager.S_FILE_LOAD_STATUS.remove(onFileLoadStatus);
				loadStatus = READY;
			}
			else if (fileStatus.status == LocalFileStatus.LOAD_ERROR)
			{
				loadStatus = ERROR;
			}
		}
		
		private function createSecondButton():void 
		{
			if (data.buttonSecond != null) {
				// CANCEL Button						
					button1  = new RoundedButton(data.buttonSecond.toUpperCase(), MainColors.BLUE_LIGHT, MainColors.BLUE_MEDIUM, null);
					button1.setStandartButtonParams();
					button1.setDownScale(1);
					button1.cancelOnVerticalMovement = true;
					button1.tapCallback = btn1Clicked;
					_view.addChild(button1);
				buttons.push(button1);
				btnsCount++;
			}
		}
		
		protected function createThirdButton():void 
		{
			if (data.buttonThird != null) {									
					button2  = new RoundedButton(data.buttonThird.toUpperCase(), MainColors.BLUE_LIGHT, MainColors.BLUE_MEDIUM, null);
					button2.setStandartButtonParams();
					button2.setDownScale(1);
					button2.cancelOnVerticalMovement = true;
					button2.tapCallback = btn2Clicked;
					_view.addChild(button2);
				buttons.push(button2);
				btnsCount++;
			}
		}
		
		override protected function drawView():void {
			super.drawView();
			
			if (!data)
			{
				return;
			}
			
			currentLayout = BUTTONS_NO_LAYOUT;
			resizeButtons(currentLayout);
			
			updateButtonsAreaHeight();
			
			content.view.y = positionDrawing + padding;
			content.view.x = padding;
			
			clearBitmaps();
			
			var fileIconClass:Class = LocalFilesManager.getFileIconClassByName(data.fileName);
			if (fileIconClass)
			{
				try
				{
					var fileIconInstance:Sprite = new fileIconClass();
					if (fileIconInstance)
					{
						UI.scaleToFit(fileIconInstance, Config.FINGER_SIZE, Config.FINGER_SIZE);
						fileIcon.bitmapData = UI.getSnapshot(fileIconInstance, StageQuality.HIGH, "ScreenLoadingDialog.fileIcon");
						UI.destroy(fileIconInstance);
						fileIconInstance = null;
					}
				}
				catch (e:Error)
				{
					
				}
			}
			
			var filenameBitmapData:BitmapData = TextUtils.createTextFieldData(data.fileName, 
																				_width - padding * 3 - fileIcon.width, 
																				10, true, 
																				TextFormatAlign.LEFT, 
																				TextFieldAutoSize.LEFT, 
																				Config.FINGER_SIZE * .3, 
																				true, 
																				MainColors.DARK_BLUE,
																				MainColors.WHITE, 
																				true, false, false);
			
			fileName.bitmapData = filenameBitmapData;
			filenameBitmapData = null;
			
			//!TODO: type of filesize?;
			if (("fileSize" in data))
			{
				var fileSizeBitmapData:BitmapData = TextUtils.createTextFieldData(TextUtils.toReadbleFileSize(data.fileSize.toString()), 
																				_width - padding * 3 - fileIcon.width, 
																				10, true, 
																				TextFormatAlign.LEFT, 
																				TextFieldAutoSize.LEFT, 
																				Config.FINGER_SIZE * .3, 
																				true, 
																				AppTheme.GREY_MEDIUM,
																				MainColors.WHITE, 
																				true, false, false);
			
				fileSize.bitmapData = fileSizeBitmapData;
				fileSizeBitmapData = null;
			}
			
			fileIconContainer.x = 0;
			fileIconContainer.y = 0;
			
			percentLoaded.text = currentFileLoadProgress.toString() + "%";
			
			fileNameContainer.x = fileIconContainer.x + fileIcon.width + padding;
			fileNameContainer.y = fileIconContainer.y;
			
			if (loadStatus == READY)
			{
				button0.setValue(Lang.textOpen);
				percentLoaded.visible = false;
				progressBar.visible = false;
			}
			else if (loadStatus == LOADING)
			{
				button0.setValue(Lang.textCancel);
				percentLoaded.visible = true;
				progressBar.visible = true;
			}
			else if (loadStatus == ERROR)
			{
				button0.setValue(Lang.textClose);
			//	percentLoaded.visible = false;
				percentLoaded.text = Lang.fileLoadError;
				progressBar.visible = false;
			}
			else if (loadStatus == SAVING)
			{
				percentLoaded.text = Lang.textSaving +"...";
			}
			
			percentLoadedContainer.x = int((_width - padding*2) * .5 - percentLoaded.width * .5);
			percentLoadedContainer.y = int(Math.max(fileNameContainer.y + fileName.height, fileIconContainer.y + fileIcon.height) + padding);
			
			progressBar.setSize(_width - padding * 2, Config.FINGER_SIZE*.1);
			progressBar.setProgress(currentFileLoadProgress);
			
			progressBarContainer.x = 0;
			progressBarContainer.y = percentLoadedContainer.y + percentLoaded.height + Config.MARGIN;
			
			fileSizeContainer.x = _width - padding * 2 - fileSize.width - 4;
			fileSizeContainer.y = progressBarContainer.y - fileSize.height - Config.MARGIN - 4;
			
			var maxContentHeight:int = getMaxContentHeight();
			
			realContentHeight = Math.min(content.itemsHeight + 1, maxContentHeight);
			
			content.setWidthAndHeight(_width - padding * 2, realContentHeight, false);
			
			updateContentHeight();
			
			updateBack();
			updateScrollArea();
			contentBottomPadding = padding;
			repositionButtons();
		}
		
		private function clearBitmaps():void 
		{
			if (fileIcon && fileIcon.bitmapData)
			{
				UI.disposeBMD(fileIcon.bitmapData);
				fileIcon.bitmapData = null;
			}
			
			if (fileName && fileName.bitmapData)
			{
				UI.disposeBMD(fileName.bitmapData);
				fileName.bitmapData = null;
			}
			
			if (fileSize && fileSize.bitmapData)
			{
				UI.disposeBMD(fileSize.bitmapData);
				fileSize.bitmapData = null;
			}
		}
		
		protected function updateScrollArea():void 
		{
			if (!content.fitInScrollArea())
			{
				content.enable();
			}
			else {
				content.disable();
			}
			content.update();
		}
		
		protected function updateContentHeight():void 
		{
			contentHeight = (padding * 3 + headerHeight + buttonsAreaHeight + content.itemsHeight);
		}
		
		protected function updateButtonsAreaHeight():void 
		{
			buttonsAreaHeight = 0;
			if (currentLayout == BUTTONS_HORIZONTAL)
			{
				buttonsAreaHeight = button0.getHeight();
			}
			else if(currentLayout == BUTTONS_VERTICAL){
				buttonsAreaHeight = button0.getHeight() * btnsCount + padding * (btnsCount - 1);
			}
		}
		
		override protected function getMaxContentHeight():Number 
		{
			return _height - padding * 3 - headerHeight - buttonsAreaHeight;
		}
		
		protected function repositionButtons():void 
		{
			var position:int = 0;
			
			var buttonsAreaWidth:int = 0;
			
			var i:int = 0;
			
			var buttonsPadding:int = Config.MARGIN*1.6;
			
			for (i = 0; i < btnsCount; i++ )
			{
				buttonsAreaWidth += (buttons[i] as RoundedButton).getWidth();
			}
			buttonsAreaWidth += buttonsPadding * (btnsCount - 1);
			
			if (currentLayout == BUTTONS_HORIZONTAL)
			{
				for (i = btnsCount - 1; i >= 0 ; i-- )
				{
					(buttons[i] as RoundedButton).y = (container.y + content.view.y + realContentHeight + contentBottomPadding);
					(buttons[i] as RoundedButton).x = int((i == btnsCount - 1)?(_width * .5 - buttonsAreaWidth * .5):((buttons[i + 1] as RoundedButton).x + (buttons[i + 1] as RoundedButton).getWidth()) + buttonsPadding);
				}
			}
			else if (currentLayout == BUTTONS_VERTICAL)
			{
				for (i = btnsCount - 1; i >= 0 ; i-- )
				{
					(buttons[i] as RoundedButton).x = int(_width * .5 - (buttons[i] as RoundedButton).getWidth() * .5);
					(buttons[i] as RoundedButton).y = int((i == btnsCount - 1)?
												(container.y + content.view.y + content.height + contentBottomPadding):
												((buttons[i + 1] as RoundedButton).y + (buttons[i + 1] as RoundedButton).getHeight() + buttonsPadding));
				}
			}
		}
		
		private function resizeButtons(layout:int):void 
		{
			if (layout == BUTTONS_NO_LAYOUT)
			{
				layout = BUTTONS_HORIZONTAL;
			}
			currentLayout = layout;
			
			var buttonsPadding:int = Config.MARGIN*1.6;
			
			var maxButtonWidth:int;
			var maxButtonsAreaWidth:int = (_width - buttonsPadding * (btnsCount - 1) - padding * 2);
			
			if (currentLayout == BUTTONS_HORIZONTAL)
			{
				maxButtonWidth = maxButtonsAreaWidth / btnsCount;
			}
			else if (currentLayout == BUTTONS_VERTICAL)
			{
				maxButtonWidth = maxButtonsAreaWidth;
			}
			
			if (button0)
				button0.setSizeLimits(Config.FINGER_SIZE * 3.5, maxButtonWidth);
			if (button1)
				button1.setSizeLimits(Config.FINGER_SIZE * 3.5, maxButtonWidth);
			if (button2 && button2 is RoundedButton)
				(button2 as RoundedButton).setSizeLimits(Config.FINGER_SIZE * 3.5, maxButtonWidth);
			
			var isTextCropped:Boolean = false;
			
			var i:int = 0;
			
			for (i = 0; i < btnsCount; i++ )
			{
				isTextCropped = isTextCropped?true:(buttons[i] as RoundedButton).isTextCropped();
			}
			
			if (isTextCropped && currentLayout == BUTTONS_HORIZONTAL)
			{
				currentLayout = BUTTONS_VERTICAL;
				
				resizeButtons(currentLayout);
			}
			else
			{
				maxButtonWidth = 0;
				for (i = 0; i < btnsCount; i++ )
				{
					(buttons[i] as RoundedButton).draw();
					maxButtonWidth = Math.max(maxButtonWidth, Math.ceil((buttons[i] as RoundedButton).getWidth()));
				}
				for (i = 0; i < btnsCount; i++ )
				{
					(buttons[i] as RoundedButton).setSizeLimits(maxButtonWidth, maxButtonWidth);
					(buttons[i] as RoundedButton).draw();
				}
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (!content.fitInScrollArea())
			{
				content.enable();
			}
			else {
				content.disable();
			}
			button0.activate();
			if (button1!=null) {
				button1.activate();
			}
			if (button2!=null) {
				button2.activate();
			}
			updateFileStatus();
		}
		
		override public function deactivateScreen():void {
			if (isDisposed) return;
			super.deactivateScreen();
			
			content.disable();
			button0.deactivate();
			if (button1!=null) {
				button1.deactivate();
			}
			if (button2!=null) {
				button2.deactivate();
			}
			LocalFilesManager.S_FILE_LOAD_STATUS.remove(onFileLoadStatus);
		}
		
		protected function btn0Clicked():void 
		{
			if (loadStatus == READY)
			{
				//open file;
				var fileLink:String = LocalFilesManager.getFileByName(data.fileId, data.fileName);
				if (fileLink)
				{
					navigateToURL(new URLRequest(fileLink));
				}
			}
			else if (loadStatus == LOADING)
			{
				//cancel loading;
				LocalFilesManager.cancelLoadFile(data.fileId);
			}
			
			if (callback != null) {
				fireCallbackFunctionWithValue(1);
			}
			DialogManager.closeDialog();
		}
		
		protected function btn1Clicked():void 
		{
			if (callback != null) {
				fireCallbackFunctionWithValue(2);
			}
			DialogManager.closeDialog();
		}
		
		protected function btn2Clicked():void 
		{
			if (callback != null) {				
				fireCallbackFunctionWithValue(3);
			}
			DialogManager.closeDialog();
		}
		
		override public function dispose():void {
			if (isDisposed) return;
			super.dispose();
			
			if (button0 != null) {
				button0.dispose();
				button0 = 	null;
			}
			
			if (button1 != null) {
				button1.dispose();
				button1 = 	null;
			}
			
			if (button2 != null) {
				button2.dispose();
				button2 = 	null;
			}
			
			callback = null;
			buttons = null;
			
			if (fileIcon)
			{
				UI.destroy(fileIcon);
				fileIcon = null;
			}
			
			if (fileSize)
			{
				UI.destroy(fileSize);
				fileSize = null;
			}
			
			if (fileName)
			{
				UI.destroy(fileName);
				fileName = null;
			}
			
			if (progressBar)
			{
				progressBar.dispose();
				progressBar = null;
			}
			
			if (percentLoaded)
			{
				percentLoaded.text = "";
				percentLoaded = null;
			}
			
			if (fileIconContainer)
			{
				UI.destroy(fileIconContainer);
				fileIconContainer = null;
			}
			if (fileNameContainer)
			{
				UI.destroy(fileNameContainer);
				fileNameContainer = null;
			}
			if (fileSizeContainer)
			{
				UI.destroy(fileSizeContainer);
				fileSizeContainer = null;
			}
			
			if (percentLoadedContainer)
			{
				UI.destroy(percentLoadedContainer);
				percentLoadedContainer = null;
			}
			if (progressBarContainer)
			{
				UI.destroy(progressBarContainer);
				progressBarContainer = null;
			}
			
			content.dispose();
			
			callback = null;
		}
		
		public function set loadStatus(value:String):void 
		{
			var needUpdate:Boolean = false;
			if (!_loadStatus)
			{
				needUpdate = true;
			}
			else if (_loadStatus != value)
			{
				needUpdate = true;
			}
			_loadStatus = value;
			if (needUpdate)
			{
				redraw();
			}
		}
		
		public function get loadStatus():String 
		{
			return _loadStatus;
		}
		
		private function redraw():void 
		{
			drawView();
		}
	}
}