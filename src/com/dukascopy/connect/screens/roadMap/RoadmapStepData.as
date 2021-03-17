package com.dukascopy.connect.screens.roadMap 
{
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RoadmapStepData 
	{
		private var step:String;
		public var title:String;
		public var status:String;
		public var action:IAction;
		
		static public const STATE_ACTIVE:String = "stateActive";
		static public const STATE_DONE:String = "stateDone";
		static public const STATE_FAIL:String = "stateFail";
		static public const STATE_INACTIVE:String = "stateInactive";
		static public const STATE_CHANGE:String = "stateChange";
		
		static public const STEP_REGISTRATION_FORM:String = "STEP_REGISTRATION_FORM";
		static public const STEP_DOCUMENT_SCAN:String = "STEP_DOCUMENT_SCAN";
		static public const STEP_DEPOSIT:String = "STEP_DEPOSIT";
		static public const STEP_SELECT_CARD:String = "STEP_SELECT_CARD";
		static public const STEP_VIDEOIDENTIFICATION:String = "STEP_VIDEOIDENTIFICATION";
		static public const STEP_APPROVE_ACCOUNT:String = "STEP_APPROVE_ACCOUNT";
		static public const STEP_SOLVENCY_CHECK:String = "STEP_SOLVENCY_CHECK";
		
		public function RoadmapStepData(step:String, title:String, action:IAction = null) 
		{
			this.step = step;
			this.title = title;
			this.action = action;
		}
		
		public function get subtitle():String
		{
			var result:String = "";
			switch(status)
			{
				case STATE_CHANGE:
				{
					result = Lang.roadmap_change;
					break;
				}
				case STATE_ACTIVE:
				{
					result = Lang.roadmap_pressToStart;
					break;
				}
				case STATE_DONE:
				{
					result = Lang.roadmap_completed;
					break;
				}
				case STATE_FAIL:
				{
					result = Lang.roadmap_failed;
					break;
				}
				case STATE_INACTIVE:
				{
					result = Lang.roadmap_waiting;
					break;
				}
			}
			if (result != null)
			{
				return result.toUpperCase();
			}
			return "";
		}
		
		public function get icon():Class
		{
			switch(step)
			{
				case STEP_REGISTRATION_FORM:
				{
					switch(status)
					{
						case STATE_CHANGE:
						case STATE_ACTIVE:
						{
							return Style.icon(Style.ICON_ROADMAP_FORM_ACTIVE);
						}
						case STATE_DONE:
						{
							return Style.icon(Style.ICON_ROADMAP_FORM_DONE);
						}
						case STATE_FAIL:
						{
							return Style.icon(Style.ICON_ROADMAP_FORM_FAIL);
						}
						case STATE_INACTIVE:
						{
							return Style.icon(Style.ICON_ROADMAP_FORM_ACTIVE);
						}
					}
				}
				case STEP_DOCUMENT_SCAN:
				{
					switch(status)
					{
						case STATE_ACTIVE:
						case STATE_CHANGE:
						{
							return Style.icon(Style.ICON_ROADMAP_SCAN_ACTIVE);
						}
						case STATE_DONE:
						{
							return Style.icon(Style.ICON_ROADMAP_SCAN_DONE);
						}
						case STATE_FAIL:
						{
							return Style.icon(Style.ICON_ROADMAP_SCAN_FAIL);
						}
						case STATE_INACTIVE:
						{
							return Style.icon(Style.ICON_ROADMAP_SCAN_ACTIVE);
						}
					}
				}
				case STEP_SOLVENCY_CHECK:
				{
					switch(status)
					{
						case STATE_CHANGE:
						case STATE_ACTIVE:
						{
							return Style.icon(Style.ICON_ROADMAP_SOLVENCY_ACTIVE);
						}
						case STATE_DONE:
						{
							return Style.icon(Style.ICON_ROADMAP_SOLVENCY_DONE);
						}
						case STATE_FAIL:
						{
							return Style.icon(Style.ICON_ROADMAP_SOLVENCY_FAIL);
						}
						case STATE_INACTIVE:
						{
							return Style.icon(Style.ICON_ROADMAP_SOLVENCY_ACTIVE);
						}
					}
				}
				case STEP_DEPOSIT:
				{
					switch(status)
					{
						case STATE_CHANGE:
						case STATE_ACTIVE:
						{
							return Style.icon(Style.ICON_ROADMAP_DEPOSIT_ACTIVE);
						}
						case STATE_DONE:
						{
							return Style.icon(Style.ICON_ROADMAP_DEPOSIT_DONE);
						}
						case STATE_FAIL:
						{
							return Style.icon(Style.ICON_ROADMAP_DEPOSIT_FAIL);
						}
						case STATE_INACTIVE:
						{
							return Style.icon(Style.ICON_ROADMAP_DEPOSIT_ACTIVE);
						}
					}
				}
				case STEP_SELECT_CARD:
				{
					switch(status)
					{
						case STATE_CHANGE:
						case STATE_ACTIVE:
						{
							return Style.icon(Style.ICON_ROADMAP_SELECT_CARD_ACTIVE);
						}
						case STATE_DONE:
						{
							return Style.icon(Style.ICON_ROADMAP_SELECT_CARD_DONE);
						}
						case STATE_FAIL:
						{
							return Style.icon(Style.ICON_ROADMAP_SELECT_CARD_FAIL);
						}
						case STATE_INACTIVE:
						{
							return Style.icon(Style.ICON_ROADMAP_SELECT_CARD_ACTIVE);
						}
					}
				}
				case STEP_VIDEOIDENTIFICATION:
				{
					switch(status)
					{
						case STATE_CHANGE:
						case STATE_ACTIVE:
						{
							return Style.icon(Style.ICON_ROADMAP_VIDEOIDENTIFICATION_ACTIVE);
						}
						case STATE_DONE:
						{
							return Style.icon(Style.ICON_ROADMAP_VIDEOIDENTIFICATION_DONE);
						}
						case STATE_FAIL:
						{
							return Style.icon(Style.ICON_ROADMAP_VIDEOIDENTIFICATION_FAIL);
						}
						case STATE_INACTIVE:
						{
							return Style.icon(Style.ICON_ROADMAP_VIDEOIDENTIFICATION_ACTIVE);
						}
					}
				}
				case STEP_APPROVE_ACCOUNT:
				{
					switch(status)
					{
						case STATE_CHANGE:
						case STATE_ACTIVE:
						{
							return Style.icon(Style.ICON_ROADMAP_APPROVE_ACCOUNT_ACTIVE);
						}
						case STATE_DONE:
						{
							return Style.icon(Style.ICON_ROADMAP_APPROVE_ACCOUNT_DONE);
						}
						case STATE_FAIL:
						{
							return Style.icon(Style.ICON_ROADMAP_APPROVE_ACCOUNT_FAIL);
						}
						case STATE_INACTIVE:
						{
							return Style.icon(Style.ICON_ROADMAP_APPROVE_ACCOUNT_ACTIVE);
						}
					}
				}
			}
			return Sprite;
		}
	}
}