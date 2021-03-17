package com.dukascopy.connect.sys.usersManager.extensions 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.vo.users.adds.UserGifts;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class UserExtensionsParser 
	{
		
		public function UserExtensionsParser() 
		{
			
		}
		
		public function parse(data:Object):UserGifts {
			var result:UserGifts;
			
			if (valid(data)) {
				result = new UserGifts();
				
				var extension:Extension;
				var l:int = data.length;
				var code:int;
				var type:ExtensionType;
				
				//!TODO: parser;
				
				var parser:ExtensionParser = new ExtensionParser();
				
				if (data is Array)
				{
					for (var i:int = 0; i < l; i++) 
					{
						extension = parser.parse(data[i]);
						result.addExtension(extension);
					}
				}
				else
				{
					extension = parser.parse(data);
					result.addExtension(extension);
				}
			}
			else {
				ApplicationErrors.add("wrong data format");
			}
			
			return result;
		}
		
		private function valid(data:Object):Boolean {
			var result:Boolean = true;
			
			//!TODO:;
			
			return result;
		}
	}
}