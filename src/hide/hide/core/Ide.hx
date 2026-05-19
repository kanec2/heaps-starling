package hide.core;

import hide.modules.MenuSystem;
import js.Browser.document;
import js.Browser.window;
import js.Node.process;
import js.node.ChildProcess;
// Пока не импортируем модули — заглушки создадим ниже
// import hide.modules.*;

class Ide {
    public static var inst(default, null):Ide;

    // === Модули (объявляем как var, а не свойства с доступом) ===
    public var windowManager:Dynamic; // Пока Dynamic, позже типизируем
    public var menuSystem:MenuSystem;
    public var fileSystem:Dynamic;
    public var projectManager:Dynamic;
    public var uiLayout:Dynamic;
    public var searchNav:Dynamic;

    // === Бэкенд ===
    private var backend:IIdeBackend;

    // === Состояние ===
    public var isInitialized(default, null):Bool = false;
    public var currentProject:Dynamic;

    public function new() {
        inst = this;
        
        // 1. Инициализация конфига
        IdeConfig.init();
        
        // 2. Создание бэкенда
        backend = createBackend();
        backend.init();
        
        // 3. Сохранение appPath
        IdeConfig.appPath = backend.getAppPath();
    }

    static function createBackend():IIdeBackend {
        #if electron
        return new hide.electron.ElectronBackend(); // 👈 Требует создания файла
        #elseif nwjs
        return new hide.nwjs.NwjsBackend();
        #else
        return new hide.core.FallbackBackend();
        #end
    }

    // === Публичный API ===
    public function getBackend():IIdeBackend return backend;
    
    public function getModule(name:String):Dynamic {
        return switch name {
            case "windowManager": windowManager;
            case "menuSystem": menuSystem;
            case "fileSystem": fileSystem;
            case "projectManager": projectManager;
            case "uiLayout": uiLayout;
            case "searchNav": searchNav;
            case _: null;
        }
    }

    // === Точка входа ===
    public function init():Void {
        if (isInitialized) return;
        
        trace("🚀 Hide IDE initializing...");
        // 1. Создаём модули
        menuSystem = new MenuSystem(this);

        // 2. Загружаем меню из XML
        menuSystem.loadFromXml();

        // 3. Регистрируем команды (примеры)
        menuSystem.registerCommand("onExit", function() { getBackend().quit(); });
        menuSystem.registerCommand("onNewProject", function() { trace("📄 New Project"); });
        menuSystem.registerCommand("onOpenProject", function() { trace("📂 Open Project"); });
        menuSystem.registerCommand("onPreferences", function() { trace("⚙️ Preferences"); });

        // Добавьте остальные onclick из вашего app.xml...

        // Пока не создаём модули — только заглушки
        // Позже раскомментируем:
        // uiLayout = new UiLayout(this);
        // menuSystem = new MenuSystem(this);
        // ...
        
        isInitialized = true;
        trace("✅ Hide IDE ready (stub mode).");
        setText('system-version',"✅ Hide IDE ready (stub mode).");
    }
    static inline function setText(id:String, text:String) {
		document.getElementById(id).textContent = text;
	}

    // 👇 НОВОЕ: Точка входа для JS-рантайма (Renderer Process)
    public static function main():Void {
        window.onload = () -> {

            trace("🌐 Renderer process starting...");
            setText('system-version',"🌐 Renderer process starting...");
            var app = new Ide();
            app.init();
            
        }
    }
}