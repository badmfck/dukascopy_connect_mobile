package com.forms.components
{
    import com.forms.FormComponent;
    import com.forms.Form;
    import flash.xml.XMLNode;
    import flash.display.Sprite;
    import com.forms.FormResourcesLoader;
    import flash.utils.ByteArray;
    import flash.xml.XMLDocument;
        

    public class FormGraph extends FormComponent{

        private var shapes:Vector.<FormGraphElement>=new Vector.<FormGraphElement>();
        private var graph:Sprite=new Sprite();
        private var gw:Number;
        private var gh:Number;
        private var _src:String;
        private var resouceLoader:FormResourcesLoader;
        private var onLoaded:Function;


        public function FormGraph(xml:XMLNode,form:Form){
            super(xml,form)
        }

        public function set src(val:String):void{
            if(_src==val)
                return;
            _src=val;
            loadResource();
        }

        public function get src():String{
            return _src;
        }

        

        override protected function createView(xml:XMLNode):void{

            if(xml.attributes.src){
                _src=xml.attributes.src;
                loadResource();
                return;
            }
            createGraphNodes(xml);

            // TODO: AS BITMAP
        }

        private function loadResource():void{
            var self:FormGraph=this;
            if(resouceLoader)
                resouceLoader.stopLoading();
            resouceLoader=new FormResourcesLoader(_src,form.formFile,function(res:ByteArray):void{
                // resource loaded
                res.position=0;
                var xml:XMLDocument=new XMLDocument(new XML(res.readUTFBytes(res.length)));
                createGraphNodes(xml.firstChild);
                resizeGraph();
                if(onLoaded!=null && onLoaded is Function){
                    if(onLoaded.length==0){
                        onLoaded();
                        return;
                    }else if(onLoaded.length==1){
                        onLoaded(self);
                        return;
                    }
                }
            })
        }


        private function createGraphNodes(xml:XMLNode):void{
            var childs:Array=xml.childNodes;
            box.addChild(graph)
            
            gw=0;
            gh=0;
            for each(var node:XMLNode in childs){
                if(node.nodeType!=1)
                    continue;
                //TODO: - check node name!
                var fge:FormGraphElement=new FormGraphElement(node);
                shapes.push(fge);
                fge.render();
                graph.addChild(fge.view);
                if(fge.view.height+fge.view.y>gh)
                    gh=fge.view.height+fge.view.y;
                if(fge.view.width+fge.view.x>gw)
                    gw=fge.view.width+fge.view.x;
                
            }
        }

        override protected function draw():void{
            if(needRedraw)
                resizeGraph();
            super.draw();
        }

        private function resizeGraph():void{
            var tw:int=bounds.display_width;
            var th:int=(gh*tw)/gw;
            if(th>bounds.display_height){
                th=bounds.display_height;
                tw=(gw*th)/gh;
            }
            graph.width=tw;
            graph.height=th;
            graph.x=(bounds.display_width-tw)*.5;
            graph.y=(bounds.display_height-th)*.5;
        }


        override public function destroy():void{
            super.destroy();
            if(shapes!=null){
                for each(var fge:FormGraphElement in shapes)
                    fge.destory();
            }
            shapes=null;
        }
        
    }
}