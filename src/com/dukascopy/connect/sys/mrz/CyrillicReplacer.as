package com.dukascopy.connect.sys.mrz{
	/**
	 * ...
	 * @author Igor Bloom
	 */
	public class CyrillicReplacer{
		
		static private var dictionary:Object = {
			"а":"a",
			"б":"b",
			"в":"v",
			"г":"g",
			"д":"d",
			"е":"e",
			"ё":"jo",
			"ж":"zh",
			"з":"z",
			"и":"i",
			"й":"j",
			"к":"k",
			"л":"l",
			"м":"m",
			"н":"n",
			"о":"o",
			"п":"p",
			"р":"r",
			"с":"s",
			"т":"t",
			"у":"u",
			"ф":"f",
			"х":"h",
			"ц":"c",
			"ч":"ch",
			"ш":"sh",
			"щ":"shh",
			"ъ":"",
			"ы":"y",
			"ь":"",
			"э":"e",
			"ю":"yu",
			"я":"ya",
			"A":"A",
			"Б":"B",
			"В":"V",
			"Г":"G",
			"Д":"D",
			"Е":"E",
			"Ё":"JO",
			"Ж":"ZH",
			"З":"Z",
			"И":"I",
			"Й":"J",
			"К":"K",
			"Л":"L",
			"М":"M",
			"Н":"N",
			"О":"O",
			"П":"P",
			"Р":"R",
			"С":"S",
			"Т":"T",
			"У":"U",
			"Ф":"F",
			"Х":"H",
			"Ц":"C",
			"Ч":"CH",
			"Ш":"SH",
			"Щ":"SHH",
			"Ъ":"",
			"Ы":"Y",
			"Ь":"",
			"Э":"E",
			"Ю":"YU",
			"Я":"YA"
		};


		static public function replace(str:String):String{
			
			//dictionary
			for(var n:String in dictionary){
				str=str.replace(new RegExp(n,"g"), dictionary[n]);
			}
			
			return str;
		}
		
	}

}