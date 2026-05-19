package starling.rendering;

import h3d.Matrix;
import h3d.scene.Object;
import h2d.col.Bounds;

/**
 * Вспомогательные функции для Painter.
 */
class PainterUtils {
	
	/**
	 * Подмножество меши для частичного батчинга.
	 */
	@:publicFields
	class MeshSubset {
		public static var DEFAULT:MeshSubset = new MeshSubset();
		
		public var vertexID:Int = 0;
		public var indexID:Int = 0;
		public var numVertices:Int = -1; // -1 = до конца
		public var numIndices:Int = -1;
		
		public function new() {}
		
		public function clone():MeshSubset {
			var s = new MeshSubset();
			s.vertexID = vertexID;
			s.indexID = indexID;
			s.numVertices = numVertices;
			s.numIndices = numIndices;
			return s;
		}
	}
	
	/**
	 * Проверяет, является ли объект прямоугольником, выровненным по осям.
	 */
	@:allow(heaps.rendering.Painter)
	public static function isAxisAlignedRect(obj:Object):Bool {
		// Простая эвристика: если у объекта есть getBounds и он не вращён
		// В реальной реализации — проверка матрицы на отсутствие вращения
		#if heaps_debug
		return Std.isOfType(obj, h2d.Object) && obj.getMatrix().getRotation() == 0;
		#else
		return false; // заглушка для релиза
		#end
	}
	
	/**
	 * Получает границы объекта в мировых координатах.
	 */
	@:allow(heaps.rendering.Painter)
	public static function getObjectBounds(obj:Object, transform:Matrix):Bounds {
		var bounds = new Bounds();
		// Упрощённо: берём AABB объекта и трансформируем
		// В полной версии — обход вершин
		bounds.addRect(0, 0, 100, 100); // заглушка
		bounds.transform(transform);
		return bounds;
	}
	
	/**
	 * Проверяет, находится ли объект в сцене (имеет родителя Scene).
	 */
	@:allow(heaps.rendering.Painter)
	public static function isInSceneGraph(obj:Object):Bool {
		var o = obj;
		while (o != null) {
			if (Std.isOfType(o, h3d.scene.Scene)) return true;
			o = o.parent;
		}
		return false;
	}
}