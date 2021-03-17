package com.dukascopy.connect.screens.call 
{
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface IProgressIndicator 
	{
		function setSize(width:int, height:int):void;
		function setStepsCount(totalVideoRecognitionStates:int):void;
		function selectStep(step:Number, animate:Boolean):void;
		function dispose():void;
	}
}