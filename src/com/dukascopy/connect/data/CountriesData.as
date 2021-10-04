package com.dukascopy.connect.data {
	
	/**
	 * @author IGOR BLOOM
	 */
	public class CountriesData {
		
		public function CountriesData() { }
		
		static private var inited:Boolean;
		public static function get COUNTRIES():Array {
			if (inited == false) {
				inited = true;
				var i:int = 0;
				var j:int = _COUNTRIES.length;
				for (i; i < j; i++) {
					_COUNTRIES[i][4] = _COUNTRIES[i][0];
					_COUNTRIES[i][0] = _COUNTRIES[i][0].toLowerCase();
				}
			}
			return _COUNTRIES;
		}

		private static const _COUNTRIES:Array = [		
			['Afghanistan', 'AF', 'AFG', '93'], // 5
			['Albania', 'AL', 'ALB', '355'], // 3
			['Algeria', 'DZ', 'DZA', '213'], // 3
			['American Samoa', 'AS', 'ASM', '1684'], // 4
			['Andorra', 'AD', 'AND','376'], // 1
			['Angola', 'AO', 'AGO', '244'], // 3
			['Anguilla', 'AI', 'AIA', '1264'], // 4
			['Antigua and Barbuda', 'AG', 'ATG', '1268'], //4
			['Argentina', 'AR', 'ARG', '54'], // 2
			['Armenia', 'AM', 'ARM', '374'], // 3
			['Aruba', 'AW', 'ABW', '297'], // 4
			['Australia', 'AU', 'AUS', '61'],// 1
			['Austria', 'AT', 'AUT', '43'], // 1
			['Azerbaijan', 'AZ', 'AZE', '994'], // 3
			['Bahamas', 'BS', 'BHS', '1242'], // 3
			['Bahrain', 'BH', 'BHR', '973'], // 1
			['Bangladesh', 'BD', 'BGD', '880'], // 3
			['Barbados', 'BB', 'BRB', '1246'], // 2
			['Belarus', 'BY', 'BLR', '375'],// 3
			['Belgium', 'BE', 'BEL', '32'],// 1
			['Belize', 'BZ', 'BLZ', '501'],	// 2
			['Benin', 'BJ', 'BEN', '229'], // 3
			['Bermuda','BM','BMU','1441'], // 3
			['Bhutan','	BT','BTN','975'], // 3
			['Bolivia','BO','BOL','591'],// 3
			['Bosnia and Herzegovina', 'BA', 'BIH', '387'], // 3
			['Botswana','BW','BWA','267'],// 3
			['Brazil','	BR','BRA','55'], // 1
			['British Virgin Islands','	VG','VGB','1284'], //3
			['Brunei','	BN','BRN','673'],// 1
			['Bulgaria','BG','BGR','359'],// 2
			['Burkina Faso','BF','BFA','226'],// 3
			['Burma (Myanmar)','MM','MMR','95'],// 3
			['Burundi','BI','BDI','257'],// 3
			['Cambodia','KH','KHM','855'],// 3
			['Cameroon','CM','CMR','237'],// 3
			['Canada','CA','CAN','1'],// 1
			['Cape Verde','CV','CPV','238'],// 3
			['Cayman Islands','KY','CYM','1345'],// 4
			['Central African Republic','CF','CAF','236'],// 4
			['Chad','TD','TCD','235'],// 4
			['Chile','CL','CHL','56'],// 1
			['China','CN','CHN','86'],// 1
			['Christmas Island','CX','CXR','61'],// 4
			['Cocos (Keeling) Islands','CC','CCK','61'],// 4
			['Colombia','CO','COL','57'],// 2
			['Comoros','KM','COM','269'],// 5
			['Cook Islands','CK','COK','682'],//4
			['Costa Rica','CR','CRC','506'],// 2
			['Croatia','HR','HRV','385'],// 1
			['Cuba','CU','CUB','53'],// 5
			['Cyprus','CY','CYP','357'],// 1
			['Czech Republic','CZ','CZE','420'],// 1
			['Democratic Republic of the Congo','CD','COD','243'], // 4
			['Denmark','DK','DNK','45'], // 1
			['Djibouti','DJ','DJI','253'],// 3
			['Dominica', 'DM', 'DMA', '1767'],// 3
			['Dominican','DO','DOM','1809'], // 4
			['Dominican Republic','DO','DOM','1829'], // 4
			['Ecuador','EC','ECU','593'], // 2
			['Egypt','EG','EGY','20'],// 2
			['El Salvador','SV','SLV','503'],// 2
			['Equatorial Guinea','GQ','GNQ','240'],// 4
			['Eritrea','ER','ERI','291'],// 4
			['Estonia','EE','EST','372'],// 1
			['Ethiopia','ET','ETH','25'],// 3
			['Falkland Islands','FK','FLK','500'],// 4
			['Faroe Islands','FO','FRO','298'],// 1
			['Fiji','FJ','FJI','679'],// 3
			['Finland','FI','FIN','358'],// 1
			['France','FR','FRA','33'],// 1
			['French Polynesia','PF','PYF','689'],// 4
			['French Guiana','GF','GFA','594'],// 4
			['Gabon','GA','GAB','241'],// 3
			['Gambia','GM','GMB','220'],// 3
			['Georgia','GE','GEO','995'],// 3
			['Germany','DE','DEU','49'],// 1
			['Ghana','GH','GHA','233'],// 3
			['Gibraltar','GI','GIB','350'],// 1
			['Greece','GR','GRC','30'],// 1
			['Greenland','GL','GRL','299'],// 1
			['Grenada','GD','GRD','1473'],// 4
			['Guam','GU','GUM','1671'],// 4
			['Guatemala','GT','GTM','502'],// 2
			['Guinea','GN','GIN','224'],// 3
			['Guinea-Bissau','GW','GNB','245'],// 3
			['Guyana','GY','GUY','592'],// 2
			['Haiti','HT','HTI','509'],// 4
			['Holy See (Vatican City)','VA','VAT','39'],// 1
			['Honduras','HN','HND','504'],// 2
			['Hong Kong','HK','HKG','852'],// 1
			['Hungary','HU','HUN','36'],// 1
			['Iceland','IS','IS','354'],// 1
			['India','IN','IND','91'],// 1
			['Indonesia','ID','IDN','62'],// 2
			['Iran','IR','IRN','98'],// 5
			['Iraq','IQ','IRQ','964'],// 4
			['Ireland','IE','IRL','353'],// 1
			['Isle of Man','IM','IMN','44'],// 4
			['Israel','IL','ISR','972'],// 1
			['Italy','IT','ITA','39'],// 1
			['Ivory Coast','CI','CIV','225'],// 3
			['Jamaica','JM','JAM','1876'],// 3
			['Japan', 'JP', 'JPN','81'],// 5
			['Jordan', 'JO', 'JOR', '962'],// 2
			['Kazakhstan', 'KZ', 'KAZ', '7'], //[77, 76] // 3
			['Kenya', 'KE', 'KEN', '254'],// 3
			['Kiribati','KI','KIR','686'],// 4
			['Kuwait','KW','KWT','965'],// 1
			['Kyrgyzstan','KG','KGZ','996'],// 4
			['Laos','LA','LAO','856'],// 3
			['Latvia','LV','LVA','371'],// 1
			['Lebanon','LB','LBN','961'],// 2
			['Lesotho','LS','LSO','266'],// 3
			['Liberia','LR','LBR','231'],// 3
			['Libya','LY','LBY','218'],// 4
			['Liechtenstein','LI','LIE','423'],// 1
			['Lithuania','LT','LTU','370'],// 1
			['Luxembourg','LU','LUX','352'],// 1
			['Macau','MO','MAC','853'],// 1
			['Macedonia','MK','MKD','389'],// 2
			['Madagascar','MG','MDG','261'],// 3
			['Malawi','MW','MWI','265'],// 3
			['Malaysia','MY','MYS','60'],// 2
			['Maldives','MV','MDV','960'],// 2
			['Mali','ML','MLI','223'],// 4
			['Malta','MT','MLT','356'],// 1
			['Marshall Islands','MH','MHL','692'],// 4
			['Martinique','MQ','MTQ','596'],// 4Martinique country code +596 
			['Mauritania','MR','MRT','222'],// 3
			['Mauritius','MU','MUS','230'],// 1
			['Mayotte','YT','MYT','262'],// 4
			['Mexico','MX','MEX','52'],// 1
			['Micronesia','FM','FSM','691'],// 2
			['Moldova','MD','MDA','373'],// 4
			['Monaco','MC','MCO','377'],// 1
			['Mongolia','MN','MNG','976'],// 3
			['Montenegro','ME','MNE','382'],// 1
			['Montserrat','MS','MSR','1664'],// 4на
			['Morocco','MA','MAR','212'],// 2
			['Mozambique','MZ','MOZ','258'],// 3
			['Namibia','NA','NAM','264'],// 3
			['Nauru','NR','NRU','674'],// 4
			['Nepal','NP','NPL','977'],// 3
			['Netherlands','NL','NLD','31'],// 1
			['Netherlands Antilles', 'AN', 'ANT', '599'],// 2
			['New Caledonia','NC','NCL','687'],// 3
			['New Zealand','NZ','NZL','64'],// 1
			['Nicaragua','NI','NIC','505'],// 2
			['Niger','NE','NER','227'],// 4
			['Nigeria','NG','NGA','234'],// 3
			['Niue','NU','NIU','683'],// 4
			['Norfolk Island','','NFK','672'],// 4
			['North Korea','KP','PRK','850'],// 5
			['Northern Mariana Islands','MP','MNP','1670'],// 4
			['Norway','NO','NOR','47'],// 1
			['Oman','OM','OMN','968'],// 1
			['Pakistan','PK','PAK','92'],// 2
			['Palau','PW','PLW','680'],// 4
			['Panama','PA','PAN','507'],// 2
			['Papua New Guinea','PG','PNG','675'],// 4
			['Paraguay','PY','PRY','595'],// 2
			['Peru','PE','PER','51'],// 2
			['Philippines','PH','PHL','63'],// 3
			['Pitcairn Islands','PN','PCN','870'],// 4
			['Poland','PL','POL','48'],// 1
			['Portugal','PT','PRT','351'],// 1
			['Puerto Rico','PR','PRI','1'],// 2
			['Qatar','QA','QAT','974'],// 1
			['Republic of the Congo','CG','COG','242'],// 4
			['Romania','RO','ROU','40'],// 2
			['Russia','RU','RUS','7'],// 2
			['Rwanda','RW','RWA','250'],// 3
			['Reunion island','RE','REU','262'],// 3
			['Saint Barthelemy','BL','BLM','590'],// 4
			['Saint Helena','SH','SHN','290'],// 4
			['Saint Kitts and Nevis','KN','KNA','1869'],// 4
			['Saint Lucia','LC','LCA','1758'],// 4
			['Saint Martin','MF','MAF','1599'],// 4
			['Saint Pierre and Miquelon','PM','SPM','508'],// 4
			['Saint Vincent and the Grenadines','VC','VCT','1784'],// 4
			['Samoa', 'WS', 'WSM', '685'],// 4
			['San Marino', 'SM', 'SMR', '378'],// 1
			['Sao Tome and Principe', 'ST', 'STP', '239'],// 3
			['Saudi Arabia', 'SA', 'SAU', '966'],// 1
			['Senegal', 'SN', 'SEN', '221'],// 3
			['Serbia', 'RS', 'SRB', '381'],// 2
			['Kosovo', 'RS', 'SRB', '383'],// 2
			['Seychelles', 'SC', 'SYC', '248'],// 3
			['Sierra Leone', 'SL', 'SLE', '232'],// 4
			['Singapore', 'SG', 'SGP', '65'],// 1
			['Slovakia', 'SK', 'SVK', '421'],// 1
			['Slovenia', 'SI', 'SVN', '386'],// 1
			['Solomon Islands', 'SB', 'SLB', '677'],// 4
			['Somalia', 'SO', 'SOM', '252'],// 5
			['South Africa', 'ZA', 'ZAF', '27'],// 1
			['South Korea', 'KR', 'KOR', '82'],// 1
			['Spain', 'ES', 'ESP', '34'],// 1
			['Sri Lanka', 'LK', 'LKA', '94'],// 3
			['Sudan', 'SD', 'SDN', '249'],// 4
			['Suriname', 'SR', 'SUR', '597'],// 2
			['Swaziland', 'SZ', 'SWZ', '268'],// 3
			['Sweden', 'SE', 'SWE', '46'],// 1
			['Switzerland', 'CH', 'CHE', '41'],// 1
			['Syria', 'SY', 'SYR', '963'],// 5
			['Taiwan', 'TW', 'TWN', '886'],// 1
			['Tajikistan','TJ','TJK','992'],// 4
			['Tanzania','TZ','TZA','255'],// 3
			['Thailand','TH','THA','66'],// 2
			['Timor-Leste','TL','TLS','670'],//4
			['Togo','TG','TGO','228'],// 3
			['Tokelau','TK','TKL','690'],// 4
			['Tonga','TO','TON','676'],// 4
			['Trinidad and Tobago','TT','TTO','1868'],// 3
			['Tunisia','TN','TUN','216'],// 2
			['Turkey','TR','TUR','90'],// 1
			['Turkmenistan','TM','TKM','993'],// 4
			['Turks and Caicos Islands','TC','TCA','1649'],// 4
			['Tuvalu', 'TV', 'TUV', '688'],// 4
			['Uganda', 'UG', 'UGA', '256'],// 3
			['Ukraine', 'UA', 'UKR', '380'],// 2
			['United Arab Emirates', 'AE', 'ARE', '971'],// 1
			['United Kingdom', 'GB', 'GBR', '44'],// 1
			['United States', 'US', 'USA', '1'],// 5
			['Uruguay', 'UY', 'URY', '598'],// 2
			['US Virgin Islands', 'VI', 'VIR', '1340'],// 4
			['Uzbekistan', 'UZ', 'UZB', '998'],// 4
			['Vanuatu', 'VU', 'VUT', '678'],// 4
			['Venezuela', 'VE', 'VEN', '58'],// 3
			['Vietnam', 'VN', 'VNM', '84'],// 2
			['Wallis and Futuna', 'WF', 'WLF', '681'],// 4
			['Yemen', 'YE', 'YEM', '967'],// 4
			['Zambia', 'ZM', 'ZMB', '260'],// 3
			['Zimbabwe', 'ZW', 'ZWE', '263']// 4
		]
		
		/**
		 * [0]-Country name, [1],[2] iso codes, [3] - country phone code, [4] - phone without code
		 * @param	phoneNumber
		 * @return
		 */
		static public function getCountryByPhoneNumber(phoneNumber:String):Array {
			// remove pluss
			if (phoneNumber.substr(0, 1) == '+')
				phoneNumber = phoneNumber.substr(1);
				
			// remove leading zeros
			var m:int = 0;
			while (phoneNumber.length && phoneNumber.substr(0, 1) == '0'){
					phoneNumber = phoneNumber.substr(1);
					m++;
					if (m == 20)
						break;
			}
			
			if (phoneNumber.length < 6) {
				//trace('CountriesData.getCountryByPhoneNumber() -> ERROR -> Nothing to find! phone number is: '+phoneNumber);
				return null;
			}
			
			// Find country;
			var digit:String = phoneNumber.charAt(0);
			var codeFounded:Boolean;
			var digitPosition:int = 0;
			var foundedCountries:Array = [];
			var l:int = _COUNTRIES.length;
			for (var n:int = 0; n < l ; n++) {
				var code:String = _COUNTRIES[n][3];
				codeFounded = true;
				digitPosition = 0;
				digit = phoneNumber.charAt(digitPosition);
				for (m= 0; m < code.length; m++) {
					if (digit != code.charAt(m)) {
						codeFounded = false;
						break;
					}
					digitPosition++;
					digit = phoneNumber.charAt(digitPosition);
				}
				if (codeFounded) {
					var neDebil:int = foundedCountries.length;
					if (foundedCountries[neDebil] == null)
						foundedCountries[neDebil] = [];
					foundedCountries[neDebil][0] = COUNTRIES[n][0];
					foundedCountries[neDebil][1] = COUNTRIES[n][1];
					foundedCountries[neDebil][2] = COUNTRIES[n][2];
					foundedCountries[neDebil][3] = COUNTRIES[n][3];
				}
			}
			
			if (foundedCountries.length==0)
				return null;
			
				
			// KAZAKHSTAN AND RUSSIA, USA, PUERTO RIKO AND CANADA - CHECK!
			//foundedCountries[0][4] = phoneNumber.substr(foundedCountries[0][3].length);
			return foundedCountries[0];
		}
		
		public static function getDisplayPhoneNumber(phone:String):String{
			if (!(phone != null && phone.length > 0))
				return phone;
			
			var n:int = 0;
			var l:int = COUNTRIES.length;
			
			// Ищем все возможные коды
			var arr:Array = [];
			for (n = 0; n < l; n++) {
				var ccode:String = COUNTRIES[n][3];
				if (phone.indexOf(ccode) == 0)
					arr[arr.length] = ccode;
			}
					
			var res:String;
			var code:String = '+';
			if (arr.length == 0) {
				// нет кода страны
				code += 'Earth';
			}else if(arr.length == 1){
				// Нашли единственное совпадение
				code += arr[0];
			}else{
				// Совпадений больше чем 1, берём то, что длиней
				var maxLength:int = 0;
				res = '';
				l = arr.length;
				for (n = 0; n < l; n++){
					if (arr[n].length > maxLength)
						res = arr[n];
				}
				code += res;
			}
			
			res = phone.substr(code.length - 1);
			var endRes:String = '';
			var firstNum:int = 2 + res.length % 2;
			var m:int = 0;
			for (n = 0; n < res.length; n++) {
				if (m < firstNum){
					endRes += res.charAt(n);
					m++;
				}else{
					endRes += ' ';
					m = 0;
					n--;
					firstNum = 2;
				}
			}
			return '(' + code+') ' + endRes;
		}
		
		static private var currentCountry:Array;
		static public function setCurrentCountry(country:Array):void {
			currentCountry = country;
		}
		static public function getCurrentCountry():Array {
			return currentCountry;
		}
		
		static public function getByCode(countryCode:String):String 
		{
			var l:int = COUNTRIES.length;
			for (var i:int = 0; i < l; i++) 
			{
				if (COUNTRIES[i] != null && COUNTRIES[i][2] == countryCode)
				{
					return COUNTRIES[i][4];
				}
			}
			return null;
		}
	}
}