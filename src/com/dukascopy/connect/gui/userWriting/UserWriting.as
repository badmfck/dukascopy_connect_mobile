package com.dukascopy.connect.gui.userWriting {
	
	import assets.UserWritingAnimation;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov
	 */
	
	public class UserWriting extends MobileClip {
		
		static public var S_USER_WRITING_DISPOSED:Signal = new Signal('UserWriting.S_USER_WRITING_DISPOSED');
		
		private var iconBMP:Bitmap;
		
		private var chatUID:String;
		private var users:Array = [];
		
		private var timer:Timer = new Timer(1000);
		private var timerInitialized:Boolean = false;
		private var _textColor:uint = 0x000000;
		private var circleSize:Number;
		private var animation:UserWritingAnimation;
	
		public function UserWriting(chatUID:String) {
			super();
			
			this.chatUID = chatUID;
			
			createView();
		}
		
		public function createView():void {
			_view = new Sprite();
			
			circleSize = Math.ceil(Config.FINGER_SIZE * .7);
			
			animation = new UserWritingAnimation();
			_view.addChild(animation);
			
			animation.width = animation.height = int(circleSize);
			animation.x = int(Config.FINGER_SIZE * .3);
			updateIconColor();
		}
		
		private function updateIconColor():void {		
			if (iconBMP != null) {
				var ct:ColorTransform = new ColorTransform();
				ct.color = _textColor;
				iconBMP.transform.colorTransform = ct;
			}
		}
		
		public function setWidth(w:int):void { }
		
		public function addUser(userUID:String, userName:String):void {
			var l:int = users.length;
			for (var i:int = 0; i < l; i++) {
				if (users[i].uid == userUID) {
					users[i].creation = new Date().getTime();
					return;
				}
			}
			users.push( { uid:userUID, name:userName, creation:new Date().getTime() } );
			
			if (timerInitialized == false) {
				timerInitialized = true;
				timer.addEventListener(TimerEvent.TIMER, clearUsers);
				timer.start();
			}
			
			clearUsers();
		}
		
		public function removeUser(userUID:String):void {
			var l:int = users.length;
			for (var i:int = 0; i < l; i++) {
				if (users[i].uid == userUID) {
					users.splice(i, 1);
					break;
				}
			}
			
			clearUsers();
		}
		
		private function clearUsers(e:TimerEvent = null):void {
			var i:int;
			var changed:Boolean = false;
			var str:String = "";
			for (i = 0; i < users.length; i++) {
				if (users[i].creation < new Date().getTime() - 7000) {
					users.splice(i, 1);
					i--;
					changed = true;
					continue;
				}
				str += ", " + users[i].name;
			}
			if (changed == false && e != null)
				return;
			if (users.length == 0) {
				dispose();
				return;
			}
			////str = str.substr(2) + " is writing";
		}
		
		override public function dispose():void {
			timer.removeEventListener(TimerEvent.TIMER, clearUsers);
			timer.stop();
			timer = null;
			
			users.length = 0;
			users = null;
			
			chatUID = "";
			
			iconBMP = null;
			
			if (animation) {
				UI.destroy(animation);
				animation = null;
			}
			
			super.dispose();
			
			S_USER_WRITING_DISPOSED.invoke(this);
		}
		
		public function getHeight():int {
			return circleSize;
			return Config.FINGER_SIZE_DOT_35;
		}
		
		public function getView():Sprite {
			return _view;
		}
		
		public function get textColor():uint { return _textColor; }
		public function set textColor(value:uint):void {
			if (_textColor == value) return;
			_textColor = value;
			updateIconColor();
		}
	}
}