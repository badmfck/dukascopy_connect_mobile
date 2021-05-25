package com.dukascopy.connect.data.screenAction.customActions 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.list.renderers.ListSimpleText;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.dccext.DCCExt;
	import com.dukascopy.dccext.DCCExtCommand;
	import com.dukascopy.dccext.DCCExtMethod;
	import com.dukascopy.dccext.appOpener.DCCExtAppOpener;
	import com.dukascopy.langs.Lang;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class OpenOtherApplicationsAction extends ScreenAction implements IScreenAction
	{
		
		public function OpenOtherApplicationsAction() 
		{
			
		}
		
		/* INTERFACE com.dukascopy.connect.data.screenAction.IScreenAction */
		
		public function execute():void 
		{
			var items:Array = new Array();
			if (ConfigManager.config != null && ConfigManager.config.applications != null)
			{
				var apps:Object;
				try
				{
					apps = JSON.parse(ConfigManager.config.applications);
				}
				catch (e:Error)
				{
					ApplicationErrors.add();
				}
				
				var item:ApplicationData;
				if (apps != null)
				{
					for (var i:int = 0; i < apps.length; i++) 
					{
						item = new ApplicationData(apps[i].name);
						item.type = apps[i].type;
						if (item.type == ApplicationData.TYPE_APP)
						{
							item.linkIOS = apps[i].linkIOS;
							item.linkAndroid = apps[i].linkAndroid;
							item.idIOS = apps[i].idIOS;
							item.idAndroid = apps[i].idAndroid;
						}
						else if (item.type == ApplicationData.TYPE_WEB)
						{
							item.link = apps[i].link;
						}
						items.push(item);
					}
				}
			}
			
			if (items != null && items.length > 0)
			{
				DialogManager.showActionSheets(Lang.launchPlatform, items, onItemSelected);
			}
		}
		
		private function onItemSelected(appData:ApplicationData):void 
		{
			
			if (appData != null)
			{
				if (appData.type == ApplicationData.TYPE_APP)
				{
					var nativeAppExist:Boolean = false;
					if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
					{
						nativeAppExist = MobileGui.androidExtension.launchApplication(appData.idAndroid);
						
						if (nativeAppExist == false)
						{
							navigateToURL(new URLRequest(appData.linkAndroid));
						}
					}
					else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
					{
						DCCExtAppOpener.open(appData.idIOS, null, function(err:String, result:Object = null):void{
							
							nativeAppExist = true;
							
							if (err != null) 
							{
								nativeAppExist = false;
							}
							else 
							{
								if (result != null)
								{
									if (result != null && "error" in result && result.error != null)
									{
										nativeAppExist = false;
									}
								}
							}
							
							if (nativeAppExist == false)
							{
								navigateToURL(new URLRequest(appData.linkIOS));
							}
						});
					}
					else if (Config.PLATFORM_WINDOWS == true)
					{
						navigateToURL(new URLRequest(appData.linkAndroid));
					}
				}
				else if (appData.type == ApplicationData.TYPE_WEB)
				{
					navigateToURL(new URLRequest(appData.link));
				}
			}
		}
	}
}

internal class ApplicationData
{
	public var label:String;
	public var url:String;
	
	static public const TYPE_APP:String = "app";
	static public const TYPE_WEB:String = "web";
	public var linkIOS:String;
	public var linkAndroid:String;
	public var link:String;
	public var type:String;
	public var idIOS:String;
	public var idAndroid:String;
	
	public function ApplicationData(label:String) 
	{
		this.label = label;
	}
	
	public function toString():String 
	{
		return type + "\n" + idIOS + "\n" + linkIOS + "\n" + idAndroid + "\n" + linkAndroid;
	}
}

