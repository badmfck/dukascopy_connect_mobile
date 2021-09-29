package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
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
			tfLabel.multiline = true;
			tfLabel.wordWrap = true;
		}
		
		override public function dispose():void {
			super.dispose();
			formatWallet = null;
		}
		
		override protected function getItemData(data:Object):Object 
		{
			if (data is EscrowInstrument)
			{
				return (data as EscrowInstrument).name;
			}
			return data;
		}
		
		override public function getView(li:ListItem, h:int, w:int, highlight:Boolean = false):IBitmapDrawable {
			super.getView(li, h, w, highlight);
			setTexts(li, w);
			updatePositions(h, w);
			return this;
		}
		
		private function setTexts(li:ListItem, w:int):void 
		{
			var data:EscrowInstrument = li.data as EscrowInstrument;
			tfName.text = data.name;
			
			var text:String = data.name;
			var code:String = data.code;
			if (Lang[code] != null && Lang[code] != "")
			{
				code = Lang[code];
			}
			if (text != code)
			{
				text += " (" + code + ")";
			}
			
			var walletText:String;
			if (data.isLinked && data.wallet != null)
			{
				walletText = data.wallet;
			}
			else if (!data.isLinked)
			{
				walletText = "";
			//	walletText = "<font color='#CD3F43'>" + Lang.linkage_required + "</font>";
			}
			else
			{
				walletText = "";
			}
			tfLabel.width = w - tfLabel.x - Config.DIALOG_MARGIN;
			tfName.width = w - tfName.x - Config.DIALOG_MARGIN;
			
			tfLabel.htmlText = walletText;
			tfLabel.height = tfLabel.textHeight + 6;
		}
		
		override public function getHeight(data:ListItem, w:int):int {
			
			drawIcon(data, 0);
			setTexts(data, w);
			updatePositions(0, w);
			return int(tfName.height + tfLabel.height - 8 + Config.FINGER_SIZE * .5);
		}
		
		override protected function drawIcon(li:ListItem, h:int):void 
		{
			flagIcon.removeChildren();
			if (li.data != null && li.data is EscrowInstrument){
				flagIcon.visible = true;
				var flagAsset:Sprite = UI.getInvestIconByInstrument((li.data as EscrowInstrument).code);
				if (flagAsset != null)
				{
					UI.scaleToFit(flagAsset, ICON_SIZE, ICON_SIZE);
					flagIcon.addChild(flagAsset);
					
					flagIcon.y = int(h * .5 - ICON_SIZE * .5 - Config.FINGER_SIZE * .01);
					flagIcon.x = padding;
					
					tfName.x = flagIcon.x + flagIcon.width + padding;
					tfLabel.x = flagIcon.x + flagIcon.width + padding;
				}
				else
				{
					tfName.x = padding;
					tfLabel.x = padding;
				}
				
			}else{
				tfName.x = padding;
				tfLabel.x = padding;
			}
		}
		
		override protected function updatePositions(h:int, w:int):void 
		{
			tfName.y = int(Config.FINGER_SIZE * .2);
			tfLabel.y = int(tfName.y + tfName.height - 8 + Config.FINGER_SIZE * .13);
		}
	}
}