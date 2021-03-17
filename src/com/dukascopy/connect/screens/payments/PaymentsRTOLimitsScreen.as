package com.dukascopy.connect.screens.payments {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.button.RectangleButton;
	import com.dukascopy.connect.gui.layout.Layout;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.shapes.QBox;
	import com.dukascopy.connect.gui.shapes.QBoxItem;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author IgorBloom + Pavel Karpov Telefision TEAM Kiev.
	 */
	
	public class PaymentsRTOLimitsScreen extends BaseScreen {
		
		static public const S_NEED_UPDATE:Signal = new Signal("PaymentsRTOLimitsScreen.S_NEED_UPDATE");
		
		private static var estiObject:Array = [
			{ name:"0-20", value:"0-20" },
			{ name:"0-60", value:"0-60" },
			{ name:">60", value:">60" }
		];
		private static var approxObject:Array = [
			{ name:"€0 - 300", value:"€0-300" },
			{ name:"€0 - 1000", value:"€0-1000" },
			{ name:">€2000", value:">€2000" }
		];
		
		private var topBar:TopBarScreen;
		private var titleBox:Sprite;
		
		private var desc:TextField;
		private var scrollPanel:ScrollPanel;
		private var layout:Layout;
		
		private var btnSend:RectangleButton;
		
		private var busyIndicator:Preloader;
		private var qBox1:QBox;
		private var qBox2:QBox;
		private var qBox3:QBox;
		
		private var oldW:int = 0;
		private var oldH:int = 0;
		
		private var initedFromInvoice:Boolean = false;
		private var proceedPayTaskOnBack:Boolean = false;
		
		public function PaymentsRTOLimitsScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = 0xF4F4F4;
			scrollPanel.view.y = topBar.trueHeight;
			view.addChild(scrollPanel.view);
			
			layout = new Layout(scrollPanel.containerBox as DisplayObjectContainer, Layout.UP_DOWN, 0, Layout.ALIGN_LEFT_OR_TOP);
				titleBox = new Sprite();
					desc = UIFactory.createTextField(Config.FINGER_SIZE * .3, true, true);
					desc.x = Config.DOUBLE_MARGIN;
					desc.y = Config.DOUBLE_MARGIN;
					desc.text = Lang.provideMandatoryInformation;
					desc.alpha = .4;
				titleBox.addChild(desc);
			layout.add(titleBox);
				qBox1 = new QBox(Lang.transfersToOtherClient);
				qBox1.add(Lang.estimateNumPayMonth, estiObject, Lang.estimateNumPay, "estimated");
				qBox1.add(Lang.amountMonthlyTransactions, approxObject, Lang.monthlyAmmount, "approx");
			layout.add(qBox1.view);
				qBox2 = new QBox(Lang.makePaymentsInternet);
				qBox2.add(Lang.estimateNumPayMonth, estiObject, Lang.estimateNumPay, "estimated");
				qBox2.add(Lang.amountMonthlyTransactions, approxObject, Lang.monthlyAmmount, "approx");
			layout.add(qBox2.view);
				qBox3 = new QBox(Lang.receivePaymentsInternet);
				qBox3.add(Lang.estimateNumPayMonth, estiObject, Lang.estimateNumPay, "estimated");
				qBox3.add(Lang.amountMonthlyTransactions, approxObject, Lang.monthlyAmmount, "approx");
			layout.add(qBox3.view);
			layout.update();
			
			btnSend = new RectangleButton(Lang.textSubmit.toUpperCase(), AppTheme.RED_MEDIUM);
			btnSend.setStandartButtonParams();
			btnSend.setDownScale(1);
			btnSend.setDownColor(0);
			btnSend.tapCallback = onBtnSend;
			btnSend.disposeBitmapOnDestroy = true;
			btnSend.show();
			_view.addChild(btnSend);
			
			S_NEED_UPDATE.add(updateView);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.doDisposeAfterClose = true;
			if (data != null && data.unfinishedTask != null){
				initedFromInvoice = true;
				proceedPayTaskOnBack = false;
			}else{
				initedFromInvoice = false;
				proceedPayTaskOnBack = false;
			}
			
			topBar.setData(Lang.addInfoRequired);
		}
		
		override public function onBack(e:Event = null):void {
			
			if (proceedPayTaskOnBack && initedFromInvoice == true && data.backScreenData != null && data.unfinishedTask!=null){
				if(data.backScreenData is ChatScreenData){
					(data.backScreenData as ChatScreenData).unfinishedPayTask = data.unfinishedTask;
				}
			}
			
			if (data && "backScreen" in data == true && data.backScreen != null) {
				MobileGui.changeMainScreen(data.backScreen, data.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
				return;
			}
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		override protected function drawView():void {
			var needScrollPanelUpdate:Boolean = false;
			var w:int;
			if (oldW != _width) {
				needScrollPanelUpdate = true;
				
				topBar.drawView(_width);
				
				w = _width - Config.DOUBLE_MARGIN * 2;
				desc.width = w;
				
				titleBox.graphics.clear();
				titleBox.graphics.beginFill(0xFFFFFF);
				titleBox.graphics.drawRect(0, 0, _width, desc.height + Config.DOUBLE_MARGIN * 2);
				
				qBox1.setSize(_width);
				qBox2.setSize(_width);
				qBox3.setSize(_width);
				layout.update();
				
				btnSend.setWidth(_width);
				setBusyIndicator();
			}
			if (oldH != _height) {
				needScrollPanelUpdate = true;
				btnSend.y = _height - btnSend.getHeight();
			}
			if (needScrollPanelUpdate == true) {
				scrollPanel.updateObjects();
				scrollPanel.setWidthAndHeight(_width, _height - topBar.trueHeight - btnSend.height);
			}
			oldW = _width;
			oldH = _height;
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			topBar.activate();
			scrollPanel.enable();
			btnSend.activate();
			qBox1.activate();
			qBox2.activate();
			qBox3.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			topBar.deactivate();
			scrollPanel.disable();
			btnSend.deactivate();
			qBox1.deactivate();
			qBox2.deactivate();
			qBox3.deactivate();
		}
		
		private function updateView():void {
			if(layout!=null)
				layout.update();
			if(scrollPanel!=null)
				scrollPanel.updateObjects();
		}
		
		private function onBtnSend():void {
			deactivateScreen();
			var obj1:Object = qBox1.getValues();
			var obj2:Object = qBox2.getValues();
			var obj3:Object = qBox3.getValues();
			//we need to validate full fill of object, do not allow user to select amount without Number
			//Validation start =========================================================================
			var validFilledObjectsCount:int = 0;
			var halfFilledCount:int = 0;
			var firstFilled:Boolean = obj1.estimated != null &&  obj1.approx != null;
			var firstHalfFilled:Boolean = obj1.estimated != null &&  obj1.approx == null || obj1.estimated == null &&  obj1.approx != null;
			validFilledObjectsCount += firstFilled?1:0;
			halfFilledCount += firstHalfFilled?1:0;
			
			var secondFilled:Boolean = obj2.estimated != null &&  obj2.approx != null;
			var secondHalfFilled:Boolean = obj2.estimated != null &&  obj2.approx == null || obj2.estimated == null &&  obj2.approx != null ;
		
			validFilledObjectsCount += secondFilled?1:0;
			halfFilledCount += secondHalfFilled?1:0;
			var thirdFilled:Boolean = obj3.estimated != null &&  obj3.approx != null;
			var thirdHalfFilled:Boolean = obj3.estimated != null &&  obj3.approx == null || obj3.estimated == null &&  obj3.approx != null ;
		
			validFilledObjectsCount += thirdFilled?1:0;
			halfFilledCount += thirdHalfFilled?1:0;
			
			if (validFilledObjectsCount == 0 ) {
				// At least one object must be fully filled 
				DialogManager.alert((Lang.textError + "!"), Lang.TEXT_RTO_FILL_FROM, function(...rest):void {
					activateScreen();
				});
				return;
			} else {
				// check for half filled
				if (halfFilledCount > 0) {
					DialogManager.alert((Lang.textError + "!"), Lang.TEXT_RTO_FILL_HALF, function(...rest):void {
						activateScreen();
					});
					return;
				}
			}
		 //Validation END ============================================================
			
			if(busyIndicator==null) {
				busyIndicator = new Preloader(Config.FINGER_SIZE * .4);
				btnSend.addChild(busyIndicator);
			}
			setBusyIndicator();
			busyIndicator.show();
			
			var tmp:Array = [qBox1, qBox2, qBox3];
			var html:String = '<p>'+ desc.text + '</p>';
			
			html += "<p><b>HOW DO YOU PLAN TO USE YOUR ACCOUNT</b></p>";
			
			// Build html
			for (var n:int = 0; n < tmp.length; n++) {
				var qb:QBox = tmp[n];
				var cb:String = qb.allSelected()?'<input type="checkbox" checked="checked" disabled="disabled"/>':'<input type="checkbox" disabled="disabled"/> ' ;
				html += "<b>" + cb + qb.label + '</b><br>';
				if (qb.allSelected()) {
					html += "<ul>";
					var itms:Array = qb.getItems();
					for (var m:int = 0; m < itms.length; m++) {
						var qi:QBoxItem = itms[m];
						html += '<li><i>' + qi.blockLabel + '</i><br>';
						for (var z:int = 0; z < qi.items.length; z++) {
							if (qi.selectedValue == qi.items[z])
								html += '<input type="checkbox" checked="checked" disabled="disabled" style="margin-left:20px;" /> ' + qi.items[z].name + '';
									else
										html += '<input type="checkbox" disabled="disabled" style="margin-left:20px;"/> ' + qi.items[z].name +'';
						}
						html += '</li><br>';
					}
					html += "</ul>";
				}
			}
			
			PayManager.submitTrialData(
				onTrialDataRespond,
				(obj1.estimated == null)?"":obj1.estimated.value,
				(obj1.approx == null)?"":obj1.approx.value,
				
				(obj2.estimated == null)?"":obj2.estimated.value,
				(obj2.approx == null)?"":obj2.approx.value,
				
				(obj3.estimated == null)?"":obj3.estimated.value,
				(obj3.approx==null)?"":obj3.approx.value,
				
				html
			)
		}
		
		private function onTrialDataRespond(respond:PayRespond):void {
			removeBusyIndicator();
			//trace("on submit callback ", respond);
			if (respond == null) {
			// net interneta
				DialogManager.alert(Lang.noInternetConnection+"!"/*"No Connection!"*/, Lang.alertProvideInternetConnection);
				activateScreen();
				return;
			}
			// Responded from server 
			// hide screen or display error	
			if (respond.hasAuthorizationError) {
			// sessija zakonchilask
				PayManager.validateAuthorization(respond);
				//removeScreen();
				return;
			}
			
			if (respond.error) {
			// obrabativaem owibki 
				if (respond.errorCode == 4401) {
					//Wrong value for
					DialogManager.alert(Lang.textError + "!", Lang.TEXT_PTO_CHECK_PROVIDED, function(i:int=1):void {
						removeScreen();
					});
					return;
				}
				if (respond.errorCode == 4402) {
					//KYC information is already provided
					DialogManager.alert(Lang.textAttention+"!", Lang.TEXT_KYC_INFORMATION, function(...rest):void {
						removeScreen();
					});
					return;
				}
				//TODO: Lang
				// Unknown error
				DialogManager.alert(Lang.textAttention+"!", "Unknown server error (" + respond.errorCode + "), please contact our support team", function(...rest):void {
					removeScreen();
				});
				return;
			}		
			
			proceedPayTaskOnBack = true;
			// Zakrivaem ekran
			removeScreen();
		}
		
		private function onBtnCancel():void {
			if(busyIndicator!=null) {
				busyIndicator.dispose();
				busyIndicator = null;
			}
			removeScreen();
		}
		
		private function removeScreen():void {
			onBack(null);
			//deactivateScreen();
			
			//MobileGui.changeMainScreen(PaymentsScreen);
			// TODO KILL SCREEN, GO BACK TO PREVIOUS
			
		
			
			//var chatScreenData:ChatScreenData = new ChatScreenData();
			//chatScreenData.usersUIDs = [userVO.uid];
			//chatScreenData.type = ChatInitType.USERS_IDS;
			//chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			//chatScreenData.backScreenData = data;
			//MobileGui.showChatScreen(chatScreenData);
		}
		
		private function setBusyIndicator():void {
			if (busyIndicator == null)
				return;
			busyIndicator.y = Math.round(btnSend.height * .5);
			busyIndicator.x = Math.round(btnSend.width - Config.FINGER_SIZE * .4 - 10);
		}
		
		private function removeBusyIndicator():void {
			if (busyIndicator != null)
				busyIndicator.hide(true);
			busyIndicator = null;
		}
		
	
		
		
		
		override public function dispose():void {
			super.dispose();
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			if (qBox1 != null)
				qBox1.dispose();
			qBox1 = null;
			if (qBox2 != null)
				qBox2.dispose();
			qBox2 = null;
			if (qBox3 != null)
				qBox3.dispose();
			qBox3 = null;
			if (desc != null) {
				if (desc.parent != null)
					desc.parent.removeChild(desc);
				desc.text = "";
				desc = null;
			}
			if (scrollPanel != null)
				scrollPanel.dispose();
			scrollPanel = null;
			if (layout != null)
				layout.dispose();
			layout = null;	
			if (btnSend != null)
				btnSend.dispose();
			btnSend = null;	
		}
	}
}