package com.dukascopy.connect.vo {

	/**
	 * ...
	 * @author Igor Bloom
	 */

	public class DepartmentVO{
		
		public var title:String;
		public var me:Boolean;
		public var id:int;
		public var short:String;
		public var membersCount:int = -1;
		
		public function DepartmentVO(data:Object) {
			title = data.title;
			me = data.me;
			id = data.id;
			short = data.short;
			membersCount = -1;
		}
		
		public function getMembersCount():int{
			return membersCount;
		}
	}
}