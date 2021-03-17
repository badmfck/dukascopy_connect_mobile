package com.dukascopy.connect.sys.usersManager.extensions 
{
	import assets.FlowerType_1;
	import assets.FlowerType_1_small;
	import assets.FlowerType_2;
	import assets.FlowerType_2_small;
	import assets.FlowerType_3;
	import assets.FlowerType_3_small;
	import assets.FlowerType_4;
	import assets.FlowerType_4_small;
	import com.dukascopy.connect.gui.components.slideSelector.ISelectorData;
	import com.dukascopy.connect.sys.applicationShop.product.ProductType;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class Extension implements ISelectorData
	{
		public var user_uid:String;
		public var till:String;
		public var reason:String;
		public var incognito:Boolean;
		public var info:String;
		public var amount:Number;
		public var avatar:String;
		public var created:Number;
		public var currency:String;
		public var days:int;
		public var id:String;
		public var name:String;
		public var pavatar:String;
		public var payer_uid:String;
		public var pname:String;
		public var updated:Number;
		
		public function get type():ExtensionType 
		{
			return _type;
		}
		
		private var _type:ExtensionType;
		
		public function Extension(type:ExtensionType) 
		{
			this._type = type;
		}
		
		public function get avatarURL():String
		{
			return avatar;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.components.slideSelector.ISelectorData */
		
		public function getImage():Class 
		{
			switch(type.value)
			{
				case ExtensionType.FLOWER_1:
				{
					return FlowerType_1;
				}
				case ExtensionType.FLOWER_2:
				{
					return FlowerType_2;
				}
				case ExtensionType.FLOWER_3:
				{
					return FlowerType_3;
				}
				case ExtensionType.FLOWER_4:
				{
					return FlowerType_4;
				}
			}
			return null;
		}
		
		public function getProductType():ProductType 
		{
			switch(type.value)
			{
				case ExtensionType.FLOWER_1:
				case ExtensionType.FLOWER_2:
				case ExtensionType.FLOWER_3:
				case ExtensionType.FLOWER_4:
				{
					return new ProductType(ProductType.TYPE_FLOWER);
				}
			}
			return null;
		}
		
		public function getProductId():int 
		{
			switch(type.value)
			{
				case ExtensionType.FLOWER_1:
				{
					// rose
					return 3;
				}
				case ExtensionType.FLOWER_2:
				{
					// premium
					return 4;
				}
				case ExtensionType.FLOWER_3:
				{
					// gerbera
					return 1;
				}
				case ExtensionType.FLOWER_4:
				{
					// chamomille
					return 2;
				}
			}
			return 0;
		}
		
		public function getSmallImage():Class 
		{
			switch(type.value)
			{
				case ExtensionType.FLOWER_1:
				{
					return FlowerType_1_small;
				}
				case ExtensionType.FLOWER_2:
				{
					return FlowerType_2_small;
				}
				case ExtensionType.FLOWER_3:
				{
					return FlowerType_3_small;
				}
				case ExtensionType.FLOWER_4:
				{
					return FlowerType_4_small;
				}
			}
			return null;
		}
		
		public function isExpired():Boolean 
		{
			//!TODO:;
			return false;
		}
		
		public function dispose():void
		{
			
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.components.slideSelector.ISelectorData */
		
		public function getImageRaw():Class 
		{
			switch(type.value)
			{
				case ExtensionType.FLOWER_1:
				{
					return flowerType_1_raw;
				}
				case ExtensionType.FLOWER_2:
				{
					return flowerType_2_raw;
				}
				case ExtensionType.FLOWER_4:
				{
					return flowerType_4_raw;
				}
			}
			return null;
		}
	}
}