package com.dukascopy.connect.vo.users.adds 
{
	import com.dukascopy.connect.sys.usersManager.extensions.Extension;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class UserGifts 
	{
		private var _gifts:Vector.<Extension>;
		
		public function UserGifts() 
		{
			_gifts = new Vector.<Extension>();
		}
		
		public function addExtension(extension:Extension):void 
		{
			_gifts.push(extension);
		}
		
		public function update(data:UserGifts):void 
		{
			var exist:Boolean;
			if (data.items != null)
			{
				for (var i:int = 0; i < data.items.length; i++) 
				{
					exist = false;
					if (_gifts != null && _gifts.length > 0)
					{
						for (var j:int = 0; j < _gifts.length; j++) 
						{
							if (_gifts[j].id == data.items[i].id)
							{
								exist = true;
							}
						}
					}
					if (exist == false)
					{
						addExtension(data.items[i]);
					}
				}
			}
		}
		
		public function empty():Boolean 
		{
			if (_gifts == null || _gifts.length == 0)
			{
				return true;
			}
			return false;
		}
		
		public function get length():int
		{
			if (_gifts != null)
			{
				return _gifts.length;
			}
			return 0;
		}
		
		public function get items():Vector.<Extension> 
		{
			return _gifts;
		}
	}
}