package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.data.escrow.CryptoWalletData;
	import com.dukascopy.connect.data.escrow.CryptoWalletStatus;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class ListCryptoWallet extends ListPayCurrency implements IListRenderer {
		
		private var formatWallet:TextFormat = new TextFormat(Config.defaultFontName, FontSize.SUBHEAD, Style.color(Style.COLOR_SUBTITLE));
		
		public function ListCryptoWallet() {
			super();
			
			tfLabel.defaultTextFormat = formatWallet;
			tfLabel.autoSize = TextFieldAutoSize.NONE;
		}
		
		override public function dispose():void {
			super.dispose();
			formatWallet = null;
		}
		
		override protected function getItemData(data:Object):Object 
		{
			if (data is CryptoWalletData)
			{
				return (data as CryptoWalletData).title;
			}
			return data;
		}
		
		override public function getView(li:ListItem, h:int, w:int, highlight:Boolean = false):IBitmapDrawable {
			super.getView(li, h, w, highlight);
			
			var data:CryptoWalletData = li.data as CryptoWalletData;
			tfName.text = data.title;
			var walletText:String;
			if (data.status == CryptoWalletStatus.ready && data.address != null)
			{
				walletText = data.address;
			}
			else if (data.status == CryptoWalletStatus.linkageRequired)
			{
				walletText = "<font color='#CD3F43'>" + Lang.linkage_required + "</font>";
			}
			else
			{
				walletText = "";
			}
			tfLabel.width = w - tfLabel.x - Config.DIALOG_MARGIN;
			tfLabel.htmlText = walletText;
			updatePositions(h, w);
			return this;
		}
		
		override public function getHeight(data:ListItem, width:int):int {
			return Config.FINGER_SIZE * 1.3;
		}
		
		override protected function drawIcon(li:ListItem, h:int):void 
		{
			flagIcon.removeChildren();
			if (li.data != null && li.data is CryptoWalletData){
				flagIcon.visible = true;
				var flagAsset:Sprite = UI.getInvestIconByInstrument((li.data as CryptoWalletData).code);
				UI.scaleToFit(flagAsset, ICON_SIZE, ICON_SIZE);
				flagIcon.addChild(flagAsset);
				
				flagIcon.y = int(h * .5 - ICON_SIZE * .5 - Config.FINGER_SIZE * .01);
				flagIcon.x = padding;
				
				tfName.x = flagIcon.x + flagIcon.width + padding;
				tfLabel.x = flagIcon.x + flagIcon.width + padding;
			}else{
				tfName.x = padding;
				tfLabel.x = padding;
			}
		}
		
		override protected function updatePositions(h:int, w:int):void 
		{
			tfLabel.y = int(h * .5 + Config.FINGER_SIZE * .01);
			tfLabel.width = w - tfLabel.x - padding;
			
			tfName.y = int(h * .5 - tfName.height);
		}
	}
}