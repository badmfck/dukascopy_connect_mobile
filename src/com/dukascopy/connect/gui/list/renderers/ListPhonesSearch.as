package com.dukascopy.connect.gui.list.renderers 
{
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.vo.users.adds.ContactSearchVO;
	import flash.display.IBitmapDrawable;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Anton Bodrychenko
	 */
	public class ListPhonesSearch extends ContactListRenderer
	{
		
		public function ListPhonesSearch() 
		{
			
		}
		
		override public function getView(data:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable
		{
			super.getView(data, height, width, highlight);
			
			if ((data.data is ContactSearchVO) == false) return this;
			const searchText:String = (data.data as ContactSearchVO).searchText;
			
			highlightMatchingText(searchText);
			return this;
		}
		
		public function highlightMatchingText(textToHighlight:String, matchCase:Boolean = false):void 
		{
			highlightTextField(fxnme, textToHighlight);
			highlightTextField(nme, textToHighlight);
		}
		
		public function highlightTextField(textField:TextField, textToHighlight:String, matchCase:Boolean = false):void 
		{
			if (textToHighlight == null) return;
			if (textToHighlight == "") return;
			
			const highlightFormat:TextFormat = textField.getTextFormat();
			highlightFormat.color = MainColors.RED;
			
			if(matchCase){
				if (textField.text.indexOf(textToHighlight) == -1) return;
				textField.setTextFormat(highlightFormat, textField.text.indexOf(textToHighlight), textField.text.indexOf(textToHighlight) + textToHighlight.length);
			}
			if(!matchCase){
				if (textField.text.toLowerCase().indexOf(textToHighlight.toLowerCase()) == -1) return;
				textField.setTextFormat(highlightFormat, textField.text.toLowerCase().indexOf(textToHighlight.toLowerCase()), textField.text.toLowerCase().indexOf(textToHighlight.toLowerCase()) + textToHighlight.length);
			}
		}
		
		override protected function getItemData(itemData:Object):Object 
		{
			if (itemData is ContactSearchVO) return itemData.entry;
			return itemData;
		}
		
	}

}