package com.dukascopy.connect.gui.list.renderers 
{
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.vo.users.adds.ContactSearchVO;
	import flash.display.IBitmapDrawable;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Anton Bodrychenko
	 */
	public class ListContactSearch extends ListContact
	{
		
		public function ListContactSearch() 
		{
			
		}
		
		override public function getView(data:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			super.getView(data, height, width, highlight);
			
			const searchText:String = (data.data as ContactSearchVO).searchText;
			
			highlightTextField(fxnme, 	searchText);
			highlightTextField(nme, 	searchText);
			
			return this;
		}
		
		private function highlightTextField(textField:TextField, textToHighlight:String, matchCase:Boolean = false):void 
		{
			if (textToHighlight == null) return;
			if (textToHighlight == "") return;
			
			const highlightFormat:TextFormat = textField.getTextFormat();
			highlightFormat.color = Color.RED;
			
			if(matchCase){
				if (textField.text.indexOf(textToHighlight) == -1) return;
				textField.setTextFormat(highlightFormat, textField.text.indexOf(textToHighlight), textField.text.indexOf(textToHighlight) + textToHighlight.length);
			}
			if(!matchCase){
				if (textField.text.toLowerCase().indexOf(textToHighlight.toLowerCase()) == -1) return;
				textField.setTextFormat(highlightFormat, textField.text.toLowerCase().indexOf(textToHighlight.toLowerCase()), textField.text.toLowerCase().indexOf(textToHighlight.toLowerCase()) + textToHighlight.length);
			}
		}
		
	}

}