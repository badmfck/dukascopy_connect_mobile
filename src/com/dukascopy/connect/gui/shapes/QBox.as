package com.dukascopy.connect.gui.shapes {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.payments.PaymentsRTOLimitsScreen;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author IgorBloom + Pavel Karpov Telefision TEAM Kiev.
	 */
	
	public class QBox extends MobileClip {
		
		private var tfLabel:TextField;
		private var btnOpen:BitmapButton;
		private var box:Sprite;
		public var label:String;
		private var boxes:Array = [];
		public var checked:Boolean = false;
		public var separator:Shape;
		
		public function QBox(label:String) {
			this.label = label;
			
			_view = new Sprite();
			tfLabel = UIFactory.createTextField(-1, true, true);
			tfLabel.text = label;
			_view.addChild(tfLabel);
			
			separator = new Shape();
			separator.graphics.beginFill(0, .2);
			separator.graphics.drawRect(0, 0, 1, 1);
			separator.graphics.endFill();
			_view.addChild(separator);
			
			box = new Sprite();
			box.x = Config.FINGER_SIZE_DOT_5;
			
			btnOpen = new BitmapButton();
			btnOpen.setStandartButtonParams();
			btnOpen.usePreventOnDown = true;
			btnOpen.cancelOnVerticalMovement = true;
			btnOpen.tapCallback = onBtnOpen;
			var overMargin:int = Config.FINGER_SIZE_DOT_5;
			btnOpen.setOverflow(overMargin, overMargin, overMargin, overMargin);
			_view.addChild(btnOpen);
			
			setCheckBoxValue();
		}
		
		private function setCheckBoxValue():void {
			if (box.parent == null) {
				checked = false;
				btnOpen.setBitmapData(UI.renderCheckBox());
			} else {
				checked = true;
				btnOpen.setBitmapData(UI.renderCheckBox(true, -1, 2, 0xFFFFFF));
			}
		}
		
		private function onBtnOpen():void {
			if (box.parent) {
				separator.visible = true;
				box.parent.removeChild(box);
			} else {
				separator.visible = false;
				_view.addChild(box);
			}
			setCheckBoxValue();
			PaymentsRTOLimitsScreen.S_NEED_UPDATE.invoke();
		}
		
		public function add(blockLabel:String, items:Array,shortLabel:String,id:String):void {
			var itm:QBoxItem = new QBoxItem(box, blockLabel, items, shortLabel, id);
			boxes[boxes.length] = itm;
		}
		
		public function setSize(width:int):void {
			btnOpen.x = Config.FINGER_SIZE_DOT_5;
			btnOpen.y = Math.round((btnOpen.fullHeight - btnOpen.height) * .5);
			tfLabel.x = Math.round(btnOpen.width + Config.FINGER_SIZE_DOT_5 * 2);
			tfLabel.width = width - tfLabel.x - Config.MARGIN;
			tfLabel.y = (btnOpen.fullHeight - tfLabel.textHeight) * .5;
			box.y = Math.round(tfLabel.y + tfLabel.height + Config.FINGER_SIZE * .3);
			
			box.x = tfLabel.x;
			var y:int = 0;
			for (var n:int = 0; n < boxes.length; n++ ) {
				var qi:QBoxItem = boxes[n];
				qi.isLast(boxes.length - 1 == n);
				qi.setSize(width);
				qi.setY(y);
				y += qi.getHeight();
			}
			
			separator.y = _view.height - 1;
			separator.width = width;
		}
		
		public function deactivate():void {
			btnOpen.deactivate();
			for (var n:int = 0; n < boxes.length; n++)
				boxes[n].deactivate();
		}
		
		public function activate():void {
			btnOpen.activate();
			for (var n:int = 0; n < boxes.length; n++)
				boxes[n].activate();
		}
		
		public function allSelected():Boolean {
			var qi:QBoxItem;
			var isAllSelected:Boolean =  boxes.length > 0;
			for (var n:int = 0; n < boxes.length; n++) {
				qi = boxes[n];
				if (qi.selectedValue == null)
					return false;
			}
			return isAllSelected;
		}
		
		public function getValues():Object {
			var	obj:Array = [];
			for (var n:int = 0; n < boxes.length; n++)
				obj[boxes[n].id] = boxes[n].getValue();
			return obj;
		}
		
		public function getItems():Array {
			return boxes;
		}
		
		override public function dispose():void {
			super.dispose();
			if (tfLabel != null) {
				if (tfLabel.parent != null)
					tfLabel.parent.removeChild(tfLabel);
				tfLabel.text = "";
			}
			tfLabel = null;
			if (btnOpen != null) 
				btnOpen.dispose();
			btnOpen = null;
			if (boxes != null) {
				var itm:QBoxItem; 
				while(boxes.length > 0) {
					itm = QBoxItem(boxes.shift());
					itm.dispose();
					itm = null;
				}
			}
			boxes = null;
			if (box != null)
				if (box.parent != null) 
					box.parent.removeChild(box);
			box = null;
		}
	}
}