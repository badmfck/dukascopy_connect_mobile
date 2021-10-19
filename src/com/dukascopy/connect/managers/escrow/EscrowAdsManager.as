package com.dukascopy.connect.managers.escrow {
	
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.screenAction.customActions.EscrowAdsCreationCheckAction;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsCryptoVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsFilterVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class EscrowAdsManager {
		
		static public const MESSAGE_KEY:String = "123456789qwerty";
		
		private var profile:UserVO;
		
		private var escrowAdsCryptosIdsLoadedFromStore:Boolean;
		private var escrowAdsCryptosIds:Object;
		private var escrowAdsCryptos:Array/*EscrowAdsCryptoVO*/;
		private var escrowInstruments:Vector.<EscrowInstrument>;
		private var escrowInstrumentsHash:String = "";
		private var escrowAdsFilter:EscrowAdsFilterVO = new EscrowAdsFilterVO();
		private var escrowAdsFilterSetted:Boolean = false;
		private var escrowAdsPHPRequestID:String;
		private var escrowAdsMinePHPRequestID:String;
		private var escrowAdsHash:String;
		private var escrowAdsMineHash:String;
		private var escrowAds:Array/*EscrowAdsVO*/;
		private var escrowAdsMine:Array/*EscrowAdsVO*/;
		private var escrowAdsLoadingRequestCount:int = 0;
		private var escrowAdsMineLoadingRequestCount:int = 0;
		private var escrowAdsLoadNeeded:Boolean;
		private var escrowAdsMineLoadNeeded:Boolean;
		
		public function EscrowAdsManager() {
			GD.S_ESCROW_ADS_CRYPTOS_REQUEST.add(onEscrowAdsCryptosRequested);
			GD.S_ESCROW_ADS_INSTRUMENT_SELECTED.add(saveEscrowAdsCryptoID);
			GD.S_ESCROW_ADS_FILTER_REQUEST.add(onEscrowAdsFilterRequested);
			GD.S_ESCROW_ADS_FILTER_SETTED.add(onEscrowFilterSetted);
			GD.S_ESCROW_ADS_REQUEST.add(onEscrowAdsRequested);
			GD.S_ESCROW_ADS_MINE_REQUEST.add(onEscrowAdsMineRequested);
			GD.S_ESCROW_ADS_REMOVE.add(close);
			GD.S_ESCROW_ADS_CREATE.add(createEscrowAds);
			GD.S_ESCROW_AD_UPDATED.add(onEscrowAdUpdatedWS);
			
			GD.S_AUTHORIZED.add(onAuthorized);
			GD.S_UNAUTHORIZED.add(onUnuthorized);
		}
		
		private function onAuthorized(data:Object):void {
			profile = data.profile;
		}
		
		private function onUnuthorized():void {
			profile = null;
		}
		
		private function onEscrowFilterSetted():void {
			escrowAdsFilterSetted = escrowAdsFilter.changed;
			escrowAdsFilter.changed = false;
		}
		
		private function onEscrowAdsFilterRequested(callback:Function):void {
			if (callback == null)
				return;
			if (callback.length != 1)
				return;
			callback(escrowAdsFilter);
		}
		
// ESCROW ADVERTISING CRYPTO --> //
		
		private function saveEscrowAdsCryptoID(escrowAdsCrypto:EscrowAdsCryptoVO):void {
			var crypto:String = escrowAdsCrypto.instrument.code;
			if (crypto == "DUK+")
				crypto = "DCO";
			escrowAdsCryptosIds ||= {};
			escrowAdsCryptosIds[crypto] = escrowAdsCrypto.maxID;
			escrowAdsCrypto.newExists = false;
			escrowAdsFilter.instrument = escrowAdsCrypto.instrument;
			onEscrowFilterSetted();
			Store.save("escrowAdsCryptoIds", escrowAdsCryptosIds);
			GD.S_ESCROW_INSTRUMENTS.remove(onEscrowInstrumentsReceived);
			GD.S_SHOW_ESCROW_ADS.invoke(escrowAdsFilter);
		}
		
		private function onEscrowAdsCryptosRequested():void {
			WSClient.call_blackHoleToGroup("que", "subscribe");
			GD.S_ESCROW_INSTRUMENTS.add(onEscrowInstrumentsReceived);
			if (escrowAdsCryptosIdsLoadedFromStore == true) {
				GD.S_ESCROW_ADS_CRYPTOS.invoke(escrowAdsCryptos);
				GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
				return;
			}
			escrowAdsCryptosIdsLoadedFromStore = true;
			Store.load("escrowAdsCryptoIds", onEscrowAdsCryptosIdsLoaded);
		}
		
		private function onEscrowAdsCryptosIdsLoaded(data:Object, err:Boolean):void {
			if (err == false)
				escrowAdsCryptosIds = data;
			GD.S_ESCROW_ADS_CRYPTOS.invoke(escrowAdsCryptos);
			GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
		}
		
		private function onEscrowInstrumentsReceived(instruments:Vector.<EscrowInstrument>):void {
			if (instruments == null || instruments.length == 0) {
				GD.S_ESCROW_ADS_CRYPTOS.invoke(null, true);
				return;
			}
			var escrowInstrumentsHashNew:String = "";
			var needToLoad:Boolean = escrowInstrumentsHash == "";
			if (needToLoad == false) {
				var index:int;
				var l:int = instruments.length;
				for (var i:int = 0; i < l; i++) {
					if (escrowInstrumentsHash == "")
						needToLoad = true;
					index = escrowInstrumentsHash.indexOf(instruments[i].code);
					if (index == -1) 
						needToLoad = true;
					if (needToLoad == false)
						escrowInstrumentsHash = escrowInstrumentsHash.replace(instruments[i].code, "");
					escrowInstrumentsHashNew += instruments[i].code;
				}
				escrowInstrumentsHash = escrowInstrumentsHashNew;
			}
			escrowInstruments = instruments;
			if (needToLoad == true)
				PHP.escrow_getStat(onEscrowAdsCryptosReceived);
			if (escrowAdsLoadNeeded == true) {
				escrowAdsLoadNeeded = false;
				onEscrowAdsRequested();
			}
			if (escrowAdsLoadNeeded == true) {
				escrowAdsMineLoadNeeded = false;
				onEscrowAdsMineRequested();
			}
		}
		
		private function onEscrowAdsCryptosReceived(phpRespond:PHPRespond):void {
			clearEscrowAdsCryptos();
			if (phpRespond.error == true)
				GD.S_TOAST.invoke(Lang.somethingWentWrong);
			if (phpRespond.data == null || phpRespond.data.length == 0) {
				GD.S_ESCROW_ADS_CRYPTOS.invoke(null, true);
				return;
			}
			escrowAdsCryptos = [];
			var l0:int = escrowInstruments.length;
			var l1:int = phpRespond.data.length;
			var exist:Boolean;
			for (var i:int = 0; i < l0; i++) {
				exist = false;
				for (var j:int = 0; j < l1; j++) {
					if (phpRespond.data[j].instrument == escrowInstruments[i].code) {
						exist = true;
						phpRespond.data[j].instrument = escrowInstruments[i];
						escrowAdsCryptos.push(new EscrowAdsCryptoVO(phpRespond.data[j]));
						break;
					}
				}
				if (exist == false) {
					escrowAdsCryptos.push(new EscrowAdsCryptoVO( {
						instrument:escrowInstruments[i]
					} ));
				}
				var escrowAdsCrypto:EscrowAdsCryptoVO = escrowAdsCryptos[escrowAdsCryptos.length - 1];
				escrowAdsCrypto.newExists = escrowAdsCryptosIds == null || escrowAdsCrypto.instrument.code in escrowAdsCryptosIds == false || escrowAdsCryptosIds[escrowAdsCrypto.instrument.code] != escrowAdsCrypto.maxID;
			}
			if (escrowAdsCryptos != null)
				escrowAdsCryptos.sortOn("instrumentCode");
			GD.S_ESCROW_ADS_CRYPTOS.invoke(escrowAdsCryptos, true);
		}
		
		private function clearEscrowAdsCryptos():void {
			if (escrowAdsCryptos == null)
				return;
			var l:int = escrowAdsCryptos.length;
			while (escrowAdsCryptos.length != 0)
				escrowAdsCryptos.shift().dispose();
			escrowAdsCryptos = null;
		}
		
// <-- ESCROW ADVERTISING CRYPTO || ESCROW ADVERTISING --> //
		
		private function onEscrowAdUpdatedWS(data:Object):void {
			if ("action" in data == false)
				return;
			if (data.action != "take")
				return;
			var escrowAd:EscrowAdsVO = getEscrowAdsByUID(data.quid, escrowAds);
			if (escrowAd != null) {
				escrowAd.updateAnswers(escrowAd.answersCount + 1);
				GD.S_ESCROW_ADS.invoke(escrowAds, true);
			}
			escrowAd = getEscrowAdsByUID(data.quid, escrowAdsMine);
			if (escrowAd != null) {
				escrowAd.updateAnswers(escrowAd.answersCount + 1);
				GD.S_ESCROW_ADS_MINE.invoke(escrowAdsMine, true);
			}
		}
		
		private function onEscrowAdsRequested(afterError:Boolean = false):void {
			if (afterError == false && escrowAdsFilterSetted == false) {
				escrowAdsSort();
				GD.S_ESCROW_ADS.invoke(escrowAds, true);
				return;
			}
			if (afterError == true) {
				if (escrowAdsLoadingRequestCount == 5) {
					clearEscrowAds();
					GD.S_ESCROW_ADS.invoke(null, true, true);
					return;
				}
			} else
				escrowAdsLoadingRequestCount == 0;
			escrowAdsLoadingRequestCount++;
			escrowAdsFilterSetted = false;
			escrowAdsPHPRequestID = new Date().getTime() + "";
			PHP.getEscrowAds(onEscrowAdsLoaded, escrowAdsFilter.filter, escrowAdsHash, escrowAdsPHPRequestID);
		}
		
		private function onEscrowAdsLoaded(phpRespond:PHPRespond):void {
			if (phpRespond.additionalData.callID != escrowAdsPHPRequestID)
				return;
			escrowAdsPHPRequestID = null;
			if (phpRespond.error == true) {
				if (phpRespond.errorMsg == "io" && NetworkManager.isConnected == true && escrowAdsFilterSetted == false)
					TweenMax.delayedCall(5, onEscrowAdsRequested, [ true ]);
				escrowAdsFilterSetted = true;
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data == null) {
				DialogManager.alert(Lang.textWarning, Lang.serverError + " " + Lang.emptyData);
				phpRespond.dispose();
				clearEscrowAds();
				escrowAdsFilterSetted = true;
				GD.S_ESCROW_ADS.invoke(null, true, true);
				return;
			}
			if (phpRespond.data.hash == escrowAdsHash) {
				GD.S_ESCROW_ADS.invoke(escrowAds, true);
				return;
			}
			var escrowAdsPHP:Array = [];
			var l1:int = 0;
			if ("others" in phpRespond.data && phpRespond.data.others != null)
				l1 = phpRespond.data.others.length;
			var l2:int = 0;
			var escrowAdsVO:EscrowAdsVO;
			for (var i:int = 0; i < l1; i++) {
				if (escrowAds != null)
					l2 = escrowAds.length;
				for (var j:int = l2; j > 0; j--) {
					if (escrowAds[j - 1].uid != phpRespond.data.others[i].uid)
						continue;
					escrowAdsPHP.push(escrowAds[j - 1]);
					escrowAds.removeAt(j - 1);
					break;
				}
				if (j == 0) {
					escrowAdsVO = createEscrowVO(phpRespond.data.others[i]);
					if (escrowAdsVO != null)
						escrowAdsPHP.push(escrowAdsVO);
				}
			}
			clearEscrowAds();
			if (escrowInstruments == null) {
				escrowAdsLoadNeeded = true;
				GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
			}
			escrowAds = escrowAdsPHP;
			escrowAdsPHP = null;
			escrowAdsSort();
			GD.S_ESCROW_ADS.invoke(escrowAds, true);
		}
		
		private function escrowAdsSort():void {
			if (escrowAds == null)
				return;
			if (escrowAdsFilter.sort == EscrowAdsFilterVO.SORT_BUY_SELL) {
				escrowAds.sort(function(a:EscrowAdsVO, b:EscrowAdsVO):int {
					if (a.side == "sell" && b.side == "sell") {
						if (a.price > b.price)
							return -1;
						else if (a.price < b.price)
							return 1;
						else
							return 0;
					} else if (a.side == "buy" && b.side == "buy") {
						if (a.price > b.price)
							return 1;
						else if (a.price < b.price)
							return -1;
						else
							return 0;
					} else if (a.side == "sell")
						return -1;
					else if (b.side == "sell")
						return 1;
					else
						return 0;
					}
				);
			} else if (escrowAdsFilter.sort == EscrowAdsFilterVO.SORT_AMOUNT) {
				escrowAds.sortOn("amount", Array.NUMERIC | Array.DESCENDING);
			} else if (escrowAdsFilter.sort == EscrowAdsFilterVO.SORT_DATE) {
				escrowAds.sortOn("created", Array.NUMERIC | Array.DESCENDING);
			} else if (escrowAdsFilter.sort == EscrowAdsFilterVO.SORT_PRICE) {
				if (escrowAdsFilter.side == "buy")
					escrowAds.sortOn("price", Array.NUMERIC);
				else
					escrowAds.sortOn("price", Array.NUMERIC | Array.DESCENDING);
			}
		}
		
		private function onEscrowAdsMineRequested(afterError:Boolean = false):void {
			if (afterError == true) {
				if (escrowAdsMineLoadingRequestCount == 5) {
					clearEscrowAds(true);
					GD.S_ESCROW_ADS_MINE.invoke(null, true, true);
					return;
				}
			} else {
				GD.S_ESCROW_ADS_MINE.invoke(escrowAdsMine);
				escrowAdsMineLoadingRequestCount == 0;
			}
			escrowAdsMineLoadingRequestCount++;
			escrowAdsMinePHPRequestID = new Date().getTime() + "";
			PHP.getEscrowAds(onEscrowAdsMineLoaded, null, escrowAdsMineHash, escrowAdsMinePHPRequestID);
		}
		
		private function onEscrowAdsMineLoaded(phpRespond:PHPRespond):void {
			if (phpRespond.additionalData.callID != escrowAdsMinePHPRequestID)
				return;
			escrowAdsMinePHPRequestID = null;
			if (phpRespond.error == true) {
				if (phpRespond.errorMsg == "io" && NetworkManager.isConnected == true)
					TweenMax.delayedCall(5, onEscrowAdsRequested, [ true ]);
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data == null) {
				DialogManager.alert(Lang.textWarning, Lang.serverError + " " + Lang.emptyData);
				phpRespond.dispose();
				clearEscrowAds(true);
				GD.S_ESCROW_ADS_MINE.invoke(null, true, true);
				return;
			}
			if (phpRespond.data.hash == escrowAdsMineHash) {
				GD.S_ESCROW_ADS_MINE.invoke(escrowAdsMine, true);
				return;
			}
			var escrowAdsPHP:Array = [];
			var l1:int = 0;
			if ("mine" in phpRespond.data && phpRespond.data.mine != null)
				l1 = phpRespond.data.mine.length;
			var l2:int = 0;
			var escrowAdsVO:EscrowAdsVO;
			for (var i:int = 0; i < l1; i++) {
				if (escrowAdsMine != null)
					l2 = escrowAdsMine.length;
				for (var j:int = l2; j > 0; j--) {
					if (escrowAdsMine[j - 1].uid != phpRespond.data.mine[i].uid)
						continue;
					escrowAdsPHP.push(escrowAdsMine[j - 1]);
					escrowAdsMine.removeAt(j - 1);
					break;
				}
				if (j == 0) {
					escrowAdsVO = createEscrowVO(phpRespond.data.mine[i]);
					if (escrowAdsVO != null)
						escrowAdsPHP.push(escrowAdsVO);
				}
			}
			clearEscrowAds(true);
			if (escrowInstruments == null) {
				escrowAdsMineLoadNeeded = true;
				GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
			}
			escrowAdsMine = escrowAdsPHP;
			escrowAdsMine.sortOn("created", Array.NUMERIC | Array.DESCENDING);
			escrowAdsPHP = null;
			GD.S_ESCROW_ADS_MINE.invoke(escrowAdsMine, true);
		}
		
		private function createEscrowVO(data:Object):EscrowAdsVO {
			var vo:EscrowAdsVO = new EscrowAdsVO(data);
			if (escrowInstruments != null) {
				var l:int = escrowInstruments.length;
				for (var i:int = 0; i < l; i++) {
					if (escrowInstruments[i].code == vo.crypto) {
						vo.instrument = escrowInstruments[i];
					}
				}
				if (vo.instrument == null) {
					vo.dispose();
					return null;
				}
			}
			vo.mine = vo.userUid == profile.uid;
			return vo;
		}
		
		private function clearEscrowAds(mine:Boolean = false):void {
			var arr:Array = (mine == true) ? escrowAdsMine : escrowAds;
			if (arr == null)
				return;
			while (arr.length != 0)
				arr.shift().dispose();
			if (mine == true)
				escrowAdsMine = null;
			else
				escrowAds = null;
		}
		
		public function close(escrowAdsUid:String):void {
			var escrowAdsVO:EscrowAdsVO = getEscrowAdsByUID(escrowAdsUid);
			if (escrowAdsVO != null) {
				if (escrowAdsVO.isRemoving == true)
					return;
				escrowAdsVO.isRemoving = true;
			}
			TweenMax.delayedCall(5, function():void {
				PHP.postEscrowAdsClose(onEscrowClosed, escrowAdsUid);
			} );
		}
		
		private function onEscrowClosed(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				if (phpRespond.errorMsg == "io") {
					DialogManager.alert(Lang.information, Lang.noInternetConnection);
				} else {
					var errorText:String = phpRespond.errorMsgLocalized;
					if (errorText == null)
					{
						ApplicationErrors.add();
						errorText = Lang.serverError + ": " + phpRespond.errorMsg;
					}
					DialogManager.alert(Lang.textError, errorText);
				}
				var escrowAdsVO:EscrowAdsVO = getEscrowAdsByUID(phpRespond.additionalData.qUID);
				if (escrowAdsVO != null) {
					escrowAdsVO.isRemoving = false;
					GD.S_ESCROW_ADS.invoke(escrowAds);
					GD.S_ESCROW_ADS_MINE.invoke(escrowAdsMine);
				}
				phpRespond.dispose();
				return;
			}
			onEscrowClosedProceed(phpRespond.additionalData.qUID, "removed");
			phpRespond.dispose();
		}
		
		private function onEscrowClosedProceed(escrowAdsUid:String, status:String = "resolved"):void {
			var escrowAdsVO:EscrowAdsVO;
			var l:int;
			var i:int
			if (escrowAds != null) {
				l = escrowAds.length;
				for (i = 0; i < l; i++) {
					escrowAdsVO = escrowAds[i];
					if (escrowAdsVO.uid == escrowAdsUid) {
						escrowAds.removeAt(i);
						GD.S_ESCROW_ADS.invoke(escrowAds);
						break;
					}
				}
			}
			if (escrowAdsMine != null) {
				l = escrowAdsMine.length;
				for (i = 0; i < l; i++) {
					escrowAdsVO = escrowAdsMine[i];
					if (escrowAdsVO.uid == escrowAdsUid) {
						escrowAdsMine.removeAt(i);
						GD.S_ESCROW_ADS_MINE.invoke(escrowAdsMine);
						break;
					}
				}
			}
		}
		
		private function getEscrowAdsByUID(escrowAdsUid:String, escrows:Array = null):EscrowAdsVO {
			var l:int;
			var i:int;
			if ((escrows == null || escrows == escrowAds) && escrowAds != null) {
				l = escrowAds.length;
				for (i = 0; i < l; i++) {
					if (escrowAds[i].uid == escrowAdsUid)
						return escrowAds[i];
				}
			}
			if ((escrows == null || escrows == escrowAds) && escrowAdsMine != null) {
				l = escrowAdsMine.length;
				for (i = 0; i < l; i++) {
					if (escrowAdsMine[i].uid == escrowAdsUid)
						return escrowAdsMine[i];
				}
			}
			return null;
		}
		
		private function createEscrowAds(escrowAdsVO:EscrowAdsVO):void {
			if (escrowAdsVO.side == null) {
				GD.S_ESCROW_ADS_CREATE_FAIL.invoke(Lang.escrow_fill_application_form);
				return;
			}
			if (escrowAdsVO.instrument == null) {
				GD.S_ESCROW_ADS_CREATE_FAIL.invoke(Lang.escrow_fill_application_form);
				return;
			}
			if (isNaN(escrowAdsVO.amount) == true) {
				GD.S_ESCROW_ADS_CREATE_FAIL.invoke(Lang.escrow_fill_application_form);
				return;
			}
			if (escrowAdsVO.currency == null) {
				GD.S_ESCROW_ADS_CREATE_FAIL.invoke(Lang.escrow_fill_application_form);
				return;
			}
			if (escrowAdsVO.priceValue == null) {
				GD.S_ESCROW_ADS_CREATE_FAIL.invoke(Lang.escrow_fill_application_form);
				return;
			}
			var escrowAdsCreationCheckAction:EscrowAdsCreationCheckAction = new EscrowAdsCreationCheckAction(escrowAdsVO);
			escrowAdsCreationCheckAction.disposeOnResult = true;
			escrowAdsCreationCheckAction.getSuccessSignal().add(onEscrowAdsCreationCheckSuccess);
			escrowAdsCreationCheckAction.getFailSignal().add(onEscrowAdsCreationCheckFail);
			escrowAdsCreationCheckAction.execute();
		}
		
		private function onEscrowAdsCreationCheckSuccess(escrowAdsVO:EscrowAdsVO):void {
			PHP.question_create(
				onQuestionCreated,
				Crypter.crypt("Escrow", MESSAGE_KEY),
				escrowAdsVO.amount,
				escrowAdsVO.instrument.code,
				escrowAdsVO.currency,
				false,
				escrowAdsVO.side,
				NaN,
				NaN,
				null,
				escrowAdsVO.priceValue
			);
		}
		
		private function onEscrowAdsCreationCheckFail(errorMessage:String):void {
			GD.S_ESCROW_ADS_CREATE_FAIL.invoke();
			GD.S_TOAST.invoke(errorMessage);
		}
		
		public function onQuestionCreated(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				var errorMsg:String = phpRespond.errorMsg;
				if (errorMsg.substr(0, 7) == "que..08")
					DialogManager.alert(Lang.textAlert, phpRespond.errorMsg.substr(8));
				if (errorMsg.substr(0, 7) == "que..17")
					DialogManager.alert(Lang.textAttention, Lang.questionOneByOne);
				if (errorMsg.substr(0, 7) == "que..16")
					DialogManager.alert(Lang.textAttention, Lang.questionYouAreBanned);
				if (errorMsg.substr(0, 7) == "que..23")
					DialogManager.alert(Lang.textAttention, Lang.questionHasUnpaid);
				if (errorMsg.substr(0, 7) == "que..04")
					DialogManager.alert(Lang.textAttention, Lang.noRights);
				if (errorMsg.substr(0, 7) == "que..24")
					DialogManager.alert(Lang.textAttention, Lang.questionNotEnoughMoney);
				if (errorMsg.substr(0, 7) == "que..28") {
					var errorText:String = Lang.questionWrongTipAmount;
					if (errorText.indexOf("3") != -1 && errorMsg != null && errorMsg.indexOf(",") != -1 && errorMsg.split(",") != null && errorMsg.split(",").length > 0) {
						errorText = errorText.replace("3", errorMsg.split(",")[1]);
					}
					DialogManager.alert(Lang.textAttention, errorText);
				}
				GD.S_ESCROW_ADS_CREATE_FAIL.invoke();
				phpRespond.dispose();
				errorMsg = "";
				return;
			}
			if (phpRespond.data == null) {
				DialogManager.alert(Lang.textWarning, Lang.serverError + " " + Lang.emptyData);
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data == false) {
				phpRespond.dispose();
				return;
			}
			onCreateQuestionSuccess(phpRespond.data);
			phpRespond.dispose();
		}
		
		private function onCreateQuestionSuccess(data:Object):void {
			var escrowAdsVO:EscrowAdsVO = new EscrowAdsVO(data);
			GD.S_ESCROW_ADS_CREATED.invoke(escrowAdsVO);
			//WSClient.call_blackHoleToGroup("que", "send", "mobile", WSMethodType.ESCROW_ADS_CREATED, { quid:escrowAdsVO.uid, senderUID:profile.uid } );
		}
	}
}