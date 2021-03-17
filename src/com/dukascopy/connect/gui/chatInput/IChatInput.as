package com.dukascopy.connect.gui.chatInput {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public interface IChatInput {
		function setWidth(width:int):void;
		function setMaxTopY(margin:int):void;
		function getView():DisplayObject;
		function activate():void;
		function setCallBack(onChatSend:Function):void;
		function show(defaultText:String = null):void;
		function setValue(text:String):void;
		function deactivate():void;
		function dispose():void;
		function setY(openChatY:int):void;
		function getStartHeight():Number;
		function hide():void;		
		function showBG():void;
		function blockStickers(val:Boolean = true):void;
		function blockExtraFunctions():void;
		function initButtons(showPayButtons:Boolean = false):void;
		function hideBackground():void;
		function isShown():Boolean;
		
		function hideStickersAndAttachButton():void;
		function setLeftMargin(value:int):void;
		function hideStickersButton():void;
		function hideAttachButton():void;
		function disableVoiceRecord():void;
		function getHeight():int;
	}
}