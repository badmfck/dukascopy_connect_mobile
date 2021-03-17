package com.dukascopy.connect.vo {
	
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.vo.users.adds.MemberVO;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class CompanyVO {
		
		public var securityKey:String;
		public var uid:String;
		public var short:String;
		public var title:String;
		public var role:String;
		public var departments:Array;
		public var entryPoints:Array;
		public var members:Array;
		public var me:MemberVO;

		public function CompanyVO(data:Object) {
			departments = [];
			entryPoints = [];
			members = [];
			
			uid = data.uid;
			role = data.role;
			title = data.title;
			short = data.short;
			securityKey = data.securityKey;
			
			var i:int;
			var l:int;
			var a:Array = null;
			if ('m' in data && data.m != null) {
				a = data.m;
				l = a.length;
				for (i = 0; i < l; i++) {
					if (a[i].uid == Auth.uid) {
						me = new MemberVO(a[i]);
						continue;
					}
					members.push(new MemberVO(a[i]));
				}
			}
			
			if ('dep' in data) {
				a = data.dep;
				l = a.length;
				for (i = 0; i < l; i++)
					departments.push(new DepartmentVO(a[i]));
			}
			
			if ('ep' in data) {
				a = data.ep;
				l = a.length;
				for (i = 0; i < l; i++)
					entryPoints.push(new EntryPointVO(a[i]));
			} else
				trace('NO ENTRY POINTS! IN COMPANY ' + data);
		}
		
		public function getEntryPoints():Array {
			var res:Array = [new EntryPointVO(null)];
			var l:int = entryPoints.length;
			for (var i:int = 0; i < l; i++) 
				if (entryPoints[i].visibility == true)
					res.push(entryPoints[i]);
			return res;
		}
		
		public function getDepByID(id:int):DepartmentVO {
			var depVO:DepartmentVO;
			if(departments != null){
				var i:int = 0;
				var l:int = departments.length;
				for (i; i < l; i++){
					depVO = departments[i];
					if(depVO.id == id){
						break;
					}
				}
			}
			return depVO;
		}
	}
}