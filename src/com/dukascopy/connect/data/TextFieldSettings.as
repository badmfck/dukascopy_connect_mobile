package com.dukascopy.connect.data 
{
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TextFieldSettings 
	{
		public var size:Number;
		public var text:String = "";
		public var color:Number = 0;
		public var align:String = TextFormatAlign.LEFT;
		
		public function TextFieldSettings(text:String = "", color:Number = 0, size:Number = 10, align:String = TextFormatAlign.LEFT) 
		{
			this.text = text;
			this.color = color;
			this.align = align;
			this.size = size;
		}
		
	}

}