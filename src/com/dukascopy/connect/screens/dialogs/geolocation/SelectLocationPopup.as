package com.dukascopy.connect.screens.dialogs.geolocation {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.location.Location;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListCityRenderer;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.geolocation.GeolocationManager;
	import com.dukascopy.connect.sys.geolocation.GeolocationManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class SelectLocationPopup extends BaseScreen {
		
		protected var container:Sprite;
		private var bg:Shape;
		
		private var title:Bitmap;
		private var acceptButton:BitmapButton;
		private var horizontalLoader:HorizontalPreloader;
		private var list:List;
		private var componentsWidth:int;
		private var titleHeight:int;
		private var searchPanel:SearchPanel;
		private var lastSelectedItem:CityLocationListItem;
		private var myLocation:CityLocationListItem;
		private var selectedCity:CityGeoposition;
		private var currentListData:Array;
		
		public function SelectLocationPopup() { }
		
		override protected function createView():void {
			super.createView();
			
			container = new Sprite();
			
			bg = new Shape();
			container.addChild(bg);
			
			title = new Bitmap();
			container.addChild(title);
			
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.setDownScale(1);
			acceptButton.setDownColor(0);
			acceptButton.tapCallback = acceptClick;
			acceptButton.disposeBitmapOnDestroy = true;
			acceptButton.show();
			container.addChild(acceptButton);
			
			horizontalLoader = new HorizontalPreloader(0xF6951D);
			container.addChild(horizontalLoader);
			
			list = new List("City");
			list.setMask(true);
			container.addChild(list.view);
			
			searchPanel = new SearchPanel(onSearchChange);
			container.addChild(searchPanel);
			
			_view.addChild(container);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			var maxListHeight:int = _height - titleHeight - acceptButton.height - Config.DOUBLE_MARGIN - Config.DOUBLE_MARGIN - searchPanel.height - Config.FINGER_SIZE * .35;
			
			var position:int = 0;
			
			title.x = Config.DIALOG_MARGIN;
			title.y = int(titleHeight * .5 - title.height * .5);
			
			position += titleHeight + Config.FINGER_SIZE * .15;
			
			searchPanel.y = position;
			searchPanel.drawView(_width);
			position += searchPanel.height + Config.FINGER_SIZE * .15;
			
			list.setWidthAndHeight(_width, (Math.min(maxListHeight, list.itemsHeight)));
			list.view.y = position + 1;
			position += list.height;
			
			position += Config.DOUBLE_MARGIN;
			acceptButton.y = position;
			position += acceptButton.height;
			position += Config.DOUBLE_MARGIN;
			
			bg.graphics.clear();
			bg.graphics.beginFill(0xF7F7F7);
			bg.graphics.drawRect(0, 0, _width, titleHeight);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, titleHeight, _width, position - titleHeight);
			bg.graphics.endFill();
			
			bg.graphics.lineStyle(1, 0x000000, 0.15);
			bg.graphics.moveTo(0, titleHeight);
			bg.graphics.lineTo(_width, titleHeight);
			
			container.y = _height - position;
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			titleHeight = Config.FINGER_SIZE * .9;
			
			drawAcceptButton();
			drawTitle();
			
			if (data != null && data.selectedCity != null && data.selectedCity is CityGeoposition) {
				selectedCity = data.selectedCity as CityGeoposition;
			}
			
			var listData:Array = getData();
			list.setData(listData, ListCityRenderer);
		}
		
		private function drawAcceptButton():void {
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textOk, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x77C043, 1, Config.FINGER_SIZE * .8, NaN);
			acceptButton.setBitmapData(buttonBitmap, true);
			acceptButton.x = int(_width * .5 - acceptButton.width * .5);
			
			acceptButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
		}
		
		private function drawTitle():void {
			if (title.bitmapData != null) {
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			title.bitmapData = TextUtils.createTextFieldData(
												Lang.selectCity, componentsWidth, 10, true, 
												TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
												Config.FINGER_SIZE * .3, true, 0x697780, 0xF7F7F7);
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			acceptButton.activate();
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
			searchPanel.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			acceptButton.deactivate();
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
			searchPanel.deactivate();
		}
		
		private function onSearchChange():void {
			var value:String = searchPanel.getValue();
		}
		
		private function showPreloader():void {
			horizontalLoader.start();
		}
		
		private function hidePreloader():void {
			horizontalLoader.stop();
		}
		
		override public function onBack(e:Event = null):void {
			DialogManager.closeDialog();
		}
		
		private function acceptClick():void {
			if (data != null && data.callback != null && data.callback is Function) {
				if (lastSelectedItem != null)
					data.callback(lastSelectedItem.city);
				else
					data.callback(null);
			}
			onBack();
		}
		
		private function getData():Array {
			var result:Array = new Array();
			//var myCity:CityGeoposition = getMyLocation();
			var cities:Array = GeolocationManager.geoCities;
			//myLocation ||= new CityLocationListItem(null, false, true);
			//myLocation.city = myCity;
			//if (myCity != null && selectedCity == myCity) {
			//	lastSelectedItem = myLocation;
			//	lastSelectedItem.select();
			//}
			//if (lastSelectedItem != null && lastSelectedItem.city == myCity) {
			//	lastSelectedItem.unselect();
			//	lastSelectedItem = myLocation;
			//	lastSelectedItem.select();
			//}
			//result.push(myLocation);
			var cl:CityLocationListItem;
			for (var i:int = 0; i < cities.length; i++) {
				//if (myCity != null && cities[i] == myCity)
				//	continue;
				if (lastSelectedItem != null && cities[i] == lastSelectedItem.city)
					cl = lastSelectedItem;
				else {
					cl = new CityLocationListItem(cities[i], false);
					if (cl.city == selectedCity) {
						cl.select();
						lastSelectedItem = cl;
					}
				}
				result.push(cl);
				
			}
			if (currentListData != null) {
				var l:int = currentListData.length;
				for (var j:int = 0; j < l; j++) {
					if (/*currentListData[j] != myLocation && */currentListData[j] != lastSelectedItem) {
						currentListData[j].dispose();
					}
				}
			}
			currentListData = result;
			return result;
		}
		
		private function onMyLocationUpdated(city:CityGeoposition):void {
			if (myLocation != null) {
				myLocation.city = city;
				list.refresh();
			}
		}
		
		private function getMyLocation():CityGeoposition {
			if (GeolocationManager.getMyLocation() == null)
				return null;
			return GeolocationManager.myCity;
		}
		
		private function onItemTap(data:Object, n:int):void {
			echo("FindSomethingScreen", "onItemTap", "");
			var item:ListItem = list.getItemByNum(n);
			var itemHitZone:String;
			if (item)
				itemHitZone = item.getLastHitZone();
			if (itemHitZone == HitZoneType.GET) {
				if (GeolocationManager.getMyLocation() == null) {
					GeolocationManager.S_LOCATION.add(onMyLocation);
					GeolocationManager.getLocation();
					return;
				}
				onMyLocation(GeolocationManager.getMyLocation());
			}
			if (data is CityLocationListItem) {
				if (data.myPosition == true && data.city == null)
					return;
				if (lastSelectedItem == data as CityLocationListItem) {
					if (lastSelectedItem != null) {
						lastSelectedItem.unselect();
						lastSelectedItem = null;
					}
				} else {
					if (lastSelectedItem != null)
						lastSelectedItem.unselect();
					lastSelectedItem = data as CityLocationListItem;
					lastSelectedItem.select();
				}
				list.updateItemByIndex(n);
			}
		}
		
		private function onMyLocation(point:Location):void {
			GeolocationManager.S_LOCATION.remove(onMyLocation);
			list.setData(getData(), ListCityRenderer);
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			Overlay.removeCurrent();
			if (acceptButton != null)
				acceptButton.dispose();
			acceptButton = null;
			if (container != null)
				UI.destroy(container);
			container = null;
			if (title != null)
				UI.destroy(title);
			title = null;
			if (bg != null)
				UI.destroy(bg);
			bg = null;
			if (horizontalLoader != null)
				horizontalLoader.dispose();
			horizontalLoader = null;
			if (searchPanel != null)
				searchPanel.dispose();
			searchPanel = null;
			if (list != null)
				list.dispose();
			list = null;
			
			if (lastSelectedItem != null)
				lastSelectedItem.dispose();
			lastSelectedItem = null;
			
			if (myLocation != null)
				myLocation.dispose();
			myLocation = null;
			
			if (currentListData != null) {
				var l:int = currentListData.length;
				for (var j:int = 0; j < l; j++) {
					currentListData[j].dispose();
				}
			}
			
			selectedCity = null;
		}
	}
}