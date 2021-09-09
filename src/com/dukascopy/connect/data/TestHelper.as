package com.dukascopy.connect.data {
	
	import com.dukascopy.connect.sys.auth.Auth;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TestHelper {
		
		public static const numbers:Array = [
			{ code:"380", phone:"957999813", pass:"123456a"},
			{ code:"7", phone:"9999999955", pass:"Dukascopy123#"},
			{ code:"7", phone:"9996226225", pass:"Dukascopy123#"},
			{ code:"380", phone:"631686555", pass:"Dukascopy123#"},
			{ code: "7", phone: "9998181810", pass: "Dukascopy123" },
			{ code: "7", phone: "9999638920", pass: "Dukascopy123#" },
			{ code: "371", phone: "25914896", pass: "Dukascopy123" },
			{ code: "371", phone: "26884412", pass: "" }
		];
		
		public function TestHelper() {
			
		}
		
		static public function getPass():String {
			var phone:String = Auth.countryCode + Auth.getMyPhone();
			for (var i:int = 0; i < numbers.length; i++) {
				if (numbers[i].code + numbers[i].phone == phone) {
					return numbers[i].pass;
				}
			}
			return "";
		}
		
		static public function getPhones():Array {
			return numbers;
		}
	}
}