package starling.core;

import h2d.Scene;
import h3d.Engine;
import h3d.scene.Scene as H3dScene;
import hxd.App;
import hxd.Event;
import hxd.Key;
import hxd.Timer;
import heaps.rendering.Painter; // наш адаптированный Painter

/**
 * Адаптация ядра Starling для Heaps.io
 * 
 * Управляет жизненным циклом, конфигурацией, событиями и рендерингом.
 * Максимально сохраняет API оригинала для упрощения миграции.
 */
class HeapsStarling {
	
	// === Конфигурация ===
	
	/** Версия движка */
	@:isVar public static var VERSION(get, never):String;
	private static inline function get_VERSION():String return "2.0.0-heaps";
	
	/** Текущий инстанс (аналог Starling.current) */
	@:isVar public static var current(get, never):HeapsStarling;
	private static var _current:HeapsStarling;
	private static inline function get_current():HeapsStarling return _current;
	
	/** Поддерживаемые профиль шейдеров */
	@:isVar public static var supportedProfiles(get, never):Array<String>;
	private static function get_supportedProfiles():Array<String> {
		return ["base", "standard", "advanced"]; // упрощённо
	}
	
	// === Состояние ===
	
	/** Активен ли движок */
	@:isVar public var isStarted(get, never):Bool;
	private var _started:Bool = false;
	private inline function get_isStarted():Bool return _started;
	
	/** Активен ли рендеринг */
	@:isVar public var renderEnabled(get, set):Bool;
	private var _renderEnabled:Bool = true;
	private inline function get_renderEnabled():Bool return _renderEnabled;
	private inline function set_renderEnabled(v:Bool):Bool {
		_renderEnabled = v;
		return v;
	}
	
	/** Частота обновления (в Гц) */
	@:isVar public var frameRate(get, set):Float;
	private var _frameRate:Float = 60.0;
	private inline function get_frameRate():Float return _frameRate;
	private inline function set_frameRate(v:Float):Float {
		_frameRate = v;
		Timer.setFrameRate(v);
		return v;
	}
	
	/** Показывать ли статистику */
	@:isVar public var showStats(get, set):Bool;
	private var _showStats:Bool = false;
	private var _statsOverlay:Null<h2d.Object>;
	private inline function get_showStats():Bool return _showStats;
	private inline function set_showStats(v:Bool):Bool {
		if (v != _showStats) {
			_showStats = v;
			updateStatsOverlay();
		}
		return v;
	}
	
	// === Основные компоненты ===
	
	/** Основной h3d.Engine */
	public var engine(get, never):Engine;
	private var _engine:Engine;
	private inline function get_engine():Engine return _engine;
	
	/** 2D-сцена (аналог starling.display.Stage) */
	public var stage(get, never):Scene;
	private var _stage:Scene;
	private inline function get_stage():Scene return _stage;
	
	/** 3D-сцена (опционально) */
	@:isVar public var scene3D(get, set):Null<H3dScene>;
	private var _scene3D:Null<H3dScene>;
	private inline function get_scene3D():Null<H3dScene> return _scene3D;
	private inline function set_scene3D(v:Null<H3dScene>):Null<H3dScene> {
		_scene3D = v;
		return v;
	}
	
	/** Painter для управления рендерингом */
	@:isVar public var painter(get, never):Painter;
	private var _painter:Painter;
	private inline function get_painter():Painter return _painter;
	
	/** Корневой контейнер для контента (аналог root) */
	@:isVar public var root(get, set):h2d.Object;
	private var _root:h2d.Object;
	private inline function get_root():h2d.Object return _root;
	private inline function set_root(v:h2d.Object):h2d.Object {
		if (_root != null && _root.parent != null) {
			_root.remove();
		}
		_root = v;
		if (_root != null && !_root.hasParent()) {
			_stage.addObject(_root);
		}
		return v;
	}
	
	// === Viewport и масштабирование ===
	
	/** Область рендеринга в экранных координатах */
	@:isVar public var viewPort(get, set):hxd.col.Rectangle;
	private var _viewPort:hxd.col.Rectangle;
	private inline function get_viewPort():hxd.col.Rectangle return _viewPort;
	private inline function set_viewPort(v:hxd.col.Rectangle):hxd.col.Rectangle {
		_viewPort = v.clone();
		applyViewPort();
		return _viewPort;
	}
	
