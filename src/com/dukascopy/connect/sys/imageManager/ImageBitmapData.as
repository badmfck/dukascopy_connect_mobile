package com.dukascopy.connect.sys.imageManager 
{
	
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.echo.echo;
	import com.freshplanet.ane.KeyboardSize.MeasureKeyboard;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author Igor
	 */
	public class ImageBitmapData extends BitmapData {
		
		private var _isDisposed:Boolean;
		private var _useCount:int = 0;
		private var _saving:Boolean =false;
		private var needDispose:Boolean = false;
		private var _isAsset:Boolean = false;
		
		static private var _assets:int = 0;
		static public var isDebug:Boolean = false;
		static private var _debugArrayStock:Array = [];
		static private var _acitveBitmaps:int = 0;
		
		static private var $matrix:Matrix;
		static private var $pt:Point;
		private var _name:String;
		
		private var _decrypted:Boolean = false;
		private var fillColor:uint;
		private var _generic:Boolean;
		
		public function ImageBitmapData(name:String, width:int, height:int, transparent:Boolean = true, fillColor:uint = 0, isAsset:Boolean = false, generic:Boolean = true) {
			
			if (isDebug)
			{
				var n:int = 0;
				var l:int = _debugArrayStock.length;
				/*for (n; n < l; n++)
				{
					if (_debugArrayStock[n].name == name && name.indexOf("http") != -1)
					{
						//crit error
					}
				}*/
			}
			
			this.fillColor = fillColor;
			_name = name;
			_generic = generic;
			_decrypted = isAsset;
			if(isDebug){
				
				_acitveBitmaps++;
				_debugArrayStock[_debugArrayStock.length ] = this;
			}
			
			_isAsset = isAsset;
			if (_isAsset)
				_assets++;
			if (width <1)
				width = 1;
			if (height <1)
				height = 1;
			super(width, height, transparent, fillColor);
		}
		
		public function incUseCount(target:String):void {
			_useCount++;
			
			if (useCount > 0)
			{
				needDispose = false;
			}
		}
		
		public function copyBitmapData(bmp:BitmapData, disposeSource:Boolean = true):void {
			if (bmp == null)
				return;
			if (!(bmp is BitmapData))
				return;
			if (!('width' in bmp && int(bmp.width) > 0))
				return;
			if ($pt == null)
				$pt = new Point(0, 0);
			this.copyPixels(bmp, bmp.rect, $pt);
			if (disposeSource)
			{
				bmp.dispose();
				bmp = null;
			}
			
			_decrypted = false;
		}
		
		override public function dispose():void {
			if (_isAsset)
				return;
			if (_isDisposed == true)
				return;
			_useCount--;
			if (_useCount < 0) {
				_useCount = 0;
			}
			if (_useCount < 1) {
				needDispose = true;
				if (_saving) {
					if (ImageSaver.isInSaveProcess(name)) {
						ImageManager.S_IMAGE_SAVED.add(onSaveComplete);
						return;
					} else {
						_saving = false;
						ImageManager.S_IMAGE_SAVED.remove(onSaveComplete);
					}
				}
				ImageManager.S_IMAGE_SAVED.remove(onSaveComplete);
				//echo("ImageBitmapData", "dispose");
				super.dispose();
				_decrypted = false;
				_isDisposed = true;
				if (isDebug) {
					
					$pt = null;
					
					var n:int = 0;
					var l:int = _debugArrayStock.length;
					for (n; n < l; n++){
						if (_debugArrayStock[n] == this) {
							_acitveBitmaps--;
							_debugArrayStock.splice(n, 1);
							break;
						}
					}
					_name = null;
					if (_isAsset)
						_assets--;
				}
			}
			//echo("ImageBitmapData", "dispose", "END");
		}
		
		private function onSaveComplete(imageURL:String):void {
			if (imageURL.length > 10 && imageURL.substr(0, 10) == "fromStore.") {
				imageURL = imageURL.slice(10);
			}
			var bitmapOriginalName:String = name;
			if (bitmapOriginalName.length > 10 && bitmapOriginalName.substr(0, 10) == "fromStore.") {
				bitmapOriginalName = bitmapOriginalName.slice(10);
			}
			if (imageURL == bitmapOriginalName) {
				_saving = false;
				ImageManager.S_IMAGE_SAVED.remove(onSaveComplete);
				if (needDispose) {
					dispose();
				}
			}
		}
		
		/**
		 * Если данные идут со store - то там они каким то боком лежат _расшифрованные_, в этом и проблемы
		 * @param	key
		 */
		public function decrypt(key:Array):void {
			if (_decrypted == true)
				return;
			if (_isDisposed)
				return;
			copyBitmapData(Crypter.decryptImage(this, key));
			_decrypted = true;
		}
		
		public function disposeNow():void {
			_useCount = 1;
			dispose();
		}
		
		public function setDecryptionStatus():void {
			_decrypted = true;
		}
		
		static public function traceBitmaps():void {
			if (isDebug == false)
				return;
			var n:int = 0;
			var l:int = _debugArrayStock.length;
			for (n; n < l; n++){
				var bmd:ImageBitmapData = _debugArrayStock[n];
				trace("["+n+"] ImageBitmapData: "+bmd.name+", size: "+bmd.width+'x'+bmd.height+', '+((bmd._isDisposed)?"disposed":"active")+', size: '+bmd.getPixels(bmd.rect).length, ", usesCount: " + bmd.useCount, ", disposed: " + bmd._isDisposed);
			}
		}
		
		static public function totalBitmapsSize():Number {
			if (isDebug == false)
				return -1;
			var n:int = 0;
			var l:int = _debugArrayStock.length;
			var size:Number = 0;
			for (n; n < l; n++){
				var bmd:ImageBitmapData = _debugArrayStock[n];
				size+=bmd.getPixels(bmd.rect).length;
			}
			return size;
		}
		
		public function get useCount():int{	return _useCount;	}
		public function get isDisposed():Boolean{ return _isDisposed; }
		public function get saving():Boolean {		return _saving;	}		
		
		public function set saving(value:Boolean):void {
			if (value == _saving)
			{
				return;
			}
			_saving = value;
			if (!_saving && needDispose && useCount < 1) {
				dispose();
			}
		}
		
		static public function getLoadedBitmaps():int {
			if (isDebug == false)
				return -1;
			var n:int = 0;
			var l:int = _debugArrayStock.length;
			var size:Number = 0;
			for (n; n < l; n++){
				var bmd:ImageBitmapData = _debugArrayStock[n];
				if (bmd._generic == false)
					size++;
			}
			return size;
		}
		
		static public function checkImages():void 
		{
			var n:int = 0;
			var l:int = _debugArrayStock.length;
			for (n; n < l; n++){
				if ((_debugArrayStock[n] as ImageBitmapData).useCount < 1 && (_debugArrayStock[n] as ImageBitmapData).name != null && (_debugArrayStock[n] as ImageBitmapData).name.indexOf("6/image.jpg") != -1)
				{
					(_debugArrayStock[n] as ImageBitmapData).dispose();
					break;
				}
			}
		}
		
		public function get isAsset():Boolean{
			return _isAsset;
		}
		
		static public function get assets():int 
		{
			return _assets;
		}
		
		static public function get activeBitmaps():int{
			return _acitveBitmaps;
		}
		
		public function get decrypted():Boolean {
			return _decrypted;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get generic():Boolean {
			return _generic;
		}
		
		public function set isAsset(value:Boolean):void 
		{
			_isAsset = value;
		}
	}

}