package starling.rendering;

import h2d.BlendMode;
import h3d.Matrix;
import h3d.mat.Texture;
import hxd.col.Rectangle;

/**
 * Хранит настройки рендер-состояния для Painter.
 */
class PainterState {
	
	public var modelviewMatrix:Matrix;
	public var projectionMatrix:Matrix;
	public var alpha:Float;
	public var blendMode:h2d.BlendMode;
	public var renderTarget:Null<Texture>;
	public var renderTargetOptions:Int; // битовые флаги
	public var culling:String;          // "none" | "front" | "back"
	public var depthTest:String;        // "always" | "less" | etc.
	public var depthMask:Bool;
	public var clipRect:Null<Rectangle>;
	
	var engine:h3d.Engine;
	
	public function new(engine:h3d.Engine) {
		this.engine = engine;
		reset();
	}
	
	/**
	 * Сбрасывает состояние к дефолтным значениям.
	 */
	public function reset():Void {
		modelviewMatrix = new Matrix();
		modelviewMatrix.identity();
		projectionMatrix = new Matrix();
		projectionMatrix.identity();
		alpha = 1.0;
		blendMode = h2d.BlendMode.Alpha;
		renderTarget = null;
		renderTargetOptions = 0;
		culling = "none";
		depthTest = "always";
		depthMask = true;
		clipRect = null;
	}
	
	/**
	 * Создаёт глубокую копию состояния.
	 */
	public function clone():PainterState {
		var s = new PainterState(engine);
		s.modelviewMatrix = modelviewMatrix.clone();
		s.projectionMatrix = projectionMatrix.clone();
		s.alpha = alpha;
		s.blendMode = blendMode;
		s.renderTarget = renderTarget;
		s.renderTargetOptions = renderTargetOptions;
		s.culling = culling;
		s.depthTest = depthTest;
		s.depthMask = depthMask;
		s.clipRect = clipRect != null ? clipRect.clone() : null;
		return s;
	}
	
	/**
	 * Применяет матрицу трансформации к текущей modelview.
	 */
	public function transformModelviewMatrix(m:Matrix):Void {
		modelviewMatrix = modelviewMatrix.mult(m);
	}
}