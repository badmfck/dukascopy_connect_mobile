package com.dukascopy.connect.data.coinMarketplace.stat 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class KalmanFilter 
	{
		public var X0:Number;
		public var P0:Number;
		
		public var F:Number;
		public var Q:Number;
		public var H:Number;
		public var R:Number;
		
		public var state:Number;
		public var covariance:Number;
		
		public function KalmanFilter(q:Number, r:Number, f:Number, h:Number) 
		{
			Q = q;
			R = r;
			F = f;
			H = h;
		}
		
		public function setState(s:Number, c:Number):void
		{
			state = s;
			covariance = c;
		}
		
		public function correct(data:Number):void
		{
			//time update - prediction
            X0 = F * state;
            P0 = F * covariance * F + Q;
			
            //measurement update - correction
            var K:Number = H * P0 / (H * P0 * H + R);
            state = X0 + K * (data - H * X0);
            covariance = (1 - K * H) * P0;  
		}
	}
}