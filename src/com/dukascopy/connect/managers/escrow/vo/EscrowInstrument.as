package com.dukascopy.connect.managers.escrow.vo{
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.langs.Lang;

    public class EscrowInstrument{

        private var _name:String;
        private var _wallet:String;
        private var _price:Vector.<EscrowPrice>=new Vector.<EscrowPrice>(); //ASK
        private var _code:String;
        private var precision:int=2;
        
        public function EscrowInstrument(name:String,wallet:String,precision:*,code:String,price:Object){
            _name = name;
            _wallet = wallet;
            _code = code;
			if (_code == "DUK+")
			{
				_code = TypeCurrency.DCO;
			}
			
			updateNameFromLocatool();
			
            if(precision is String){
                var p:int =-1;
                try{
                    p=parseInt(precision)
                }catch(e:Error){}
                if(p!=-1)
                    this.precision = p;
            }else if(!isNaN(precision))
                this.precision = precision;
            updatePrice(price)
        }
		
		private function updateNameFromLocatool():void 
		{
			if (Lang.cryptoTitles != null && code in Lang.cryptoTitles == true)
				_name = Lang.cryptoTitles[code];
		}
		
        public function get name():String{
            return _name;
        };
		
        public function get wallet():String{
            return _wallet;
        }
		
		public function set wallet(value:String):void 
		{
			_wallet = value;
		}
		
        public function get code():String{
            return _code;
        }
		
        public function get price():Vector.<EscrowPrice>{
            return _price;
        }
		
        public function get isLinked():Boolean{
            return _wallet!=null;
        }
		
        public function updatePrice(val:Object):void{
			if (val != null)
			{
				if (val is EscrowPrice)
				{
					_price = new Vector.<EscrowPrice>();
					_price.push(val as EscrowPrice);
				}
				else
				{
					var newPrice:Vector.<EscrowPrice>=new Vector.<EscrowPrice>();
					
					for(var i:String in val){
						var v:*= val[i];
						var p:Number =-1;
						if(v is String){
							try{
								p = parseFloat(v);
							}catch(e:Error){}
						}else if(!isNaN(v))
							p = v;
						
						if(isNaN(p) || p==-1)
							continue;
						
						p=parseFloat(p.toFixed(precision));
						
						if(newPrice==null)
							newPrice = new Vector.<EscrowPrice>();
						newPrice.push(new EscrowPrice(i, p));
					}
					
					_price = newPrice;
				}
			}
        }
		
        public function toString():String{
            var p:String = "";
            for each(var i:EscrowPrice in _price){
                if(p.length>0)
                    p += "\n\t\t";
                p+=i;
            }
            return "\n" + name+" (" + code+") at\n\t\t" + p + "\n\tprecision: " + precision + ",\n\twallet: " + ((wallet != null)?wallet:"No linked wallet");
        }
    }
}