package com.dukascopy.connect.sys.stickerManager {
	import com.dukascopy.connect.sys.echo.echo;
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.StickersLocalCollection;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.type.StikerGroupType;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class StickerManager {
		
		static public var S_STICKERS:Signal = new Signal("StickerManager.S_STICKERS");
		static public var S_WAITING_TIMER_ENDS:Signal = new Signal("StickerManager.S_WAITING_TIMER_ENDS");
		
		static public var recentStickers:Array = [];
		static public var recentLoading:Boolean = false;
		static public var recentLoaded:Boolean = false;
		static private const periodTS:Number = 1000 * 60 * 60 * 24;
		static private var ts:Number = 0;
		static private var storeStickerObject:Array = null;
		
		public static function getSticker(id:int, ver:int, callBack:Function = null):String {
			var link:String = "https://dccapi.dukascopy.com/?method=stickers.img&key=web&id=" + id + "&ver=" + ver;
			if (callBack != null)
				ImageManager.loadImage(link, callBack);
			return link;
		}
		
		public static function getLocalStickerClass(id:int, ver:int):Class
		{
			var stikerClass:Class;
			try {
				stikerClass = getDefinitionByName("assets.stiker.Stiker_" + id) as Class;
			}
			catch (e:Error)
			{
				//!TODO: add notification - local image for sticker not found, need to update swc with new image;
			}
			
			return stikerClass;
		}
		
		public static function getLocalStickerVector(id:int, ver:int, imageWidth:int, imageHeight:int):Sprite
		{
			var stikerClass:Class = getLocalStickerClass(id, ver);
			if (!stikerClass)
			{
				return null;
			}
			var imageSprite:Sprite = new stikerClass();
			if (imageWidth > 0 && imageHeight > 0)
			{
				var k:Number = Math.max(imageSprite.width/imageWidth, imageSprite.height/imageHeight);
				imageSprite.width = imageSprite.width/k;
				imageSprite.height = imageSprite.height/k;
			}
			return imageSprite;
		}
		
		/*public static function getLocalStickerImage(id:int, ver:int, imageWidth:int, imageHeight:int):ImageBitmapData {
			
			var stikerClass:Class = getLocalStickerClass(id, ver);
			if (!stikerClass)
			{
				return null;
			}
			var imageSprite:Sprite = new stikerClass();
			if (imageWidth > 0 && imageHeight > 0)
			{
				var k:Number = Math.max(imageSprite.width/imageWidth, imageSprite.height/imageHeight);
				imageSprite.width = imageSprite.width/k;
				imageSprite.height = imageSprite.height/k;
			}
			return UI.getSnapshot(imageSprite, StageQuality.HIGH, "StickerManager.image");
		}*/
		
		static public function getStickers():void {
			
			storeStickerObject = StickersLocalCollection.collection;
			S_STICKERS.invoke();
			
		//	Store.load(Store.VAR_STICKERS, onLoadFromStore);
		}
		
		static public function getAllStickers():Array {
			return storeStickerObject;
		}
		
		static public function getGroupIcon(i:int, callBack:Function = null):String {
			var link:String = "https://dccapi.dukascopy.com/?method=stickers.img&key=web&type=g&id=" + storeStickerObject[i].id + "&ver=" + storeStickerObject[i].ver;
			
			//!TODO: better to use id, but need to know real id for the group "adult", now its not exist on server side;
			if (storeStickerObject[i].id == StikerGroupType.STIKER_GROUP_ADULT_ID || 
				storeStickerObject[i].id == StikerGroupType.STIKER_GROUP_DOG_ID ||
				storeStickerObject[i].id == StikerGroupType.STIKER_GROUP_GIRL_ID ||
				storeStickerObject[i].id == StikerGroupType.STIKER_GROUP_COW_ID ||
				storeStickerObject[i].id == StikerGroupType.STIKER_GROUP_REGULAR_ID ||
				storeStickerObject[i].id == StikerGroupType.STIKER_GROUP_BOY_ID ||
				storeStickerObject[i].id == StikerGroupType.STIKER_GROUP_GESTURES_ID) {
				var groupClassName:String = "assets.stiker.Group_" + storeStickerObject[i].id + "_" + storeStickerObject[i].ver;
				
				var groupClass:Class;
				try {
					groupClass = getDefinitionByName(groupClassName) as Class;
					if (groupClass) {
						link = groupClassName;
						if (callBack != null) {
							TweenMax.delayedCall(1, function():void {
								echo("StickerManager", "getGroupIcon", "TweenMax.delayedCall all is OK");
								callBack(link, UI.getSnapshot(new groupClass(), StageQuality.HIGH, "StickerManager.groupImage"));
							}, null, true);
						}
						return link;
					} else {
						//!TODO: add notification - local image for stickers group not found, need to update swc with new image;
					}
				}
				catch (e:Error) {
					//!TODO: add notification - local image for stickers group not found, need to update swc with new image;
				}
			}
			
			if (callBack != null) {
				TweenMax.delayedCall(1, function():void {
					echo("StickerManager", "getGroupIcon", "TweenMax.delayedCall");
					ImageManager.loadImage(link, callBack);
				}, null, true);
			}
			return link;
		}
		
		static public function addRecent(data:Object):void {
			var rs:Object;
			var i:int = 0
			for (i; i < recentStickers.length; i++) {
				if (recentStickers[i].id == data.id) {
					rs = recentStickers[i];
					rs.count ++;
					recentStickers.splice(i, 1);
					i --;
					for (i; i > -1; i--) {
						if (recentStickers[i].count > rs.count) {
							recentStickers.splice(i + 1, 0, rs);
							break;
						}
					}
					if (i == -1)
						recentStickers.unshift(rs);
					return;
				}
			}
			data.count = 1;
			for (i = recentStickers.length; i > 0; i--) {
				if (recentStickers[i - 1].count > 1) {
					if (i != 60) {
						recentStickers.splice(i, 0, data);
						break;
					}
					break;
				}
			}
			if (i == 0)
				recentStickers.unshift(data);
			if (recentStickers.length == 61)
				recentStickers.splice(60, 1);
		}
		
		static public function saveRecentToStore():void {
			Store.save("recentStickers", recentStickers);
		}
		
		static public function loadRecentFromStore():void {
			if (recentLoaded == true || recentLoading == true)
				return;
			recentLoading = true;
			Store.load("recentStickers", onRecentLoaded);
		}
		
		static public function addWaitingSticker(object:Object):void {
			object.wasDown = true;
			TweenMax.delayedCall(1, function():void {
				object.wasDown = false;
				S_WAITING_TIMER_ENDS.invoke();
			});
		}
		
		static private function onRecentLoaded(data:Object, err:Boolean):void {
			recentLoaded = true;
			recentLoading = false;
			if (err == true)
				return;
			recentStickers = data as Array;
		}
		
		static private function onLoadFromStore(data:Array, error:Boolean):void {
			loadFromPHP();
			if (error == true)
				return;
			if (data == null)
				return;
			storeStickerObject = data;
			
			//!TODO:remove when real "adult" stickers will be avaliable from server; Also need to check version for each sticker in this collection;
		//	addAdultStikersGroup();
		//	addDogStickersGroup();
			
			S_STICKERS.invoke();
		}
		
		/*static private function addDogStickersGroup():void 
		{
			if (isCategoryExist(StikerGroupType.STIKER_GROUP_DOG_ID))
			{
				return;
			}
			var dogCategory:Object = new Object();
			dogCategory.ver = 1;
			dogCategory.id = StikerGroupType.STIKER_GROUP_DOG_ID;
			dogCategory.name = StikerGroupType.STIKER_GROUP_DOG;
			dogCategory.sort = 10;
			dogCategory.stickers = getDogStikers();
			
			storeStickerObject.push(dogCategory);
		}*/
		
		/*static private function getDogStikers():Array 
		{
			var adult:Array = new Array();
			adult.push( { id:148, sort:0, ver:1 } );
			adult.push( { id:149, sort:0, ver:1 } );
			adult.push( { id:152, sort:0, ver:1 } );
			adult.push( { id:153, sort:0, ver:1 } );
			adult.push( { id:154, sort:0, ver:1 } );
			adult.push( { id:155, sort:0, ver:1 } );
			adult.push( { id:156, sort:0, ver:1 } );
			adult.push( { id:157, sort:0, ver:1 } );
			adult.push( { id:158, sort:0, ver:1 } );
			adult.push( { id:159, sort:0, ver:1 } );
			adult.push( { id:160, sort:0, ver:1 } );
			adult.push( { id:161, sort:0, ver:1 } );
			return adult;
		}*/
		
		/*static private function addAdultStikersGroup():void 
		{
			if (isCategoryExist(StikerGroupType.STIKER_GROUP_ADULT_ID))
			{
				return;
			}
			var adultCategory:Object = new Object();
			adultCategory.ver = 1;
			adultCategory.id = StikerGroupType.STIKER_GROUP_ADULT_ID;
			adultCategory.name = StikerGroupType.STIKER_GROUP_ADULT;
			adultCategory.sort = 10;
			adultCategory.stickers = getAdultStikers();
			
			storeStickerObject.push(adultCategory);
		}*/
		
		static private function isCategoryExist(stikerGroupId:int):Boolean 
		{
			var exist:Boolean = false;
			var length:int = storeStickerObject.length;
			for (var i:int = 0; i < length; i++) 
			{
				if (storeStickerObject[i].id == stikerGroupId)
				{
					return true;
				}
			}
			return exist;
		}
		
		/*static private function getAdultStikers():Array 
		{
			var adult:Array = new Array();
			adult.push( { id:1, sort:0, ver:1 } );
			adult.push( { id:2, sort:0, ver:1 } );
			adult.push( { id:3, sort:0, ver:1 } );
			adult.push( { id:4, sort:0, ver:1 } );
			adult.push( { id:5, sort:0, ver:1 } );
			adult.push( { id:6, sort:0, ver:1 } );
			adult.push( { id:7, sort:0, ver:1 } );
			adult.push( { id:8, sort:0, ver:1 } );
			adult.push( { id:9, sort:0, ver:1 } );
			adult.push( { id:10, sort:0, ver:1 } );
			adult.push( { id:12, sort:0, ver:1 } );
			adult.push( { id:13, sort:0, ver:1 } );
			adult.push( { id:14, sort:0, ver:1 } );
			adult.push( { id:15, sort:0, ver:1 } );
			adult.push( { id:16, sort:0, ver:1 } );
			return adult;
		}*/
		
		static private function loadFromPHP():void {
			if (ts > new Date().getTime() - periodTS)
				return;
			Store.load(Store.VAR_STICKERS_HASH, onLoadMD5FromStore);
		}
		
		static private function onLoadMD5FromStore(data:String, error:Boolean):void {
			if (error == true)
				PHP.stickers_get(onLoadFromPHP);
			else
				PHP.stickers_get(onLoadFromPHP, data + "1");
		}
		
		static private function onLoadFromPHP(phpRespond:PHPRespond):void {
			if (phpRespond.error == true)
				return;
			if (phpRespond.data == null)
				return;
			if (phpRespond.data.groups == null)
				return;
			ts = new Date().getTime();
			Store.save(Store.VAR_STICKERS, phpRespond.data.groups);
			if (phpRespond.data.hash != null)
				Store.save(Store.VAR_STICKERS_HASH, phpRespond.data.hash);
		//	trace(phpRespond.data.groups);
			storeStickerObject = phpRespond.data.groups;
			
			/*for (var i:int = 0; i < phpRespond.data.groups.length; i++) 
			{
				trace("{");
				trace("	id:" + '"' + phpRespond.data.groups[i].id + '",');
				trace("	name:" + '"' + phpRespond.data.groups[i].name + '",');
				trace("	sort:" + '"' + phpRespond.data.groups[i].sort + '",');
				trace("	stickers: [");
				for (var j:int = 0; j < phpRespond.data.groups[i].stickers.length; j++) 
				{
					trace("		{id:" + '"' + phpRespond.data.groups[i].stickers[j].id + '",' + "sort:" + '"' + phpRespond.data.groups[i].stickers[j].sort + '",' + "ver:" + '"' + phpRespond.data.groups[i].stickers[j].ver + '"},');
				}
				trace("	]");
				trace("},");
			}*/
			
			//!TODO:remove when real "adult" stickers will be avaliable from server; Also need to check version for each sticker in this collection;
		//	addAdultStikersGroup();
		//	addDogStickersGroup();
			
			S_STICKERS.invoke();
		}
	}
}