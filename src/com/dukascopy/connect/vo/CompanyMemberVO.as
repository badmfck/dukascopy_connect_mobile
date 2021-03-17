package com.dukascopy.connect.vo {
	
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.utils.ArrayUtils;
	import com.dukascopy.connect.vo.users.adds.MemberVO;

	/**
	 * ...
	 * @author ...
	 */
	
	public class CompanyMemberVO {

		public var uid:String;
		public var short:String;
		public var title:String;
		
		public var dep:Array;
		private var _members:Array;
		public var me:MemberVO;
		
		public function CompanyMemberVO(data:Object) {
			
			if(data == null) return;
			
			members = [];
			if("info" in data){
				var info:Object = data["info"];
				uid = info.uid || "";
				title = info.title || "";
				short = info.short || "";
			}
			dep = [];
			var i:int;
			var l:int;
			var obj:Object;
			if("dep" in data){
				var arrDep:Array = data["dep"];
				i = 0; l = arrDep.length;
				for (i; i < l; i++) {
					obj = arrDep[i];
					dep.push(new DepartmentVO(obj));
				}
			}
			if("members" in data){
				var arrMembers:Array = data["members"];
				arrMembers = ArrayUtils.sortArray(arrMembers, "name"); 
				i = 0;
				 l = arrMembers.length;
				for (i; i < l; i++) {
					obj = arrMembers[i];
					if (obj.uid == Auth.uid) {
						me = new MemberVO(obj);
						continue;
					}
					members.push(new MemberVO(obj));
				}
			}
		}

		public function getDepByID(id:int):DepartmentVO {
			var depVO:DepartmentVO;
			if(dep != null){
				var i:int = 0;
				var l:int = dep.length;
				for (i; i < l; i++){
					depVO = dep[i];
					if(depVO.id == id){
						break;
					}
				}

			}
			return depVO;
		}
		
		public function get members():Array 
		{
			return [];
		}
		
		public function set members(value:Array):void 
		{
			_members = [];// value;
		}
		

	}
}
