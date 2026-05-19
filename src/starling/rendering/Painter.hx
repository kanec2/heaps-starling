package starling.rendering;

import h2d.BlendMode;
import h3d.Matrix;
import h3d.scene.Object;
import h3d.pass.Pass;
import h3d.mat.Texture;
import h3d.impl.Driver;
import hxd.Renderer;
import hxd.Event;
import hxd.col.Rectangle;
import hxd.Stack;

/**
 * Адаптация Starling Painter для Heaps.io
 * 
 * Оркестрирует рендеринг, управляет состоянием, батчингом, масками и клиппингом.
 * API максимально близок к оригиналу для упрощения миграции.
 */
class Painter {
	
	// === Контекст и буферы ===
	private var _engine:h3d.Engine;
	private var _driver:Driver;
	private var _shareContext:Bool = false;
	private var _drawCount:Int = 0;
	private var _frameID:UInt = 0;
	private var _pixelSize:Float = 1.0;
	private var _enableErrorChecking:Bool = false;
	
	// === Стек состояний ===
	private var _state:PainterState;
	private var _stateStack:Stack<PainterState>;
	private var _stateStackMax:Int = 32;
	
	// === Стек клиппинга ===
	private var _clipRectStack:Stack<hxd.col.Rectangle>;
	
	// === Батчинг ===
	private var _batchProcessor:BatchProcessor;
	private var _batchProcessorCurr:BatchProcessor;
	private var _batchProcessorPrev:BatchProcessor;
	private var _batchProcessorSpec:BatchProcessor;
	private var _batchCacheExclusions:hxd.ObjectMap<Object, Bool>;
	private var _batchTrimInterval:Int = 250;
	private var _cacheEnabled:Bool = true;
	
	// === Маски (stencil) ===
	private var _stencilReferenceValues:Map<String, Int>;
	
	// === Рендер-таргеты ===
	private var _actualRenderTarget:Null<Texture>;
	private var _actualRenderTargetOptions:Int;
	private var _backBufferWidth:Int;
	private var _backBufferHeight:Int;
	private var _backBufferScaleFactor:Float = 1.0;
	
	// === Контекстные настройки ===
	private var _actualCulling:String;
	private var _actualBlendMode:h2d.BlendMode;
	private var _actualDepthMask:Bool;
	private var _actualDepthTest:String;
	
	// === Хелперы ===
	private static var sMatrix:Matrix = new Matrix();
	private static var sClipRect:hxd.col.Rectangle = new hxd.col.Rectangle();
	private static var sBufferRect:hxd.col.Rectangle = new hxd.col.Rectangle();
	
	// === Shared data (для нескольких инстансов) ===
	private static var sSharedData:Map<String, Dynamic> = new Map();
	
	// ========================================================================
	// КОНСТРУКТОР
	// ========================================================================
	
	/**
	 * Создаёт новый Painter.
	 * @param engine Экземпляр h3d.Engine (по умолчанию — текущий)
	 * @param shareContext Если true, не управлять контекстом напрямую
	 */
	public function new(?engine:h3d.Engine, shareContext:Bool = false) {
		this._engine = engine != null ? engine : h3d.Engine.getCurrent();
		this._driver = this._engine.driver;
		this._shareContext = shareContext;
		
		_state = new PainterState(this._engine);
		_stateStack = new Stack<PainterState>(_stateStackMax);
		_clipRectStack = new Stack<hxd.col.Rectangle>();
		
		_batchProcessor = new BatchProcessor(onBatchComplete);
		_batchProcessorCurr = _batchProcessor;
		_batchProcessorPrev = new BatchProcessor(onBatchComplete);
		_batchProcessorSpec = new BatchProcessor(onBatchComplete);
		_batchCacheExclusions = new hxd.ObjectMap();
		
		_stencilReferenceValues = new Map();
		
		_actualBlendMode = h2d.BlendMode.Alpha;
		_actualDepthMask = true;
		_actualDepthTest = "always";
		_actualCulling = "none";
		
		refreshBackBufferSize(_backBufferScaleFactor);
	}
	
