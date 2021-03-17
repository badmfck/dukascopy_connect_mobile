package com.dukascopy.connect.sys.mrz {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.auth.Auth;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class MrzData {
		
		public var keys:flash.utils.Dictionary;
		
		private var _screenshot:String;
		private var _dateOfBirth:String;
		private var _dateExpired:String;
		private var _firstName:String;
		private var _lastName:String;
		private var _gender:String;
		private var _country:String;
		private var _docType:String;
		private var _docNumber:String;
		private var _personalNumber:String;
		private var _nationality:String;
		private var _mrzLine1:String;
		private var _mrzLine2:String;
		private var _mrzLine3:String;
		
		public function MrzData() { }
		
		public function update(data:Object):void {
			if ("secondary_identifier" in data == true)
				_firstName = data.secondary_identifier;
			else if ("first_name_mrz" in data == true)
				_firstName = data.first_name_mrz;
			
			if ("primary_identifier" in data == true)
				_lastName = data.primary_identifier;
			else if ("last_name_mrz" in data == true)
				_lastName = data.last_name_mrz;
			
			if ("date_of_birth" in data == true)
				_dateOfBirth = data.date_of_birth.substr(8, 2) + "." +
							   data.date_of_birth.substr(5, 2) + "." +
							   data.date_of_birth.substr(0, 4);
			else if ("birth_date_mrz" in data == true)
				_dateOfBirth = data.birth_date_mrz;
			
			if ("date_of_expiry" in data == true)
				_dateExpired = data.date_of_expiry.substr(8, 2) + "." +
							   data.date_of_expiry.substr(5, 2) + "." +
							   data.date_of_expiry.substr(0, 4);
			else if ("expiry_date_mrz" in data == true)
				_dateExpired = data.expiry_date_mrz;
			
			if ("type" in data == true)
				_docType = data.type;
			else if ("doc_type_code_mrz" in data == true)
				_docType = data.doc_type_code_mrz;
			
			if ("sex" in data == true)
				_gender = data.sex;
			else if ("gender_mrz" in data == true)
				_gender = data.gender_mrz;
			
			if ("issuing_country" in data == true)
				_country = data.issuing_country;
			else if ("issuer_mrz" in data == true)
				_country = data.issuer_mrz;
			
			if ("document_number" in data == true)
				_docNumber = data.document_number;
			else if ("number_mrz" in data == true)
				_docNumber = data.number_mrz;
			
			if ("personal_number" in data == true)
				_personalNumber = data.personal_number;
			else if ("opt_data_2_mrz" in data == true)
				_personalNumber = data.opt_data_2_mrz;
			
			if ("nationality" in data == true)
				_nationality = data.nationality;
			else if ("nationality_mrz" in data == true)
				_nationality = data.nationality_mrz;
			
			if ("lines" in data == true && data.lines != null && data.lines.length > 0)
				_mrzLine1 = data.lines[0];
			else if ("mrz_line1" in data == true)
				_mrzLine1 = data.mrz_line1;
			
			if ("lines" in data == true && data.lines != null && data.lines.length > 1)
				_mrzLine2 = data.lines[1];
			else if ("mrz_line2" in data == true)
				_mrzLine2 = data.mrz_line2;
				
			if ("lines" in data == true && data.lines != null && data.lines.length > 2)
				_mrzLine3 = data.lines[2];
			else if ("mrz_line3" in data == true)
				_mrzLine3 = data.mrz_line3;
			
			if ("document_screenshot" in data == true)
				_screenshot = data.document_screenshot;
		}
		
		public function get screenshot():String { return _screenshot; }
		public function get dateOfBirth():String {
			if (Config.isTest() == true && Auth.phone == 3807676868325)
				_dateOfBirth = "01.01." + (new Date().getFullYear() - (Config.MAX_OPEN_ACC_AGE - 1));
			return _dateOfBirth;
		}
		public function get dateExpired():String { return _dateExpired; }
		public function get firstName():String { return _firstName; }
		public function get lastName():String { return _lastName; }
		public function get gender():String { return _gender; }
		public function get country():String { return _country; }
		public function get docType():String { return _docType; }
		public function get docNumber():String { return _docNumber; }
		public function get personalNumber():String { return _personalNumber; }
		public function get nationality():String { return _nationality; }
		public function get mrzLine1():String { return _mrzLine1; }
		public function get mrzLine2():String { return _mrzLine2; }
		public function get mrzLine3():String { return _mrzLine3; }
		public function get mrzLines():String {
			var res:String;
			if (_mrzLine1 != null && _mrzLine1 != "")
				res = _mrzLine1;
			if (_mrzLine2 != null && _mrzLine2 != "")
				res += _mrzLine2;
			if (_mrzLine3 != null && _mrzLine3 != "")
				res += _mrzLine3;
			return res;
		}
	}
}