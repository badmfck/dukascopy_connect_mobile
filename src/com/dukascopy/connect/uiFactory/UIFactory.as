package com.dukascopy.connect.uiFactory {
	
	import com.dukascopy.connect.Config;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class UIFactory {
		
		static public function createTextField(fontSize:int = -1, multiline:Boolean = false, autosize:Boolean = false):TextField {
			if (fontSize == -1)
				fontSize = Config.FINGER_SIZE * .3;
			var tf:TextField = new TextField();
			tf.multiline = multiline;
			if (multiline)
				tf.wordWrap = true;
			tf.defaultTextFormat = new TextFormat("Tahoma", fontSize);
			tf.text = '|`qI';
			tf.selectable = false;
			tf.cacheAsBitmap = true;
			tf.height = tf.textHeight + 4;
			if (autosize == true)
				tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = "";
			return tf;
		}
	}
}