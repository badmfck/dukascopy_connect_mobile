package com.dukascopy.connect.sys.photoGaleryManager.exif {
	
	public class Tags {
		
		[Embed(source = "assets/0th_ifd_tiff.xml")] public static const PRIMARY:Class;
		[Embed(source = "assets/0th_ifd_exif.xml")] public static const EXIF:Class;
		[Embed(source = "assets/0th_ifd_gps.xml")] public static const GPS:Class;
		[Embed(source = "assets/0th_ifd_int.xml")] public static const INTEROPERABILITY:Class;
		[Embed(source = "assets/1st_ifd_tiff.xml")] public static const THUMBNAIL:Class;
		
		private static const levels:Object = {
			"primary": PRIMARY,
			"exif": EXIF,
			"gps": GPS,
			"interoperability": INTEROPERABILITY,
			"thumbnail": THUMBNAIL
		};
		
		public static function getSet(level:String):* {
			if (!levels[level])
				return null;
			return XML(levels[level].data);
		}
	}
}