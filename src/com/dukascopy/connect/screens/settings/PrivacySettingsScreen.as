package com.dukascopy.connect.screens.settings 
{
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.settings.SettingsControlData;
	import com.dukascopy.connect.data.settings.SettingsValue;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.components.renderer.SettingsControlRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListSimpleText;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.settings.GlobalSettings;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PrivacySettingsScreen extends ScrollScreen
	{
		private var controlsData:Vector.<SettingsControlData>;
		private var buttons:Vector.<SettingsControlButton>;
		private var selectedData:SettingsControlData;
		private var loader:CirclePreloader;
		
		public function PrivacySettingsScreen() 
		{
			super();
		}
		
		override protected function createView():void {
			super.createView();
		}
		
		override public function initScreen(data:Object = null):void 
		{
			if (data == null)
			{
				data = new Object();
			}
			data.title = Lang.privacySettings;
			
			super.initScreen(data);
			
			loadData();
		}
		
		private function loadData():void 
		{
			if (GlobalSettings.isAvaliable() == true)
			{
				buildControls(false);
			}
			else
			{
				showLoader();
				GlobalSettings.SETTINGS_LOADED.add(onDataLoaded);
				GlobalSettings.loadSettings();
			}
		}
		
		private function buildControls(updateLayout:Boolean):void 
		{
			controlsData = GlobalSettings.getSettings();
			createControls();
			if (updateLayout == true)
			{
				updateContentPositions();
				drawView();
				updateScroll();
			}
			if (isActivated == true)
			{
				activateControls();
			}
		}
		
		private function showLoader():void 
		{
			if (loader == null)
			{
				loader = new CirclePreloader();
				view.addChild(loader);
				loader.x = int(_width * .5);
				loader.y = int(_height * .5);
			}
		}
		
		private function hideLoader():void 
		{
			if (loader != null)
			{
				if (view.contains(loader))
				{
					view.removeChild(loader);
				}
				loader.dispose();
				loader = null;
			}
		}
		
		private function onDataLoaded():void 
		{
			hideLoader();
			GlobalSettings.SETTINGS_LOADED.remove(onDataLoaded);
			if (GlobalSettings.isAvaliable() == true)
			{
				buildControls(true);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function createControls():void 
		{
			clearControls();
			
			buttons = new Vector.<SettingsControlButton>();
			
			if (controlsData != null)
			{
				var renderer:SettingsControlRenderer = new SettingsControlRenderer();
				for (var i:int = 0; i < controlsData.length; i++) 
				{
					addControl(renderer, controlsData[i]);
				}
				renderer.dispose();
				renderer = null;
			}
		}
		
		private function addControl(renderer:SettingsControlRenderer, settingsControlData:SettingsControlData):void 
		{
			var settingsButton:SettingsControlButton = renderer.render(settingsControlData, _width);
			if (settingsButton != null)
			{
				buttons.push(settingsButton);
				addItem(settingsButton);
				settingsButton.tapCallback = onItemClick;
			}
		}
		
		private function onItemClick(itemData:Object):void 
		{
			if (itemData is SettingsControlData)
			{
				selectedData = itemData as SettingsControlData;
				
				ServiceScreenManager.showScreen(
					ServiceScreenManager.TYPE_SCREEN,
					ListSelectionPopup,
					{
						items:selectedData.getItems(),
						title:selectedData.label,
						renderer:ListSimpleText,
						callback:onSettingsValueSelected
					}, 0.2
				);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function onSettingsValueSelected(selectedValue:SelectorItemData):void
		{
			if (selectedData != null && selectedValue != null && selectedValue.data is SettingsValue)
			{
				var changed:Boolean = selectedData.select((selectedValue.data as SettingsValue).type);
				if (changed == true)
				{
					createControls();
					updateContentPositions();
					drawView();
					updateScroll();
					
					saveControlSelection(selectedData);
				}
			}
		}
		
		private function saveControlSelection(controlData:SettingsControlData):void 
		{
			GlobalSettings.save(controlData);
		}
		
		private function clearControls():void 
		{
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					removeItem(buttons[i]);
					buttons[i].dispose();
				}
				buttons = null;
			}
		}
		
		override protected function updateContentPositions():void 
		{
			if (buttons != null)
			{
				var position:int = 0;
				
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].y = position;
					position += buttons[i].height;
				}
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			
			activateControls();
		}
		
		private function activateControls():void 
		{
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].activate();
				}
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].deactivate();
				}
			}
		}
		
		override public function dispose():void {
			
			controlsData = null;
			selectedData = null;
			
			GlobalSettings.SETTINGS_LOADED.remove(onDataLoaded);
			
			clearControls();
			
			if (loader != null)
			{
				loader.dispose();
				loader = null;
			}
			
			super.dispose();
			//!TODO:;
		}
	}
}