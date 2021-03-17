package com.dukascopy.connect.vo.chat {
	
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class PuzzleMessageVO {
		
		private var _amount:Number;
		private var _currency:String;
		private var _isPaid:Boolean;
		
		public function PuzzleMessageVO(data:Object) {
			if (data == null)
				return;
			
			_amount = data.amount;
			_currency = data.currency;
			_isPaid =  data.isPaid;
		}
		
		public function get amount():Number 
		{
			return _amount;
		}
		
		public function set amount(value:Number):void 
		{
			_amount = value;
		}
		
		public function get currency():String 
		{
			return _currency;
		}
		
		public function set currency(value:String):void 
		{
			_currency = value;
		}
		
		public function get isPaid():Boolean 
		{
			return _isPaid;
		}
		
		public function set isPaid(value:Boolean):void 
		{
			_isPaid = value;
		}
	}
}