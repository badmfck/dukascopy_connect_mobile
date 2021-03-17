/**
 * Created by aleksei.leschenko on 11.10.2016.
 */
package com.dukascopy.connect.screens.payments.card {
	public class CardStatic {

		public static const  TYPE_ACTIVE :String  = "Active";
		
		public static const  STATUS_ACTIVE :String  = "A";
		public static const  STATUS_NEW :String  = "N";
		public static const  STATUS_SOFT_BLOCKED :String  = "S";
		public static const  STATUS_HARD_BLOCKED :String  = "H";
		
		public static const  STATUS_ORDERED :String  = "O";
		public static const  STATUS_ORDERED_NAME :String  = "Ordered";

		// My card statuses
		public static const  STATUS_NOT_VERIFIED :String  = "NOT VERIFIED"/*"PENDING"*/;
		public static const  STATUS_PENDING :String  = "PENDING"/*"CONFIRMED"*/;
		public static const  STATUS_VERIFIED :String  = "VERIFIED";
		public static const  STATUS_REJECTED :String  = "REJECTED";
		public static const  STATUS_CLOSED :String  = "Closed";

	}
}
