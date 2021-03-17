package com.dukascopy.connect.gui.list.renderers.bankAccountElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.BaseRenderer;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ListBankEmpty extends BaseRenderer implements IListRenderer {
		
		private var tf:TextField;
		
		public function ListBankEmpty() {
			tf = new TextField();
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .3, 0x373E4E, null, null, null, null, null, TextFormatAlign.CENTER);
			tf.multiline = true;
			tf.wordWrap = true;
			tf.text = Lang.noTransactionsYet.toUpperCase();
			tf.x = Config.DOUBLE_MARGIN;
			tf.y = Config.FINGER_SIZE;
			addChild(tf);
		}
		
		public function getHeight(li:ListItem, width:int):int {
			tf.width = width - Config.DOUBLE_MARGIN * 2;
			tf.height = tf.textHeight + 4;
			return tf.height + Config.FINGER_SIZE_DOUBLE;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			return this;
		}
		
		public function dispose():void {
			if (tf != null)
			{
				UI.destroy(tf);
				tf = null;
			}
		}
		
		public function get isTransparent():Boolean {
			return true;
		}
	}
}