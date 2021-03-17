package com.dukascopy.connect.screens.dialogs.paidChat
{
	import assets.PhotoShotIcon;
	import assets.replacePhotoIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.paidChat.PaidChatData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.TakeGalleryAction;
	import com.dukascopy.connect.data.screenAction.customActions.TakePhotoAction;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.serviceScreen.BottomMenuScreen;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class CreatePaidChatPopup extends BaseScreen
	{
		protected var container:Sprite;
		private var bg:Shape;
		private var acceptButton:BitmapButton;
		private var backButton:BitmapButton;
		private var scroll:ScrollPanel;
		private var componentsWidth:Number;
		private var photoSection:Sprite;
		private var addPhotoButton:BitmapButton;
		private var replacePhotoButton:BitmapButton;
		private var smallText:int;
		private var titleName:Bitmap;
		private var titleDescription:Bitmap;
		private var titleCost:Bitmap;
		private var inputName:InputField;
		private var inputDescription:InputField;
		private var inputCost:InputField;
		private var scrollStart:Sprite;
		private var loadedPhoto:Bitmap;
		private var photoLoader:CirclePreloader;
		private var horizontalLoader:HorizontalPreloader;
		private var currentRequest:PaidChatData;
		private var currentPhotoId:String;
		private var locked:Boolean;
		private var photo:TakePhotoAction;
		private var gallery:TakeGalleryAction;
		
		public function CreatePaidChatPopup()
		{
		
		}
		
		override protected function createView():void
		{
			super.createView();
			container = new Sprite();
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			var round:int = Config.FINGER_SIZE * .3;
			var round3:int = round * 3;
			bg.graphics.drawRect(0, 0, round3, round3);
			bg.scale9Grid = new Rectangle(round, round, round, round);
			container.addChild(bg);
			
			scroll = new ScrollPanel();
			container.addChild(scroll.view);
			
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.setDownScale(1);
			acceptButton.setDownColor(0);
			acceptButton.tapCallback = nextClick;
			acceptButton.disposeBitmapOnDestroy = true;
			acceptButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(acceptButton);
			
			photoSection = new Sprite();
			container.addChild(photoSection);
			
			loadedPhoto = new Bitmap();
			photoSection.addChild(loadedPhoto);
			
			addPhotoButton = new BitmapButton();
			addPhotoButton.setStandartButtonParams();
			addPhotoButton.setDownScale(1);
			addPhotoButton.setDownColor(0);
			addPhotoButton.tapCallback = addPhotoClick;
			addPhotoButton.disposeBitmapOnDestroy = true;
			addPhotoButton.setOverlay(HitZoneType.CIRCLE);
			addPhotoButton.setOverlayPadding(Config.FINGER_SIZE * .4);
			container.addChild(addPhotoButton);
			
			replacePhotoButton = new BitmapButton();
			replacePhotoButton.setStandartButtonParams();
			replacePhotoButton.setDownScale(1);
			replacePhotoButton.setDownColor(0);
			replacePhotoButton.tapCallback = addPhotoClick;
			replacePhotoButton.disposeBitmapOnDestroy = true;
			replacePhotoButton.setOverlay(HitZoneType.CIRCLE);
			replacePhotoButton.setOverlayPadding(Config.FINGER_SIZE * .1);
			container.addChild(replacePhotoButton);
			
			replacePhotoButton.visible = false;
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			inputName = new InputField(-1, Input.MODE_INPUT);
			inputName.onChangedFunction = titleChanged;
			scroll.addObject(inputName);
			
			inputDescription = new InputField(-1, Input.MODE_INPUT);
			scroll.addObject(inputDescription);
			
			inputCost = new InputField();
			scroll.addObject(inputCost);
			
			titleName = new Bitmap();
			scroll.addObject(titleName);
			
			titleDescription = new Bitmap();
			scroll.addObject(titleDescription);
			
			titleCost = new Bitmap();
			scroll.addObject(titleCost);
			
			horizontalLoader = new HorizontalPreloader(0x007CA6);
			container.addChild(horizontalLoader);
			
			_view.addChild(container);
			
			scrollStart = new Sprite();
			scroll.addObject(scrollStart);
			scrollStart.graphics.beginFill(0xFFFFFF);
			scrollStart.graphics.drawRect(0, 0, 1, 1);
			scrollStart.graphics.endFill();
		}
		
		private function titleChanged():void
		{
			inputName.valid();
		}
		
		private function addPhotoClick():void
		{
			if (locked == true)
			{
				return;
			}
			
			removeActions();
			
			var actions:Vector.<IScreenAction> = new Vector.<IScreenAction>();
			
			photo = new TakePhotoAction();
			photo.getSuccessSignal().add(onPhotoReady);
			photo.getFailSignal().add(onPhotoFail);
			photo.setData(Lang.makePhoto);
			
			gallery = new TakeGalleryAction();
			gallery.getSuccessSignal().add(onPhotoReady);
			gallery.getFailSignal().add(onPhotoFail);
			gallery.setData(Lang.photoGallery);
			
			actions.push(photo);
			actions.push(gallery);
			
			DialogManager.showDialog(BottomMenuScreen, actions);
		}
		
		private function removeActions():void 
		{
			if (photo != null)
			{
				if (photo.getSuccessSignal() != null)
				{
					photo.getSuccessSignal().remove(onPhotoReady);
				}
				if (photo.getFailSignal() != null)
				{
					photo.getFailSignal().remove(onPhotoFail);
				}
				
				photo.dispose();
			}
			
			if (gallery != null)
			{
				if (gallery.getSuccessSignal() != null)
				{
					gallery.getSuccessSignal().remove(onPhotoReady);
				}
				if (gallery.getFailSignal() != null)
				{
					gallery.getFailSignal().remove(onPhotoFail);
				}
				
				gallery.dispose();
			}
		}
		
		private function onPhotoFail(failData:Object = null):void
		{
			if (failData != null && failData is String)
			{
				ToastMessage.display(failData as String);
			}
		}
		
		private function onPhotoReady(imageId:String):void
		{
			addPhotoButton.visible = false;
			addPhotoLoader();
			
			loadImage(imageId);
		}
		
		private function addPhotoLoader():void 
		{
			if (photoLoader == null)
			{
				photoLoader = new CirclePreloader();
				container.addChild(photoLoader);
				photoLoader.x = int(_width * .5);
				photoLoader.y = int(photoSection.y + photoSection.height * .5);
			}
		}
		
		private function loadImage(imageId:String):void
		{
			if (isDisposed)
			{
				return;
			}
			currentPhotoId = imageId;
			ImageManager.loadImage(Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + imageId, onPhotoLoaded);
		}
		
		private function onPhotoLoaded(success:Boolean, image:ImageBitmapData):void
		{
			if (isDisposed)
			{
				return;
			}
			
			removePhotoLoader();
			
			if (success == true)
			{
				showPhoto(image);
				
				replacePhotoButton.visible = true;
				if (isActivated == true)
				{
					replacePhotoButton.activate();
				}
			}
			else
			{
				addPhotoButton.visible = true;
				if (isActivated == true)
				{
					addPhotoButton.activate();
				}
			}
		}
		
		private function showPhoto(image:ImageBitmapData):void 
		{
			if (loadedPhoto.bitmapData != null)
			{
				loadedPhoto.bitmapData.dispose();
				loadedPhoto.bitmapData = null;
			}
			
			loadedPhoto.bitmapData = image;
			loadedPhoto.smoothing = true;
			var sectionHeight:int = _width * 0.76;
			loadedPhoto.width = _width;
			loadedPhoto.height = sectionHeight;
			
			loadedPhoto.alpha = 0;
			TweenMax.to(loadedPhoto, 0.3, {alpha: 1});
		}
		
		private function removePhotoLoader():void 
		{
			if (photoLoader != null && container != null)
			{
				if (container.contains(photoLoader))
				{
					photoLoader.dispose();
					container.removeChild(photoLoader);
					photoLoader = null;
				}
			}
		}
		
		override public function onBack(e:Event = null):void
		{
			ServiceScreenManager.closeView();
		}
		
		private function backClick():void
		{
			onBack();
		}
		
		private function nextClick():void
		{
			if (locked == true)
			{
				return;
			}
			
			SoftKeyboard.closeKeyboard();
			
			var dataReady:Boolean = true;
			
			if (inputName.valueString == null || inputName.valueString == "")
			{
				inputName.invalid();
				ToastMessage.display(Lang.pleaseAddTitle);
				dataReady = false;
			}
			
			if (inputCost.value == 0)
			{
				inputCost.invalid();
				ToastMessage.display(Lang.pleaseSetChatCost);
				dataReady = false;
			}
			
			if (dataReady == true)
			{
				makeRequest();
			}
		}
		
		private function makeRequest():void
		{
			showLoader();
			lock();
			
			currentRequest = new PaidChatData();
			currentRequest.currency = TypeCurrency.DCO;
			currentRequest.cost = inputCost.value;
			currentRequest.title = inputName.valueString;
			currentRequest.description = inputDescription.valueString;
			currentRequest.photo = currentPhotoId;
			
			Shop.S_MY_PAID_CHAT_UPDATE.add(onStatusChanged);
			Shop.applyPaidChat(currentRequest);
		}
		
		private function showLoader():void
		{
			horizontalLoader.y = photoSection.y + photoSection.height;
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			horizontalLoader.start();
		}
		
		private function onStatusChanged():void
		{
			Shop.S_MY_PAID_CHAT_UPDATE.remove(onStatusChanged);
			
			if (isDisposed)
			{
				return;
			}
			
			horizontalLoader.stop();
			
			unlock();
			
			if (Shop.getMyPaidChatData() != null)
			{
				ServiceScreenManager.closeView();
			}
		}
		
		private function lock():void
		{
			locked = true;
		}
		
		private function unlock():void
		{
			locked = false;
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			smallText = Config.FINGER_SIZE * .28;
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			drawAcceptButton(Lang.textOk);
			acceptButton.deactivate();
			drawBackButton();
			drawPhotoSection();
			drawAddPhotoButton();
			drawTitleName();
			drawTitleDescription();
			drawTitleCost();
			drawInputs();
			drawReplacePhotoButton();
		}
		
		private function drawReplacePhotoButton():void
		{
			var icon:Sprite = new replacePhotoIcon();
			UI.scaleToFit(icon, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
			replacePhotoButton.setBitmapData(UI.getSnapshot(icon), true);
			replacePhotoButton.setOverflow(Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
		}
		
		private function drawInputs():void
		{
			var itemWidth:int = _width - Config.DIALOG_MARGIN * 2;
			
			inputName.draw(itemWidth, null, NaN, null, null);
			inputDescription.draw(itemWidth, null, NaN, null, null);
			inputCost.draw(itemWidth, null, 1, null, Lang[TypeCurrency.DCO]);
		}
		
		private function drawTitleName():void
		{
			titleName.bitmapData = TextUtils.createTextFieldData("+ " + Lang.addTitle, _width - Config.DIALOG_MARGIN * 2, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, smallText, false, 0x4C5762);
		}
		
		private function drawTitleDescription():void
		{
			titleDescription.bitmapData = TextUtils.createTextFieldData("+ " + Lang.addDescription, _width - Config.DIALOG_MARGIN * 2, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, smallText, false, 0x4C5762);
		}
		
		private function drawTitleCost():void
		{
			titleCost.bitmapData = TextUtils.createTextFieldData("+ " + Lang.addChatCost, _width - Config.DIALOG_MARGIN * 2, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, smallText, false, 0x4C5762);
		}
		
		private function drawAddPhotoButton():void
		{
			var clip:Sprite = new Sprite();
			var icon:Sprite = new PhotoShotIcon();
			UI.colorize(icon, 0xFFFFFF);
			var iconSize:int = Config.FINGER_SIZE * .86;
			UI.scaleToFit(icon, iconSize, iconSize);
			var text:BitmapData = TextUtils.createTextFieldData("+ " + Lang.addPhoto, Config.FINGER_SIZE * 2, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, smallText, true, 0xFFFFFF);
			var finalBD:ImageBitmapData = new ImageBitmapData("addPhotoButton", Math.max(Math.ceil(icon.width), Math.ceil(text.width)), int(icon.height + text.height + Config.FINGER_SIZE * .3));
			var iconBD:ImageBitmapData = UI.getSnapshot(icon);
			finalBD.copyPixels(iconBD, iconBD.rect, new Point(int(finalBD.width * .5 - iconBD.width * .5), 0));
			finalBD.copyPixels(text, text.rect, new Point(int(finalBD.width * .5 - text.width * .5), int(finalBD.height - text.height)));
			
			iconBD.dispose();
			text.dispose();
			iconBD = null;
			text = null;
			
			addPhotoButton.setBitmapData(finalBD, true);
		}
		
		private function drawPhotoSection():void
		{
			var sectionHeight:int = _width * 0.76;
			photoSection.graphics.beginFill(0x0099CC);
			photoSection.graphics.drawRect(0, 0, _width, sectionHeight);
			photoSection.graphics.endFill();
		}
		
		private function drawAcceptButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			acceptButton.setBitmapData(buttonBitmap, true);
			acceptButton.x = int(acceptButton.width + Config.DIALOG_MARGIN * 2);
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 0, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap);
			backButton.x = Config.DIALOG_MARGIN;
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
			
			var position:int = 0;
			
			photoSection.y = position;
			position += photoSection.height;
			scroll.view.y = position;
			
			var scrollPosition:int = Config.FINGER_SIZE * .5;
			
			titleName.y = scrollPosition;
			titleName.x = Config.DIALOG_MARGIN;
			scrollPosition += titleName.height;
			inputName.y = scrollPosition;
			inputName.x = Config.DIALOG_MARGIN;
			scrollPosition += inputName.getHeight() + Config.FINGER_SIZE * .5;
			
			titleDescription.y = scrollPosition;
			titleDescription.x = Config.DIALOG_MARGIN;
			scrollPosition += titleDescription.height;
			inputDescription.y = scrollPosition;
			inputDescription.x = Config.DIALOG_MARGIN;
			scrollPosition += inputDescription.getHeight() + Config.FINGER_SIZE * .5;
			
			titleCost.y = scrollPosition;
			titleCost.x = Config.DIALOG_MARGIN;
			scrollPosition += titleCost.height;
			inputCost.y = scrollPosition;
			inputCost.x = Config.DIALOG_MARGIN;
			scrollPosition += inputCost.getHeight();
			
			var maxScrollHeight:int = Math.max(_height - photoSection.height - Config.FINGER_SIZE * .6 - acceptButton.height, Config.FINGER_SIZE * 2) - Config.APPLE_BOTTOM_OFFSET;
			scroll.setWidthAndHeight(_width, Math.min(maxScrollHeight, scroll.itemsHeight + Config.FINGER_SIZE * .1));
			scroll.update();
			position += scroll.height + Config.FINGER_SIZE * .3;
			acceptButton.y = position;
			backButton.y = position;
			position += acceptButton.height + Config.FINGER_SIZE * .3;
			
			addPhotoButton.x = int(_width * .5 - addPhotoButton.width * .5);
			addPhotoButton.y = int(photoSection.y + photoSection.height * .5 - addPhotoButton.height * .5);
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, 0, _width, position);
			bg.graphics.endFill();
			
			replacePhotoButton.x = int(_width - replacePhotoButton.width - Config.FINGER_SIZE * .2);
			replacePhotoButton.y = int(photoSection.y + photoSection.height - replacePhotoButton.height - Config.FINGER_SIZE * .2);
			
			container.y = _height - position - Config.APPLE_BOTTOM_OFFSET;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			scroll.enable();
			
			backButton.activate();
			addPhotoButton.activate();
			acceptButton.activate();
			inputName.activate();
			inputDescription.activate();
			inputCost.activate();
			if (replacePhotoButton.visible == true)
			{
				replacePhotoButton.activate();
			}
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			scroll.disable();
			
			backButton.deactivate();
			addPhotoButton.deactivate();
			acceptButton.deactivate();
			inputName.deactivate();
			inputDescription.deactivate();
			inputCost.deactivate();
			replacePhotoButton.deactivate()
		}
		
		override public function dispose():void
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			Overlay.removeCurrent();
			
			removeActions();
			
			TweenMax.killTweensOf(loadedPhoto);
			
			Shop.S_MY_PAID_CHAT_UPDATE.remove(onStatusChanged);
			
			if (titleCost != null)
			{
				UI.destroy(titleCost);
				titleCost = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
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
			if (photoSection != null)
			{
				UI.destroy(photoSection);
				photoSection = null;
			}
			if (titleName != null)
			{
				UI.destroy(titleName);
				titleName = null;
			}
			if (loadedPhoto != null)
			{
				UI.destroy(loadedPhoto);
				loadedPhoto = null;
			}
			if (scrollStart != null)
			{
				UI.destroy(scrollStart);
				scrollStart = null;
			}
			if (titleDescription != null)
			{
				UI.destroy(titleDescription);
				titleDescription = null;
			}
			if (acceptButton != null)
			{
				acceptButton.dispose();
				acceptButton = null;
			}
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (scroll != null)
			{
				scroll.dispose();
				scroll = null;
			}
			if (addPhotoButton != null)
			{
				addPhotoButton.dispose();
				addPhotoButton = null;
			}
			if (replacePhotoButton != null)
			{
				replacePhotoButton.dispose();
				replacePhotoButton = null;
			}
			if (inputName != null)
			{
				inputName.dispose();
				inputName = null;
			}
			if (inputDescription != null)
			{
				inputDescription.dispose();
				inputDescription = null;
			}
			if (inputCost != null)
			{
				inputCost.dispose();
				inputCost = null;
			}
			if (photoLoader != null)
			{
				photoLoader.dispose();
				photoLoader = null;
			}
			if (horizontalLoader != null)
			{
				horizontalLoader.dispose();
				horizontalLoader = null;
			}
			
			currentRequest = null;
		}
	}
}