	/**
	 * Освобождает ресурсы.
	 */
	public function dispose():Void {
		if (_batchProcessor != null) _batchProcessor.dispose();
		if (_batchProcessorPrev != null) _batchProcessorPrev.dispose();
		if (_batchProcessorSpec != null) _batchProcessorSpec.dispose();
		_batchCacheExclusions = null;
		_stateStack = null;
		_clipRectStack = null;
		_stencilReferenceValues = null;
	}
	
	// ========================================================================
	// STATE STACK — Управление состоянием
	// ========================================================================
	
	/**
	 * Сохраняет текущее состояние в стек.
	 * @param token Опциональный токен для отслеживания позиции в кэше
	 */
	public function pushState(?token:BatchToken):Void {
		_stateStack.push(_state.clone());
		
		if (token != null) {
			fillToken(token);
		}
	}
	
	/**
	 * Восстанавливает состояние из стека.
	 * @param token Опциональный токен для обновления позиции
	 */
	public function popState(?token:BatchToken):Void {
		if (_stateStack.length > 0) {
			_state = _stateStack.pop();
			applyState();
		}
		
		if (token != null) {
			fillToken(token);
		}
	}
	
	/**
	 * Восстанавливает состояние, не удаляя его из стека.
	 */
	public function restoreState():Void {
		if (_stateStack.length > 0) {
			_state = _stateStack.peek().clone();
			applyState();
		}
	}
	
	/**
	 * Применяет текущее состояние к драйверу.
	 */
	private function applyState():Void {
		// Матрица
		_driver.setMatrix(_state.modelviewMatrix);
		
		// Альфа
		_driver.setAlpha(_state.alpha);
		
		// Blend mode
		if (_state.blendMode != _actualBlendMode) {
			applyBlendMode(_state.blendMode);
			_actualBlendMode = _state.blendMode;
		}
		
		// Render target
		if (_state.renderTarget != _actualRenderTarget) {
			applyRenderTarget(_state.renderTarget, _state.renderTargetOptions);
		}
		
		// Culling
		if (_state.culling != _actualCulling) {
			applyCulling(_state.culling);
		}
		
		// Depth test / mask
		if (_state.depthTest != _actualDepthTest || _state.depthMask != _actualDepthMask) {
			applyDepthTest(_state.depthTest, _state.depthMask);
		}
		
		// Clip rect
		applyClipRect(_state.clipRect);
	}
	
	/**
	 * Устанавливает параметры состояния: матрицу, альфу, blend mode.
	 */
	public function setStateTo(transformationMatrix:Matrix, alphaFactor:Float = 1.0, blendMode:h2d.BlendMode = null):Void {
		if (transformationMatrix != null) {
			_state.modelviewMatrix = transformationMatrix.clone();
		}
		if (alphaFactor != 1.0) {
			_state.alpha *= alphaFactor;
		}
		if (blendMode != null && blendMode != h2d.BlendMode.Auto) {
			if (blendMode != _state.blendMode) {
				finishMeshBatch(); // Завершаем батч при смене режима
				_state.blendMode = blendMode;
			}
		}
	}
	
	/**
	 * Обновляет токен текущей позицией в кэше.
	 */
	public function fillToken(token:BatchToken):Void {
		if (_batchProcessorCurr != null) {
			_batchProcessorCurr.fillToken(token);
		}
	}
	
	// ========================================================================
	// МАСКИ — Stencil buffer
	// ========================================================================
	
	/**
	 * Рисует маску в stencil buffer, инкрементируя значения.
	 * @param mask Объект-маска
	 * @param maskee Опциональный объект, который будет исключён из кэша
	 */
	public function drawMask(mask:Object, ?maskee:Object):Void {
		// Оптимизация: если маска — прямоугольник, используем clip rect
		if (PainterUtils.isAxisAlignedRect(mask)) {
			var rect = PainterUtils.getObjectBounds(mask, _state.modelviewMatrix);
			pushClipRect(rect);
			if (maskee != null) excludeFromCache(maskee);
			return;
		}
		
		// Стандартный путь: stencil buffer
		var key = getRenderTargetKey();
		var refValue = _stencilReferenceValues.get(key);
		if (refValue == null) refValue = 0;
		
		_driver.enableStencil(true);
		_driver.setStencilFunc(Driver.STENCIL_ALWAYS, Driver.STENCIL_KEEP, Driver.STENCIL_INCREMENT);
		_driver.setStencilRef(refValue + 1);
		
		// Рендерим маску
		var oldMatrix = _state.modelviewMatrix.clone();
		if (!PainterUtils.isInSceneGraph(mask)) {
			_state.modelviewMatrix = _state.modelviewMatrix.clone();
		}
		mask.render(_engine);
		_state.modelviewMatrix = oldMatrix;
		
		// Обновляем ref value
		_stencilReferenceValues.set(key, refValue + 1);
		_driver.setStencilFunc(Driver.STENCIL_EQUAL, Driver.STENCIL_KEEP, Driver.STENCIL_KEEP);
		
		if (maskee != null) excludeFromCache(maskee);
	}
	