	/** Коэффициент масштабирования контента */
	@:isVar public var contentScaleFactor(get, set):Float;
	private var _contentScaleFactor:Float = 1.0;
	private inline function get_contentScaleFactor():Float return _contentScaleFactor;
	private inline function set_contentScaleFactor(v:Float):Float {
		_contentScaleFactor = v;
		applyContentScale();
		return v;
	}
	
	/** Режим масштабирования контента */
	@:isVar public var scaleMode(get, set):String; // "exactFit" | "noBorder" | "noScale" | "showAll"
	private var _scaleMode:String = "showAll";
	private inline function get_scaleMode():String return _scaleMode;
	private inline function set_scaleMode(v:String):String {
		_scaleMode = v;
		applyContentScale();
		return v;
	}
	
	/** Ориентация контента */
	@:isVar public var align(get, set):String; // "topLeft" | "center" | etc.
	private var _align:String = "center";
	private inline function get_align():String return _align;
	private inline function set_align(v:String):String {
		_align = v;
		applyContentScale();
		return v;
	}
	
	// === Настройки рендеринга ===
	
	/** Антиалиасинг (количество сэмплов) */
	@:isVar public var antiAliasing(get, set):Int;
	private var _antiAliasing:Int = 0;
	private inline function get_antiAliasing():Int return _antiAliasing;
	private inline function set_antiAliasing(v:Int):Int {
		_antiAliasing = v;
		if (_engine != null) {
			_engine.setAntialiasing(v);
		}
		return v;
	}
	
	/** Поддерживаемые текстуры (профиль) */
	@:isVar public var textureProfile(get, set):String;
	private var _textureProfile:String = "baseline";
	private inline function get_textureProfile():String return _textureProfile;
	private inline function set_textureProfile(v:String):String {
		_textureProfile = v;
		// В полной версии — проверка возможностей GPU
		return v;
	}
	
	/** Отключить автоматическую очистку буфера */
	@:isVar public var skipUnchangedFrames(get, set):Bool;
	private var _skipUnchangedFrames:Bool = false;
	private inline function get_skipUnchangedFrames():Bool return _skipUnchangedFrames;
	private inline function set_skipUnchangedFrames(v:Bool):Bool {
		_skipUnchangedFrames = v;
		return v;
	}
	
	// === События ===
	
	/** Диспетчер событий (кастомный, аналог EventDispatcher) */
	@:isVar public var eventDispatcher(get, never):EventDispatcher;
	private var _eventDispatcher:EventDispatcher;
	private inline function get_eventDispatcher():EventDispatcher return _eventDispatcher;
	
	// === Статистика ===
	
	/** Счётчик draw calls за кадр */
	@:isVar public var drawCalls(get, never):Int;
	private inline function get_drawCalls():Int {
		return _painter != null ? _painter.drawCount : 0;
	}
	
	/** Счётчик треугольников за кадр */
	@:isVar public var triangles(get, never):Int;
	private inline function get_triangles():Int {
		// В полной версии — агрегация из статистики Heaps
		return 0;
	}
	
	// === Внутренние поля ===
	
	@:noCompletion private var _app:App;
	@:noCompletion private var _contextCreated:Bool = false;
	@:noCompletion private var _supportsDepthAndStencil:Bool = true;
	@:noCompletion private var _multisample:Bool = false;
	@:noCompletion private var _profile:String = "baseline";
	@:noCompletion private var _simulatedMultitouch:Bool = false;
	@:noCompletion private var _nativeStage:hxd.Window;
	
	// ========================================================================
	// КОНСТРУКТОР И ИНИЦИАЛИЗАЦИЯ
	// ========================================================================
	
	/**
	 * Создаёт новый инстанс HeapsStarling.
	 * 
	 * @param appClass Класс приложения (наследник hxd.App)
	 * @param viewPort Область рендеринга (по умолчанию — всё окно)
	 * @param stage3D Не используется в Heaps (оставлен для совместимости API)
	 * @param renderMode Не используется (оставлен для совместимости)
	 */
	@:deprecated("Используйте конструктор без параметров и настройку через свойства")
	@:noCompletion
	public function new(appClass:Class<App>, ?viewPort:hxd.col.Rectangle, 
	                    ?stage3D:Dynamic, renderMode:String = "auto") {
		
		_current = this;
		_eventDispatcher = new EventDispatcher();
		
		_viewPort = viewPort != null ? viewPort.clone() : new hxd.col.Rectangle(0, 0, 800, 600);
		
		// Создаём приложение
		_app = Type.createInstance(appClass, []);
		_engine = _app.engine;
		_nativeStage = hxd.Window.getInstance();
		
		// Инициализируем сцену
		_stage = new Scene(_engine);
		
		// Создаём Painter
		_painter = new Painter(_engine);
		
		// Настраиваем обработчики
		setupEventHandlers();
	}
	
