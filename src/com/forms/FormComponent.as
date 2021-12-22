package com.forms{

    import flash.display.Sprite;
    import flash.xml.XMLNode;
    import flash.display.DisplayObjectContainer;
    import flash.display.DisplayObject;
    import flash.xml.XMLDocument;
    import flash.filesystem.File;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;
    import com.forms.Dispatcher;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.system.Capabilities;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.display.LineScaleMode;
    import flash.events.MouseEvent;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.StageQuality;
    import flash.filters.DropShadowFilter;
    import flash.display.Shape;
    import com.forms.components.FormListItem;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    import flash.system.System;
    

    public class FormComponent{

        protected var bounds:FormBounds=new FormBounds(0,0);
        protected var oldDisplayBW:int=-1;
        protected var oldDisplayBH:int=-1;
        protected var style:FormStyle;
        protected var _nodeName:String;
        public function get nodeName():String{return _nodeName;}
        protected var _nodeType:int;
        public function get nodeType():int{return _nodeType;}
        private var _id:String=null;
        private var _name:String=null;
        public function get id():String{return _id}
        public function get name():String{return _name}
        protected var _view:DisplayObject;
        protected var box:Sprite;
        protected var border:Shape;
        private var bitmapView:Bitmap;
        private var bitmapViewData:BitmapData;
        public function get view():DisplayObject{return bitmapView?bitmapView:_view;}
        protected var _components:Vector.<FormComponent>=new Vector.<FormComponent>();
        public function get children():Vector.<FormComponent>{return _components}
        protected var form:Form;
        protected var _parent:FormComponent=null;
        protected var destroyed:Boolean=false;
        private var mask:Sprite;
        private var scroller:FormScroller;
        protected var attributes:Object=null;
        protected var enableChilds:Boolean=true;
        private var distributeChildsCount:int=0;
        private var componentsNames:Object;
        protected var needRedraw:Boolean=true;
        private var controller:IFormController=null;
        private var localIDs:Object=null;
        private var documentLoaded:Boolean=false;
        private static var nextTempID:int=0;
        private var predefinedStyle:Object;
        private var originalXML:XMLNode;
        private var _formFile:File;
        public function get formFile():File{
            return _formFile;
        }

        // variables
        protected var userValues:Object=null;

        private var oldTextContent:String;

        // listeners
        private var drawn:Boolean=false;
        public var _onDraw:Function=null; // calls each time when component renders, onDraw(view,bounds):Boolean, when returns false, default draw procedure will be stopped
        public function set onDraw(val:Function):void{
            _onDraw=val;
            if(drawn && _onDraw!=null && _onDraw is Function)
                _onDraw(view,bounds);
        }
        
        private var _onDocumentLoaded:Function=null; // call when xml loaded & parsed
        public function set onDocumentLoaded(val:Function):void{
            _onDocumentLoaded=val;
            if(documentLoaded && this is Form)
                callDocumentLoaded();
        }

        public function getBounds():FormBounds{
                return bounds;
        }

        public function get isFirst():Boolean{
            var index:int=elementIndex;
            if(index==-1)
                return false;
            return index==0;
        }

        public function get isLast():Boolean{
            var index:int=elementIndex;
            if("__children" in attributes){
                return parseInt(attributes["__children"])==(index+1);
            }
            return false;
        }

        public function get elementIndex():int{
            if(attributes && "__index" in attributes){
                return parseInt(attributes["__index"]);
            }
            return -1;
        }

        public function update():void{  
            rebuild(true);
        }


        private var _onTap:Function=null;
        public function set onTap(val:Function):void{
            if(val==null)
                _view.removeEventListener(MouseEvent.CLICK,onMouseClick);
            if(val!=null && _onTap==null && val is Function)
                _view.addEventListener(MouseEvent.CLICK,onMouseClick);

            if(!(val is Function)){
                trace("Error! can't add non-function callback to tap")
                return;
            }
             _onTap=val;
        }
        
        private var fdis:Dispatcher;
        private var filePath:String=null;
        
        public function FormComponent(xml:*,form:Form,predefinedStyle:Object=null,additionalChilds:XML=null,dolly:Boolean=false){
            
            if(xml==null)
                trace('CREATE COMPONENT!',xml);

            _view=new Sprite();
            if(!(this is FormText)){
                box=new Sprite();
                border=new Shape();
                (_view as DisplayObjectContainer).addChild(box);
                (_view as DisplayObjectContainer).addChild(border);
            }
            

            this.predefinedStyle=predefinedStyle;
            
            
            this.form=form;
            if(xml!=null){
                if(xml is XML){
                    onXMLReady(new XMLDocument(xml).firstChild,predefinedStyle,additionalChilds,dolly);
                    return;
                }

                if(xml is XMLNode){
                    onXMLReady(xml,predefinedStyle,additionalChilds,dolly)
                    return;
                }
                if(xml is String){
                    trace("GOT STRING! ") // check if URL, convert string to xmlDocument ?
                    return;
                }
                if(xml is File){
                    loadFile(xml as File,predefinedStyle,additionalChilds);
                    return;
                }
            }

            if(xml==null && !(this is FormText)){
                // NO XML
                attributes={};
                style=new FormStyle(null,predefinedStyle,this);
                _nodeType=1;
                _nodeName="__generated"
                if(_onDocumentLoaded!=null && _onDocumentLoaded is Function && this is Form)
                    _onDocumentLoaded();
                if(this is Form)
                    documentLoaded=true;
            }
        }

        private function onMouseClick(e:MouseEvent):void{
            if(_onTap!=null && _onTap is Function){
                if(_onTap.length==0)
                    _onTap();
                if(_onTap.length==1)
                    _onTap(this)
                if(_onTap.length==2)
                    _onTap(this,e)
            }
        }

        public function reload():void{
            if(destroyed || filePath==null || !(this is Form))
                return
            trace('Reload file: '+filePath);
            loadFile(new File(filePath),{},null);
        }

        public function attachController(controller:IFormController):void{
            
            if(this.controller!=null && this.controller!=controller)
                this.controller.removeControllerLinkages();

            if(controller==null){
                this.controller=null;
                return;
            }

            this.controller=controller;
            linkComponentsToController(_components)
        }

        private function linkComponentsToController(comps:Vector.<FormComponent>):void{
            if(controller==null || comps==null || comps.length==0)
                return;
            for each(var c:FormComponent in comps){
                if(c.id!=null && c.id in this.controller){
                    try{
                        this.controller[c.id]=c;
                    }catch(e:Error){
                        trace("Can't add element to controller");
                    }
                }
                if(c!=null && c._components.length>0)
                    linkComponentsToController(c._components);
            }
        }

        private function loadFile(file:File,predefinedStyle:Object,additionalChilds:XML):void{
            
            if(!file.exists || file.isDirectory){
                setupError("File not exists: "+file.nativePath);
                return;
            }

            _formFile=file;

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
                    onXMLReady(new XMLDocument(xml).firstChild,predefinedStyle,additionalChilds);
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

        public function setStyle(val:Object):void{
            style.setStyle(val);
        }

        public function set textContent(val:String):void{

            if(val==oldTextContent)
                return;
            oldTextContent=val;

            var txtNode:FormText;
            if(val==null || val==""){
                clearAll();
                return;
            }

            var lines:Array=val.split("\n");

            // TEXT NODE
            if(_components.length == 1 && _components[0] is FormText && lines.length==1){
                txtNode=_components[0] as FormText;
                txtNode.textContent=val;
                rebuild();
                return;
            }

            clearAll(false);
            for(var i:int=0;i<lines.length;i++){
                var txt:FormText=createTextNode(lines[i]);
                _add(txt,-1,false);
            }
            rebuild();
        }

        public function get parent():FormComponent{
            return _parent;
        }


        private function setupDebugger(file:File):void{
            // DEBUG, RELOAD ON FILE CHANGE
            if(filePath!=null || !(this is Form) || !Capabilities.isDebugger || !(Capabilities.os.toLowerCase().indexOf("mac")!=-1 || Capabilities.os.toLowerCase().indexOf("win")!=-1))
                return;

            if(view && view.stage){
                view.stage.addEventListener(KeyboardEvent.KEY_DOWN,function(e:KeyboardEvent):void{
                    if(e.altKey || e.commandKey || e.ctrlKey){
                        if(e.keyCode==Keyboard.D){
                            Form.debug=!Form.debug
                            needRedraw=true;
                            rebuild();
                        }
                    }
                })
            }

             
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
            },null);
        }

        public function forceRedraw():void{
            rebuild();
        }

        public function setupUserValues(data:Object):void{
            userValues=data;
        }

        public function getUserValues():Object{
            return userValues;
        }

        public function setID(newID:String):void{
            if(form==null)
                return;

            if(newID==id)
                return;

            if(id!=null)
                form.unregID(id)

            form.regID(newID,this);
            if(box!=null)
                box.name="box_"+nodeName+"_"+newID;
            _id=newID;
        }

        private function onXMLReady(xml:XMLNode,predefinedStyle:Object,additionalChilds:XML,dolly:Boolean=false):void{
            if(xml==null){
                if(Capabilities.isDebugger)
                    throw new Error("Form Error, XML node is null");
                return;
            }

            _nodeName=xml.nodeName;
            _nodeType=xml.nodeType;


            if(xml.attributes!=null && ("id" in xml.attributes))
                _id=xml.attributes["id"];

           
            if(additionalChilds!=null){
                var inner:XMLDocument=new XMLDocument(additionalChilds);
                if(inner.firstChild && inner.firstChild.nodeType==1){
                    // adding attributes
                    if(inner.firstChild.attributes){
                        for (var attrName:String in inner.firstChild.attributes){
                            if(!(attrName in xml.attributes) && attrName!="id")
                                xml.attributes[attrName]=inner.firstChild.attributes[attrName];
                        }
                    }
                    
                    if(inner.firstChild.childNodes.length>0){
                        while(inner.firstChild.childNodes.length>0){
                            var fcld:XMLNode=inner.firstChild.firstChild;
                            if("id" in fcld.attributes){
                                if(_id==null)
                                    _id="__temp_"+(nextTempID++);
                                fcld.attributes["--parent-id"]=_id;
                                fcld.attributes["--local-child-id"]=true;
                            }

                            markEmbededChilds(fcld);
                            xml.appendChild(fcld);
                        }
                    }
                }
            }


            attributes=xml.attributes;
            
          
            if(_id){
                if(this.form!=null && attributes["--local-child-id"]!=true && !dolly){
                    this.form.regID(_id,this);
                    if(box!=null)
                        box.name="box_"+nodeName+"_"+_id;
                }
                else if(this.form!=null && attributes["--local-child-id"]==true){
                    var parent:FormComponent=form.getComponentByID(attributes['--parent-id']);
                    parent.regLocalID(attributes["id"],this);
                }
            }
            
            if(xml.attributes!=null && ("name" in xml.attributes)){
                _name=xml.attributes["name"];
            }

            // find data-attributes
            if(attributes!=null){
                var uv:Object;
                for(var s:String in attributes){
                    if(s.indexOf("data-")===0){
                        if(uv==null)
                            uv={}
                        uv[s]=attributes[s];
                    }
                }
                if(uv){
                    uv=FormStyle.normalizeAttributes(uv);
                    setupUserValues(uv);
                }
            }

            style=new FormStyle(xml,predefinedStyle,this);
            createView(xml);
        }

        protected function regLocalID(nme:String,cmp:FormComponent):void{
            if(localIDs==null)
                localIDs={}
            localIDs[nme]=cmp;
        }

        private function markEmbededChilds(fcld:XMLNode):void{
            if(fcld.nodeType==3)
                return;
            if(!fcld.hasChildNodes())
                return;
            var cn:Array=fcld.childNodes;
            for each(var ch:XMLNode in cn){
                if(ch.nodeType==3)
                    continue;

                if("id" in ch.attributes){
                   if(_id==null)
                        _id="__temp_"+(nextTempID++);
                    ch.attributes["--parent-id"]=_id;
                    ch.attributes["--local-child-id"]=true;
                }
                markEmbededChilds(ch);
            }
        }

        private function callDocumentLoaded():void{

            if(attributes["onclick"])
                attributes["onClick"]=attributes['onclick'];
            if(attributes["onClick"] && attributes["onClick"] is String && attributes["onClick"].length>0){
                if(view is Sprite){
                    (view as Sprite).buttonMode=true;
                    view.addEventListener(MouseEvent.CLICK,onElementClick);
                }
                
            }

            if(this is Form){
                documentLoaded=true;
                if(_onDocumentLoaded!=null && _onDocumentLoaded is Function)
                    _onDocumentLoaded();
            }
        }

        private function onElementClick(e:MouseEvent):void{
            if(form!=null)
                form.onElementClick(this,attributes["onClick"]);
        }

        protected function createView(xml:XMLNode):void{
            originalXML=xml;
            if(_components.length>0){
                for each(var cc:FormComponent in _components)
                    cc.destroy();
                _components=new Vector.<FormComponent>();
            }

            

            if(!enableChilds){
                callDocumentLoaded();
                return;
            }


            // TEXT NODE
            if(xml.nodeType==3){
                var txtNode:FormText=createTextNode(xml.nodeValue)
                if(txtNode!=null)
                    _add(txtNode,-1,false);
                callDocumentLoaded();
                return;
            }
            
            distributeChildsCount=0
            var childs:Array=xml.childNodes;


            var index:int=0;
            for each(var node:XMLNode in childs){
                var c:FormComponent=null;
                if(node.nodeType==3){
                    c=createTextNode(node.nodeValue);
                    if(c==null)
                        continue;
                }else{
                    node.attributes['__index']=index++;
                    node.attributes['__children']=childs.length;
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
                if(c.nodeName!="space")
                    distributeChildsCount++;
            }

            if(style.asBitmap)
                bitmapView=new Bitmap();

            callDocumentLoaded();
        }

        private function createTextNode(txt:String):FormText{
            var txtCheck:String=txt.replace(/[\s\n\t\r]/gm,"");
             if(txtCheck.length==0)
                return null;
            return new FormText(txt);
        }

        public function addAll(components:Vector.<FormComponent>,doRebuild:Boolean=true):void{
            for each(var c:FormComponent in components)
                _add(c,-1,false)
            if(doRebuild)
                rebuild();
        }

        protected function _removeAll(components:Vector.<FormComponent>,doRebuld:Boolean=true):void{
            for each(var c:FormComponent in components)
                _remove(c,false)
            if(doRebuld)
                rebuild();
        }

        public function removeAll(components:Vector.<FormComponent>):void{
            _removeAll(components);
        }

        public function remove(c:FormComponent):Boolean{
            return _remove(c,true);
        }

        protected function _remove(c:FormComponent,doRebuld:Boolean=true):Boolean{
            if(c==null)
                return false;
            var l:int=_components.length;
            var res:Boolean=false;
            for (var i:int=0;i<l;i++){
                if(_components[i]==c){
                    _components.removeAt(i);
                    res=true;
                    break;
                }
            }
            c.destroy();
            if(doRebuld)
                rebuild();
            return res;
        }
    
        public function clearAll(doRebuild:Boolean=true):void{
            for each(var c:FormComponent in _components){
                c.destroy();        
            }
            _components=new <FormComponent>[];
            if(doRebuild)
                rebuild();
        }

        public function add(component:FormComponent,index:int=-1):void{
            //TODO: store objects to add
            if(this is Form && !documentLoaded){
                trace("WARN: no form loaded yet");
                return;
            }else
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
                box.addChildAt(component.view,index);
            }else{
                _components.push(component);
                box.addChild(component.view);
            }
            
            component._parent=this;
            if(component.id!=null)
                attachControllerUpward(component);

            if(doRebuild)
                rebuild();
        }

        private function attachControllerUpward(component:FormComponent):void{
            if(this.controller && component.id!=null){
                try{
                   this.controller[id]=this;
                }catch(e:Error){
                    trace("Can't attach element to controller: "+id);
                    
                }
            }
        }

        protected function rebuild(force:Boolean=false):void{
            if(!needRedraw && force)
                needRedraw=true;

            // root level;
            if(parent==null){
                redraw();
                return;
            }

            // IF MASKED
            if(scroller!=null && mask!=null && mask.parent!=null){
                redraw()
                return;
            }

            // IF ABSOLUTE
            if(style && style.position && style.position=="absolute"){
                redraw();
                return;
            }

            // find root
            var p:FormComponent=parent;
            while(p.parent!=null){
                if(p.mask!=null && p.mask.parent!=null && p.scroller!=null)
                    break;
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

        protected function getParentPaddingOffset(side:String):int{
            var offset:int=0;
            if(parent.style){
                if(side=="width")
                    offset=parent.style.padding.left+parent.style.padding.right;
                else
                    offset=parent.style.padding.top+parent.style.padding.bottom;
            }
            return offset;
        }

        protected function calculateBounds(percentOffsetW:int,percentOffsetH:int):void{
            // SETUP SIZE
            if(bounds==null)
                return;
            bounds.display_width=style.width>0?style.width:-2;
            bounds.display_height=style.height>0?style.height:-2;
            
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
                        trace("FC.WARN: parent height must be set, when using percentage value in child, ",this);
                        bounds.display_height=-1; // no parent height
                    }
                }
                if(style.isWidthPrecentage){
                    if(parentW>-1){
                        if(percentOffsetW==-1)
                            percentOffsetW=0;
                        bounds.display_width=Math.round((style.width/100)*(parentW-percentOffsetW));
                    }else{
                        trace("FC.WARN: parent width must be set, when using percentage value in child.")
                        bounds.display_width=-1; // NO PARENT WIDTH
                    }
                }
            }
         
            if(parent!=null && parent.style!=null){
                if(parent.style.layout.toString()==FormLayout.HORIZONTAL){
                    bounds.display_height-=parent.style.padding.top+parent.style.padding.bottom
                    bounds.display_height-=parent.style.border.top+parent.style.border.bottom
                }

                if(parent.style.layout.toString()==FormLayout.VERTICAL){
                    bounds.display_width-=parent.style.padding.left+parent.style.padding.right
                    bounds.display_width-=parent.style.border.left+parent.style.border.right
                }
            }


            
            //bounds.display_height-=(style.padding.top+style.padding.bottom);

            /*if(parent!=null && parent.style!=null){
                if(style.layout.toString()==FormLayout.VERTICAL){
                    if(bounds.display_width>0)
                        bounds.display_width-=parent.style.padding.left+parent.style.padding.right
                }else{
                    if(bounds.display_height>0)
                        bounds.display_height-=parent.style.padding.top+parent.style.padding.bottom
                    if(bounds.display_width>0)
                        bounds.display_width-=parent.style.padding.right+parent.style.padding.left
                }
            }*/
        }

        protected function redraw(percentOffsetW:int=-1,percentOffsetH:int=-1,parentValues:Object=null):void{

            if(destroyed)
                return;


            if(id=="tst")                  
                 trace("123");

     
            var uv:Object=parentValues;
            if(userValues!=null)
                uv=userValues;


                     
            calculateBounds(percentOffsetW,percentOffsetH);
            

            var percentagesChidldren:Array=[];
            
            // setup layout
            var nextPos:int=style.layout.toString()==FormLayout.VERTICAL?style.padding.top:style.padding.left;

            // border
            nextPos+=style.layout.toString()==FormLayout.VERTICAL?style.border.top:style.border.left;

            var startPos:int=nextPos;

            var maxSize:int=0;
            var lastSize:int=0;
            var offset:Object;
            var oppositeOffset:int=0;
            var maxH:int=0;

            var c:FormComponent;
            var absCmp:Vector.<FormComponent>;
            for each(c in _components){

                if(c.destroyed)
                    continue;
                var obj:Object=null;

                if(c.style!=null && c.style.position!=null && c.style.position=="absolute"){
                    if(absCmp==null)
                            absCmp=new <FormComponent>[];
                        absCmp.push(c);
                }

                // distribute childs
                if(style.distributeChilds.toString()==FormDistributeChilds.EVEN){

                    if(style.layout.toString()==FormLayout.HORIZONTAL && c.nodeName!="space"){
                        c.style.isWidthPrecentage=true;
                        c.style.width=int(Math.round(100/distributeChildsCount));
                        if(obj==null)
                            obj={}
                        obj.child=c;
                        obj.width=true;
                        percentagesChidldren.push(obj)
                        continue;
                    }
                    
                    if(style.layout.toString()==FormLayout.VERTICAL && c.nodeName!="space"){
                        c.style.isHeightPercentage=true;
                        c.style.height=int(Math.round(100/distributeChildsCount));
                        if(obj==null)
                            obj={}
                        obj.child=c;
                        obj.height=true;
                        percentagesChidldren.push(obj)
                        continue;
                    }
                    
                }


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

                    if(style.layout.toString()==FormLayout.HORIZONTAL && obj.width){
                        continue;
                    } 
                    if(style.layout.toString()==FormLayout.VERTICAL && obj.height){
                        continue;
                    } 

                    //continue;
                }

                

                c.redraw(-1,-1,uv); // build child
                
                if(c.style==null || c.style.position==null || c.style.position!="absolute"){
                    c.view[style.layout.axis]=nextPos; // setup position

                    var oppositePos:int=style.layout.toString()==FormLayout.VERTICAL?style.padding.left:style.padding.top;
                    oppositePos+=style.layout.toString()==FormLayout.VERTICAL?style.border.left:style.border.top;
                    oppositePos+=oppositeOffset;

                    c.view[style.layout.oppositeAxis]=oppositePos;

                    if(style.layout.toString()==FormLayout.HORIZONTAL && attributes!=null && attributes.wrap=="true"){

                        if(c.bounds.display_height>maxH)
                            maxH=c.bounds.display_height;

                        if(c.view[style.layout.axis]+c.bounds.display_width>bounds.display_width){

                            nextPos=startPos;
                            oppositeOffset+=maxH;
                            maxH=0;

                            oppositePos=style.layout.toString()==FormLayout.VERTICAL?style.padding.left:style.padding.top;
                            oppositePos+=style.layout.toString()==FormLayout.VERTICAL?style.border.left:style.border.top;
                            oppositePos+=oppositeOffset;

                            c.view[style.layout.oppositeAxis]=oppositePos;
                            c.view[style.layout.axis]=nextPos; 
                        }

                    }

                    setupAlign(c);
                    nextPos+=c.bounds["display_"+style.layout.side]; // inc position
                    if(c.bounds[style.layout.oppositeSide]>maxSize)
                        maxSize=c.bounds[style.layout.oppositeSide]

                    // do offset
                    offset=setupOffset(c);
                    nextPos+=offset[style.layout.axis];

                }
                
            }

          

            nextPos+=style.layout.toString()==FormLayout.VERTICAL?style.padding.bottom:style.padding.right;
            nextPos+=style.layout.toString()==FormLayout.VERTICAL?style.border.bottom:style.border.right;
            bounds[style.layout.side]=nextPos;

            if(percentagesChidldren.length==0){
                if(bounds[style.layout.side]<bounds['display_'+style.layout.side])
                    bounds[style.layout.side]=bounds["display_"+style.layout.side]
            }

            if(maxSize==0 && bounds["display_"+style.layout.oppositeSide]>0)
                maxSize=bounds["display_"+style.layout.oppositeSide];

            bounds[style.layout.oppositeSide]=maxSize;

            // setup wrap content for display size
            if(percentagesChidldren.length==0){
                if(bounds['display_'+style.layout.oppositeSide]<0){
                    if(style.layout.toString()==FormLayout.VERTICAL){
                        maxSize+=style.padding.left+style.padding.right;
                        maxSize+=style.border.left+style.border.right;
                    }else{
                        maxSize+=style.padding.top+style.padding.bottom;
                        maxSize+=style.border.top+style.border.bottom;
                    }

                    bounds['display_'+style.layout.oppositeSide]=maxSize;
                    bounds[style.layout.oppositeSide]=maxSize;
                }else{
                    bounds[style.layout.oppositeSide]=bounds['display_'+style.layout.oppositeSide];
                }
                if(bounds['display_'+style.layout.side]<0){
                
                    bounds['display_'+style.layout.side]=bounds[style.layout.side];
                    
                }
            }
            
            // move bounds to display size, if display size > 0
            
            if(percentagesChidldren.length>0){
                oppositeOffset=0;
                maxH=0;

                nextPos=style.layout.toString()==FormLayout.VERTICAL?style.padding.top:style.padding.left;
                nextPos+=style.layout.toString()==FormLayout.VERTICAL?style.border.top:style.border.left;
                for each(c in _components){
                    if(c.destroyed)
                        continue;
                    for each(var pC:Object in percentagesChidldren){
                        if(pC.child==c){
                            var poffsetW:int=pC.width ==true && bounds.display_width !=bounds.width? bounds.width: -1;
                            var poffsetH:int=pC.height==true && bounds.display_height!=bounds.height?bounds.height:-1;
                            if(style.layout.toString()==FormLayout.HORIZONTAL)
                                poffsetH=-1;
                            else
                                poffsetW=-1;
                            c.redraw(poffsetW,poffsetH,uv);
                            break;
                        }
                    }
                    
                    if(c.style==null || c.style.position==null || c.style.position!="absolute"){
                        c.view[style.layout.axis]=nextPos; // setup position
                        
                        oppositePos=style.layout.toString()==FormLayout.VERTICAL?style.padding.left:style.padding.top;
                        oppositePos+=style.layout.toString()==FormLayout.VERTICAL?style.border.left:style.border.top;
                        c.view[style.layout.oppositeAxis]=oppositePos;


                        if(style.layout.toString()==FormLayout.HORIZONTAL && attributes!=null && attributes.wrap=="true"){

                            if(c.bounds.display_height>maxH)
                                maxH=c.bounds.display_height;

                            if(c.view[style.layout.axis]+c.bounds.display_width>bounds.display_width){

                                nextPos=startPos;
                                oppositeOffset+=maxH;
                                maxH=0;

                                oppositePos=style.layout.toString()==FormLayout.VERTICAL?style.padding.left:style.padding.top;
                                oppositePos+=style.layout.toString()==FormLayout.VERTICAL?style.border.left:style.border.top;
                                oppositePos+=oppositeOffset;

                                c.view[style.layout.oppositeAxis]=oppositePos;
                                c.view[style.layout.axis]=nextPos; 
                            }

                        }

                        setupAlign(c);
                        nextPos+=c.bounds["display_"+style.layout.side]; // inc position
                        if(c.bounds[style.layout.oppositeSide]>maxSize)
                            maxSize=c.bounds[style.layout.oppositeSide]

                        // do offset
                        offset=setupOffset(c);
                        nextPos+=offset[style.layout.axis];

                        
                    }
                }
            
                nextPos+=style.layout.toString()==FormLayout.VERTICAL?style.padding.bottom:style.padding.right;
                nextPos+=style.layout.toString()==FormLayout.VERTICAL?style.border.bottom:style.border.right;
                bounds[style.layout.side]=nextPos;
                if(bounds[style.layout.side]<bounds['display_'+style.layout.side])
                    bounds[style.layout.side]=bounds["display_"+style.layout.side]

                bounds[style.layout.oppositeSide]=maxSize;

                // setup wrap content for display size
                if(bounds['display_'+style.layout.oppositeSide]<0){
                    bounds['display_'+style.layout.oppositeSide]=maxSize;
                }

                if(bounds['display_'+style.layout.side]<0)
                    bounds['display_'+style.layout.side]=bounds[style.layout.side];
            }

            if (style!=null && style.layout.toString()==FormLayout.VERTICAL
                && bounds.height>bounds.display_height){
                setupScroll(style.layout.axis);
            }else{
                if(mask!=null){

                    // if border radius !=null
                    removeMaskIfNeeded();
                    
                    box.x=0;
                    box.y=0;
                }
                if(scroller!=null){
                    scroller.dispose()
                    for each(var cc:FormComponent in _components){
                        if(!cc.view.visible)
                            cc.view.visible=true;
                    }
                }
                scroller=null;
            }


            if(bounds.display_height!=oldDisplayBH || bounds.display_width!=oldDisplayBW)
                needRedraw=true;
            oldDisplayBW=bounds.display_width;
            oldDisplayBH=bounds.display_height;

            //setup absolute
            if(absCmp!=null){
                for each(c in absCmp)
                    c.view.parent.addChild(c.view);
            }

            draw();
        }

        protected function setupScroll(axis:String):void{
            if(style.overflow!="scroll" && style.overflow!="hidden")
                return;
            if(mask==null)
                createMask();

            if(style.overflow=="hidden"){
                if(scroller){
                    scroller.dispose()
                     for each(var c:FormComponent in _components){
                        if(!c.view.visible)
                            c.view.visible=true;
                    }
                }
                scroller=null
                box.x=0;
                box.y=0;
                return;
            }
            
            //SCROLL
            if(scroller==null){
                scroller=new FormScroller(view,box,mask,axis);
                scroller.onMoved=onComponentMoved;
            }
            scroller.setBounds(bounds);
            
        }

        protected function onComponentMoved():void{
            for each(var c:FormComponent in _components){
                var cy:int=box.y+c.view.y;
                if(cy+c.getBounds().display_height<0){
                    if(c.view.visible){
                        c.view.visible=false;
                        if(c is FormListItem)
                            (c as FormListItem).deactivated()
                        if(c.style.asBitmap)
                            c.clearBitmap()
                    }
                }else if(cy>mask.height){
                    if(c.view.visible){
                        c.view.visible=false;
                        if(c is FormListItem)
                            (c as FormListItem).deactivated()
                        if(c.style.asBitmap)
                            c.clearBitmap()
                    }
                }else
                    if(!c.view.visible){
                        c.view.visible=true;
                        if(c is FormListItem)
                            (c as FormListItem).activated()
                        if(c.style.asBitmap)
                            c.redrawBitmap();
                    }
            }
        }

        protected function setupOffset(c:FormComponent):Object{
            var res:Object={x:0,y:0}
            if(c.style==null)
                return res;

            res.x=c.style.xOffset;
            res.y=c.style.yOffset;
            if(c.style.xOffsetPercents)
                res.x=(c.style.xOffset/100)*c.bounds.display_width;
            
            if(c.style.yOffsetPercents)
               res.y=(c.style.yOffset/100)*c.bounds.display_height

            c.view.x+=res.x;
            c.view.y+=res.y;
            return res;
        }

        

        /**
         * Setup align & padding
         */
        protected function setupAlign(c:FormComponent):void{

            if(!style.align.isSet)
                return;
            
            var x:int=0;
            var y:int=0;
            
            if(style.align.value==FormAlign.CENTER){
                if(style.layout.toString()==FormLayout.VERTICAL){
                    //vertical align:
                    x=Math.round((bounds.display_width-c.bounds.display_width)*.5)
                    c.view.x=x;
                }
                if(style.layout.toString()==FormLayout.HORIZONTAL){
                     //vertical align:
                    y=Math.round((bounds.display_height-c.bounds.display_height)*.5)
                    c.view.y=y;
                }
            }            
        }

        protected function draw():void{
            
            if(_view.alpha!=style.opacity){
                _view.alpha=style.opacity;
                if(_view.alpha==0)
                    _view.visible=false;
                else _view.visible=true;
            }
            

            if(style.asBitmap && bitmapView.alpha!=style.opacity)
                bitmapView.alpha=style.opacity;

            drawn=true;
            if(_onDraw!=null && _onDraw is Function && _onDraw.length==2){
                if(!_onDraw(_view,bounds))
                    return;
            }

            

            // draw env
            if(_view is Sprite && needRedraw){
                var spr:Sprite=_view as Sprite;
                spr.graphics.clear();
                spr.graphics.beginFill(style.background.color,style.background.alpha);

                if(Form.debug){
                    spr.graphics.lineStyle(1,Math.round(Math.random()*0xFFFFFF),1,true,LineScaleMode.NONE)
                    //spr.graphics.beginFill(0x0,.1);
                }

                /*if(Form.debug && style.padding.isSet){
                    spr.graphics.drawRect(
                    style.padding.left,
                    style.padding.top,
                    bounds.display_width-style.padding.left-style.padding.right,
                    bounds.display_height-style.padding.top-style.padding.bottom);
                }*/

                spr.graphics.drawRoundRectComplex(
                    0,
                    0,
                    bounds.display_width,
                    bounds.display_height,
                    style.borderRadius.top,
                    style.borderRadius.right,
                    style.borderRadius.left,
                    style.borderRadius.bottom
                );
                
                

                spr.graphics.endFill();


                if(style.border.isSet && style.borderColor.isSet){
                    border.graphics.clear();
                    border.graphics.beginFill(style.borderColor.top);
                    var radius:Object=style.borderRadius;
                    var size:Object=style.border;
                    var s:Object={top:0,right:0,bottom:0,left:0};
                    drawBorder(s);
                    drawBorder(size,true);
                }

                if(style.borderRadius.isSet())
                    createMask();

                needRedraw=false;
            }

            // setup filters
            var boxShadowApplied:Boolean=false;
            if(style.boxShadow!=null){
                var filters:Array=view.filters;
                for each(var f:Object in filters){
                    if(f is DropShadowFilter){
                        // TODO: CHECK/COMPARE PARAMETERS
                        boxShadowApplied=true;
                        break;
                    }
                }
                if(!boxShadowApplied){
                    filters.push(style.boxShadow.value);
                    view.filters=filters;
                }
            }

            // draw as bitmap
            redrawBitmap()
        }

        private function createMask():void{
            if(mask==null){
                mask=new Sprite();
                view.mask=mask;
            }
            if(mask.parent==null)
                (view as DisplayObjectContainer).addChild(mask)

            mask.graphics.clear();
            mask.graphics.beginFill(0xFF0000);
            mask.graphics.drawRoundRectComplex(
                0,
                0,
                bounds.display_width,
                bounds.display_height,
                style.borderRadius.top,
                style.borderRadius.right,
                style.borderRadius.left,
                style.borderRadius.bottom
            );

        }

        private function removeMaskIfNeeded():void{
            if(style.borderRadius.isSet())
                return;
            mask.graphics.clear();
            if(mask.parent!=null)
                mask.parent.removeChild(mask)
            _view.mask=null;
            mask=null;
        }

        private function drawBorder(size:Object,second:Boolean=false):void{

            var radius:Object={}
            radius.top=style.borderRadius.top-size.top
            if(radius.top<0)
                radius.top=0;

            radius.right=style.borderRadius.right-size.right
            if(radius.right<0)
                radius.right=0;

            radius.bottom=style.borderRadius.bottom-size.bottom
            if(radius.bottom<0)
                radius.bottom=0;

            radius.left=style.borderRadius.left-size.left
            if(radius.left<0)
                radius.left=0;


            // TOP
            /*border.graphics.drawCircle(style.borderRadius.top,style.borderRadius.top,radius.top);

            // RIGHT
            border.graphics.drawCircle(bounds.display_width-style.borderRadius.right,style.borderRadius.right,radius.right);

            //BOTTOM
            border.graphics.drawCircle(bounds.display_width-style.borderRadius.bottom,bounds.display_height-style.borderRadius.bottom,radius.bottom);

            //LEFT
            border.graphics.drawCircle(style.borderRadius.left,bounds.display_height-style.borderRadius.left,radius.left);*/
            

            // DRAW FIRST LINE
                       

            var rx:int=bounds.display_width-radius.right-size.right;
            var ry:int=size.right;
            var drawCurve:Boolean=true;
           
            border.graphics.moveTo(rx,ry);

 
            border.graphics.cubicCurveTo(

                bounds.display_width-Math.round((radius.right)*.5)-size.right,
                size.right,

                bounds.display_width-size.right,
                Math.round((radius.right)*.5)+size.right,

                bounds.display_width-size.right,
                radius.right+size.right
            );
            
            

            border.graphics.lineTo(bounds.display_width-size.bottom,bounds.display_height-radius.bottom-size.bottom);

            border.graphics.cubicCurveTo(
                bounds.display_width-size.bottom,
                bounds.display_height-Math.round(radius.bottom*.5)-size.bottom,

                bounds.display_width-Math.round(radius.bottom*.5)-size.bottom,
                bounds.display_height-size.bottom,

                bounds.display_width-radius.bottom-size.bottom,
                bounds.display_height-size.bottom
            );

            border.graphics.lineTo(radius.left+size.left,bounds.display_height-size.left);
            
            border.graphics.cubicCurveTo(
                Math.round(radius.left*.5)+size.left,
                bounds.display_height-size.left,

                size.left,
                bounds.display_height-Math.round(radius.left*.5)-size.left,

                size.left,
                bounds.display_height-radius.left-size.left
            );


            
            // DRAW TOP
 
            var tx:int=size.top;
            var ty:int=radius.top+size.top;
            

            border.graphics.lineTo(tx,ty);

            

            border.graphics.cubicCurveTo(
                size.top,
                Math.round(radius.top*.5)+size.top,

                Math.round(radius.top*.5)+size.top,
                size.top, 

                radius.top+size.top,
                size.top 
            );
  

            rx=bounds.display_width-radius.right-size.right
            ry=size.right;
         
            border.graphics.lineTo(rx,ry);

            // sell create
            // price form rates + %
            // reserved price ID
            // send to socket price ID
          
        }

        protected function redrawBitmap():void{
            if(!style.asBitmap) 
                return;
            
            if(bitmapViewData==null || bitmapViewData.width!=bounds.display_width || bitmapViewData.height!=bounds.display_height){
                if(bitmapViewData)
                    bitmapViewData.dispose();
                bitmapViewData=new BitmapData(bounds.display_width,bounds.display_height,true,0);
                bitmapView.bitmapData=bitmapViewData;
                bitmapView.smoothing=true;
            }else{
                bitmapViewData.fillRect(bitmapViewData.rect,0);
            }

            bitmapViewData.drawWithQuality(_view,null,null,null,null,true,StageQuality.BEST);
            
        }
        protected function clearBitmap():void{
            if(style==null || bitmapViewData==null)
                return;
            if(style.asBitmap && bitmapViewData){
                bitmapViewData.dispose()
                bitmapViewData=null;
            }
        }

        public function getChildByLocalID(val:String):FormComponent{
            if(localIDs==null)
                return null;
            return localIDs[val];
        }

        public function getChildByName(val:String):FormComponent{
            
            if(componentsNames==null)
                componentsNames={}

            if(componentsNames[val]!=null)
                return componentsNames[val];
            
            for each(var fc:FormComponent in _components){
                if(fc.name==val){
                    componentsNames[val]=fc;
                    return fc;
                }
            }
            
            return null;
        }

        protected function getColor():FormColor{
            var p:FormComponent=this;
            if(nodeType!=1)
                p=parent;
            while(p!=null){
                if(p.style.color.isSet)
                    return p.style.color;
                p=p.parent;
            }
            return null;
        }

          protected function getFontOptions():FormFontOptions{
            var p:FormComponent=this;
            var opt:FormFontOptions=new FormFontOptions();
            var fontSize:FormTextSize;
            var textAlign:FormTextAlign;
            var fontFace:FormFontFace;
            var fontWeight:FormFontWeight;
            var textTransform:FormTextTransform;
            if(nodeType!=1)
                p=parent;
            while(p!=null){
                if(fontSize==null && p.style.fontSize.isSet){
                    fontSize= p.style.fontSize;
                    if(textAlign && fontSize && fontFace && fontWeight && textTransform)
                        break;
                }
                if(textAlign==null && p.style.textAlign.isSet){
                    textAlign=p.style.textAlign;
                    if(textAlign && fontSize && fontFace && fontWeight && textTransform)
                        break;
                }
                
                if(fontFace==null && p.style.fontFace.isSet){
                    fontFace=p.style.fontFace;
                    if(textAlign && fontSize && fontFace && fontWeight && textTransform)
                        break;
                }
                
                if(fontWeight==null && p.style.fontWeight.isSet){
                    fontWeight=p.style.fontWeight;
                    if(textAlign && fontSize && fontFace && fontWeight && textTransform)
                        break;
                }
                
                if(textTransform==null && p.style.textTransform.isSet){
                    textTransform=p.style.textTransform;
                    if(textAlign && fontSize && fontFace && fontWeight && textTransform)
                        break;
                }
                p=p.parent;
            }
            opt.fontSize=fontSize;
            opt.textAlign=textAlign;
            opt.fontFace=fontFace;
            opt.fontWeight=fontWeight;
            opt.textTransform=textTransform;
            return opt;
        }

        protected function removeFromStage():void{
            _parent=null;
            if(_view!=null && _view.parent!=null)
                _view.parent.removeChild(_view);
        }

        public function toString(lvl:int=1):String{
            var cnt:String="";
            if(this is FormText){
                cnt=(this as FormText).textContent;
                if(cnt.length>50)
                    cnt=cnt.substr(0,45)+"... (total "+cnt.length+")"
                cnt=" content: "+cnt+" ";
            }
            var s_name:String="node:"+nodeName+(cnt)+", nodeType:"+nodeType+((id)?", id: "+id:"")+((name)?", name: "+name:", onStage:"+(view.stage!=null)+", visible:"+view.visible);
            s_name+=", bounds:"+bounds.toString()+", x:"+view.x+", y:"+view.y+"\n";
            var tab:String="|";
            var tabChar:String="__"
            for(var i:int=0;i<lvl;i++)
                tab+=tabChar;
            if(_components!=null){
                if(_components.length>0){
                    s_name+=tab+" childs: "+_components.length+"\n";
                    
                    for each(var fc:FormComponent in _components)
                        s_name+=tab+tabChar+" "+fc.toString(++lvl)+"\n"
                }
            }

            return s_name;
        }

        public function clone():FormComponent{
            
            if(!originalXML){
                trace("WARN: component not ready yet to clone");
                return null;
            }

            if(form==null){
                // NO FORM!!
                trace("WARN: No-form!")
                return null;
            }

            var dolly:FormComponent=new FormComponent(originalXML,form,predefinedStyle,null,true);
            return dolly;
        }

        public function destroy():void{
            destroyed=true;
            if(view)
                view.removeEventListener(MouseEvent.CLICK,onElementClick);
            for each(var c:FormComponent in _components)
                c.destroy();
            removeFromStage();
            if(form!=null && id!=null)
                form.unregID(id);
            if(_onTap!=null)
                onTap=null
            _parent=null;
            userValues=null;
            style=null;
            bounds=null;
            onDraw=null;
            if(scroller!=null) 
                scroller.dispose();
            scroller=null;
            if(controller)
                controller.removeControllerLinkages();
            controller=null;
            userValues=null;
            if(componentsNames!=null){
                for(var i:String in componentsNames){
                    componentsNames[i]=null
                    delete componentsNames[i];
                }
                componentsNames=null;
            }
            clearBitmap();
            if(localIDs){
                for(var s:String in localIDs){
                    localIDs[s]=null;
                    delete localIDs[s];
                }
            }
            
            originalXML=null;
            
            localIDs=null;
            form=null;
            if(box!=null)
                box.name+="_destroyed"
        }
    }
}