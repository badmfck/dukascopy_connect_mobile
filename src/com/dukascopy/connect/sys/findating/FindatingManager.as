package com.dukascopy.connect.sys.findating {
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.vo.users.adds.FindatingVO;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class FindatingManager {
		
		static public const S_FINDATING:Signal = new Signal("FindatingManager.S_FINDATING");
		static public const S_FINDATING_FINISHED_LOADING:Signal = new Signal("FindatingManager.S_FINDATING_FINISHED_LOADING");
		
		static private var _findatings:Array = null;
		static private var currentHash:String = "";
		
		static private var inited:Boolean = false;
		static private var active:Boolean = false;
		static private var busy:Boolean = false;
		static private var _findatingResponded:Boolean = false;
		
		public function FindatingManager() { }
		
		public static function activate():void {
			active = true;
		}
		
		public static function deactivate():void {
			active = false;
			clear();
		}
		
		static private function init():void {
			if (inited == true)
				return;
			inited = true;
			WS.S_CONNECTED.add(onWSConnected);
			Auth.S_NEED_AUTHORIZATION.add(onAuthNeeded);
		}
		
		static private function onAuthNeeded():void {
			// TODO - NEED DISPOSE CONTACTS, ILYA
			_findatings = null;
			currentHash = "";
			inited = false;
			active = false;
			busy = false;
			_findatingResponded = false;
		}
		
		static private function onWSConnected():void {
			if (active == false)
				return;
			TweenMax.delayedCall(1, function():void {
				echo("FindatingManager", "onWSConnected", "TweenMax.delayedCall");
				if (currentHash != null && currentHash != "") {
					loadFindatingsFromPHP(currentHash);
					return;
				}
				Store.load(Store.VAR_FINDATINGS_HASH, onLoadHashFromStore);
			}, null, true);
		}
		
		static public function getFindatings():void {
			init();
			
			if (_findatings != null) {
				trace('WGH??');
				return;
			}
			
			TweenMax.delayedCall(1, function():void {
				echo("FindatingManager","getFindatings", "TweenMax.delayedCall");
				Store.load(Store.VAR_FINDATINGS, onLoadFindatingsFromStore);
			}, null, true);
		}
		
		static private function onLoadFindatingsFromStore(data:Array, error:Boolean):void {
			TweenMax.delayedCall(1, function():void {
				echo("FindatingManager","onLoadFindatingsFromStore","TweenMax.delayedCall");
				if (data != null) {
					if (_findatings != null)
						clear();
					_findatings = [];
					var _findatingsCount:int = data.length;
					for (var i:int = 0; i < _findatingsCount; i++)
						_findatings.push(new FindatingVO(data[i]));
					_findatingResponded = true;
					S_FINDATING.invoke(_findatings);
				}
				TweenMax.delayedCall(1, function():void {
					echo("FindatingManager","onLoadFindatingsFromStore", "TweenMax.delayedCall internal TweenMax.delayedCall");
					Store.load(Store.VAR_FINDATINGS_HASH, onLoadHashFromStore);
				}, null, true);
			}, null, true);
		}
		
		static private function onLoadHashFromStore(data:String, error:Boolean):void {
			TweenMax.delayedCall(1, function():void {
				echo("FindatingManager","onLoadHashFromStore", "TweenMax.delayedCall");
				loadFindatingsFromPHP(data);
			}, null, true);
		}
		
		static private function loadFindatingsFromPHP(hash:String):void {
			if (hash == null)
				hash = "";
			TweenMax.delayedCall(1, function():void {
				echo("FindatingManager","loadFindatingsFromPHP", "TweenMax.delayedCall");
				PHP.findating_get(onLoadFindatingsFromPHP, hash);
			}, null, true);
		}
		
		static private function onLoadFindatingsFromPHP(phpRespond:PHPRespond):void {
			_findatingResponded = true;
			S_FINDATING_FINISHED_LOADING.invoke();
			if (phpRespond.error == true) {
				busy = false;
				return;
			}
			if (phpRespond.data == null) {
				busy = false;
				return;
			}
			if (phpRespond.data.findating == null) {
				busy = false;
				return;
			}
			TweenMax.delayedCall(1, function():void {
				echo("FindatingManager","onLoadFindatingsFromPHP", "TweenMax.delayedCall");
				busy = false;
				Store.save(Store.VAR_FINDATINGS, phpRespond.data.findating);
				if (phpRespond.data.hash != null)
					Store.save(Store.VAR_FINDATINGS_HASH, phpRespond.data.hash);
				if (_findatings != null)
					clear();
				_findatings = [];
				var _findatingsCount:int = phpRespond.data.findating.length;
				for (var i:int = 0; i < _findatingsCount; i++)
					_findatings.push(new FindatingVO(phpRespond.data.findating[i]));
				S_FINDATING.invoke(_findatings);
			}, null, true);
		}
		
		static private function clear():void {
			if (_findatings == null)
				return;
			while (_findatings.length != 0) {
				_findatings[0].dispose();
				_findatings[0] = null;
				_findatings.splice(0, 1);
			}
			_findatings = null;	
		}
		
		static public function get findatings():Array {
			return _findatings;
		}
		
		static public function get findatingResponded():Boolean 	{
			return _findatingResponded;
		}
	}
}