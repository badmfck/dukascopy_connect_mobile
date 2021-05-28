package com.dukascopy.connect.data.escrow 
{
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CryptoWalletData 
	{
		public var title:String;
		public var code:String;
		public var address:String;
		public var status:CryptoWalletStatus;
		
		public function CryptoWalletData(code:String, address:String, status:CryptoWalletStatus) 
		{
			if (Lang["currency_" + code] != null)
			{
				title = Lang["currency_" + code];
				if (Lang[code] != null)
				{
					title += " (" + Lang[code] + ")";
				}
				else
				{
					title += " (" + code + ")";
				}
			}
			else if (code != null)
			{
				title = code;
			}
			else
			{
				title = "no title";
				ApplicationErrors.add();
			}
			this.code = code;
			this.address = address;
			this.status = status;
		}
		
		public function getIcon():Sprite 
		{
			return UI.getInvestIconByInstrument(code);
		}
	}
}