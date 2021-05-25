package com.forms{

    import flash.display.Sprite;
    import flash.xml.XMLNode;
    import flash.display.DisplayObjectContainer;
    import flash.display.DisplayObject;
    import flash.xml.XMLDocument;
    import flash.filesystem.File;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;
    import com.dukascopy.connect.sys.Dispatcher;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    import flash.system.Capabilities;
    import flash.utils.Timer;
    import flash.events.TimerEvent;

    public class FormComponent{

        protected var bounds:FormBounds=new FormBounds(0,0);
        protected var style:FormStyle;
        protected var nodeName:String;
        protected var nodeType:int;
        private var _id:String=null;
        public function get id():String{return _id}
        protected var _view:DisplayObject;
        public function get view():DisplayObject{return _view;}
        private var _components:Vector.<FormComponent>=new Vector.<FormComponent>();
        private var form:Form;
        protected var parent:FormComponent=null;
        protected var destroyed:Boolean=false


        // listeners
        public var onDraw:Function=null; // calls each time when component renders, onDraw(view,bounds):Boolean, when returns false, default draw procedure will be stopped
        public var onDocumentLoaded:Function=null; // call when xml loaded & parsed
        private var _onTap:Function=null;
        public function set onTap(val:Function):void{ _onTap=val; }
        
        private var fdis:Dispatcher;
        private var filePath:String=null;

        public function FormComponent(xml:*,form:Form,predefinedStyle:Object=null){
            
            _view=new Sprite();
            this.form=form;
            if(xml is XML){
                onXMLReady(new XMLDocument(xml).firstChild,predefinedStyle);
                return;
            }

            if(xml is XMLNode){
                onXMLReady(xml,predefinedStyle)
                return;
            }
            if(xml is String){
                trace("GOT STRING! ") // check if URL, convert string to xmlDocument ?
                return;
            }
            if(xml is File){
                loadFile(xml as File,predefinedStyle);
                return;
            }

            if(xml==null){
                // NO XML
                if(onDocumentLoaded!=null && onDocumentLoaded is Function)
                    onDocumentLoaded();
            }
        }

        public function reload():void{
            if(destroyed || filePath==null || !(this is Form))
                return
            trace('Reload file: '+filePath);
            loadFile(new File(filePath),{});
        }

        private function loadFile(file:File,predefinedStyle:Object):void{
            
            if(!file.exists || file.isDirectory){
                setupError("File not exists: "+file.nativePath);
                return;
            }

            var fs:FileStream=new FileStream();
            fdis=new Dispatcher(fs);
            var self:FormComponent=this;
            fdis.add(Event.COMPLETE,function(e:Event):void{
                
                setupDebugger(file);

                filePath=file.nativePath;

                if(destroyed)
                    return;

                var content:String="";
                while(fs.bytesAvailable)
                    content=fs.readUTFBytes(fs.bytesAvailable);
                var xml:XML=null;
                try{
                    xml=new XML(content);
                }catch(e:Error){
                    setupError("Can't parse XML")
                    return;
                }
                if(xml!=null)
                    onXMLReady(new XMLDocument(xml).firstChild,predefinedStyle);
            })
            fdis.add(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void{
                setupError("Can't load file: "+file.nativePath+",\n"+e.text)
                fdis.clear();
            })
            fdis.add(SecurityErrorEvent.SECURITY_ERROR,function(e:SecurityErrorEvent):void{
                setupError("Can't load file: "+file.nativePath+",\n"+e.text)
                fdis.clear();
            })

            fs.openAsync(file,FileMode.READ);

        }

        private function setupDebugger(file:File):void{
            // DEBUG, RELOAD ON FILE CHANGE
            if(filePath!=null || !(this is Form) || !Capabilities.isDebugger || !(Capabilities.os.toLowerCase().indexOf("mac")!=-1 || Capabilities.os.toLowerCase().indexOf("win")!=-1))
                return;

            
            var timer:Timer=new Timer(2000);
            var ddis:Dispatcher=new Dispatcher(timer);
            var lastFileModDate:Number=file.modificationDate.getTime();
            ddis.add(TimerEvent.TIMER,function():void{
                if(!file.exists){
                    timer.stop();
                    ddis.clear()
                    return;
                }
                if(destroyed){
                    ddis.clear();
                    return;
                }
                if(file.modificationDate.getTime()!=lastFileModDate){
                    lastFileModDate=file.modificationDate.getTime();
                    reload();
                }
            })
            timer.start();
        }

        private function setupError(err:String):void{
            var errXML:XML=<body>{err}</body>
            onXMLReady(new XMLDocument(errXML).firstChild,{
                backgroundColor:"#FF0000"
            });
        }

        private function onXMLReady(xml:XMLNode,predefinedStyle:Object):void{
            nodeName=xml.nodeName;
            nodeType=xml.nodeType;
            
            if(xml.attributes!=null && ("id" in xml.attributes)){
                _id=xml.attributes["id"];
                if(this.form!=null)
                    this.form.regID(_id,this);
            }
            style=new FormStyle(xml,predefinedStyle);
            createView(xml);
        }

        protected function createView(xml:XMLNode):void{
            
            if(_components.length>0){
                for each(var cc:FormComponent in _components)
                    cc.destroy();
                _components=new Vector.<FormComponent>();
            }


            // TEXT NODE
            if(xml.nodeType==3){
                var txtNode:FormText=createTextNode(xml.nodeValue)
                if(txtNode!=null)
                    _add(txtNode,-1,false);
                if(onDocumentLoaded!=null && onDocumentLoaded is Function)
                    onDocumentLoaded();
                return;
            }

            var childs:Array=xml.childNodes;
            for each(var node:XMLNode in childs){
                var c:FormComponent=null;
                if(node.nodeType==3){
                    c=createTextNode(node.nodeValue);
                    if(c==null)
                        continue;
                }else{
                    var nName:String=node.nodeName.toLowerCase()
                    var avaiableComponents:Vector.<FormRegisteredComponent>=form.avaiableComponentRenderes;
                    for each(var ac:FormRegisteredComponent in avaiableComponents){
                        if(ac.name==nName){
                            c=new ac._class(node,form);
                            break;
                        }
                    }
                    if(c==null)
                        c=new FormComponent(node,form);
                }
                _add(c,-1,false);
            }
            if(onDocumentLoaded!=null && onDocumentLoaded is Function)
                onDocumentLoaded();
        }

        private function createTextNode(txt:String):FormText{
            var txtCheck:String=txt.replace(/[\s\n\t\r]/gm,"");
             if(txtCheck.length==0)
                return null;
            return new FormText(txt);
        }

        public function addAll(components:Vector.<FormComponent>):void{
            for each(var c:FormComponent in components)
                _add(c,-1,false)
            rebuild();
        }

        public function add(component:FormComponent,index:int=-1):void{
            _add(component,index,true);
        }

        private function _add(component:FormComponent,index:int,doRebuild:Boolean):void{
            var found:Boolean=false;
            var l:int=_components.length;
            for(var i:int=0;i<l;i++){
                var c:FormComponent=_components[i];
                if(c==component){
                    found=true;
                    _components.removeAt(i);
                    break;
                }
            }
            component.removeFromStage();
            if(index>-1){
                _components.insertAt(index,component)
                (_view as DisplayObjectContainer).addChildAt(component.view,index);
            }else{
                _components.push(component);
                (_view as DisplayObjectContainer).addChild(component.view);
            }
            component.parent=this;
            if(doRebuild)
                rebuild();
        }

        private function rebuild():void{
            // root level;
            if(parent==null){
                redraw();
                return;
            }
            // find root
            var p:FormComponent=parent;
            while(p.parent!=null){
                p=p.parent;
            }
            p.redraw();
        }

        protected function getParentSize(side:String):int{
            /*var p:FormComponent=parent;
            var result:int=0;

            // MATCH PARENT
            while(p!=null){
                if(p.style[side]>-1)
                    return p.style[side];
                p=p.parent;
            }*/

            return parent.bounds["display_"+side];

            //return result;
        }

        protected function redraw(percentOffsetW:int=-1,percentOffsetH:int=-1):void{
            
            // SETUP SIZE
            bounds.display_width=style.width>0?style.width:-2;
            bounds.display_height=style.height>0?style.height:-2;
            
            if(id=="btnEscrowCreate")
                trace('123');
            // check parent style & setup dimm
            if(parent!=null){
                var parentH:int=getParentSize("height")
                var parentW:int=getParentSize("width")
                if(style.width==-1 && parent.style.layout.toString()==FormLayout.VERTICAL){
                    bounds.display_width=parentW;
                    if(style.height<0)
                        bounds.display_height=-1; // wrap content, set value after layout
                }else if(style.height==-1 && parent.style.layout.toString()==FormLayout.HORIZONTAL){
                    //bounds.display_height=parentH;
                    if(style.width<0)
                        bounds.display_width=-1; // wrap content, set value after layout
                }
                // percentage
                if(style.isHeightPercentage){
                    if(parentH>-1){
                        if(percentOffsetH==-1)
                            percentOffsetH=0;
                        bounds.display_height=Math.round((style.height/100)*(parentH-percentOffsetH));
                    }else{
                        trace("FC.WARN: parent height must be set, when using percentage value in child")
                        bounds.display_height=-1; // no parent height
                    }
                }
                if(style.isWidthPrecentage){
                    if(parentW>-1){
                        if(percentOffsetW==-1)
                            percentOffsetW=0;
                        bounds.display_width=Math.round((style.width/100)*(parentW-percentOffsetW));
                    }else{
                        trace("FC.WARN: parent width must be set, when using percentage value in child")
                        bounds.display_width=-1; // NO PARENT WIDTH
                    }
                }
            }

            if(style.layout.toString()==FormLayout.VERTICAL){
                if(bounds.display_width>0 && parent!=null && parent.style!=null)
                    bounds.display_width-=parent.style.padding.left+parent.style.padding.right
            }else{
                if(bounds.display_height>0 && parent!=null && parent.style!=null)
                    bounds.display_height-=parent.style.padding.top+parent.style.padding.bottom
            }
            
            
            var percentagesChidldren:Array=[];
            
            // setup layout
            var nextPos:int=style.layout.toString()==FormLayout.VERTICAL?style.padding.top:style.padding.left;
            var maxSize:int=0;
            var lastSize:int=0;
            for each(var c:FormComponent in _components){

                var obj:Object=null;
                if(c.style!=null && c.style.isHeightPercentage){
                    if(obj==null)
                        obj={}
                    obj.child=c;
                    obj.height=true;
                }
                
                if(c.style!=null && c.style.isWidthPrecentage){
                    if(obj==null)
                        obj={}
                    obj.child=c;
                    obj.width=true;
                }

                if(obj!=null){
                    percentagesChidldren.push(obj)
                    continue;
                }


                c.redraw(); // build child
                c.view[style.layout.axis]=nextPos; // setup position
                c.view[style.layout.oppositeAxis]=style.layout.toString()==FormLayout.VERTICAL?style.padding.left:style.padding.top;
                setupAlign(c);
                nextPos+=c.bounds[style.layout.side]; // inc position
                if(c.bounds[style.layout.oppositeSide]>maxSize)
                    maxSize=c.bounds[style.layout.oppositeSide]
            }
            nextPos+=style.layout.toString()==FormLayout.VERTICAL?style.padding.bottom:style.padding.right;
            bounds[style.layout.side]=nextPos;

            if(percentagesChidldren.length==0){
                if(bounds[style.layout.side]<bounds['display_'+style.layout.side])
                    bounds[style.layout.side]=bounds["display_"+style.layout.side]
            }

            if(maxSize==0 && bounds["display_"+style.layout.oppositeSide]>0)
                maxSize=bounds["display_"+style.layout.oppositeSide];

            bounds[style.layout.oppositeSide]=maxSize;

            // setup wrap content for display size
            if(bounds['display_'+style.layout.oppositeSide]<0)
                bounds['display_'+style.layout.oppositeSide]=maxSize;
            else
                bounds[style.layout.oppositeSide]=bounds['display_'+style.layout.oppositeSide];
            if(bounds['display_'+style.layout.side]<0)
                bounds['display_'+style.layout.side]=bounds[style.layout.side];
            /*else
                bounds[style.layout.side]=bounds['display_'+style.layout.side];
            */
            // move bounds to display size, if display size > 0
            
            if(percentagesChidldren.length>0){
                nextPos=style.layout.toString()==FormLayout.VERTICAL?style.padding.top:style.padding.left;;
                for each(c in _components){
                    for each(var pC:Object in percentagesChidldren){
                        if(pC.child==c){
                            var poffsetW:int=pC.width==true && bounds.display_width!=bounds.width?bounds.width:-1;
                            var poffsetH:int=pC.height==true && bounds.display_height!=bounds.height?bounds.height:-1;
                            c.redraw(poffsetW,poffsetH);
                            break;
                        }
                    }
                    
                    c.view[style.layout.axis]=nextPos; // setup position
                    c.view[style.layout.oppositeAxis]=style.layout.toString()==FormLayout.VERTICAL?style.padding.left:style.padding.top;
                    setupAlign(c);
                    nextPos+=c.bounds[style.layout.side]; // inc position
                    if(c.bounds[style.layout.oppositeSide]>maxSize)
                        maxSize=c.bounds[style.layout.oppositeSide]
                }
                nextPos+=style.layout.toString()==FormLayout.VERTICAL?style.padding.bottom:style.padding.right;
                bounds[style.layout.side]=nextPos;
                if(bounds[style.layout.side]<bounds['display_'+style.layout.side])
                    bounds[style.layout.side]=bounds["display_"+style.layout.side]

                bounds[style.layout.oppositeSide]=maxSize;

                // setup wrap content for display size
                if(bounds['display_'+style.layout.oppositeSide]<0)
                    bounds['display_'+style.layout.oppositeSide]=maxSize;

                if(bounds['display_'+style.layout.side]<0)
                    bounds['display_'+style.layout.side]=bounds[style.layout.side];
            }

            // SETUP ALIGN
            draw();
        }

        /**
         * Setup align & padding
         */
        protected function setupAlign(c:FormComponent):void{
            if(style.align.value==FormAlign.CENTER_CENTER){
                if(style.layout.toString()==FormLayout.VERTICAL){
                    //vertical align:
                    var y:int=Math.round((c.bounds.display_height-bounds.display_height)*.5)
                    //c.view.y=y;
                    var x:int=Math.round((bounds.display_width-c.bounds.display_width)*.5)
                    c.view.x=x;
                }
            }            
        }

        protected function draw():void{
            
            if(onDraw!=null && onDraw is Function && onDraw.length==2)
                onDraw(_view,bounds);

            // draw env
            if(_view is Sprite){
                var spr:Sprite=_view as Sprite;
                spr.graphics.beginFill(style.background.color,style.background.alpha);
                spr.graphics.drawRect(0,0,bounds.display_width,bounds.display_height);
            }
        }


        protected function removeFromStage():void{
            parent=null;
            if(_view!=null && _view.parent!=null)
                _view.parent.removeChild(_view);
        }

        public function destroy():void{
            destroyed=true;
            for each(var c:FormComponent in _components)
                c.destroy();
            removeFromStage();
            if(form!=null && id!=null)
                form.unregID(id);
            if(_onTap!=null)
                onTap=null
            parent=null;
            style=null;
            bounds=null;
            onDraw=null;
        }
    }
}