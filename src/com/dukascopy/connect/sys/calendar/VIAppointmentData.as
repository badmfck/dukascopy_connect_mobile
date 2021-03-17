package com.dukascopy.connect.sys.calendar 
{
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class VIAppointmentData 
	{
		private var loading:Boolean;
		public var errors:int = 0;
		public var id:String;
		public var success:Boolean;
		public var exist:Boolean;
		public var date:Date;
		public var hours:TimeRange;
		public var minutes:TimeRange;
		
		public function VIAppointmentData(rawData:Object = null) 
		{
			if (rawData == null)
			{
				load();
			}
			else
			{
				exist = true;
				success = true;
				
				parse(rawData.info);
			}
		}
		
		private function parse(data:Object):void 
		{
			id = data.id;
			date = new Date();
			date.setTime(data.startUTS * 1000);
			hours = new TimeRange(date.getHours(), 10);
			minutes = new TimeRange(date.getMinutes(), 10);
		}
		
		public function load():void 
		{
			if (errors > 3)
			{
				return;
			}
			if (loading == true)
			{
				return;
			}
			loading = true;
			PHP.call_barabanCheckMyBook(onAppointmentDataLoaded);
		}
		
		public function dispose():void 
		{
			
		}
		
		private function onAppointmentDataLoaded(respond:PHPRespond):void 
		{
			loading = false;
			if (respond.error == true)
			{
			//	ToastMessage.display(Lang.textError);
				success = false;
				exist = true;
				errors++;
				respond.dispose();
			//	return;
			}
			else
			{
				success = true;
				exist = false;
				if(respond.data != false)
				{
					parse(respond.data);
					
					exist = true;
				}
				respond.dispose();
			}
			
			Calendar.S_APPOINTMENT_DATA.invoke();
		}
	}
}