	/**
	 * Упрощённый конструктор для прямого использования.
	 */
	@:overload(function(engine:Engine):Void {})
	public function new() {
		_current = this;
		_eventDispatcher = new EventDispatcher();
		
		// Получаем или создаём engine
		_engine = Engine.getCurrent();
		_nativeStage = hxd.Window.getInstance();
		
		_viewPort = new hxd.col.Rectangle(0, 0, _engine.width, _engine.height);
		
		_stage = new Scene(_engine);
		_painter = new Painter(_engine);
		
		setupEventHandlers();
	}
	
	/**
	 * Настраивает обработчики событий Heaps.
	 */
	private function setupEventHandlers():Void {
		// Обработка изменения размера окна
		_nativeStage.addEventTarget(function(e:hxd.Event) {
			if (e.kind == EResize) {
				onResize();
			}
		});
		
		// Обработка ввода (перенаправление в Starling-style события)
		_nativeStage.addEventTarget(function(e:hxd.Event) {
			handleInputEvent(e);
		});
	}
	
	// ========================================================================
	// ЗАПУСК И ОСТАНОВКА
	// ========================================================================
	
	/**
	 * Запускает движок.
	 * 
	 * @param appClass Класс приложения (опционально, если не задан в конструкторе)
	 * @param stage Не используется в Heaps
	 * @param renderMode Не используется
	 * @param profile Профиль рендеринга
	 * @param forceSoftware Не используется в Heaps
	 * @param enableErrorChecking Включить проверку ошибок драйвера
	 */
	@:deprecated("Используйте startWithApp() или создавайте HeapsStarling напрямую")
	@:noCompletion
	public static function start(appClass:Class<App>, stage:Dynamic, 
	                             renderMode:String = "auto", profile:String = "baseline",
	                             forceSoftware:Bool = false, enableErrorChecking:Bool = false):HeapsStarling {
		
		var starling = new HeapsStarling(appClass);
		starling._profile = profile;
		starling._painter.enableErrorChecking = enableErrorChecking;
		starling.start();
		return starling;
	}
	
	/**
	 * Запускает уже созданный инстанс.
	 */
	@:overload(function():Void {})
	public function start(?appClass:Class<App>):Void {
		if (_started) return;
		
		_started = true;
		
		// Применяем настройки
		applyViewPort();
		applyContentScale();
		_engine.setAntialiasing(_antiAliasing);
		
		// Уведомляем о создании контекста
		_contextCreated = true;
		onContextCreated();
		
		// Уведомляем слушателей
		_eventDispatcher.dispatchEvent(new Event("context_created"));
		
		// Запускаем цикл (если приложение ещё не запущено)
		// В Heaps это обычно происходит автоматически
		#if !heaps_already_running
		hxd.Timer.init();
		#end
	}
	
	/**
	 * Останавливает движок.
	 */
	@:noCompletion
	public function stop():Void {
		if (!_started) return;
		
		_started = false;
		_eventDispatcher.dispatchEvent(new Event("stopped"));
		
		// В Heaps полная остановка требует закрытия окна
		// Обычно достаточно отключить рендеринг
		_renderEnabled = false;
	}
	
	/**
	 * Освобождает ресурсы.
	 */
	@:noCompletion
	public function dispose():Void {
		stop();
		
		if (_painter != null) {
			_painter.dispose();
			_painter = null;
		}
		
		if (_stage != null) {
			_stage.dispose();
			_stage = null;
		}
		
		_eventDispatcher.removeAllListeners();
		_eventDispatcher = null;
		
		_current = null;
		_contextCreated = false;
	}
	
	// ========================================================================
	// ЖИЗНЕННЫЙ ЦИКЛ
	// ========================================================================
	
