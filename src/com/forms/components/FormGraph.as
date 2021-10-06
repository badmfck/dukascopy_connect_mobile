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

        public function FormGraph(xml:XMLNode,form:Form){
            super(xml,form)
        }

        override protected function createView(xml:XMLNode):void{

            if(xml.attributes.src){
                new FormResourcesLoader(xml.attributes.src,form.formFile,function(res:ByteArray):void{
                    // resource loaded
                    trace("RESOURCE LOADED!");
                    res.position=0;
                    var xml:XMLDocument=new XMLDocument(new XML(res.readUTFBytes(res.length)));
                    createGraphNodes(xml.firstChild);
                    resizeGraph();
                })
                return;
            }

            createGraphNodes(xml);


            // TODO: AS BITMAP
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