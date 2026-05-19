package starling.rendering;


/**
 * Описывает позицию в кэше рендеринга.
 */
class BatchToken {
	
	public var batchID:Int = 0;
	public var vertexID:Int = 0;
	public var indexID:Int = 0;
	public var drawCalls:Int = 0;
	
	public function new() {}
	
	public function reset():Void {
		batchID = vertexID = indexID = drawCalls = 0;
	}
	
	public function setTo(batchId:Int, vertexId:Int = 0, indexId:Int = 0):Void {
		batchID = batchId;
		vertexID = vertexId;
		indexID = indexId;
	}
	
	public function clone():BatchToken {
		var t = new BatchToken();
		t.batchID = batchID;
		t.vertexID = vertexID;
		t.indexID = indexID;
		t.drawCalls = drawCalls;
		return t;
	}
}