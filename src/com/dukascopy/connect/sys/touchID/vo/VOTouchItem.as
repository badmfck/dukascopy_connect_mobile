/**
 * Created by aleksei.leschenko on 29.08.2016.
 */
package com.dukascopy.connect.sys.touchID.vo {
	public class VOTouchItem {

		private var _account:String = "";
		private var _secret:String = "";

		private var _data:Object;

		public function VOTouchItem(obj:Object = null){
			update(obj);
		}

		public function update(obj:Object):void {
			if(obj != null){
				if(obj["account"]){
					account = obj["account"];
				}if(obj["secret"]){
					secret = obj["secret"];
				}
				_data = obj;
			}
		}

		public function get account():String {
			return _account;
		}

		public function set account(value:String):void {

			_account = value;
		}

		public function get secret():String {
			return _secret;
		}

		public function set secret(value:String):void {
			_secret = value;
		}

		public function clear():void {
			_account = "";
			_secret = "";
			_data = new Object();
		}

		public function get data():Object {
			_data = new Object();
			_data.account = account;
			_data.secret = secret;
			return _data;
		}
	}
}
