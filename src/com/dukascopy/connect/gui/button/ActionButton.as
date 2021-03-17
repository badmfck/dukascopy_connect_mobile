package com.dukascopy.connect.gui.button {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.style.Style;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ActionButton extends BitmapButton {
		
		private var action:IScreenAction;
		
		public function ActionButton(action:IScreenAction) {
			this.action = action;
			super();
			
			setStandartButtonParams();
			setDownScale(1.3);
			setDownColor(0xFFFFFF);
			disposeBitmapOnDestroy = true;
			usePreventOnDown = false;
			show();
			
			tapCallback = callAction;
		}
		
		public function build(itemWidth:int, itemHeight:int, iconScale:Number = 1):void {
			if (action) {
				var iconClass:Class = action.getIconClass();
				var icon:Sprite = new iconClass();
				var ct:ColorTransform = new ColorTransform();
				ct.color = Style.color(Style.TOP_BAR_ICON_COLOR);
				icon.transform.colorTransform = ct;
				UI.scaleToFit(icon, iconScale * Config.FINGER_SIZE * .6, Config.FINGER_SIZE);
				setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "ActionButton.icon"), true);
				
				setHitZone(icon.width, icon.height);
				var horizontalOverflow:int = Math.max(0, (Config.FINGER_SIZE * .85 - icon.width) * .5);
				var verticalOverflow:int = Math.max(0, (Config.FINGER_SIZE - icon.height) * .5);
				setOverflow(verticalOverflow, horizontalOverflow, horizontalOverflow, verticalOverflow);
				
				UI.destroy(icon);
				icon = null;
			}
		}
		
		override public function dispose():void {
			action = null;
			super.dispose();
		}
		
		private function callAction():void {
			if (action)
				action.execute();
		}
	}
}