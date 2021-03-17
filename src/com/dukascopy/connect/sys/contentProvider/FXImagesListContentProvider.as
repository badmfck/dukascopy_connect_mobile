package com.dukascopy.connect.sys.contentProvider 
{
	import com.adobe.webapis.URLLoaderBase;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.FxImageData;
	import com.dukascopy.connect.sys.imageManager.IImageData;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.vo.users.adds.UserMediaVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class FXImagesListContentProvider implements IContentProvider
	{
		private var SIGNAL_COMPLETE:Signal = new Signal("ImagesListContentProvider.SIGNAL_COMPLETE");
		private var SIGNAL_ERROR:Signal = new Signal("ImagesListContentProvider.SIGNAL_ERROR");
		private var result:Array;
		private var userModel:UserVO;
		private var localDataExist:Boolean = false;
		
		public function FXImagesListContentProvider()
		{
			
		}
		
		/* INTERFACE com.dukascopy.connect.sys.contentProvider.IContentProvider */
		
		public function setData(value:Object):void 
		{
			userModel = value as UserVO;
			if (userModel == null || userModel.fxID == 0)
			{
				SIGNAL_ERROR.invoke();
			}
		}
		
		public function get S_COMPLETE():Signal 
		{
			return SIGNAL_COMPLETE;
		}
		
		public function get S_ERROR():Signal 
		{
			return SIGNAL_ERROR;
		}
		
		public function getResult():Array 
		{
			return result;
		}
		
		public function dispose():void 
		{
			SIGNAL_COMPLETE.dispose();
			SIGNAL_ERROR.dispose();
			
			SIGNAL_COMPLETE = null;
			SIGNAL_ERROR = null;
			
			result = null;
			userModel = null;
		}
		
		public function execute():void 
		{
			if (userModel == null)
			{
				SIGNAL_ERROR.invoke();
				return;
			}
			
			if (userModel.media != null)
			{
				var photos:Array = userModel.media.fxGallery;
				
				if (photos != null)
				{
					result = photos;
					SIGNAL_COMPLETE.invoke();
					
					loadRemoteData();
					return;
				}
			}
			
			Store.load(Store.VAR_USER_FX_PHOTOS + userModel.fxID, onLocalDataLoaded);
		}
		
		private function onLocalDataLoaded(data:Object, error:Boolean):void
		{
			if (userModel == null)
			{
				if (SIGNAL_ERROR != null)
				{
					SIGNAL_ERROR.invoke();
				}
			}
			
			if (error == false)
			{
				if (data != null && (data is Array))
				{
					processRawData(data as Array);
				}
				
				localDataExist = true;
			}
			
			loadRemoteData();
		}
		
		private function loadRemoteData():void 
		{
			if (userModel == null)
			{
				if (SIGNAL_ERROR != null)
				{
					SIGNAL_ERROR.invoke();
				}
				
				return;
			}
			
			PHP.profile_getFXGallery(userModel.fxID, onServerResponse);
		}
		
		private function onServerResponse(phpRespond:PHPRespond):void 
		{
			if (userModel == null)
			{
				phpRespond.dispose();
				if (SIGNAL_ERROR != null)
				{
					SIGNAL_ERROR.invoke();
				}
			}
			
			if (phpRespond.error == true) {
				echo("FXImagesListContentProvider", "onServerResponse", Lang.serverError+ " " + phpRespond.errorMsg);
				phpRespond.dispose();
				if (SIGNAL_ERROR != null)
				{
					SIGNAL_ERROR.invoke();
				}
				return;
			}
			if (phpRespond.data == null) {
				echo("FXImagesListContentProvider", "onServerResponse", "Server Error: Empty data");
				try
				{
					phpRespond.dispose();
				}
				catch (e:Error)
				{
					//!TODO: Error #2029: This URLStream object does not have a stream opened
				}
				
				if (SIGNAL_ERROR != null)
				{
					SIGNAL_ERROR.invoke();
				}
				return;
			}
			
			if (phpRespond.data is Array)
			{
				Store.save(Store.VAR_USER_FX_PHOTOS + userModel.fxID, phpRespond.data);
				
				if (localDataExist == false)
				{
					processRawData(phpRespond.data as Array);
				}
			}
			else
			{
				if (SIGNAL_ERROR != null)
				{
					SIGNAL_ERROR.invoke();
				}
			}
			phpRespond.dispose();
		}
		
		private function processRawData(rawData:Array):void 
		{
			if (rawData == null)
			{
				if (SIGNAL_ERROR != null)
				{
					SIGNAL_ERROR.invoke();
				}
				return;
			}
			
			result = new Array();
			var l:int = rawData.length;
			for (var j:int = 0; j < l; j++) 
			{
				result.push(new FxImageData(rawData[j]));
			}
			
			if (userModel.media == null)
			{
				userModel.media = new UserMediaVO();
			}
			userModel.media.fxGallery = result;
			
			if (SIGNAL_COMPLETE != null)
			{
				SIGNAL_COMPLETE.invoke();
			}
		}
	}
}