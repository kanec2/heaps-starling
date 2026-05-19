package starling.rendering;

import h3d.scene.Object;
import h3d.Buffer;
import hxd.Stack;

/**
 * Управляет группировкой объектов для минимизации draw calls.
 */
class BatchProcessor {
	
	public typedef Batch = {
		var objects:Array<Object>;
		var materialKey:String;
		var vertexCount:Int;
		var indexCount:Int;
		function render(engine:h3d.Engine, state:PainterState):Void;
	}
	
	private var _batches:Array<Batch>;
	private var _currentBatch:Null<Batch>;
	private var _onComplete:Batch->Void;
	private var _cacheToken:BatchToken;
	
	var _pool:Stack<Batch>;
	
	public function new(onComplete:Batch->Void) {
		_onComplete = onComplete;
		_batches = [];
		_pool = new Stack();
		_cacheToken = new BatchToken();
	}
	
	public function dispose():Void {
		for (b in _batches) {
			// В Heaps не нужно явно диспозить, но можно очистить ссылки
			b.objects = null;
		}
		_batches = [];
		_pool.clear();
		_currentBatch = null;
	}
	
	/**
	 * Добавляет объект в текущий батч или создаёт новый.
	 */
	public function addMesh(mesh:Object, state:PainterState, ?subset:PainterUtils.MeshSubset):Void {
		var matKey = getMaterialKey(mesh, state);
		
		if (_currentBatch == null || _currentBatch.materialKey != matKey || !canAdd(_currentBatch, mesh)) {
			finishBatch();
			_currentBatch = createBatch(matKey);
			_batches.push(_currentBatch);
			_cacheToken.batchID = _batches.length - 1;
			_cacheToken.vertexID = 0;
			_cacheToken.indexID = 0;
		}
		
		_currentBatch.objects.push(mesh);
		_currentBatch.vertexCount += mesh.getVertexCount();
		_currentBatch.indexCount += mesh.getIndexCount();
		
		_cacheToken.vertexID += mesh.getVertexCount();
		_cacheToken.indexID += mesh.getIndexCount();
	}
	
	/**
	 * Завершает текущий батч и вызывает callback.
	 */
	public function finishBatch():Void {
		if (_currentBatch != null) {
			var batch = _currentBatch;
			_currentBatch = null;
			if (_onComplete != null) _onComplete(batch);
		}
	}
	
	/**
	 * Завершает кадр.
	 */
	public function finishFrame():Void {
		finishBatch();
	}
	
	/**
	 * Очищает все батчи и возвращает их в пул.
	 */
	public function clear():Void {
		for (b in _batches) {
			b.objects = [];
			_pool.push(b);
		}
		_batches = [];
		_currentBatch = null;
		_cacheToken.reset();
	}
	
	/**
	 * Освобождает неиспользуемые батчи из пула.
	 */
	public function trim():Void {
		// В простом варианте — просто очищаем пул
		_pool.clear();
	}
	
	/**
	 * Обновляет токен текущей позицией.
	 */
	public function fillToken(token:BatchToken):Void {
		token.batchID = _cacheToken.batchID;
		token.vertexID = _cacheToken.vertexID;
		token.indexID = _cacheToken.indexID;
		token.drawCalls = _batches.length;
	}
	
	/**
	 * Рендерит диапазон из кэша (для drawFromCache).
	 */
	public function drawFromCache(start:BatchToken, end:BatchToken, engine:h3d.Engine, state:PainterState):Void {
		var startBatch = start.batchID;
		var endBatch = end.batchID;
		
		for (i in startBatch...endBatch) {
			if (i < _batches.length) {
				_batches[i].render(engine, state);
			}
		}
	}
	
	// === Внутренние методы ===
	
	private function createBatch(matKey:String):Batch {
		var b:Batch = if (_pool.length > 0) _pool.pop() else { objects: [], materialKey: "", vertexCount: 0, indexCount: 0, render: null };
		b.materialKey = matKey;
		b.vertexCount = 0;
		b.indexCount = 0;
		b.objects = [];
		b.render = function(engine:h3d.Engine, state:PainterState) {
			// В реальной реализации здесь был бы эффективный рендер батча
			// Для простоты — рендерим каждый объект отдельно
			for (obj in b.objects) {
				obj.render(engine);
			}
		};
		return b;
	}
	
	private function getMaterialKey(mesh:Object, state:PainterState):String {
		// Упрощённый ключ: можно расширить под ваши нужды
		// В идеале — хэш материала + шейдера + параметров
		return Std.string(mesh);
	}
	
	private function canAdd(batch:Batch, mesh:Object):Bool {
		// Проверяем, можно ли добавить меш в текущий батч
		// Здесь можно добавить логику совместимости материалов
		return batch.vertexCount + mesh.getVertexCount() < 65535; // ограничение индексов
	}
}