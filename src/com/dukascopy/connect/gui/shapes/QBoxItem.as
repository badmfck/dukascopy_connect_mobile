package com.dukascopy.connect.gui.shapes {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.screens.dialogs.DialogDropDown;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author IgorBloom + Pavel Karpov Telefision TEAM Kiev.
	 */
	
	public class QBoxItem {
			
		static private const dropItemHeight:int = Math.round(Config.FINGER_SIZE * 0.8);
		static private const arrowHeight:int = Math.round(dropItemHeight * 0.15);
		static private const arrowCathetus:int = Math.round(dropItemHeight * 0.12);
		
		private var view:Sprite;
		public var selectedValue:Object = null;
		private var valueButton:DDFieldButton;
		private var labelText:TextField;
		private var box:Sprite;
		
		public var items:Array;
		private var lastItem:Boolean = false;
		private var shortLabel:String;
		public var blockLabel:String;
		public var id:String;
		
		public function QBoxItem(box:Sprite, blockLabel:String, items:Array, shortLabel:String, id:String) {
			this.blockLabel = blockLabel;
			this.id = id;
			this.box = box;
			this.shortLabel = shortLabel;
			this.items = items;
			// item
			view = new Sprite();
			// Value name
			labelText = UIFactory.createTextField(Config.FINGER_SIZE * .21, true, true);
			labelText.text = blockLabel;
			labelText.alpha = .55;
			view.addChild(labelText);
			// value view
			valueButton = new DDFieldButton(onValueTapped);
			view.addChild(valueButton);
			box.addChild(view);
		}
		
		public function getValue():Object {
			return selectedValue;
		}
		
		public function isLast(val:Boolean):void {
			lastItem = val;
		}
		
		public function setSize(w:int):void {
			labelText.width = w - box.x - Config.MARGIN;
			valueButton.y = Math.round(labelText.y + labelText.height + Config.FINGER_SIZE * .1);
			var boxW:int = w * .5;
			valueButton.setSize(boxW, dropItemHeight);
			
			if (lastItem == false) {
				valueButton.graphics.beginFill(0, .1);
				valueButton.graphics.drawRect(0, dropItemHeight + Config.DOUBLE_MARGIN, w, 1);
			}
			
			valueButton.graphics.beginFill(0xFF0000, 0);
			valueButton.graphics.drawRect(0, dropItemHeight, 1, Config.DOUBLE_MARGIN * 2); // bottom margin
		}
		
		public function getHeight():int {
			return view.height;
		}
		
		public function setY(y:int):void {
			view.y = y;
		}
		
		public function deactivate():void {
			valueButton.deactivate();
		}
		
		public function activate():void {
			valueButton.activate();
		}
		
		private function onValueTapped():void {
			DialogManager.showDialog(DialogDropDown, { items:items, title:shortLabel, callBack:onValueSelected });
		}
		
		private function onValueSelected(data:Object):void {
			selectedValue = data;
			if(data != null)
				valueButton.setValue(data.name);
			else
				valueButton.setValue();
		}
		
		public function dispose():void {
			if (labelText != null) {
				if (labelText.parent != null) 
					labelText.parent.removeChild(labelText);
				labelText.text = "";
				labelText = null;
			}
			
			if (valueButton != null) 
				valueButton.dispose();
			valueButton = null;
			selectedValue = null;
			if (view.parent != null)	
				view.parent.removeChild(view);
			view = null;
			box = null;

			items = null;
			shortLabel = "";
			blockLabel = "";
			id = "";
		}
	}
}