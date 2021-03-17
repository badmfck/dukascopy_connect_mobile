package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class RtoAgreementData 
	{
		public var clientName:String;
		public var birthDate:String;
		public var citizenship:String;
		public var homeAddress:String;
		public var date:String;
		
		public function RtoAgreementData(rawData:Object = null) {
			if (rawData != null) {
				clientName = rawData.clientName;
				birthDate = rawData.birthDate;
				citizenship = rawData.citizenship;
				homeAddress = rawData.homeAddress;
				date = rawData.date;
			}
		}
		
		public function toObject():Object 
		{
			return { clientName:clientName,	birthDate:birthDate, citizenship:citizenship, homeAddress:homeAddress, date:date };
		}
	}
}