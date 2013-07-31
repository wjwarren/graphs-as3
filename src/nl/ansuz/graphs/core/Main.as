package nl.ansuz.graphs.core {
	import flash.geom.Point;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.display.SimpleButton;
	import flash.display.DisplayObject;
	import nl.ansuz.graphs.ForceBasedGraph;
	import flash.events.Event;
	import nl.ansuz.graphs.bo.NodeBO;
	import flash.display.Sprite;

	/**
	 * @author Wijnand Warren
	 */
	public class Main extends Sprite {
		
		private var nodeList:Vector.<NodeBO>;
		private var nodeHolder:Sprite;
		private var edgeHolder:Sprite;
		
		private var stepButton:SimpleButton;
		
		private var graphEngine:ForceBasedGraph;
		
		/**
		 * CONSTRUCTOR
		 */
		public function Main() {
			init();
		}

		/**
		 * 
		 */
		private function init():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			createFakeNodes(20, 300, 200);
			createFakeConnections(15, 26);
			createEngine();
			
			createEdgeHolder();
			createNodeGraphics();
			createButtons();
			
			addAllEventListeners();
			
			updateGraph();
			startDrawing();
		}

		private function addAllEventListeners():void {
			stepButton.addEventListener(MouseEvent.CLICK, stepClickHandler);
			
			nodeHolder.addEventListener(MouseEvent.MOUSE_DOWN, nodeDownHandler);
			nodeHolder.addEventListener(MouseEvent.MOUSE_UP, nodeUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, nodeUpHandler);
		}

		private function nodeDownHandler(event:MouseEvent):void {
			nodeHolder.startDrag();
		}

		private function nodeUpHandler(event:MouseEvent):void {
			nodeHolder.stopDrag();
			
			edgeHolder.x = nodeHolder.x;
			edgeHolder.y = nodeHolder.y;
		}

		/**
		 * 
		 */
		private function createButtons():void {
			var stepField:TextField = new TextField();
			stepField.autoSize = TextFieldAutoSize.LEFT;
			stepField.text = "Step";
			
			stepButton = new SimpleButton(stepField, stepField, stepField, stepField);
			stepButton.x = 10;
			stepButton.y = 10;
			
			addChild(stepButton);
		}

		/**
		 * Creates the engine that will calculate node positions.
		 */
		private function createEngine():void {
			graphEngine = new ForceBasedGraph(nodeList, 100, 0.06);
		}

		/**
		 * Generates some fake nodes.
		 */
		private function createFakeNodes(numberOfNodes:int, width:int, height:int):void {
			nodeList = new Vector.<NodeBO>();
			
			var node:NodeBO;
			for(var i:int = 0; i <  numberOfNodes; i++) {
				node = new NodeBO();
				node.position.x = Math.random() * width;
				node.position.y = Math.random() * height;
				nodeList.push(node);
			}
		}

		/**
		 * Generate some fake connection between nodes.
		 */
		private function createFakeConnections(min:int, max:int):void {
			trace("Main.createFakeConnections(min, max)", min, max);
			var totalConnections:int = int( Math.random()*(max - min) ) + min;
			var totalNodes:int = nodeList.length;
			trace(" - totalConnections:", totalConnections);
			
			var aIndex:int;
			var bIndex:int;
			var a:NodeBO;
			var b:NodeBO;
			
			for(var i:int = 1; i < totalNodes; i++) {
				a = nodeList[i - 1];
				b = nodeList[i];
				
				a.connections.push(b);
				b.connections.push(a);
			}
			
			totalConnections -= (totalNodes - 1);
			
			while(totalConnections > 0) {
				trace(" - Trying to add connection");
				aIndex = int(Math.random()*totalNodes);
				bIndex = int(Math.random()*totalNodes);
				
				a = nodeList[aIndex];
				b = nodeList[bIndex];
				
				if(aIndex == bIndex || a.connections.indexOf(b) >= 0) {
					trace(" - Found duplicate!");
					continue;
				}
				
				a.connections.push(b);
				b.connections.push(a);
				
				totalConnections--;
			}
		}
		
		/**
		 * 
		 */
		private function createEdgeHolder():void {
			edgeHolder = new Sprite();
			edgeHolder.x = 25;
			addChild(edgeHolder);
		}
		
		/**
		 * Get some graphical representations of nodes running.
		 */
		private function createNodeGraphics():void {
			nodeHolder = new Sprite();
			var totalNodes:int = nodeList.length;
			
			var node:Sprite;
			for(var i: int = 0; i < totalNodes; i++) {
				node = new Sprite();
				node.graphics.beginFill(0x990000);
				node.graphics.drawCircle(0, 0, 10);
				node.graphics.endFill();
				nodeHolder.addChild(node);
			}
			
			nodeHolder.x = 25;
			addChild(nodeHolder);
		}

		/**
		 * 
		 */
		private function startDrawing():void {
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}

		/**
		 * 
		 */
		private function updateGraph():void {
			// remove all edges.
			edgeHolder.graphics.clear();
			
			var totalNodes:int = nodeList.length;
			
			var node:NodeBO;
			var graphic:DisplayObject;
			for(var i: int = 0; i < totalNodes; i++) {
				node = nodeList[i];
				graphic = nodeHolder.getChildAt(i);
				
				graphic.x = node.position.x;
				graphic.y = node.position.y;
				
				drawEdges(node);
			}
		}

		/**
		 * 
		 */
		private function drawEdges(aNode:NodeBO):void {
			var bNode:NodeBO;
			
			edgeHolder.graphics.lineStyle(2, 0x666666);
			
			for(var i:int =0 ; i < aNode.connections.length; i++) {
				bNode = aNode.connections[i];
				
				edgeHolder.graphics.moveTo(aNode.position.x, aNode.position.y);
				edgeHolder.graphics.lineTo(bNode.position.x, bNode.position.y);
			}
		}

		/**
		 * 
		 */
		private function centerGraph():void {
			var node:NodeBO;
			var max:Point = new Point(0, 0);
			var min:Point = new Point(0, 0);
			
			for (var i:int = 0; i < nodeList.length; i++) {
				node = nodeList[i];
				// Max
				if(node.position.x > max.x) {
					max.x = node.position.x;
				}
				if(node.position.y > max.y) {
					max.y = node.position.y;
				}
				// Min
				if(node.position.x < min.x) {
					min.x = node.position.x;
				}
				if(node.position.y < min.y) {
					min.y = node.position.y;
				}
			}
			// offset graphs
			nodeHolder.x = edgeHolder.x = -min.x + 25;
			nodeHolder.y = edgeHolder.y = -min.y + 25;
		}
		
		// ------------------------
		// EVENT HANDLERS
		// ------------------------
		
		/**
		 * 
		 */
		private function enterFrameHandler(event:Event):void {
			if(graphEngine.isStable) {
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				centerGraph();
				trace("All done!");
			} else {
				graphEngine.step();
				updateGraph();
				centerGraph();
			}
		}
		
		/**
		 * 
		 */
		private function stepClickHandler(event:MouseEvent):void {
			enterFrameHandler(null);
		}
	}
}