	/**
	 * Вызывается при создании/восстановлении контекста.
	 */
	@:noCompletion
	private function onContextCreated():Void {
		// Сбрасываем состояние рендерера
		_painter.setupContextDefaults();
		
		// Инициализируем корневой объект, если не задан
		if (_root == null) {
			_root = new h2d.Object(_stage);
		}
		
		// Применяем масштабирование
		applyContentScale();
		
		// Уведомляем слушателей
		_eventDispatcher.dispatchEvent(new Event("root_created"));
	}
	
	/**
	 * Обработка изменения размера окна.
	 */
	@:noCompletion
	private function onResize():Void {
		// Обновляем viewport по умолчанию
		_viewPort.width = _engine.width;
		_viewPort.height = _engine.height;
		
		// Пересчитываем масштабирование контента
		applyContentScale();
		
		_eventDispatcher.dispatchEvent(new Event("resize", _engine.width, _engine.height));
	}
	
	/**
	 * Обработка ввода — преобразует события Heaps в Starling-style.
	 */
	@:noCompletion
	private function handleInputEvent(e:hxd.Event):Void {
		var starlingEvent:Null<Event> = null;
		
		switch (e.kind) {
			case EPush:
				starlingEvent = new Event("touch_begin", e.x, e.y, e.button);
			case ERelease:
				starlingEvent = new Event("touch_end", e.x, e.y, e.button);
			case EMove:
				starlingEvent = new Event("touch_move", e.x, e.y);
			case EWheel:
				starlingEvent = new Event("mouse_wheel", 0, e.wheelDelta);
			case EKeyDown:
				starlingEvent = new Event("key_down", 0, 0, 0, Key.toString(e.keyCode));
			case EKeyUp:
				starlingEvent = new Event("key_up", 0, 0, 0, Key.toString(e.keyCode));
			default:
		}
		
		if (starlingEvent != null) {
			// Конвертируем координаты в координаты контента
			starlingEvent.x = (starlingEvent.x - _viewPort.x) / _contentScaleFactor;
			starlingEvent.y = (starlingEvent.y - _viewPort.y) / _contentScaleFactor;
			
			_eventDispatcher.dispatchEvent(starlingEvent);
		}
	}
	
	// ========================================================================
	// VIEWPORT И МАСШТАБИРОВАНИЕ
	// ========================================================================
	
	/**
	 * Применяет настройки viewport к движку.
	 */
	@:noCompletion
	private function applyViewPort():Void {
		if (_engine == null) return;
		
		// В Heaps viewport задаётся через scissor + проекцию
		// Упрощённо: устанавливаем scissor для области рендеринга
		_engine.driver.setScissorRect(
			Std.int(_viewPort.x),
			Std.int(_engine.height - _viewPort.y - _viewPort.height), // инверсия Y
			Std.int(_viewPort.width),
			Std.int(_viewPort.height)
		);
	}
	
	/**
	 * Применяет масштабирование и выравнивание контента.
	 */
	@:noCompletion
	private function applyContentScale():Void {
		if (_stage == null) return;
		
		var stageW = _viewPort.width;
		var stageH = _viewPort.height;
		var contentW = _stage.width;
		var contentH = _stage.height;
		
		if (contentW == 0 || contentH == 0) return;
		
		var scale:Float = switch (_scaleMode) {
			case "exactFit": 
				Math.max(stageW / contentW, stageH / contentH);
			case "noBorder": 
				Math.max(stageW / contentW, stageH / contentH);
			case "noScale": 
				1.0;
			case "showAll": 
				Math.min(stageW / contentW, stageH / contentH);
			default: 
				_contentScaleFactor;
		};
		
		// Применяем масштаб к корневому объекту
		if (_root != null) {
			_root.setScale(scale);
			
			// Выравнивание
			var offsetX:Float = 0;
			var offsetY:Float = 0;
			
			switch (_align) {
				case "center":
					offsetX = (stageW - contentW * scale) / 2;
					offsetY = (stageH - contentH * scale) / 2;
				case "top":
					offsetX = (stageW - contentW * scale) / 2;
				case "bottom":
					offsetX = (stageW - contentW * scale) / 2;
					offsetY = stageH - contentH * scale;
				case "left":
					offsetY = (stageH - contentH * scale) / 2;
				case "right":
					offsetX = stageW - contentW * scale;
					offsetY = (stageH - contentH * scale) / 2;
				// "topLeft" — по умолчанию (0, 0)
			}
			
			_root.setPosition(
				_viewPort.x + offsetX,
				_viewPort.y + offsetY
			);
		}
		
		// Обновляем painter с новым масштабом
		_painter.refreshBackBufferSize(_contentScaleFactor);
	}
	
