package com.dukascopy.connect.sys.applicationShop.commodity {
	
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.connect.sys.payments.PayInvestmentsManager;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	
	public class Commodity {
		
		public var type:CommodityType;
		
		public function Commodity(type:CommodityType) {
			this.type = type;
		}
		
		public function get disabled():Boolean {
			return false;
		}
		
		public function get id():String {
			return null;
		}
		
		public function get iconColor():Number {
			return -1;
		}
		
		public function get icon():String {
			var iconInstance:Sprite = getIcon();
			if (iconInstance != null) {
				return getQualifiedClassName(iconInstance)
			}
			return null;
		}
		
		public function get fullLink():String {
			return getName();
		}
		
		public function getName():String {
			if (type != null) {
				return PayInvestmentsManager.getInvestmentNameByInstrument(type.value);
			} else {
				ApplicationErrors.add("crit");
			}
			return "";
		}
		
		public function getIcon():Sprite {
			if (type != null) {
				return UI.getInvestIconByInstrument(type.value);
			} else {
				ApplicationErrors.add("crit");
			}
			return null;
		}
		
		public function getMeasurmentName():String {
			return CurrencyHelpers.getCurrencyByKey(type.value);
		}
	}
}