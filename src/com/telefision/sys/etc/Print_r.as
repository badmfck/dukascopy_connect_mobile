package com.telefision.sys.etc {
	
	import flash.system.Capabilities;
	import flash.utils.describeType;
	
	public class Print_r {
		
		public function Print_r():void { }
		
		public static function show(arr:Object, save:Boolean = false, lvl:int = 0, endRes:String = null):String {
			if (Capabilities.isDebugger==false)	
				return '';
				
			if (!endRes)
				endRes = "";
				
			var str:String = ' ';
			
			if (lvl == 0) {
				if (save)
					endRes = '\nPRINT_R\n';
				trace('\nPRINT_R\n');
				
			}
			
			for (var m:int = 0; m < lvl; m++) str += '   ';
			for (var n:String in arr) {
				if (typeof(arr[n]) == 'object') {
					if (arr[n] == null) {
						if (save)
							endRes += "\n" + str + '' + n + ' = null';
						trace("\n" + str + '' + n + ' = null');
					} else {
						
						if (save)
							endRes += "\n" + str + '' + ' OBJECT: ' + n;
							
						trace("\n" + str + '' + ' OBJECT: ' + n);
						
						endRes = show(arr[n], save, (lvl + 1), endRes);
						
						if (save)
							endRes += "\n";
							
						trace("\n");
					}
				} else {
					if (save)
						endRes += str + '' + n + ' = ' + arr[n];
					trace(str + '' + n + ' = ' + arr[n]);
				}
			}
			if (lvl == 0) {
				if (save)
					endRes +='\n\n'
				trace('\n\n');
			}
			
			return endRes;
		}
		
		public static function pr(obj:*, level:int = 0, output:String = "", save:Boolean = false):* {
			var tabs:String = "";
			for (var i:int = 0; i < level; i++) {
				tabs += "\t";
			}
			
			for(var child:String in obj) {
				output += tabs +"[" + child +"] => " + obj[child];
				
				var childOutput:String = pr(obj[child], level + 1);
				if (childOutput != '') output += ' {\n' + childOutput + tabs +'}';
				
				output += "\n";
			}
			
			if (level == 0) {
				if (save) return output;
					else trace(output);
			}
			else return output;
		}
		

		public static function toString(obj:*):void {
			show(xxserialize(obj));
		}
		
		public static function xxserialize(obj:*):Object{
			var res:Object = {};
			var varList:XMLList = describeType(obj)..variable;
			for (var i:int; i < varList.length(); i++)
				res[varList[i].@name] = obj[varList[i].@name];
			return res;
		}
	}
}