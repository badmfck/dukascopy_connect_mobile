package com.dukascopy.connect.gui.components.radio 
{
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RadioItem extends Sprite
	{
		private var baseState:Bitmap;
		private var selectedState:Bitmap;
		private var text:Bitmap;
		
		public function RadioItem() 
		{
			baseState = new Bitmap();
			addChild(baseState);
			
			selectedState = new Bitmap();
			addChild(selectedState);
			
			text = new Bitmap();
			addChild(text);
			
			selectedState.visible = false;
		}
		
		public function activate():void
		{
			
		}
		
		public function deactivate():void
		{
			
		}
		
		public function dispose():void
		{
			if (baseState != null)
			{
				UI.destroy(baseState);
				baseState = null;
			}
			if (selectedState != null)
			{
				UI.destroy(selectedState);
				selectedState = null;
			}
			if (text != null)
			{
				UI.destroy(text);
				text = null;
			}
		}
		
		public function draw(selectorItemData:SelectorItemData, itemWidth:int):void 
		{
			
		}
	}
}