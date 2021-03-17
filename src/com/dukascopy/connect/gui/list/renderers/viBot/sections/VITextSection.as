package com.dukascopy.connect.gui.list.renderers.viBot.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class VITextSection extends VIAccountElementSectionBase {
		
		protected var textColor:uint;
		
		private var textFormat:TextFormat;
		
		protected var leftTextField:TextField;
		
		protected const V_PADDING:int = Config.FINGER_SIZE * .27;
		protected const H_PADDING:int = Config.FINGER_SIZE * .38;
		protected const FONT_SIZE_NORMAL:int = Config.FINGER_SIZE * .29;
		
		protected var dataField:String;
		
		protected var _fitToContent:Boolean;
		
		public function VITextSection() {
			super();
			
			textFormat = new TextFormat();
			textFormat.font = "Tahoma";
			textFormat.size = FONT_SIZE_NORMAL;
			textFormat.align = TextFormatAlign.LEFT;
			
			leftTextField = new TextField();
			leftTextField.x = BIRD_SIZE + H_PADDING;
			leftTextField.y = V_PADDING;
			leftTextField.defaultTextFormat = textFormat;
			leftTextField.multiline = true;
			leftTextField.wordWrap = true;
			addChild(leftTextField);
		}
		
		public function setFitToContent(val:Boolean = true):void {
			_fitToContent = val;
		}
		
		override public function setWidth(w:int):void {
			super.setWidth(w);
		}
		
		override public function setData(data:Object, field:String = null):Boolean {
			dataField = field;
			if (dataField == null)
				dataField = "message";
			if (dataField in data == false || data[dataField] == "" || data[dataField] == null)
				return false;
			
			this.data = data;
			
			return true;
		}
		
		override public function fillData(li:ListItem):void {
			isFirst = false;
			isLast = false;
			
			setColorScheme();
			renderContent(li);
			
			bottomCornerY = contentHeight - CORNER_RADIUS;
			trueHeight = contentHeight;
		}
		
		protected function renderContent(li:ListItem):void {
			if (data != null &&
				data[dataField] != null &&
				data[dataField] != "")
			{
				if (data[dataField] in Lang.viText == true &&
					Lang.viText[data[dataField]] != null &&
					Lang.viText[data[dataField]] != "")
				{
					leftTextField.text = Lang.viText[data[dataField]];
				}
				else
				{
					leftTextField.text = data[dataField];
				}
			}
			else
			{
				leftTextField.text = "";
				ApplicationErrors.add();
			}
				
			leftTextField.width = widthWithoutCorners;
			leftTextField.height = leftTextField.textHeight + 4;
			leftTextField.textColor = textColor;
			if (leftTextField.height + V_PADDING * 2 < CORNER_RADIUS_DOUBLE)
				leftTextField.y = int((CORNER_RADIUS_DOUBLE - leftTextField.height) * .5) + 1;
			else
				leftTextField.y = V_PADDING;
			contentHeight = leftTextField.height + V_PADDING * 2;
			fitToContent();
		}
		
		protected function fitToContent():void {
			if (_fitToContent == false)
				return
			trueWidth = leftTextField.textWidth + 4 + H_PADDING * 2 + BIRD_SIZE_DOUBLE;
			widthWithoutCorners = trueWidth - CORNER_RADIUS_DOUBLE - BIRD_SIZE_DOUBLE;
			right = trueWidth - BIRD_SIZE;
		}
		
		override protected function setColorScheme():void {
			bgColor = COLOR_WHITE;
			lineColor = COLOR_BLACK;
			lineAlpha = LINE_OPACITY_1;
		}
		
		override public function dispose():void {
			textFormat = null;
			
			UI.destroy(leftTextField);
			leftTextField = null;
			
			UI.destroy(this);
			super.dispose();
		}
		
		override public function getTextLineY():int {
			return leftTextField.y + leftTextField.getLineMetrics(0).ascent + 2;
		}
	}
}