package com.dukascopy.connect.managers.escrow {
	
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsCryptoVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsFilterVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class EscrowAdsManager {
		
		private static var escrowAdsCryptosIdsLoadedFromStore:Boolean;
		
		private var escrowAdsCryptosIds:Object;
		private var escrowAdsCryptos:Array/*EscrowAdsCryptoVO*/;
		private var escrowInstruments:Vector.<EscrowInstrument>;
		private var escrowInstrumentsHash:String = "";
		private var escrowAdsFilter:EscrowAdsFilterVO = new EscrowAdsFilterVO();
		
		public function EscrowAdsManager() {
			GD.S_ESCROW_ADS_CRYPTOS_REQUEST.add(onEscrowAdsCryptosRequested);
			GD.S_ESCROW_ADS_INSTRUMENT_SELECTED.add(saveEscrowAdsCryptoID);
			GD.S_ESCROW_ADS_FILTER_REQUEST.add(onEscrowAdsFilterRequested);
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
			escrowAdsCryptosIds[crypto] = escrowAdsCrypto.maxID;
			escrowAdsFilter.instrument = escrowAdsCrypto.instrument;
			Store.save("escrowAdsCryptoIds", escrowAdsCryptosIds);
			GD.S_ESCROW_INSTRUMENTS.remove(onEscrowInstrumentsReceived);
			GD.S_SHOW_ESCROW_ADS.invoke(escrowAdsFilter);
		}
		
		private function onEscrowAdsCryptosRequested():void {
			GD.S_ESCROW_INSTRUMENTS.add(onEscrowInstrumentsReceived);
			if (escrowAdsCryptosIdsLoadedFromStore == true) {
				PHP.escrow_getStat(onEscrowAdsCryptosReceived);
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
				GD.S_ESCROW_ADS_CRYPTOS.invoke(null);
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
		}
		
		private function onEscrowAdsCryptosReceived(phpRespond:PHPRespond):void {
			clearEscrowAdsCryptos();
			if (phpRespond.error == true) {
				ToastMessage.display(Lang.somethingWentWrong);
			}
			if (phpRespond.data == null || phpRespond.data.length == 0) {
				GD.S_ESCROW_ADS_CRYPTOS.invoke(null);
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
						escrowAdsCryptos.push(new EscrowAdsCryptoVO(phpRespond.data[i]));
						break;
					}
				}
				if (exist == false) {
					escrowAdsCryptos.push(new EscrowAdsCryptoVO( {
						instrument:escrowInstruments[i]
					} ));
				}
			}
			GD.S_ESCROW_ADS_CRYPTOS.invoke(escrowAdsCryptos);
		}
		
		private function clearEscrowAdsCryptos():void {
			if (escrowAdsCryptos == null)
				return;
			var l:int = escrowAdsCryptos.length;
			while (escrowAdsCryptos.length != 0)
				escrowAdsCryptos.shift().dispose();
			escrowAdsCryptos = null;
		}
		
// <-- ESCROW ADVERTISING CRYPTO //
		
	}
}