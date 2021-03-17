package com.dukascopy.connect.gui.components.selector 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CategorySelectorItem extends Sprite implements ISelectorItem
	{
		private var textFormat:TextFormat;
		private var countTextFormat:TextFormat;
		private  var _labelField:TextField;
		private  var _countField:TextField;
		private var back:Sprite;
		
		private var verticalPadding:int;
		private var horizontalPadding:int;
		private var smallHorizontalPadding:int;
		private var smallRadius:int = 0;
		private var bigRadius:int = 0;
		
		
		public function CategorySelectorItem() {
			textFormat = new TextFormat();
			textFormat.size = Config.FINGER_SIZE * .35;			
			countTextFormat = new TextFormat();			
			countTextFormat.size = Config.FINGER_SIZE * .17;
			smallHorizontalPadding = Config.FINGER_SIZE * .07;
			
			back = new Sprite();
			addChild(back);
			_labelField = new TextField();
			_countField = new TextField();			
			
			verticalPadding = Config.FINGER_SIZE * .1;
			horizontalPadding = Config.FINGER_SIZE * .25;
		}
		
		
		/**
		 * TODO call this when no longer needed
		 */
		public function dispose():void {
			if (_labelField != null){
				UI.destroy(_labelField);
				_labelField = null;
			}			
			if (_countField != null){
				UI.destroy(_countField);
				_countField = null;
			}			
			if (textFormat != null){
				textFormat = null;
			}
			if (countTextFormat != null){
				countTextFormat = null;
			}
			UI.destroy(back);
		}
		
		public function render(data:SelectorItemData, select:Boolean = false):ImageBitmapData {
			if (!data)
				return null;
			
			back.graphics.clear();	
			countTextFormat.color = (select == true) ? Style.color(Style.COLOR_BACKGROUND) : Style.color(Style.COLOR_SUBTITLE);
			textFormat.color = (select == true) ? Style.color(Style.COLOR_TEXT) : Style.color(Style.COLOR_SUBTITLE);
			
			_labelField.text = data.data.name;
			_labelField.setTextFormat(textFormat);
			_labelField.width = _labelField.textWidth + 4;
			_labelField.height = _labelField.textHeight + 4;
			_labelField.x = horizontalPadding;
			_labelField.y = verticalPadding;
			
			_countField.text = data.data.total;
			_countField.setTextFormat(countTextFormat);
			_countField.width = _countField.textWidth + 4;
			_countField.height = _countField.textHeight + 4;
			_countField.x = _labelField.x + _labelField.width;
			
			back.addChild(_labelField);
			back.addChild(_countField);			
			
			smallRadius = Config.FINGER_SIZE * .2;
			bigRadius = Config.FINGER_SIZE * .6;
			if (select) {
				textFormat.color = Style.color(Style.COLOR_BACKGROUND);
				back.graphics.beginFill(0xFFC600);
				back.graphics.drawRoundRect(0, 0, _labelField.width + horizontalPadding * 2, _labelField.height + verticalPadding * 2, bigRadius, bigRadius);
				back.graphics.beginFill(Color.RED);
				back.graphics.drawRoundRect(_countField.x-smallHorizontalPadding, _countField.y, _countField.width+smallHorizontalPadding*2 , _countField.height, smallRadius,smallRadius);
				back.graphics.endFill();
			} else {
				textFormat.color = Style.color(Style.COLOR_SUBTITLE);
				back.graphics.beginFill(0xFFC600);
				back.graphics.drawRoundRect(0, 0, _labelField.width + horizontalPadding * 2, _labelField.height + verticalPadding * 2, bigRadius, bigRadius);
				back.graphics.drawRoundRect(2, 2, _labelField.width + horizontalPadding * 2-4, _labelField.height + verticalPadding * 2-4, bigRadius-2, bigRadius-2);
				back.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				back.graphics.drawRoundRect(_countField.x-smallHorizontalPadding, _countField.y, _countField.width+smallHorizontalPadding*2 , _countField.height, smallRadius, smallRadius);
				back.graphics.endFill();
			}			
			var bitmapData:ImageBitmapData = new ImageBitmapData("TextSelectorItem", _labelField.width + _countField.width+horizontalPadding+smallHorizontalPadding*2,_labelField.height + verticalPadding * 2, Config.FINGER_SIZE * .6);
			//var bitmapData:ImageBitmapData = new ImageBitmapData("TextSelectorItem", _labelField.width +horizontalPadding*2,_labelField.height + verticalPadding * 2, Config.FINGER_SIZE * .6);
			bitmapData.drawWithQuality(back, null,null,null,null,false,StageQuality.HIGH);			
			return bitmapData;
		}
	}
}