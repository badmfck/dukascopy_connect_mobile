package com.dukascopy.connect.data 
{
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.vo.ChatVO;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowScreenData 
	{
		public var escrowOffer:EscrowMessageData;
		public var chat:ChatVO;
		public var userName:String;
		public var callback:Function;
		public var created:Number;
		public var messageId:Number;
		public var instrument:EscrowInstrument;
		public var title:String;
		
		public function EscrowScreenData() 
		{
			
		}
	}
}