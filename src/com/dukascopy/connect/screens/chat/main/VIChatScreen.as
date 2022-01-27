package com.dukascopy.connect.screens.chat.main {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.chatInput.ChatInputIOS;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.call.RecognitionChatSection;
	import com.dukascopy.connect.screens.chat.video.ChatMessagePanel;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.vo.CallVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class VIChatScreen extends ChatScreen {
		
		private var header:ChatMessagePanel;
		private var fullscreenVideo:Boolean;
		private var hideTime:Number = 0.3;
		private var showTime:Number = 0.3;
		private var hideTimeout:Number = 2;
		private var listHeight:int;
		private var fullscreenVideoSplit:Boolean;
		private var recognitionSection:RecognitionChatSection;
		private var recognitionMode:Boolean;
		
		public function VIChatScreen() { }
		
		override protected function createView():void {
			super.createView();
			recognitionSection = new RecognitionChatSection();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			var callVO:CallVO = CallManager.getCallVO();
			if (callVO != null && callVO.cleared == false) {
				recognitionMode = true;
				showHeader("1. " + Lang.documentPhoto);
				view.addChild(recognitionSection.view);
				var videoSize:Rectangle = new Rectangle(0, 0, _width, int(list.height / 2));
				recognitionSection.setInitialSize(videoSize.width, videoSize.height);
				recognitionSection.initScreen({});
				recognitionSection.setWidthAndHeight(videoSize.width, videoSize.height);
				drawVideoSplitSimple();
				recognitionSection.setProgressIndicator(header);
				var position:int;
				if (header != null)
					position = header.y + header.height;
				else
					position = chatTop.y + chatTop.height;
				recognitionSection.setPosition(position);
				view.setChildIndex(chatTop, view.numChildren - 1);
				if (header != null)
					view.setChildIndex(header, view.numChildren - 1);
				if (Config.PLATFORM_APPLE == true) {
					ChatInputIOS.S_INPUT_HIDE_END.add(onInputHideEnd);
					ChatInputIOS.S_INPUT_SHOW_START.add(onInputShowStart);
					ChatInputIOS.S_INPUT_HIDE_START.add(onInputHideStart);
				}
			}
		}
		
		override public function onBack(e:Event = null):void {
			if (recognitionMode == true)
				DialogManager.alert(Lang.information, Lang.youWantToStopVI, onBackAlertResponse, Lang.textOk, Lang.CANCEL);
			else
				super.onBack();
		}
		
		private function onBackAlertResponse(val:int):void {
			if (val == 1)
				onHangout();
		}
		
		private function onInputHideStart(duration:Number):void {
			if (recognitionSection != null)
				recognitionSection.show(duration);
		}
		
		private function onInputShowStart():void {
			if (recognitionSection != null) {
				if (recognitionSection.hided == false) {
					recognitionSection.hide();
					fullscreenVideoSplit = false;
					list.view.y = header.y + header.height;
					if (backgroundImage != null)
						backgroundImage.y = list.view.y;
					backColorClip.y = list.view.y;
					drawView();
				}
			}
		}
		
		private function onInputHideEnd():void {
			if (recognitionSection != null) {
				if (recognitionSection.hided == true) {
					recognitionSection.onShown();
					fullscreenVideoSplit = true;
					list.view.y = int(header.y + header.height + listHeight / 2);
					if (backgroundImage != null)
						backgroundImage.y = list.view.y;
					backColorClip.y = list.view.y;
					drawView();
				}
			}
		}
		
		override protected function onInputPositionChange():void {
			if (recognitionMode == false) {
				super.onInputPositionChange();
				return;
			}
			if (Config.PLATFORM_APPLE == true) {
				super.onInputPositionChange();
				return;
			}
			if (chatInput.getView().y < MobileGui.stage.stageHeight - chatInput.getStartHeight()) {
				if (recognitionSection != null) {
					if (recognitionSection.hided == false) {
						recognitionSection.hide();
						fullscreenVideoSplit = false;
						list.view.y = header.y + header.height;
						if (backgroundImage != null)
							backgroundImage.y = list.view.y;
						backColorClip.y = list.view.y;
						drawView();
					} else {
						super.onInputPositionChange();
					}
				} else {
					super.onInputPositionChange();
				}
			} else {
				if (recognitionSection != null) {
					if (recognitionSection.hided == true) {
						recognitionSection.show(0.3);
						recognitionSection.onShown();
						fullscreenVideoSplit = true;
						list.view.y = int(header.y + header.height + listHeight / 2);
						if (backgroundImage != null)
							backgroundImage.y = list.view.y;
						backColorClip.y = list.view.y;
						drawView();
					} else {
						super.onInputPositionChange();
					}
				} else {
					super.onInputPositionChange();
				}
			}
		}
		
		public function showHeader(message:String):void {
			if (header == null) {
				header = new ChatMessagePanel(onHangout);
				header.y = int(chatTop.y + chatTop.height);
				view.addChild(header);
			}
			header.draw(new Point(_width, int(Config.FINGER_SIZE*1.0)), message);
			list.view.y = int(header.y + header.height);
			drawView();
		}
		
		private function onHangout():void {
			if (recognitionSection != null)
				recognitionSection.hangup();
		}
		
		public function hideHeader():void {
			if (header != null) {
				header.dispose();
				try {
					view.removeChild(header);
				} catch (err:Error) {
					ApplicationErrors.add();
				}
				header = null;
			}
			list.view.y = header.y + header.height;
			drawView();
		}
		
		private function drawVideoSplitSimple():void {
			listHeight = list.height;
			fullscreenVideoSplit = true;
			list.view.y = int(header.y + header.height + listHeight / 2);
			if (backgroundImage != null)
				backgroundImage.y = list.view.y;
			backColorClip.y = list.view.y;
			drawView();
		}
		
		override protected function drawView():void {
			super.drawView();
			if (fullscreenVideoSplit == true) {
				if (backgroundImage != null)
					backgroundImage.y = list.view.y;
				backColorClip.y = list.view.y;
			} else {
				if (fullscreenVideo == true)
					backColorClip.alpha = 0;
				else
					backColorClip.alpha = 1;
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (header != null)
				header.activate();
			if (recognitionMode == true)
				recognitionSection.activateScreen();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (header != null)
				header.deactivate();
			if (recognitionMode == true)
				recognitionSection.deactivateScreen();
		}
		
		override public function dispose():void {
			if (list != null)
				TweenMax.killTweensOf(list.view);
			super.dispose();
			if (header != null)
				header.dispose();
			header = null;
			if (recognitionSection != null && recognitionMode == true)
				recognitionSection.dispose();
			recognitionSection = null;
			if (Config.PLATFORM_APPLE == true) {
				ChatInputIOS.S_INPUT_HIDE_END.remove(onInputHideEnd);
				ChatInputIOS.S_INPUT_SHOW_START.remove(onInputShowStart);
				ChatInputIOS.S_INPUT_HIDE_START.remove(onInputHideStart);
			}
		}

		public function showState(forceShow:Boolean = false):void {
			if (recognitionSection != null)
				recognitionSection.showState(forceShow);
		}
	}
}