	/**
	 * Стирает маску из stencil buffer, декрементируя значения.
	 */
	public function eraseMask(mask:Object, ?maskee:Object):Void {
		var key = getRenderTargetKey();
		var refValue = _stencilReferenceValues.get(key);
		if (refValue == null || refValue <= 0) return;
		
		// Если использовался clip rect — просто pop
		if (PainterUtils.isAxisAlignedRect(mask) && _clipRectStack.length > 0) {
			popClipRect();
			if (maskee != null) excludeFromCache(maskee);
			return;
		}
		
		_driver.setStencilFunc(Driver.STENCIL_ALWAYS, Driver.STENCIL_KEEP, Driver.STENCIL_DECREMENT);
		_driver.setStencilRef(refValue);
		
		var oldMatrix = _state.modelviewMatrix.clone();
		if (!PainterUtils.isInSceneGraph(mask)) {
			_state.modelviewMatrix = _state.modelviewMatrix.clone();
		}
		mask.render(_engine);
		_state.modelviewMatrix = oldMatrix;
		
		_stencilReferenceValues.set(key, refValue - 1);
		if (refValue - 1 <= 0) {
			_driver.enableStencil(false);
		} else {
			_driver.setStencilFunc(Driver.STENCIL_EQUAL, Driver.STENCIL_KEEP, Driver.STENCIL_KEEP);
			_driver.setStencilRef(refValue - 1);
		}
		
		if (maskee != null) excludeFromCache(maskee);
	}
	
	private function getRenderTargetKey():String {
		if (_state.renderTarget == null) return "backbuffer";
		return Std.string(_state.renderTarget);
	}
	
	// ========================================================================
	// CLIPPING — Прямоугольные области обрезки
	// ========================================================================
	
	/**
	 * Добавляет прямоугольник обрезки в стек.
	 */
	public function pushClipRect(rect:hxd.col.Rectangle):Void {
		var intersection = rect;
		if (_clipRectStack.length > 0) {
			var parent = _clipRectStack.peek();
			intersection = parent.intersection(rect);
		}
		_clipRectStack.push(intersection.clone());
		_state.clipRect = intersection;
		applyClipRect(intersection);
	}
	
	/**
	 * Удаляет верхний прямоугольник из стека.
	 */
	public function popClipRect():Void {
		if (_clipRectStack.length == 0) return;
		_clipRectStack.pop();
		if (_clipRectStack.length > 0) {
			_state.clipRect = _clipRectStack.peek();
			applyClipRect(_state.clipRect);
		} else {
			_state.clipRect = null;
			_driver.setScissorRect(null);
		}
	}
	
	private function applyClipRect(rect:Null<hxd.col.Rectangle>):Void {
		if (rect == null) {
			_driver.setScissorRect(null);
			return;
		}
		
		// Конвертация в пиксели с учётом backBufferScaleFactor
		var x = Std.int(rect.x * _backBufferScaleFactor);
		var y = Std.int(rect.y * _backBufferScaleFactor);
		var w = Std.int(rect.width * _backBufferScaleFactor);
		var h = Std.int(rect.height * _backBufferScaleFactor);
		
		// Инверсия Y для OpenGL
		var driverY = _backBufferHeight - y - h;
		_driver.setScissorRect(x, driverY, w, h);
	}
	
	// ========================================================================
	// BATCHING — Группировка отрисовки
	// ========================================================================
	
