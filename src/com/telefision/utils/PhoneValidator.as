package com.telefision.utils {
	
	/**
	 * ...
	 * @author Alexey
	 */
	
	public class PhoneValidator {
		
		public static function isValidPhoneNumber(phoneNumber:String):Boolean {
			var countryCode:String  = "((\\+|00)?([1-9]|[1-9][0-9]|[1-9][0-9]{2}))";
			var num:String = "([0-9]{3,10})";
			phoneNumber = phoneNumber.match(/[\+\d]/g).join('');
			var phone:RegExp = new RegExp("^" + countryCode + num +"$");
			return phone.test(phoneNumber);
		}
	}
}