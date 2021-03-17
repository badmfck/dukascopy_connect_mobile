package com.dukascopy.connect.gui.layout{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	/**
	 * ...
	 * @author Igor
	 */
	public class Layout {
		
		
		static public const UP_DOWN:String = "upDown";
		static public const LEFT_RIGHT:String = "leftDown";
		
		static public const ALIGN_LEFT_OR_TOP:int = 0;
		static public const ALIGN_CENTER:int = 1;
		static public const ALIGN_RIGHT_OR_BOTTOM:int = 2;
		
		private var _y:int = 0;
		private var _x:int = 0;
		private var _width:int = 0;
		private var _height:int = 0;
		private var container:DisplayObjectContainer;
		private var stock:Array = [];
		private var space:int;
		private var align:int;
		private var i:Object;
		private var type:String;
		
		
		/**
		 * 
		 * @param	container 
		 * @param	type - vertical or horizontal
		 * @param	space spaces between items
		 * @param	align 0 - left or top, 1 center, 2 right or bottom
		 */
		public function Layout(container:DisplayObjectContainer, type:String = Layout.UP_DOWN, space:int = 0, align:int = ALIGN_LEFT_OR_TOP) {
			this.type = type;
			this.align = align;
			this.space = space;
			this.container = container;
		}
		
		private function setPositions():void {
			// TOP DOWN LAYOUT
			var l:int = stock.length;
			var n:int = 0;
			var startY:int = _y;
			var startX:int = _x;
			var maxWidth:int = 0;
			var maxHeight:int = 0;
			
			_height = 0;
			_width = 0;
			
			// TOP DOWN
			if (type == Layout.UP_DOWN) {
				for (n; n < l; n++) {
					i = stock[n];
					i.y = startY;
					i.x = startX;
					startY += i.height + space;
					if (i.width > _width)
						_width = i.width;
				}
				_height = startY - space;
				
				if (align > 0) {
					for (n = 0; n < l; n++) {
						i = stock[n];
						if(align==1)
							i.x = Math.round(startX + ((_width - i.width) * .5));
						if(align==2)
							i.x = Math.round(startX + (_width - i.width));
					}
				}
			}
			
			// LEFT RIGHT
			if (type == Layout.LEFT_RIGHT) {
				for (n; n < l; n++) {
					i = stock[n];
					i.y = startY;
					i.x = startX;
					startX += i.width+space;
					if (i.height > _height)
						_height = i.height;
				}
				_width = startX - space;
				
				if (align > 0) {
					for (n = 0; n < l; n++) {
						i = stock[n];
						if(align==1)
							i.y = Math.round(startY + ((_height - i.height) * .5));
						if(align==2)
							i.y = Math.round(startY + (_height - i.height));
					}
				}
			}
		}
		
		/**
		 * Add object to layout algorythm
		 * @param	obj		Display Object
		 * @param	calculate	Boolean - if true - after adding position of all elements will be recalculated.
		 */
		public function add(obj:DisplayObject,calculate:Boolean=false):void{
			container.addChild(obj);
			stock.push(obj);
			if (calculate)
			{
				setPositions();
			}
		}
		
		public function remove(obj:DisplayObject,calculate:Boolean=false):void {
			if (obj.parent == container)
				obj.parent.removeChild(obj);
			if (stock.indexOf(obj) !=-1)
				stock.splice(stock.indexOf(obj), 1);
			if (calculate)
				setPositions();
		}
		
		public function getIsContain(obj:DisplayObject):Boolean {
			return stock.indexOf(obj) !=-1;
		}
		
		public function update():void {
			setPositions();
		}
		
		public function dispose():void{
			stock = [];
			stock = null;
		}
		
		public function get x():int { return _x; }
		public function get y():int { return _y; }
		
		public function set y(val:int):void {
			_y = val;
			setPositions();
		}
		
		public function set x(val:int):void {
			_x = val;
			setPositions();
		}
		
		public function get width():int{
			return _width;
		}
		
		public function get height():int{
			return _height;
		}
		
	}

}