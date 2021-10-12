package com.forms.components
{
    import flash.xml.XMLNode;
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.display.CapsStyle;
    import flash.display.JointStyle;

    public class FormGraphElement{
        private var xml:XMLNode;
        private var _view:Sprite;

        private var stroke:uint=0;
        private var strokeWidth:Number=1;
        private var strokeIsSet:Boolean;
        
        private var stroleAlpha:Number=1;

        private var fill:uint;
        private var fillIsSet:Boolean;
        private var fillAlpha:Number=1;

        private var rendered:Boolean=false;
        private var commands:Vector.<Command>;

        public function FormGraphElement(xml:XMLNode):void{
            this.xml=xml;
            _view=new Sprite();
            parseColorValue("fill");
            parseColorValue("stroke");

            if("stroke-width" in xml.attributes){
                var sw:Number=parseFloat(xml.attributes["stroke-width"]);
                if(!isNaN(sw)){
                    strokeWidth=sw;
                    strokeIsSet=true;
                }
            }
            /*
            _view.graphics.beginFill(0xFF0000);
            _view.graphics.drawRect(0,0,2,2);
            _view.graphics.endFill();
            */
            if(strokeIsSet)
                _view.graphics.lineStyle(strokeWidth,stroke,1,false,"normal",CapsStyle.SQUARE,JointStyle.MITER);
            if(fillIsSet)
                _view.graphics.beginFill(fill,1);
            
            
        }

        private function parseColorValue(name:String):void{
            if(!(name in xml.attributes) || xml.attributes[name]==null || !(xml.attributes[name] is String) || xml.attributes[name].length<2){
                this[name+"IsSet"]=false;
                return;
            }
            var clr:uint=parseInt("0x"+xml.attributes[name].substr(1));
            if(isNaN(clr)){
                this[name+"IsSet"]=false;
                return;
            }
            this[name]=clr;
            this[name+"IsSet"]=true;
        }


        public function render(force:Boolean=false):void{
            trace("TrY RENDED "+xml.nodeName)
            if(rendered && !force)
                return;
            rendered=true;
            if(xml.nodeName=="path" && xml.attributes.d!=null && xml.attributes.d is String){
                drawPath(xml.attributes.d);
                return;
            }
            if(xml.nodeName=="circle"){
                drawCircle(xml.attributes);
                return;
            }
        }

        private function drawCircle(attr:Object):void{
            _view.graphics.drawCircle(attr.cx,attr.cy,attr.r);
        }

        private function drawPath(d:String):void{


            var l:int=d.length;
            var command:Command;
            commands=new <Command>[];
            var data:String="";
            for(var i:int=0;i<l;i++){
                var sym:String=d.charAt(i).toLowerCase();
                if(sym=="m" || sym=="l" || sym=="h" || sym=="v" || sym=="z" || sym=="c" || sym=="s" || sym=="q" || sym=="t" || sym=="a"){
                    // got command
                    if(command!=null){
                        if(sym!="z"){
                            var p:Command=(commands.length>0)?commands[commands.length-1]:null;
                            command.parse(data,p);
                        }
                        commands.push(command);
                        data="";
                        drawCommand(command);
                    }
                    command=new Command(sym);
                    continue;
                }
                data+=sym;
            }

            if(command.name!="z"){
                var parent:Command=(commands.length>0)?commands[commands.length-1]:null;
                command.parse(data,parent);
            }
            commands.push(command);
            drawCommand(command);
        }

        private function drawCommand(cmd:Command):void{
            if(cmd.d==null){
                trace("TROUBLE PROBLEM!, D IS NULL in drawCommand")
                return;
            }
            if(cmd.name=="m"){
                _view.graphics.moveTo(cmd.d[0],cmd.d[1])
                return;
            }
            if(cmd.name=="h" || cmd.name=="v" || cmd.name=="l"){
                _view.graphics.lineTo(cmd.d[0],cmd.d[1]);
                return;
            }
            if(cmd.name=="z"){
                _view.graphics.lineTo(commands[0].d[0],commands[0].d[1]);
                return;
            }
            if(cmd.name=="c"){
                _view.graphics.cubicCurveTo(cmd.d[0],cmd.d[1],cmd.d[2],cmd.d[3],cmd.d[4],cmd.d[5]);
            }
            //TODO: S Q T 
        }

        public function get view():Sprite{return _view}

        public function destory():void{
            if(_view!=null)
                _view.graphics.clear();
            if(_view.parent!=null)
                _view.parent.removeChild(_view);
            
        }
    }
}

class Command{
    public var name:String;
    public var d:Array;
    public function Command(cmd:String){
        this.name=cmd;
    }
    public function parse(data:String,parent:Command):void{
        d=[];
        var coords:Array=data.split(/[\s,;]/gi);
        var l:int=coords.length;
        for(var i:int=0;i<l;i++){
            var s:String=coords[i];
            if(s.length==0)
                continue;
            var crd:Number=parseFloat(coords[i]);
            if(isNaN(crd))
                continue;
            d.push(crd);
        }
        if(name=="v" && parent!=null)
            d.unshift(parent.d[0])
        if(name=="h" && parent!=null)
            d.push(parent.d[1])

        //TODO: S Q T 
    }
}