	/**
	 * Добавляет меш в текущий батч.
	 * @param mesh Объект для батчинга
	 * @param subset Подмножество вершин/индексов (опционально)
	 */
	public function batchMesh(mesh:Object, ?subset:PainterUtils.MeshSubset):Void {
		if (!_cacheEnabled) {
			mesh.render(_engine);
			_drawCount++;
			return;
		}
		
		_batchProcessorCurr.addMesh(mesh, _state, subset);
	}
	
	/**
	 * Завершает текущий батч.
	 */
	public function finishMeshBatch():Void {
		_batchProcessorCurr.finishBatch();
	}
	
	/**
	 * Callback при завершении батча — рендерит его.
	 */
	private function onBatchComplete(batch:BatchProcessor.Batch):Void {
		batch.render(_engine, _state);
		_drawCount++;
	}
	
	/**
	 * Исключает объект из кэша рендеринга.
	 */
	public function excludeFromCache(obj:Object):Void {
		_batchCacheExclusions.set(obj, true);
	}
	
	/**
	 * Включает/выключает тримминг батчей для экономии памяти.
	 */
	public function enableBatchTrimming(enabled:Bool = true, interval:Int = 250):Void {
		_batchTrimInterval = enabled ? interval : 0;
	}
	
	// ========================================================================
	// FRAME MANAGEMENT — Управление кадром
	// ========================================================================
	
	/**
	 * Завершает кадр: финализирует батчи, сбрасывает счётчики.
	 */
	public function finishFrame():Void {
		_batchProcessorCurr.finishFrame();
		
		// Тримминг по интервалу
		if (_batchTrimInterval > 0 && _frameID % _batchTrimInterval == 0) {
			_batchProcessor.trim();
			_batchProcessorPrev.trim();
		}
		
		_frameID++;
	}
	
	/**
	 * Подготовка к новому кадру.
	 */
	public function nextFrame():Void {
		_state.reset();
		_stateStack.clear();
		_clipRectStack.clear();
		_batchProcessor.clear();
		_batchProcessorCurr = _batchProcessor;
		_drawCount = 0;
		_stencilReferenceValues = new Map();
		_driver.enableStencil(false);
		_driver.setDepthTest("always", true);
		setupContextDefaults();
		
		// Кэш включается в начале каждого кадра
		_cacheEnabled = true;
	}
	
	/**
	 * Сбрасывает настройки контекста к дефолтным для Starling/Heaps.
	 */
	public function setupContextDefaults():Void {
		_actualBlendMode = h2d.BlendMode.Alpha;
		_actualCulling = "none";
		_actualDepthTest = "always";
		_actualDepthMask = true;
		
		applyBlendMode(_actualBlendMode);
		applyCulling(_actualCulling);
		applyDepthTest(_actualDepthTest, _actualDepthMask);
	}
	
	// ========================================================================
	// CONTEXT & RENDER TARGETS
	// ========================================================================
	
	/**
	 * Применяет blend mode к драйверу.
	 */
	private function applyBlendMode(mode:h2d.BlendMode):Void {
		switch (mode) {
			case h2d.BlendMode.Alpha:
				_driver.setBlendMode(Driver.BLEND_SRC_ALPHA, Driver.BLEND_ONE_MINUS_SRC_ALPHA);
			case h2d.BlendMode.Add:
				_driver.setBlendMode(Driver.BLEND_SRC_ALPHA, Driver.BLEND_ONE);
			case h2d.BlendMode.Multiply:
				_driver.setBlendMode(Driver.BLEND_DST_COLOR, Driver.BLEND_ONE_MINUS_SRC_ALPHA);
			case h2d.BlendMode.Screen:
				_driver.setBlendMode(Driver.BLEND_ONE, Driver.BLEND_ONE_MINUS_SRC_ALPHA);
			case h2d.BlendMode.Erase:
				_driver.setBlendMode(Driver.BLEND_ZERO, Driver.BLEND_ONE_MINUS_SRC_ALPHA);
			default:
				_driver.setBlendMode(Driver.BLEND_SRC_ALPHA, Driver.BLEND_ONE_MINUS_SRC_ALPHA);
		}
	}
	
	/**
	 * Применяет culling.
	 */
	private function applyCulling(mode:String):Void {
		switch (mode) {
			case "none": _driver.setCulling(Driver.CULL_NONE);
			case "front": _driver.setCulling(Driver.CULL_FRONT);
			case "back": _driver.setCulling(Driver.CULL_BACK);
		}
		_actualCulling = mode;
	}
	
