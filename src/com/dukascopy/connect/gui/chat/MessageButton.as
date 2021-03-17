package com.dukascopy.connect.gui.chat 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.customActions.CallGetEuroAction;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class MessageButton extends Sprite
	{
		private var icon:Sprite;
		private var back:Sprite;
		private var text:Bitmap;
		private var backgroundColor:Number = 0xfff000;
		private var fontSize:Number  = 9;
		private var textMargin:Number  = 5;
		private var textBoxRadius:int = 5;
		
		public function MessageButton() 
		{
			create();
		}
		
		private function create():void 
		{
			back = new Sprite();
			addChild(back);
			
			text = new Bitmap();
			addChild(text);
				
			fontSize = Math.ceil(Config.FINGER_SIZE * .25);
			if (fontSize < 9)
				fontSize = 9;
			textMargin = Math.ceil(Config.FINGER_SIZE * .2);
			textBoxRadius = Math.ceil(Config.FINGER_SIZE * .25);
			
		}
		
		
		public function setData(action:IScreenAction, itemWidth:int):void {
			clean();
			
			if (action is CallGetEuroAction) {
				text.bitmapData = TextUtils.createTextFieldData(
																"<u>" + (action.getData() as String) + "</u>", 
																itemWidth - textMargin*2, 															
																10, 
																true, 
																TextFormatAlign.LEFT, 
																TextFieldAutoSize.LEFT,
																fontSize,														
																true, 0x0051CA,
																backgroundColor, 
																true, 
																true, 
																false);
				back.graphics.clear();
				back.graphics.beginFill(backgroundColor);
				back.graphics.drawRoundRect(0, 0, itemWidth, text.height + textMargin*2, textBoxRadius*2, textBoxRadius*2);
				back.graphics.endFill();
				
				text.x = textMargin;
				text.y = int(back.height * .5 - text.height * .5);
			} else {
				icon = new (action.getIconClass())();
				var ct:ColorTransform = new ColorTransform();
				ct.color = 0x0051CA;
				icon.transform.colorTransform = ct;
				addChild(icon);
				
				UI.scaleToFit(icon, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
				
				text.bitmapData = TextUtils.createTextFieldData(
																"<u>" + (action.getData() as String) + "</u>", 
																itemWidth - textMargin*3, 
																10, 
																true, 
																TextFormatAlign.LEFT, 
																TextFieldAutoSize.LEFT, 
																fontSize,
																true, 0x0051CA,
																backgroundColor, 
																true, 
																true, 
																false);
				back.graphics.clear();
				back.graphics.beginFill(backgroundColor);
				back.graphics.drawRoundRect(0, 0, itemWidth, Math.max(text.height, icon.height) + textMargin * 2, textBoxRadius*2, textBoxRadius*2);
				back.graphics.endFill();
				
				icon.x = textMargin;
				icon.y = textMargin;
				
				text.x = int(icon.x + icon.width + textMargin);
				text.y = int(back.height * .5 - text.height * .5);
			}
		}
		
		private function clean():void 
		{
			if (icon)
			{
				removeChild(icon);
				icon = null;
			}
			if (text && text.bitmapData)
			{
				text.bitmapData.dispose();
				text.bitmapData = null;
			}
		}
		
		public function dispose():void {
			clean();
			if (back) {
				UI.destroy(back);
			}
		}
	}
}