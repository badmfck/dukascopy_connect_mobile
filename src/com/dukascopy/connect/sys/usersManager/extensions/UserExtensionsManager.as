package com.dukascopy.connect.sys.usersManager.extensions 
{
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.dialogs.extensions.PutUserExtensionPopup;
	import com.dukascopy.connect.screens.dialogs.extensions.UsersExtensionsListScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.applicationShop.product.ProductCost;
	import com.dukascopy.connect.sys.applicationShop.product.ShopProduct;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.usersManager.extensions.FlowerData;
	import com.dukascopy.connect.sys.usersManager.extensions.config.FlowersConfig;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class UserExtensionsManager 
	{
		static public const FLOWERS:String = "flowers";
		static public const STATE_MISS_TOP:String = "stateMissTop";
		static public const STATE_MISS_ALL:String = "stateMissAll";
		static public const STATE_MISS_TOP_MORE:String = "stateMissTopMore";
		
		static public var S_ADD_EXTENSION_RESPONSE:Signal = new Signal("UserExtensionsManager.S_ADD_EXTENSION_RESPONSE");
		static public var S_UPDATED:Signal = new Signal("UserExtensionsManager.S_UPDATED");
		static public var S_USER_UPDATE:Signal = new Signal("UserExtensionsManager.S_USER_UPDATE");
		static public var S_EXTENSIONS_LIST:Signal = new Signal("UserExtensionsManager.S_EXTENSIONS_LIST");
		static public var S_CURENT_MISS_LIST:Signal = new Signal("UserExtensionsManager.S_CURENT_MISS_LIST");
		
		static private var requests:Vector.<ExtensionRequestData>;
		static private var flowersConfig:FlowersConfig;
		static private var usersList:UsersExtensionsList;
		static private var topList:TopExtensionsList;
		static private var topMissList:CurrentMissList;
		static private var allMissList:TopExtensionsList;
		static public var stateMiss:String = STATE_MISS_TOP;
		
		public function UserExtensionsManager() 
		{
			
		}
		
		public static function init():void
		{
			Auth.S_NEED_AUTHORIZATION.add(clean);
		}
		
		static private function clean():void
		{
			if (topList != null)
			{
				topList.dispose();
				topList = null;
			}
		}
		
		static public function buyExtension(request:ExtensionRequestData):void 
		{
			if (requests == null)
			{
				requests = new Vector.<ExtensionRequestData>();
			}
			requests.push(request);
			
			Shop.S_PRODUCT_BUY_RESPONSE.add(onProductBuyResponse);
			Shop.buyExtensionProduct(getProduct(request), request.id, request.wallet);
		}
		
		static private function getProduct(request:ExtensionRequestData):ShopProduct 
		{
			var product:ShopProduct = new ShopProduct(request.extension.getProductType(), request.duration, getCost(request), request.extension.getProductId());
			product.userUID = request.userUID;
			product.targetData = request.extension;
			return product;
		}
		
		static private function getCost(request:ExtensionRequestData):ProductCost 
		{
			//!TODO:!!!!!
			if (flowersConfig != null)
			{
				var flowerConfig:FlowerData = flowersConfig.getFlowerData(request.extension.getProductId());
				if (flowerConfig != null)
				{
					var amount:Number = request.duration.getDays() * flowerConfig.pricePerDay;
					if (request.extension.incognito == true)
					{
						amount = amount * 2;
					}
					
					var cost:ProductCost = new ProductCost(amount, flowerConfig.currency);
					
					return cost;
				}
				else
				{
					return null;
				}
			}
			else
			{
				return null;
			}
		}
		
		static private function onProductBuyResponse(success:Boolean, requestId:String, errorMessage:String = null, taskCanBeRequestedAgain:Boolean = true):void 
		{
			if (requests != null)
			{
				var request:ExtensionRequestData;
				var l:int = requests.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (requests[i].id == requestId)
					{
						request = requests.removeAt(i);
						break;
					}
				}
				if (success == true)
				{
					if (request != null)
					{
						var user:UserVO = UsersManager.getUserByUID(request.userUID);
						if (user != null)
						{
							request.extension.pname = Auth.myProfile.getDisplayName();
							user.addExtension(request.extension);
							S_USER_UPDATE.invoke(user.uid);
						}
					}
				}
			}
			else
			{
				ApplicationErrors.add();
			}
			
			S_ADD_EXTENSION_RESPONSE.invoke(success, requestId, errorMessage, taskCanBeRequestedAgain);
		}
		
		static public function buyFlower(userVO:UserVO):void 
		{
			if (userVO != null && userVO.disposed == false) {
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, PutUserExtensionPopup, {user:userVO});
			}
			else{
				// application error;
				
				var errorDetails:String;
				if (userVO == null) {
					errorDetails = "user VO null";
				}
				else if (userVO.disposed == true){
					errorDetails = "user VO disposed";
				}
				ApplicationErrors.add(errorDetails);
			}
		}
		
		static public function getExtensions(type:String):Vector.<Extension> 
		{
			var result:Vector.<Extension>;
			
			if (type == FLOWERS)
			{
				checkFlowersConfig();
				
				result = new Vector.<Extension>();
				result.push(new Extension(new ExtensionType(ExtensionType.FLOWER_4)));
				result.push(new Extension(new ExtensionType(ExtensionType.FLOWER_2)));
				result.push(new Extension(new ExtensionType(ExtensionType.FLOWER_1)));
			//	result.push(new Extension(new ExtensionType(ExtensionType.FLOWER_4)));
			}
			return result;
		}
		
		static public function onFailedFinishRequest(buyExtensionProduct:int):void 
		{
			//!TODO:;
		}
		
		static public function getFlowersConfig():FlowersConfig 
		{
			return flowersConfig;
		}
		
		static public function showExtensionsList():void 
		{
			MobileGui.changeMainScreen(UsersExtensionsListScreen,  {
																	title:Lang.myBans,
																	backScreen:MobileGui.centerScreen.currentScreenClass, 
																	backScreenData:MobileGui.centerScreen.currentScreen.data
																},
										ScreenManager.DIRECTION_RIGHT_LEFT);
		}
		
		static public function getExtensionsList():Array
		{
			if (topList == null)
			{
				topList = new TopExtensionsList(S_CURENT_MISS_LIST);
			}
			
			return topList.loadData();
		}
		
		static public function getCurrentMissList():Array
		{
			if (stateMiss == STATE_MISS_TOP)
			{
				if (topMissList == null)
				{
					topMissList = new CurrentMissList(S_CURENT_MISS_LIST);
				}
				
				return topMissList.loadData();
			}
			else if (stateMiss == STATE_MISS_ALL)
			{
				return getExtensionsList();
			}
			else if (stateMiss == STATE_MISS_TOP_MORE)
			{
				if (allMissList == null)
				{
					allMissList = new TopExtensionsList(S_CURENT_MISS_LIST, 50);
				}
				return allMissList.loadData();
			}
			
			return null;
		}
		
		static private function checkFlowersConfig():void 
		{
			if (flowersConfig == null)
			{
				flowersConfig = new FlowersConfig();
			}
		}
		
		static private function processBuyFlower():void
		{
			/*var cost:ProductCost
			
			var product:ShopProduct(new ProductType(ProductType.TYPE_FLOWER), new SubscriptionDuration(new SubscriptionDurationType(SubscriptionDurationType.ONCE)), )
			Shop.buyProduct(*/
		}
	}
}