	// ========================================================================
	// СТАТИСТИКА И ОТЛАДКА
	// ========================================================================
	
	/**
	 * Обновляет оверлей статистики.
	 */
	@:noCompletion
	private function updateStatsOverlay():Void {
		if (_showStats) {
			if (_statsOverlay == null) {
				_statsOverlay = new h2d.Object(_stage);
				var tf = new h2d.Text(hxd.res.DefaultFont.get(), _statsOverlay);
				tf.textColor = 0xFFFFFF;
				tf.dropShadow = new h2d.col.Color(0, 0.5);
				tf.x = 10;
				tf.y = 10;
				
				// Обновляем текст каждый кадр
				_app.onUpdate = function(dt:Float) {
					tf.text = 'FPS: ${Math.round(1/dt)} | Draw: ${drawCalls} | Tri: ${triangles}';
				};
			}
			_statsOverlay.visible = true;
		} else if (_statsOverlay != null) {
			_statsOverlay.visible = false;
		}
	}
	
	/**
	 * Сбрасывает счётчики статистики для нового кадра.
	 */
	@:noCompletion
	@:allow(heaps.rendering.Painter)
	private function resetStats():Void {
		// В полной версии — сброс агрегированной статистики
	}
	
	// ========================================================================
	// ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
	// ========================================================================
	
	/**
	 * Проверяет, поддерживает ли устройство depth+stencil буферы.
	 */
	@:noCompletion
	@:deprecated("В Heaps это всегда поддерживается на целевых платформах")
	@:isVar public var supportsDepthAndStencil(get, never):Bool;
	private inline function get_supportsDepthAndStencil():Bool {
		return _supportsDepthAndStencil;
	}
	
	/**
	 * Возвращает профиль рендеринга.
	 */
	@:noCompletion
	@:isVar public var profile(get, never):String;
	private inline function get_profile():String {
		return _profile;
	}
	
	/**
	 * Включает/выключает симуляцию мультитача.
	 */
	@:noCompletion
	@:isVar public var simulateMultitouch(get, set):Bool;
	private inline function get_simulateMultitouch():Bool {
		return _simulatedMultitouch;
	}
	private inline function set_simulateMultitouch(v:Bool):Bool {
		_simulatedMultitouch = v;
		// В Heaps мультитач поддерживается нативно
		// Эта настройка оставлена для совместимости API
		return v;
	}
	
	/**
	 * Возвращает нативный stage (окно Heaps).
	 */
	@:noCompletion
	@:isVar public var nativeStage(get, never):hxd.Window;
	private inline function get_nativeStage():hxd.Window {
		return _nativeStage;
	}
	
	/**
	 * Возвращает корневой объект сцены.
	 */
	@:noCompletion
	@:isVar public var get_rootContainer(get, never):h2d.Object;
	private inline function get_rootContainer():h2d.Object {
		return _root;
	}
	
	// ========================================================================
	// СОБЫТИЯ (Starling-compatible)
	// ========================================================================
	
	/**
	 * Добавляет слушателя события.
	 */
	@:noCompletion
	public function addEventListener(type:String, listener:Dynamic->Void, 
	                                 useCapture:Bool = false, priority:Int = 0, 
	                                 useWeakReference:Bool = false):Void {
		_eventDispatcher.addEventListener(type, listener, useCapture, priority);
	}
	
	/**
	 * Удаляет слушателя события.
	 */
	@:noCompletion
	public function removeEventListener(type:String, listener:Dynamic->Void, 
	                                    useCapture:Bool = false):Void {
		_eventDispatcher.removeEventListener(type, listener, useCapture);
	}
	
	/**
	 * Диспатчит событие.
	 */
	@:noCompletion
	public function dispatchEvent(event:Event):Bool {
		return _eventDispatcher.dispatchEvent(event);
	}
	
	/**
	 * Проверяет наличие слушателей для типа события.
	 */
	@:noCompletion
	public function hasEventListener(type:String):Bool {
		return _eventDispatcher.hasEventListener(type);
	}
}