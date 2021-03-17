package com.dukascopy.connect.utils
{
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ArrayUtils
	{
		private static var langsPriority:Array;
		
		public function ArrayUtils()
		{
		
		}
		
		static public function sortArray(contacts:Array, field:String):Array
		{
			if (contacts)
			{
				var kirylicElements:Array = new Array();
				var latinElements:Array = new Array();
				var kirilycRegular:RegExp = new RegExp("^[А-Яёа-я].*");
				var match:Array;
				
				var l:int = contacts.length;
				for (var i:int = 0; i < l; i++)
				{
					if ((field in contacts[i]) && contacts[i][field])
					{
						match = (contacts[i][field] as String).match(kirilycRegular);
						if (match && match.length > 0)
						{
							kirylicElements.push(contacts[i]);
						}
						else
						{
							latinElements.push(contacts[i]);
						}
					}
				}
				kirylicElements = kirylicElements.sortOn([field], Array.CASEINSENSITIVE);
				latinElements = latinElements.sortOn([field], Array.CASEINSENSITIVE);
				return kirylicElements.concat(latinElements);
			}
			return null;
		}
		
		static public function sortLanguages(value:Array):Array
		{
			if (langsPriority == null)
			{
				langsPriority = new Array();
				langsPriority["en"] = 1;
				langsPriority["ru"] = 2;
				langsPriority["fr"] = 3;
				langsPriority["de"] = 4;
				langsPriority["hu"] = 5;
				langsPriority["pl"] = 6;
				langsPriority["cs"] = 7;
				langsPriority["sk"] = 8;
				langsPriority["zh"] = 9;
				langsPriority["ja"] = 10;
			}
			var result:Array = value.sort(orderLang);
			langsPriority = null;
			return result;
		}
		
		static public function getObjectHash(object:Object, ignoreFields:Array = null):String
		{
			var sortedData:Array = getSorted(object, ignoreFields);
			if (sortedData != null)
			{
				var by:ByteArray = new ByteArray();
				by.writeObject(sortedData);
				
				return MD5.hashBytes(by);
			}
			else
			{
				return null;
			}
		}
		
		static private function getSorted(object:Object, ignoreFields:Array = null):Array 
		{
			var i:int;
			var l:int;
			if (object != null)
			{
				var fields:Array = [];
				for (var key:Object in object)
				{
					if (ignoreFields != null)
					{
						var skipField:Boolean = false;
						i = 0;
						l = ignoreFields.length;
						for (i = 0; i < l; i++) 
						{
							if (ignoreFields[i] == key)
							{
								skipField = true;
								break;
							}
						}
					}
					if (skipField == false)
					{
						if (object[key] is String || object[key] is int || object[key] is Number || object[key] is Boolean)
						{
							fields.push({key: key, value: object[key]});
						}
						else
						{
							fields.push({key: key, value: getSorted(object[key], ignoreFields)});
						}
					}
				}
				fields.sortOn("key", Array.CASEINSENSITIVE);
				
				return fields;
			}
			else
			{
				return null;
			}
		}
		
		static private function orderLang(a:Object, b:Object):Number
		{
			if ("id" in a && "id" in b)
			{
				if (langsPriority[a.id] < langsPriority[b.id])
				{
					return -1;
				}
				else if (langsPriority[a.id] > langsPriority[b.id])
				{
					return 1;
				}
				else
				{
					return 0;
				}
			}
			return 0;
		}
	
	/*public static function makeSystem(xyTable:Vector.<Point>, basis:int):Vector.<Vector.<Number>>
	   {
	   var matrix:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
	   for (var i:int = 0; i < basis; i++)
	   {
	   for (var j:int = 0; j < basis; j++)
	   {
	   matrix[i][j] = 0;
	   }
	   }
	
	   var sumA:Number = 0;
	   var sumB:Number = 0;
	
	   for (i = 0; i < basis; i++){
	   for (var j:int = 0; j < basis; j++)
	   {
	   sumA = 0;
	   sumB = 0;
	
	   for (var k:int = 0; k < amount; k++)
	   {
	   sumA += Math.pow(xyTable[0][k], i) * Math.pow(xyTable[0][k], j);
	   sumB += xyTable[1][k] * Math.pow(xyTable[0][k], i);
	   }
	   matrix[i][j] = sumA;
	   matrix[i][basis] = sumB;
	   }
	   }
	   return matrix;
	   }
	
	   private function Gauss(rowCount:int, colCount:int):Vector.<Number>
	   {
	   var i:int;
	   var mask:Vector.<int> = new Vector.<int>;
	   for (i = 0; i < colCount - 1; i++)
	   mask[i] = i;
	   if (GaussDirectPass(rowCount, colCount))
	   {
	   var answer:Vector.<Number> = GaussReversePass(colCount, rowCount);
	   return answer;
	   }
	   else
	   {
	   return null;
	   }
	   }
	
	   private function GaussDirectPass(rowCount:int, colCount:int):Boolean
	   {
	   var i:int;
	   var j:int;
	   var k:int;
	   var maxId:int;
	   var tmpInt:int;
	   var maxVal:Number;
	   var tmpDouble:Number;
	
	   for (i = 0; i < rowCount; i++)
	   {
	   maxId = i;
	   maxVal = matrix[i][i];
	   for (j = i + 1; j < colCount - 1; j++)
	   {
	   if (Math.abs(maxVal) < Math.abs(matrix[i][j]))
	   {
	   maxVal = matrix[i][j];
	   maxId = j;
	   }
	   }
	
	   if (maxVal == 0) return false;
	   if (i != maxId)
	   {
	   for (j = 0; j < rowCount; j++)
	   {
	   tmpDouble = matrix[j][i];
	   matrix[j][i] = matrix[j][maxId];
	   matrix[j][maxId] = tmpDouble;
	   }
	   tmpInt = mask[i];
	   mask[i] = mask[maxId];
	   mask[maxId] = tmpInt;
	   }
	   for (j = 0; j < colCount; j++)
	   {
	   matrix[i][j] /= maxVal;
	   }
	   var tempMn:Number;
	   for (j = i + 1; j < rowCount; j++)
	   {
	   tempMn = matrix[j][i];
	   for (k = 0; k < colCount; k++)
	   {
	   matrix[j][k] -= matrix[i][k] * tempMn;
	   }
	   }
	   }
	   return true;
	   }
	
	   private function GaussReversePass(colCount:int, rowCount:int):Vector.<Number>
	   {
	   var i:int;
	   var j:int;
	   var k:int;
	   var tempMn:Number;
	   for (i = rowCount - 1; i >= 0; i--)
	   {
	   for (j = i - 1; j >= 0; j--)
	   {
	   tempMn = matrix[j][i];
	   for (k = 0; k < colCount; k++)
	   {
	   matrix[j][k] -= matrix[i][k] * tempMn;
	   }
	   }
	   }
	   var answer:Vector.<Number> = new Vector.<Number>();
	   for (i = 0; i < rowCount; i++)
	   {
	   answer[mask[i]] = matrix[i][colCount - 1];
	   }
	   return answer;
	   }*/
	}
}