	/**
	 * Применяет depth test.
	 */
	private function applyDepthTest(func:String, mask:Bool):Void {
		var f = switch (func) {
			case "never": Driver.DEPTH_NEVER;
			case "less": Driver.DEPTH_LESS;
			case "equal": Driver.DEPTH_EQUAL;
			case "lequal": Driver.DEPTH_LEQUAL;
			case "greater": Driver.DEPTH_GREATER;
			case "notequal": Driver.DEPTH_NOTEQUAL;
			case "gequal": Driver.DEPTH_GEQUAL;
			case "always": Driver.DEPTH_ALWAYS;
			default: Driver.DEPTH_ALWAYS;
		};
		_driver.setDepthTest(f, mask);
		_actualDepthTest = func;
		_actualDepthMask = mask;
	}
	
	/**
	 * Переключает render target.
	 */
	private function applyRenderTarget(target:Null<Texture>, options:Int):Void {
		if (target == _actualRenderTarget && options == _actualRenderTargetOptions) return;
		
		if (target == null) {
			// Возврат к основному буферу
			_engine.popTarget();
		} else {
			// Переключение на кастомный таргет
			_engine.pushTarget(target, (options & 1) != 0); // 1 = с очисткой
		}
		
		_actualRenderTarget = target;
		_actualRenderTargetOptions = options;
		
		// Обновляем размеры для scissor
		if (target != null) {
			_backBufferWidth = target.width;
			_backBufferHeight = target.height;
		} else {
			refreshBackBufferSize(_backBufferScaleFactor);
		}
	}
	
	/**
	 * Очищает текущий рендер-таргет.
	 */
	public function clear(rgb:UInt = 0, alpha:Float = 0.0):Void {
		var r = ((rgb >> 16) & 0xFF) / 255.0;
		var g = ((rgb >> 8) & 0xFF) / 255.0;
		var b = (rgb & 0xFF) / 255.0;
		_engine.driver.clear(r, g, b, alpha, 1.0, 0);
		
		// Сброс stencil ref при очистке
		var key = getRenderTargetKey();
		_stencilReferenceValues.set(key, 0);
		_driver.enableStencil(false);
	}
	
	/**
	 * Отображает содержимое back buffer на экране (финальный present).
	 * В Heaps это происходит автоматически, но метод оставлен для совместимости.
	 */
	public function present():Void {
		// В Heaps flip происходит автоматически в конце кадра
		// Этот метод — заглушка для совместимости со Starling API
	}
	
	/**
	 * Обновляет размеры back buffer.
	 */
	public function refreshBackBufferSize(scaleFactor:Float):Void {
		_backBufferScaleFactor = scaleFactor;
		_backBufferWidth = Std.int(_engine.width * scaleFactor);
		_backBufferHeight = Std.int(_engine.height * scaleFactor);
		_pixelSize = 1.0 / scaleFactor;
	}
	
	// ========================================================================
	// RENDER CACHE — Кэширование рендеринга
	// ========================================================================
	
	/**
	 * Рисует меши из кэша между двумя токенами.
	 */
	public function drawFromCache(startToken:BatchToken, endToken:BatchToken):Void {
		if (!_cacheEnabled) return;
		
		_batchProcessorPrev.drawFromCache(startToken, endToken, _engine, _state);
		_drawCount += endToken.drawCalls - startToken.drawCalls;
	}
	
	// ========================================================================
	// PROPERTIES — Свойства
	// ========================================================================
	
	// === Контекст ===
	
	/** Текущий h3d.Engine */
	public var engine(get, never):h3d.Engine;
	private inline function get_engine():h3d.Engine return _engine;
	
	/** Низкоуровневый Driver */
	public var driver(get, never):Driver;
	private inline function get_driver():Driver return _driver;
	
	/** Stage3D-эквивалент: возвращает engine */
	public var stage3D(get, never):Dynamic;
	private inline function get_stage3D():Dynamic return _engine;
	
	/** Context3D-эквивалент: возвращает driver */
	public var context(get, never):Driver;
	private inline function get_context():Driver return _driver;
	
	/** Валиден ли контекст */
	public var contextValid(get, never):Bool;
	private inline function get_contextValid():Bool return _engine != null && !_engine.driver.isDisposed;
	
