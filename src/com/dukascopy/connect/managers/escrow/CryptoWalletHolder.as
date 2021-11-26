package com.dukascopy.connect.managers.escrow 
{
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.managers.escrow.vo.CryptoWallet;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.store.Store;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CryptoWalletHolder 
	{
		private var wallets:Vector.<CryptoWallet>;
		private var dataLoaded:Boolean;
		
		public function CryptoWalletHolder() 
		{
			addListeners();
		}
		
		private function addListeners():void 
		{
			Auth.S_NEED_AUTHORIZATION.add(clear);
			
			GD.S_CRYPTO_WALLET_REQUEST.add(getWallets);
			GD.S_CRYPTO_WALLET_ADD.add(addCryptoWallet);
		}
		
		private function clear():void 
		{
			wallets = null;
		}
		
		private function addCryptoWallet(crypto:String, walletAddress:String):void 
		{
			var exist:Boolean;
			if (wallets != null)
			{
				var l:int = wallets.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (wallets[i].wallet == walletAddress && wallets[i].crypto == crypto)
					{
						exist = true;
						break;
					}
				}
			}
			if (!exist)
			{
				var wallet:CryptoWallet = new CryptoWallet(crypto, walletAddress);
				if (wallets == null)
				{
					wallets = new Vector.<CryptoWallet>();
				}
				wallets.push(wallet);
				
				saveLocalData();
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function saveLocalData():void 
		{
			if (wallets != null)
			{
				Store.save(Store.CRYPTO_WALLETS, wallets, onLocalDataSaved);
			}
			else
			{
				Store.remove(Store.CRYPTO_WALLETS);
			}
		}
		
		private function onLocalDataSaved(error:Boolean):void 
		{
			
		}
		
		private function getWallets():void 
		{
			if (dataLoaded)
			{
				dispatchWallets();
			}
			else
			{
				Store.load(Store.CRYPTO_WALLETS, onLocalDataLoaded);
			}
		}
		
		private function onLocalDataLoaded(data:Object, error:Boolean):void 
		{
			dataLoaded = true;
			if (error == false)
			{
				if (data != null)
				{
					parseLocalData(data);
				}
			}
			dispatchWallets();
		}
		
		private function parseLocalData(value:Object):void 
		{
			if (value != null)
			{
				wallets = new Vector.<CryptoWallet>();
				for each (var item:Object in value) 
				{
					wallets.push(new CryptoWallet(item.crypto, item.wallet));
				}
			}
		}
		
		private function dispatchWallets():void 
		{
			GD.S_CRYPTO_WALLETS.invoke(wallets);
		}
	}
}