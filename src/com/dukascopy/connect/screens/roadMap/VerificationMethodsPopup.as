package com.dukascopy.connect.screens.roadMap {
	
	import assets.AskFriendIcon;
	import assets.CardDepositIcon;
	import assets.CryptoDepositIcon;
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
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.AnimatedTitlePopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ScrollAnimatedTitlePopup;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
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
	
	public class VerificationMethodsPopup extends ScrollAnimatedTitlePopup {
		private var title:Bitmap;
		private var needCallback:Boolean;
		private var paddind:int;
		private var clips:Vector.<SolencyMethodClip>;
		private var lastSelectedItem:SolencyMethodClip;
		public var price:String;
		
		public function VerificationMethodsPopup() { }
		
		override protected function createView():void {
			super.createView();
			
			title = new Bitmap();
			addItem(title);
			
			paddind = Config.DIALOG_MARGIN;
			
			clips = new Vector.<SolencyMethodClip>();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if (data != null && "price" in data)
			{
				price = data.price;
			}
			
			drawTitle();
			drawSteps();
			
			var position:int = Config.FINGER_SIZE * .8;
			title.y = position;
			title.x = int(_width * .5 - title.width * .5);
			position += title.height + Config.FINGER_SIZE * .8;
			
			if (clips != null)
			{
				var paddingV:int = Config.FINGER_SIZE * .27;
				for (var i:int = 0; i < clips.length; i++) 
				{
					clips[i].y = position;
					
					position += clips[i].getHeight() + paddingV;
					
					clips[i].x = paddind;
				}
				updateScroll();
			}
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			scrollBottom.y = scrollPanel.itemsHeight + Config.APPLE_BOTTOM_OFFSET + Config.FINGER_SIZE * .3;
			super.drawView();
		}
		
		private function drawSteps():void 
		{
			var methodsData:Vector.<SolvencyMethodData> = createStepsData();
			
			if (methodsData != null)
			{
				var clip:SolencyMethodClip;
				for (var i:int = 0; i < methodsData.length; i++) 
				{
					clip = new SolencyMethodClip();
					clip.onSelect = onItemSelected;
					clip.setData(methodsData[i], _width - paddind * 2);
					addItem(clip);
					clips.push(clip);
					if (clip.data.selected)
					{
						lastSelectedItem = clip;
					}
				}
			}
		}
		
		private function onItemSelected(selectedItem:SolencyMethodClip):void 
		{
			if (lastSelectedItem != null)
			{
				lastSelectedItem.unselect();
			}
			lastSelectedItem = selectedItem;
			lastSelectedItem.select();
			
			needCallback = true;
			TweenMax.killDelayedCallsTo(close);
			TweenMax.delayedCall(1, close);
		}
		
		private function createStepsData():Vector.<SolvencyMethodData> 
		{
			var textValue:String;
			
			var methodsData:Vector.<SolvencyMethodData> = new Vector.<SolvencyMethodData>();
			
			var methodCardDeposit:SolvencyMethodData = new SolvencyMethodData();
			methodCardDeposit.title = Lang.solvency_card_deposit;
			textValue = Lang.solvency_card_deposit_description_2;
			textValue = LangManager.replace(/%@/g, textValue, price);
			methodCardDeposit.subtitle = textValue;
			methodCardDeposit.selected = false;
			methodCardDeposit.icon = CardDepositIcon;
			methodCardDeposit.type = SolvencyMethodData.METHOD_CARD_DEPOSIT;
			methodsData.push(methodCardDeposit);
			
			var methodCardWireDeposit:SolvencyMethodData = new SolvencyMethodData();
			methodCardWireDeposit.title = Lang.solvency_wire_deposit;
			textValue = Lang.solvency_wire_deposit_description;
			textValue = LangManager.replace(/%@/g, textValue, price);
			methodCardWireDeposit.subtitle = textValue;
			methodCardWireDeposit.selected = false;
			methodCardWireDeposit.icon = CardDepositIcon;
			methodCardWireDeposit.type = SolvencyMethodData.METHOD_WIRE_DEPOSIT;
			methodsData.push(methodCardWireDeposit);
			
			var methodCryptoDeposit:SolvencyMethodData
			if (data != null && "allowZBX" in data && data.allowZBX == true)
			{
				methodCryptoDeposit = new SolvencyMethodData();
				methodCryptoDeposit.title = Lang.solvency_crypto_deposit;
				textValue = Lang.solvency_crypto_deposit_description_2;
				textValue = LangManager.replace(/%@/g, textValue, price);
				methodCryptoDeposit.subtitle = textValue;
				methodCryptoDeposit.selected = false;
				methodCryptoDeposit.icon = CryptoDepositIcon;
				methodCryptoDeposit.type = SolvencyMethodData.METHOD_CRYPTO_DEPOSIT;
				methodsData.push(methodCryptoDeposit);
			}
			
			var methodAskFriend:SolvencyMethodData;
			methodAskFriend = new SolvencyMethodData();
			methodAskFriend.title = Lang.solvency_ask_friend;
			textValue = Lang.solvency_ask_friend_description_2;
			textValue = LangManager.replace(/%@/g, textValue, price);
			methodAskFriend.subtitle = textValue;
			methodAskFriend.selected = false;
			methodAskFriend.icon = AskFriendIcon;
			methodAskFriend.type = SolvencyMethodData.METHOD_ASK_FRIEND;
			methodsData.push(methodAskFriend);
			
			if (data != null && "selected" in data)
			{
				if (data.selected == SolvencyMethodData.METHOD_CARD_DEPOSIT)
				{
					methodCardDeposit.selected = true;
				}
				else if (data.selected == SolvencyMethodData.METHOD_CRYPTO_DEPOSIT)
				{
					if (methodCryptoDeposit != null)
					{
						methodCryptoDeposit.selected = true;
					}
				}
				else if (data.selected == SolvencyMethodData.METHOD_ASK_FRIEND)
				{
					if (methodAskFriend != null)
					{
						methodAskFriend.selected = true;
					}
				}
				else if (data.selected == SolvencyMethodData.METHOD_WIRE_DEPOSIT)
				{
					if (methodCardWireDeposit != null)
					{
						methodCardWireDeposit.selected = true;
					}
				}
			}
			
			return methodsData;
		}
		
		private function drawTitle():void 
		{
			title.bitmapData = TextUtils.createTextFieldData(
				"<b>" + Lang.selectVerificationMethod + "</b>",
				_width - contentPadding * 2,
				10,
				true,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE*.4,
				true,
				Style.color(Style.COLOR_TEXT),
				Style.color(Style.COLOR_BACKGROUND),
				false, true
			);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			if (clips != null)
			{
				for (var i:int = 0; i < clips.length; i++) 
				{
					clips[i].activate();
				}
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			if (clips != null)
			{
				for (var i:int = 0; i < clips.length; i++) 
				{
					clips[i].deactivate();
				}
			}
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 1)
				{
					if (lastSelectedItem != null && lastSelectedItem.data != null)
					{
						data.callback(lastSelectedItem.data.type);
					}
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			
			lastSelectedItem = null;
			
			if (clips != null)
			{
				for (var i:int = 0; i < clips.length; i++) 
				{
					clips[i].dispose();
				}
			}
		}
	}
}