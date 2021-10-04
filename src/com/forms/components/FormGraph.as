package com.forms.components
{
    import com.forms.FormComponent;
    import com.forms.Form;
    import flash.xml.XMLNode;
    import flash.display.Sprite;

    public class FormGraph extends FormComponent{

        private var shapes:Vector.<FormGraphElement>=new Vector.<FormGraphElement>();
        private var graph:Sprite=new Sprite();
        
        public function FormGraph(xml:XMLNode,form:Form){
            super(xml,form)
        }

        override protected function createView(xml:XMLNode):void{
            var childs:Array=xml.childNodes;
            box.addChild(graph)
            for each(var node:XMLNode in childs){
                if(node.nodeType!=1)
                    continue;
                //TODO: - check node name!
                var fge:FormGraphElement=new FormGraphElement(node);
                shapes.push(fge);
                graph.addChild(fge.view);
                fge.render();
            }
            // TODO: AS BITMAP
        }

        override protected function draw():void{
            
            if(needRedraw){
                var tw:int=bounds.display_width;
                var th:int=(graph.height*tw)/graph.width;
                if(th>bounds.display_height){
                    th=bounds.display_height;
                    tw=(graph.width*th)/graph.height;  
                }
                graph.width=tw;
                graph.height=th;
            }

            super.draw();
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