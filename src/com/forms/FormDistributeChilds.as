package com.forms
{
    public class FormDistributeChilds{
        static public const EVEN:String="even";
        private var val:String;
        public function FormDistributeChilds(val:String){
            if(val==null)
                val="";
            val=val.toLowerCase();
            if(val!="even")
                val=""
            this.val=val;
        }

        public function toString():String{
            return val;
        }
    }
}