package nl.ansuz.graphs {
	
	import flash.geom.Point;
	import nl.ansuz.graphs.bo.NodeBO;
	
	/**
	 * Aligns nodes in a graph using a Force Based algorithm.
	 * 
	 * @see http://en.wikipedia.org/wiki/Force-based_algorithms_%28graph_drawing%29
	 * @see http://blog.ivank.net/force-based-graph-drawing-in-as3.html
	 * 
	 * @author Wijnand Warren
	 */
	public class ForceBasedGraph {
		
		public static const SUGGESTED_COULOMB_CONSTANT:int = 200;
		public static const SUGGESTED_SPRING_CONSTANT:Number = 0.06;
		public static const SUGGESTED_DAMPING:Number = 0.65;
		
		private static const STABLE_THRESHOLD:int = 40;
		
		private var nodeList:Vector.<NodeBO>;
		private var coulombConstant:int;
		private var springConstant:Number;
		private var damping:Number;
		private var _isStable:Boolean;
		private var stepCount:int;
		
		/**
		 * CONSTRUCTOR
		 * 
		 * @param nodes The list of nodes to balance.
		 * @param coulombConstant Coulomb constant (Ke). A positive force implies it is repulsive, while a negative force implies it is attractive.
		 * 	(Basically determines the approximate distance between nodes.)
		 * @param springConstant Rate or spring constant (k). Used to pull connected nodes to each other.
		 * @param damping The amount of damping to apply, to reduce the overall system energy.
		 */
		public function ForceBasedGraph(nodes:Vector.<NodeBO>, coulombConstant:int = 200, springConstant:Number = 0.06, damping:Number = 0.65) {
			nodeList = nodes;
			this.coulombConstant = coulombConstant;
			this.springConstant = springConstant;
			this.damping = damping;
			init();
		}
		
		/**
		 * Initializes this class.
		 */
		private function init():void {
			_isStable = false;
			stepCount = 0;
		}
		
		// ------------------------
		// PUBLIC METHODS
		// ------------------------
		
		/**
		 * Calculates one iteration of the node positions.
		 */
		public function step():void {
			// No need to calculate more than necessary.
			if(_isStable) return;
			
			stepCount++;
			
			var totalKineticEnergy:Point = new Point(0, 0);
			var v:NodeBO;
			var u:NodeBO;
			
			var totalNodes:int = nodeList.length;
			var totalNodeConnections:int;
			
			var deltaX:Number;
			var deltaY:Number;
			var distanceSquared:Number;
			
			// Loop over all nodes.
			for(var i:int = 0; i < totalNodes; i++) {
				v = nodeList[i];
				v.netForce.x = 0;
				v.netForce.y = 0;
				
				// Calculate Coulumb repulsion by looping over all other nodes
				for(var j:int = 0; j < totalNodes; j++) {
					// skip self
					if(i == j) {
						continue;
					}
					
					u = nodeList[j];
					deltaX = v.position.x-u.position.x;
					deltaY = v.position.y-u.position.y;
					// Squared distance between u and v.
					distanceSquared = (deltaX * deltaX + deltaY * deltaY);
					// Calculate actual repulsion
					v.netForce.x += coulombConstant * deltaX / distanceSquared;
					v.netForce.y += coulombConstant * deltaY / distanceSquared;
				}
				
				// Calculate Spring Equation for all connections to this node.
				totalNodeConnections = v.connections.length;
				for(var k:int = 0; k < totalNodeConnections; k++) {
					u = v.connections[k];
					v.netForce.x += springConstant * (u.position.x - v.position.x);
					v.netForce.y += springConstant * (u.position.y - v.position.y);
				}
				
				// Calculate new velocity
				v.velocity.x = (v.velocity.x + v.netForce.x) * damping;
				v.velocity.y = (v.velocity.y + v.netForce.y) * damping;
				
				// Calculate new position
				v.position.x += v.velocity.x;
				v.position.y += v.velocity.y;
				
				// Calculate total kinetic energy
				totalKineticEnergy.x += v.mass * (v.velocity.x * v.velocity.x);
				totalKineticEnergy.y += v.mass * (v.velocity.y * v.velocity.y);
			}
			
			if(totalKineticEnergy.x <= STABLE_THRESHOLD && totalKineticEnergy.x <= STABLE_THRESHOLD) {
				_isStable = true;
				// TODO: Dispatch an event here?
			}
		}
		
		/**
		 * Whether or not the system is stable.
		 * If not, keep on calling step() :)
		 */
		public function get isStable():Boolean {
			return _isStable;
		}
	}
}
