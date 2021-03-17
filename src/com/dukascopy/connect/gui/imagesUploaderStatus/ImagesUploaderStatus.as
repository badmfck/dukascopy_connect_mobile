package com.dukascopy.connect.gui.imagesUploaderStatus {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.imageManager.FileUploader;
	import com.dukascopy.connect.sys.imageManager.ImageUploader;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class ImagesUploaderStatus extends Sprite {
		
		private var imgUploader:FileUploader;
		private var tf:TextField;
		
		public function ImagesUploaderStatus(imgUploader:FileUploader) {
			this.imgUploader = imgUploader;
			
			graphics.beginFill(0, 0.3);
			graphics.drawRoundRect(0, 0, Config.FINGER_SIZE * 3, Config.FINGER_SIZE - Config.DOUBLE_MARGIN, Config.FINGER_SIZE - Config.DOUBLE_MARGIN, Config.FINGER_SIZE - Config.DOUBLE_MARGIN)
			
			var t:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * 0.24, 0xFFFFFF);
			
			tf = new TextField();
			tf.defaultTextFormat = t;
			tf.multiline = false;
			tf.wordWrap = false;
			tf.text = "Pp";
			tf.height = tf.textHeight + 4;
			tf.text = "";
			tf.y = int((Config.FINGER_SIZE - Config.DOUBLE_MARGIN - tf.height ) * .5);
			tf.x = Config.DOUBLE_MARGIN;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.selectable = false;
			addChild(tf);
		}
		
		public function update(status:String, data:Object):void {
			if (status == "") {
				tf.text = "waiting";
			} else if (status == ImageUploader.STATUS_START) {
				tf.text = "crypting";
			} else if (status == ImageUploader.STATUS_START_UPLOAD) {
				tf.text = "uploading: 0%";
			} else if (status == ImageUploader.STATUS_PROGRESS) {
				tf.text = "uploading: " + int(data[1] / data[0] * 100) + "%";
			} else if (status == ImageUploader.STATUS_COMPLETED) {
				tf.text = "uploaded";
			} else if (status == ImageUploader.STATUS_ERROR) {
				tf.text = "error";
			}
		}
		
		public function getImgUploader():FileUploader {
			return imgUploader;
		}
		
		public function dispose():void {
			if (tf != null) {
				tf.text = "";
				if (tf.parent != null)
					tf.parent.removeChild(tf);
			}
			tf = null;
			graphics.clear();
			imgUploader = null;
		}
	}
}