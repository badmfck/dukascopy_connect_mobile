package com.dukascopy.connect.utils {
	
	import com.dukascopy.connect.managers.els.ELSManager;
	import com.dukascopy.connect.managers.els.IELSManager;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class Services {
		
		private static var _ELS:IELSManager;
		public static function get ELS():IELSManager {
			if (_ELS == null)
				_ELS = new ELSManager();
			return _ELS;
		}
	}
}