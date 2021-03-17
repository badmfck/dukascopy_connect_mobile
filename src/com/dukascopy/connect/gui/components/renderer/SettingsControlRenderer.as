package com.dukascopy.connect.gui.components.renderer 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.settings.SettingsControlData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.settings.SettingsControlButton;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import white.Right;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SettingsControlRenderer 
	{
		private var textField:TextField;
		private var formatTitle:TextFormat;
		private var formatSubtitle:TextFormat;
		private var iconImage:ImageBitmapData;
		private var padding:int;
		private var vPadding:int;
		private var line:ImageBitmapData;
		
		public function SettingsControlRenderer() 
		{
			textField = new TextField();
			formatTitle = new TextFormat();
			formatSubtitle = new TextFormat();
			
			var icon:Right = new Right();
			UI.colorize(icon, Style.color(Style.ICON_RIGHT_COLOR));
			UI.scaleToFit(icon, Config.FINGER_SIZE * .25, Config.FINGER_SIZE * .25);
			iconImage = UI.getSnapshot(icon);
			padding = Config.DOUBLE_MARGIN;
			vPadding = Config.FINGER_SIZE * .27;
			
		}
		
		public function render(data:SettingsControlData, width:int):SettingsControlButton 
		{
			if (line == null)
			{
				line = new ImageBitmapData("SettingsControlRenderer.line", width, UI.getLineThickness(), false, Style.color(Style.COLOR_SEPARATOR));
			}
			
			if (data.label == null)
			{
				ApplicationErrors.add();
				return null;
			}
			var button:SettingsControlButton = new SettingsControlButton(data);
			
			button.preventOnMove = true;
			
			var titleImage:ImageBitmapData = TextUtils.createTextFieldData(data.label, width - padding * 3, 
																			10, true, TextFormatAlign.LEFT, 
																			TextFieldAutoSize.LEFT, FontSize.BODY, 
																			true, Style.color(Style.COLOR_TEXT), 
																			Style.color(Style.COLOR_BACKGROUND));
			var subtitleImage:ImageBitmapData;
			if (data.getSelectedLabel() != null)
			{
				subtitleImage = TextUtils.createTextFieldData(data.getSelectedLabel(), width - padding * 3, 
																			10, true, TextFormatAlign.LEFT, 
																			TextFieldAutoSize.LEFT, FontSize.SUBHEAD, 
																			true, Style.color(Style.COLOR_SUBTITLE), 
																			Style.color(Style.COLOR_BACKGROUND));
			}
			
			var buttonHeight:int;
			buttonHeight += vPadding;
			buttonHeight += titleImage.height;
			if (subtitleImage != null)
			{
				buttonHeight += int(vPadding * .7);
				buttonHeight += subtitleImage.height;
			}
			buttonHeight += vPadding;
			
			var resultImage:ImageBitmapData = new ImageBitmapData("SettingsControlRenderer", width, buttonHeight, false, Style.color(Style.COLOR_BACKGROUND));
			resultImage.copyPixels(titleImage, titleImage.rect, new Point(padding, vPadding), null, null, true);
			if (subtitleImage != null)
			{
				resultImage.copyPixels(subtitleImage, subtitleImage.rect, new Point(padding, vPadding + int(vPadding * .7) + titleImage.height), null, null, true);
			}
			resultImage.copyPixels(iconImage, iconImage.rect, new Point(int(width - padding - iconImage.width), int(resultImage.height * .5 - iconImage.height * .5)), null, null, true);
			resultImage.copyPixels(line, line.rect, new Point(0, int(buttonHeight - line.height)), null, null, true);
			titleImage.dispose();
			titleImage = null;
			if (subtitleImage != null)
			{
				subtitleImage.dispose();
				subtitleImage = null;
			}
			button.setBitmapData(resultImage);
			return button;
		}
		
		public function dispose():void
		{
			UI.destroy(textField);
			formatTitle = null;
			formatSubtitle = null;
			iconImage.dispose();
			iconImage = null;
			line.dispose();
			line = null;
		}
	}
}