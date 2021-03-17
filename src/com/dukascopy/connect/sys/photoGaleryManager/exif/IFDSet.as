package com.dukascopy.connect.sys.photoGaleryManager.exif {
	
	public class IFDSet extends Object {
		
		internal var _primary:IFD;
		internal var _exif:IFD;
		internal var _gps:IFD;
		internal var _thumbnail:IFD;
		internal var _interoperability:IFD;
		
		public function IFDSet() { }
		
		public function get primary():IFD { return _primary; }
		public function get exif():IFD { return _exif; }
		public function get gps():IFD { return _gps; }
		public function get thumbnail():IFD { return _thumbnail; }
		public function get interoperability():IFD { return _interoperability; }
	}
}
