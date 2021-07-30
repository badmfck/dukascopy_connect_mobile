package com.dukascopy.connect.sys.php {
	import com.dukascopy.connect.sys.echo.echo;
	import com.greensock.TweenMax;
	import com.telefision.utils.Loop;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author ...
	 */
	public class PHPFormData {
		
		
		// INSTANCE
		private var postData:ByteArray;
		
		public function PHPFormData(){
			echo("PHPFormData","constructor","create instance");
			postData = new ByteArray();
			postData.endian = Endian.BIG_ENDIAN;
		}
		
		/**
		 * Add param to FormData
		 * @param	name	String variable name
		 * @param	value	String utf-8 value
		 */
		public function addParam(name:String, value:String):void {
			 //add parameters to postData
			echo("PHPFormData","addParam","name: "+name+", value: "+value);
			postData = BOUNDARY(postData);
			postData = LINEBREAK(postData);
			var bytes:String = 'Content-Disposition: form-data; name="' + name + '"';
			var i:int = 0;
			var l:int = bytes.length;
			for ( i = 0; i < l; i++ )
				postData.writeByte(bytes.charCodeAt(i));
			postData = LINEBREAK(postData);
			postData = LINEBREAK(postData);
			postData.writeUTFBytes(value);
			postData = LINEBREAK(postData);
		}
		
		/**
		 * Asynchroniously adding file to form data
		 * @param	name		String fileName for $_FILES[%filename%]
		 * @param	file		ByteArray of file
		 * @param	callBack	Function - function():void
		 */
		public function addFile(name:String, filename:String, file:ByteArray, callBack:Function, fileType:String = null):void {
			echo("PHPFormData","addFile","try to add file: name: "+name+", filename: "+filename+", bytes: "+file.length+", fileType: "+(fileType?fileType:"null"));
			postData = BOUNDARY(postData);
            postData = LINEBREAK(postData);
            var bytes:String = 'Content-Disposition: form-data; name="' + name+'"; filename="';
			var l:int = bytes.length;
			var i:int = 0;
            for ( i = 0; i <l; i++)
                postData.writeByte(bytes.charCodeAt(i));
            
            postData.writeUTFBytes(filename);
            postData = QUOTATIONMARK(postData);
            postData = LINEBREAK(postData);
            bytes = 'Content-Type: application/octet-stream';
			l = bytes.length;
            for ( i = 0; i < l; i++ )
                postData.writeByte( bytes.charCodeAt(i) );
			postData = LINEBREAK(postData);
            postData = LINEBREAK(postData);
			
			
			
			// FILES TO UPLOAD
			var perFrame:int = 10000; 
			var startPosition:int = 0;
			file.position = 0;
			
			var __writeFile:Function = function():void {
				if (startPosition >= file.length){
					postData = LINEBREAK(postData);
					Loop.remove(__writeFile);
					echo("PHPFormData","addFile","all chunks added");
					callBack();
					return;
				}
				
				echo("PHPFormData","addFile","add chunk, startPosition: "+startPosition+", file length: "+file.length+", "+perFrame);

				var len:int = perFrame;
				var fl:int = file.length;
				if (startPosition + perFrame > fl)
					len = fl - startPosition;
				postData.writeBytes(file, startPosition, len);
				startPosition += perFrame;
			};
			
			Loop.add(__writeFile);
		}
		
		/**
		 * Send FormData to server
		 * @param	url			String URL to send
		 * @param	callBack	function(r:PHPRespond):void
		 */
		public function send(url:String, callBack:Function):void {

			echo("PHPFormData","send","send file to: "+url);

			postData = BOUNDARY(postData);
			postData = DOUBLEDASH(postData);
			
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.url = url;
			urlRequest.contentType = 'multipart/form-data; boundary=' + getBoundary();
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = postData;
			urlRequest.requestHeaders = [new URLRequestHeader( 'Cache-Control', 'no-cache' )];
			
			var __finish:Function = function(err:String, data:String = null):void {
				postData.clear();
				postData = null;
				TweenMax.delayedCall(1, function():void {
					echo("file:", "PHPFormData finish: ");
					echo("PHPFormData","send.finish", "TweenMax.delayedCall");
					BaseServerLoader.createRespond(err, data, callBack);
				}, null, true);
			}
			
			var __onComplete:Function = function(e:Event):void {
				__finish(null,urlLoader.data);
			}
			
			var __onError:Function = function(e:Event):void {
				__finish(PHP.NETWORK_ERROR);
			}
			
			var __onSecError:Function = function(e:Event):void {
				__finish('sec');
			}

			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, __onComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, __onError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __onSecError);
			urlLoader.load(urlRequest);
			
		}
		
		
		 /**
         * Boundary used to break up different parts of the http POST body
         */
        private static var _boundary:String = "";

        /**
         * Get the boundary for the post.
         * Must be passed as part of the contentType of the UrlRequest
         */
        public static function getBoundary():String {
            if(_boundary.length == 0) {
                for (var i:int = 0; i < 0x20; i++ ) {
                    _boundary += String.fromCharCode( int( 97 + Math.random() * 25 ) );
                }
            }

            return _boundary;
        }
	
		
		
        /**
         * Add a boundary to the PostData with leading doubledash
         */
        private static function BOUNDARY(p:ByteArray):ByteArray {
            var l:int = getBoundary().length;

            p = DOUBLEDASH(p);
            for (var i:int = 0; i<l; i++ ) {
                p.writeByte( _boundary.charCodeAt( i ) );
            }
            return p;
        }

        /**
         * Add one linebreak
         */
        private static function LINEBREAK(p:ByteArray):ByteArray {
            p.writeShort(0x0d0a);
            return p;
        }

        /**
         * Add quotation mark
         */
        private static function QUOTATIONMARK(p:ByteArray):ByteArray {
            p.writeByte(0x22);
            return p;
        }

        /**
         * Add Double Dash
         */
        private static function DOUBLEDASH(p:ByteArray):ByteArray {
            p.writeShort(0x2d2d);
            return p;
        }
		
	}

}