package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.textedit.PayMessagePreviewBox;
	import com.dukascopy.connect.gui.textedit.TextComposer;
	import com.dukascopy.connect.screens.dialogs.loader.DotLoader;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Aleksei L
	 */

	public class ScreenAddPuzzleDialog extends ScreenAlertDialog {

		private var labelBitmapAmount:Bitmap;
		private var labelBitmapCurrency:Bitmap;
		private var selectorCurrency:DDFieldButton;
		private var addImageButton:BitmapButton;		
		private var addGalleryButton:BitmapButton;		
		private var iAmount:Input;

		private var pandingBitmap:Bitmap;
		private var paramsObj:Object = {amount:"", currency:"" , message:""};
		
		private var _systemOptionsReady:Boolean = false;

		private var isTempData:Boolean;
		public static var TEMP_DATA:Object;
		private var _hideDotsShowSelect:Boolean;
		private var dotLoader:DotLoader;
		
		
		private var attachmentImageSize:int;
		private var attachmentPreviewBitmap:Bitmap;
		private var emptyAttachmentBitmapData:BitmapData;
		private var currentUploadedImage:ImageBitmapData;
		
		
		
		public function ScreenAddPuzzleDialog() {
			super();
		}

		
		
		override protected function createView():void {
			super.createView();
			
			pandingBitmap = new Bitmap(new BitmapData(100, Config.DOUBLE_MARGIN, true));
			labelBitmapAmount =new Bitmap();
			labelBitmapCurrency =new Bitmap();
			
			iAmount = new Input(Input.MODE_DIGIT_DECIMAL); 
			iAmount.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			
		//	iAmount.setMode(Input.MODE_INPUT);
			iAmount.S_CHANGED.add(onChangeInputValue);			
			iAmount.setRoundBG(false);
			iAmount.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			iAmount.setRoundRectangleRadius(0);
			iAmount.inUse = true;
			
			selectorCurrency = new DDFieldButton(selectCurrency);
			
			// Attachment image preview 
			attachmentImageSize = Config.FINGER_SIZE * 4;
			emptyAttachmentBitmapData = new BitmapData(attachmentImageSize, attachmentImageSize, false, 0xcccccc);
			attachmentPreviewBitmap = new Bitmap();
			
			// add image button
			addImageButton = new BitmapButton();
			addImageButton.setStandartButtonParams();		
			addImageButton.setDownColor(0xFFFFFF);
			addImageButton.tapCallback = onSelectImageClick;
			addImageButton.disposeBitmapOnDestroy = true;
			addImageButton.usePreventOnDown = false;			
			var addImageIcon:SWFAddPuzleImageIcon = new SWFAddPuzleImageIcon();
			
			var iconSize:int = attachmentImageSize*.35;			
			UI.scaleToFit(addImageIcon, iconSize, iconSize);
			addImageButton.setBitmapData(UI.getSnapshot(addImageIcon, StageQuality.HIGH, "ScreenAddPuzzleDialog.addImageIcon"), true);
			addImageIcon = null;
			
			
			//add gallery button 
			
			addGalleryButton = new BitmapButton();
			addGalleryButton.setStandartButtonParams();		
			addGalleryButton.setDownColor(0xFFFFFF);
			addGalleryButton.tapCallback = onSelectGalleryClick;
			addGalleryButton.disposeBitmapOnDestroy = true;
			addGalleryButton.usePreventOnDown = false;			
			var addGalleryIcon:SWFAddPuzleGalleryIcon = new SWFAddPuzleGalleryIcon();
			
			UI.scaleToFit(addGalleryIcon, iconSize, iconSize);
			addGalleryButton.setBitmapData(UI.getSnapshot(addGalleryIcon, StageQuality.HIGH, "ScreenAddPuzzleDialog.addGalleryIcon"), true);
			addGalleryIcon = null;
		}
		
		// On select image Click
		private function onSelectImageClick():void 
		{
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED_PUZZLE.add(onImageSelected);
			PhotoGaleryManager.takeCamera(false, false, PhotoGaleryManager.PUZZLE);
		}
		
		// On select gallery Click
		private function onSelectGalleryClick():void 
		{
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED_PUZZLE.add(onImageSelected);
			PhotoGaleryManager.takeImage(false, false, PhotoGaleryManager.PUZZLE);
		}
		
		private function onImageSelected(success:Boolean, image:ImageBitmapData, message:String):void 
		{
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED_PUZZLE.remove(onImageSelected);
			if (success == true && image != null)
			{
				if (image.width > Config.MAX_UPLOAD_IMAGE_SIZE || image.height > Config.MAX_UPLOAD_IMAGE_SIZE)
					image = ImageManager.resize(image, Config.MAX_UPLOAD_IMAGE_SIZE * 1.5, Config.MAX_UPLOAD_IMAGE_SIZE * 1.5, ImageManager.SCALE_INNER_PROP);
				
				if (currentUploadedImage != null)
				{
					currentUploadedImage.dispose();
					currentUploadedImage = null;
				}
				
				if (paramsObj != null)
				{
					paramsObj.image = new ImageBitmapData("PuzzleImage", image.width, image.height);
					
					paramsObj.image.copyBitmapData(image);
					currentUploadedImage = paramsObj.image;
				}
			}
			checkStateForBtn();
			updatePreview();
			drawView();
		}
		
		private function updatePreview():void
		{
			if (currentUploadedImage != null){
				attachmentPreviewBitmap.bitmapData = currentUploadedImage;
			}else{
				attachmentPreviewBitmap.bitmapData = emptyAttachmentBitmapData;
			}
			
			if(attachmentPreviewBitmap.bitmapData!=null){
				var destScale:Number = UI.getMinScale(attachmentPreviewBitmap.bitmapData.width, attachmentPreviewBitmap.bitmapData.height, _width -Config.DOUBLE_MARGIN*2, _width -Config.DOUBLE_MARGIN*2);
				attachmentPreviewBitmap.scaleX = attachmentPreviewBitmap.scaleY   = destScale;
				attachmentPreviewBitmap.x = (_width - attachmentPreviewBitmap.width) * .5 - Config.DOUBLE_MARGIN;
			}
		}
		
		private function onChangeInputValue():void {
			if (iAmount != null) {
				checkStateForBtn();
			}
		}
		
		
		private function onSystemOptions():void {
			if (PayManager.systemOptions == null){
				showToastMessage();
				onCloseButtonClick();
				return;
			}
			// A esli net paymentov 
			if("currencyList" in PayManager.systemOptions )
			{
				_hideDotsShowSelect = true;
				selectorCurrency.activate();
				var str:String = "";
				for each ( str in PayManager.systemOptions.currencyList) {
					paramsObj.currency = str;
					localSelectCurrency(str);
					_systemOptionsReady = true;
					break;
				}
				recreateContent(vPadding);
				content.updateObjects();
			}else{
				showToastMessage();
				onCloseButtonClick();
			}
		}

		
		/**
		 * show alert
		 */
		private function showToastMessage():void {
			ToastMessage.display(Lang.connectionError);
		}

		private function saveTemp():void {
			TEMP_DATA = data;
			if (iAmount.value != "" || iAmount.value != Lang.textAmount || !isNaN(Number(iAmount.value)) || Number(iAmount.value) != 0) {
				paramsObj.amount = iAmount.value;				
			}			
			TEMP_DATA.amount = paramsObj.amount;
			TEMP_DATA.currency = paramsObj.currency;
			TEMP_DATA.message = paramsObj.message;
			TEMP_DATA.image = paramsObj.image;
		}

		private function selectCurrency(e:Event = null):void {
			// redraw view to full height to prevent soft keyboard view resizing bug
			saveTemp();
			DialogManager.showDialog(ScreenPayDialog, { callback:callBackSelectCurrency, data:PayManager.systemOptions.currencyList, itemClass:ListPayCurrency, label:Lang.selectCurrency } );
			onChangeInputValue();
		}
		

		private function localSelectCurrency(currency:String):void {
			if(selectorCurrency != null){
				selectorCurrency.setValue(currency);
				content.updateObjects();
				selectorCurrency.activate();
			}
		}
		
		
		private function callBackSelectCurrency(currency:String):void {
			if (TEMP_DATA != null) {
				if (currency != null)
					TEMP_DATA.currency = currency;
				DialogManager.showAddPuzzle(null,TEMP_DATA);
				TEMP_DATA = null;
			}
		}
		
		
		
		

		override public function initScreen(data:Object = null):void {
			super.initScreen(data);

		
			var obj :Object = PayManager.systemOptions;
			
			if(obj != null && "currencyList" in obj)
			{
				if(TEMP_DATA != null){
					isTempData = true;
					return;
				}else{
					
				}
				
				_systemOptionsReady = true;				
				var str:String = "";
				for each ( str in obj.currencyList) {
					paramsObj.currency = str;
					break;
				}

			}else{
				
				_systemOptionsReady = false;
				if(PayManager.S_SYSTEM_OPTIONS_READY == null){
					PayManager.S_SYSTEM_OPTIONS_READY = new Signal("PayManager.S_SYSTEM_OPTIONS_READY");
				}
				if(PayManager.S_SYSTEM_OPTIONS_ERROR == null){
					PayManager.S_SYSTEM_OPTIONS_ERROR = new Signal("PayManager.S_SYSTEM_OPTIONS_ERROR");
				}
				PayManager.S_SYSTEM_OPTIONS_READY.add(onSystemOptions);
				PayManager.S_SYSTEM_OPTIONS_ERROR.add(onSystemOptions);

				callBackGetConfig();
			}
			
			paramsObj.amount = data!=null && data.amount || paramsObj.amount;
			paramsObj.currency = data!=null && data.currency || paramsObj.currency;
			paramsObj.message = data != null && data.message || paramsObj.message;
				
			if (data != null && data.image != null && !(data.image as ImageBitmapData).isDisposed){				
				paramsObj.image = data.image;
				currentUploadedImage = paramsObj.image;
			}
			
			if (ChatManager.getCurrentChat() != null)
			{
				paramsObj.chatUID = ChatManager.getCurrentChat().uid;
			}
			
			if(iAmount != null && paramsObj.amount != "" && paramsObj.amount != Lang.textAmount)
			{
				iAmount.value = paramsObj.amount;
			}
			
			if( paramsObj.currency != ""){
				localSelectCurrency(paramsObj.currency);
				_hideDotsShowSelect = true;
			}else{
				if(TEMP_DATA==null || TEMP_DATA.currency== null){
					_hideDotsShowSelect = false;
				}else{
					localSelectCurrency(TEMP_DATA.currency);
					_hideDotsShowSelect = true;
					
				}
			}
			
			//if( paramsObj.message != ""){
				//descriptionBox.textValue = paramsObj.message;
			//}
			
			if (addImageButton != null){
				addImageButton.show();
			}		
			
			if (addGalleryButton != null){
				addGalleryButton.show();
			}		
			
			updatePreview();
			checkStateForBtn();
			recreateContent(vPadding);
		}
		
		private function callBackGetConfig():void
		{
				PayManager.callGetSystemOptions();
		}
		
		override protected function fireCallbackFunctionWithValue(value:int):void {
			var callBackFunction:Function = callback;
			callback = null;
			if(value !=1 ){
				callBackFunction(value, null);
				if (TEMP_DATA != null && "image" in TEMP_DATA && TEMP_DATA.image != null && TEMP_DATA.image is ImageBitmapData)
				{
					(TEMP_DATA.image as ImageBitmapData).dispose();
					TEMP_DATA.image = null;
				}
				
				TEMP_DATA = null;
			}else{
				callBackFunction(value, paramsObj);
				TEMP_DATA = null;
				isTempData = false;
			}
		}

		override protected function getMaxContentHeight():Number {
			return _height - vPadding * 2 - headerHeight - buttonsAreaHeight;
		}

		override protected function drawView():void {
			super.drawView();
			// todo add check for valid input
			recreateContent(vPadding);
		}

		override protected function repositionButtons():void {
			contentBottomPadding = 0;
			super.repositionButtons();
		}

		override protected function updateScrollArea():void {
			if (!content.fitInScrollArea()) {
//				content.scrollToPosition(passInput.view.y - Config.MARGIN);
				content.enable();
			}
			else {
				content.disable();
			}

			content.update();
		}

		override protected function recreateContent(padding:Number):void {
			super.recreateContent(padding);

			var trueWidth:int = int((_width - Config.DOUBLE_MARGIN * 3) * .5);
			if(labelBitmapAmount.bitmapData == null)
				labelBitmapAmount.bitmapData = UI.renderTextShadowed(Lang.textAmount, trueWidth, Config.FINGER_SIZE, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .21,false,0xffffff,0x000000,AppTheme.GREY_MEDIUM,true,1,false);
			if(labelBitmapCurrency.bitmapData == null)
				labelBitmapCurrency.bitmapData = UI.renderTextShadowed(Lang.textCurrency, trueWidth, Config.FINGER_SIZE, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .21,false,0xffffff,0x000000,AppTheme.GREY_MEDIUM,true,1,false);

			content.addObject(labelBitmapAmount);
			content.addObject(labelBitmapCurrency);
			content.addObject(iAmount.view);
			content.addObject(attachmentPreviewBitmap);
			content.addObject(addImageButton);
			content.addObject(addGalleryButton);
			
			
			if(_hideDotsShowSelect){
				content.addObject(selectorCurrency);
				if(dotLoader != null){
					dotLoader.stopAnim();
					content.removeObject(dotLoader);
				}
			}else{
				content.removeObject(selectorCurrency);
				if(dotLoader == null){
					dotLoader = new DotLoader();
					dotLoader.startAnim();
				}
				content.addObject(dotLoader);

			}
			
			content.addObject(pandingBitmap);
	
		
			// Tut pipec kakojto 
			selectorCurrency.setSize(trueWidth - Config.DOUBLE_MARGIN, Config.FINGER_SIZE * .8);
			var xPos:Number = content.view.width - (selectorCurrency.width + Config.MARGIN);
			
			labelBitmapCurrency.x = xPos;			
			labelBitmapAmount.x = Config.MARGIN;
			labelBitmapAmount.y = Config.MARGIN;
			labelBitmapCurrency.y = labelBitmapAmount.y;
				
		
			iAmount.view.x = labelBitmapAmount.x;
			iAmount.view.y = int(labelBitmapAmount.y + labelBitmapAmount.height + Config.MARGIN);
			iAmount.width =  trueWidth - Config.DOUBLE_MARGIN;
			
		
			selectorCurrency.y = iAmount.view.y;
			selectorCurrency.x = xPos;
				
		
		
			if (_hideDotsShowSelect) {
				
			
			}else{
				dotLoader.y = iAmount.view.y + Config.DOUBLE_MARGIN;
				dotLoader.x = xPos;
			}
			
			var realWidth:int = _width - Config.DOUBLE_MARGIN * 2 - Config.MARGIN;
			
			//attachmentPreviewBitmap.bitmapData = new BitmapData();
			attachmentPreviewBitmap.y = selectorCurrency.y +selectorCurrency.height +Config.DOUBLE_MARGIN;			
			var destBtnY:int = attachmentPreviewBitmap.y +attachmentPreviewBitmap.height * .5 -addImageButton.height * .5 ;
			addImageButton.y = Math.max(attachmentPreviewBitmap.y + Config.DOUBLE_MARGIN, destBtnY);
			addImageButton.x = realWidth * .5+Config.MARGIN*2;			
			addGalleryButton.x = realWidth * .5 -addGalleryButton.width - Config.MARGIN*2;
			addGalleryButton.y = addImageButton.y;			
			
			pandingBitmap.y = attachmentPreviewBitmap.y +attachmentPreviewBitmap.height+Config.DOUBLE_MARGIN;

		}


		override protected function updateContentHeight():void {
			contentHeight = (vPadding * 2 + headerHeight + buttonsAreaHeight + content.itemsHeight + Config.DOUBLE_MARGIN);
		}
		

		
		override public function activateScreen():void {
			super.activateScreen();
			iAmount.activate();
			iAmount.S_CHANGED.add(onChangeInputValue);
			if(addImageButton!=null){
				addImageButton.activate();
			}
			
			if(addGalleryButton!=null){
				addGalleryButton.activate();
			}
			//PointerManager.addTap(descriptionBox, onAddMessageClick);
			if(_systemOptionsReady){
				selectorCurrency.activate();
			}
		}
		
		

		override public function deactivateScreen():void {
			super.deactivateScreen();
			//PointerManager.removeTap(descriptionBox, onAddMessageClick);
				
			if (iAmount){
				if (iAmount.value == ""){
					// To force default label to redraw we call this method
					iAmount.forceFocusOut();	
				}
				iAmount.deactivate();
			}
			if(addImageButton!=null){
				addImageButton.deactivate();
			}
			
			if(addGalleryButton!=null){
				addGalleryButton.deactivate();
			}
			if(selectorCurrency)
			{
				selectorCurrency.deactivate();
			}
			iAmount.S_CHANGED.remove(onChangeInputValue);
		}
		private function focusOnInput():void
		{
			iAmount.setFocus();
			iAmount.getTextField().requestSoftKeyboard();
			/*if(iAmount.value == Lang.textAmount){
				iAmount.value ="";
			}*/
		}
		
		
		override protected function btn0Clicked():void {
			if(checkStateForBtn()){
				if (callback != null) {
					fireCallbackFunctionWithValue(1);
				}
				DialogManager.closeDialog();
			}
		}

		
		private function checkStateForBtn():Boolean {
			var isT:Boolean;
			if (isValidDecimal(iAmount.value)){
				iAmount.view.alpha = 1;
				paramsObj.amount = iAmount.value;
			}else{
				isT = true;
				iAmount.view.alpha = .5;
			}
			
			if( paramsObj.currency == ""){
				isT = true;
			}
			if (currentUploadedImage == null){
				isT = true;
			}
			
			if(isT){
				saveTemp();
				if(button0){
					button0.alpha = .5;
					button0.deactivate();
				}
				return false;
			}else{
				if(button0){
					button0.alpha = 1;
					button0.activate();
				}
				return true;
			}
		}
		
		
		
		private function isValidDecimal(numberString:String):Boolean
		{
			if (numberString == "")
				return false;
			
			if (numberString == Lang.textAmount)
				return false;
			if (isNaN(Number(iAmount.value)))
				return false;
				
			if (Number(iAmount.value) == 0)
				return false;
					
			var curVal:String = numberString;			
			var ind:int = curVal.indexOf(".");	
			
			if (ind ==-1){ // Not decimal 
				if (numberString.charAt(0) == '0')
					return false;
					
				return true;
				
			}else{ // Decimal 
				
				var numericPart:String = curVal.slice(0, ind);
				var decimalPart:String = curVal.slice(ind + 1, curVal.length );
				
				if (decimalPart.length > 2){
					return false;
				}
				
				var fullNumber:Number = Number(numericPart);
				var decimalNumber:Number = Number(decimalPart);
				
				if (numericPart.length > 1 && fullNumber==0){
					return false;
				}
				
				if (numericPart.length > 1 && numericPart.charAt(0) == '0'){					
					return false;
				}
				
				if (decimalPart.length > 1 && decimalNumber==0){
					return false;
				}
				
				return true;
			}
		}

		override protected function btn1Clicked():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(2);
			}
			DialogManager.closeDialog();
		}

		override protected function btn2Clicked():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(3);
			}
			DialogManager.closeDialog();
		}

		override protected function onCloseButtonClick():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(0);
			}
			DialogManager.closeDialog();
		}

		override public function dispose():void {
			super.dispose();
			if(PayManager.S_SYSTEM_OPTIONS_READY != null)
				PayManager.S_SYSTEM_OPTIONS_READY.remove(onSystemOptions);
			if(PayManager.S_SYSTEM_OPTIONS_ERROR != null)
				PayManager.S_SYSTEM_OPTIONS_ERROR.remove(onSystemOptions);
			
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED_PUZZLE.remove(onImageSelected);
			
			currentUploadedImage = null;
			
			if(dotLoader){
				dotLoader.dispose();
				dotLoader = null;
			}
			
			if(isTempData) {
				TEMP_DATA = null;
			}
			
			if (addImageButton != null){
				addImageButton.dispose();
				addImageButton = null;
			}
			
			if (addGalleryButton != null){
				addGalleryButton.dispose();
				addGalleryButton = null;
			}

			if (pandingBitmap){
				UI.destroy(pandingBitmap);
				pandingBitmap = null;
			}

			if (labelBitmapAmount) {
				UI.destroy(labelBitmapAmount);
				labelBitmapAmount = null;
			}	
			
			if (attachmentPreviewBitmap) {
				attachmentPreviewBitmap.bitmapData = null;
				UI.destroy(attachmentPreviewBitmap);
				attachmentPreviewBitmap = null;
			}

			if (labelBitmapCurrency) {
				UI.destroy(labelBitmapCurrency);
				labelBitmapCurrency = null;
			}
			

			if (selectorCurrency != null) {
				selectorCurrency.dispose();
				selectorCurrency = null;
			}
			if (iAmount)
				iAmount.deactivate();
		}
	}
}