	// === Размеры ===
	
	/** Ширина back buffer в точках */
	public var backBufferWidth(get, never):Int;
	private inline function get_backBufferWidth():Int return _backBufferWidth;
	
	/** Высота back buffer в точках */
	public var backBufferHeight(get, never):Int;
	private inline function get_backBufferHeight():Int return _backBufferHeight;
	
	/** Масштаб: пикселей на точку */
	public var backBufferScaleFactor(get, never):Float;
	private inline function get_backBufferScaleFactor():Float return _backBufferScaleFactor;
	
	/** Размер точки в пикселях */
	public var pixelSize(get, set):Float;
	private inline function get_pixelSize():Float return _pixelSize;
	private inline function set_pixelSize(v:Float):Float return _pixelSize = v;
	
	// === Состояние ===
	
	/** Текущее состояние рендеринга */
	public var state(get, never):PainterState;
	private inline function get_state():PainterState return _state;
	
	/** Стек состояний: текущая глубина */
	@:isVar public var stateStackLength(get, never):Int;
	private inline function get_stateStackLength():Int return _stateStack.length;
	
	// === Батчинг и кэш ===
	
	/** Счётчик draw calls в текущем кадре */
	@:isVar public var drawCount(get, set):Int;
	private inline function get_drawCount():Int return _drawCount;
	private inline function set_drawCount(v:Int):Int return _drawCount = v;
	
	/** Включён ли кэш рендеринга */
	@:isVar public var cacheEnabled(get, set):Bool;
	private inline function get_cacheEnabled():Bool return _cacheEnabled;
	private inline function set_cacheEnabled(v:Bool):Bool {
		_cacheEnabled = v;
		if (!v) {
			// При отключении кэша — сбросить батчи
			_batchProcessor.clear();
		}
		return v;
	}
	
	/** ID текущего кадра (если кэш включён) */
	@:isVar public var frameID(get, set):UInt;
	private inline function get_frameID():UInt return _cacheEnabled ? _frameID : 0;
	private inline function set_frameID(v:UInt):UInt return _frameID = v;
	
	// === Настройки ===
	
	/** Разделяется ли контекст с другим фреймворком */
	@:isVar public var shareContext(get, set):Bool;
	private inline function get_shareContext():Bool return _shareContext;
	private inline function set_shareContext(v:Bool):Bool return _shareContext = v;
	
	/** Включена ли проверка ошибок Stage3D-вызовов */
	@:isVar public var enableErrorChecking(get, set):Bool;
	private inline function get_enableErrorChecking():Bool return _enableErrorChecking;
	private inline function set_enableErrorChecking(v:Bool):Bool {
		_enableErrorChecking = v;
		_driver.enableErrorChecking(v);
		return v;
	}
	
	/** Текущее значение stencil reference */
	@:isVar public var stencilReferenceValue(get, set):Int;
	private inline function get_stencilReferenceValue():Int {
		return _stencilReferenceValues.get(getRenderTargetKey()) ?? 0;
	}
	private inline function set_stencilReferenceValue(v:Int):Int {
		_stencilReferenceValues.set(getRenderTargetKey(), v);
		_driver.setStencilRef(v);
		return v;
	}
	
	// === Shared data ===
	
	/** Глобальные данные, привязанные к контексту */
	@:isVar public var sharedData(get, never):Map<String, Dynamic>;
	private inline function get_sharedData():Map<String, Dynamic> {
		var key = Std.string(_engine.driver);
		if (!sSharedData.exists(key)) {
			sSharedData.set(key, new Map());
		}
		return sSharedData.get(key);
	}
	
	// ========================================================================
	// STATIC HELPERS
	// ========================================================================
	
	/**
	 * Получает глобальный Painter для текущего engine.
	 * Рекомендуется хранить ссылку в своём классе приложения.
	 */
	@:deprecated("Используйте собственный экземпляр Painter вместо глобального доступа")
	@:noCompletion
	public static function getCurrent():Painter {
		// Заглушка: в Heaps нет глобального Painter, создавайте свой
		#if debug
		trace("Warning: Painter.getCurrent() — создайте свой экземпляр для лучшего контроля");
		#end
		return new Painter();
	}
}