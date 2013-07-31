package nl.ansuz.graphs.bo {
	import flash.geom.Point;
	
	/**
	 * Representation of a node in our graph.
	 * 
	 * @author Wijnand Warren
	 */
	public class NodeBO {
		
		/**
		 * The mass of this node.
		 */
		public var mass:Number;
		
		/**
		 * The speed (or velocity) of this node.
		 */
		public var velocity:Point;
		
		/**
		 * The position of this vertex (in 2D space).
		 */
		public var position:Point;
		
		/**
		 * The total amount of force on this node 
		 */
		public var netForce:Point;
		
		/**
		 * The connections this node has to other nodes.
		 */
		public var connections:Vector.<NodeBO>;
		
		/**
		 * CONSTRUCTOR
		 */
		public function NodeBO() {
			init();
		}
		
		/**
		 * Initializes this class.
		 */
		private function init():void {
			velocity = new Point(0, 0);
			position = new Point(0, 0);
			netForce = new Point(0, 0);
			connections = new Vector.<NodeBO>();
			mass = 1;
		}
		
	}
}
