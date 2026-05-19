package hide.electron;

import hide.core.IIdeBackend;
import electron.renderer.IpcRenderer; // 👇 Ваш импорт из electron.main.*


class ElectronBackend implements IIdeBackend {
    
    var menuClickHandler:Null<String->Void> = null;

    public function new() {}
    
    public function init():Void {
        trace("[ElectronBackend] init()");
        
        // 👇 ТЕСТОВЫЙ СЛУШАТЕЛЬ — самый ранний возможный
        IpcRenderer.on("menu:click", function(event, data) {
            trace("🔥🔥🔥 RAW IPC RECEIVED 🔥🔥🔥");
            trace("Channel: menu:click");
            trace("Data: " + haxe.Json.stringify(data));
            trace("Type of data: " + Type.typeof(data));
            if (data != null) {
                trace("data.id: " + data.id);
                trace("Type of id: " + Type.typeof(data.id));
            }
        });

        // Слушаем клики из Main Process
        IpcRenderer.on("menu:click", function(event, data) {
            if (menuClickHandler != null && data.id != null) {
                menuClickHandler(data.id);
            }
        });
    }
    
    public function isReady():Bool return true;
    
    // === Окна ===
    public function openWindow(url:String, options:Dynamic, ?id:String):Void {
        trace("[ElectronBackend] openWindow: " + url);
        IpcRenderer.send("window:open", { url: url, options: options, id: id });
    }
    public function closeWindow(?id:String):Void { trace("[ElectronBackend] closeWindow"); }
    public function focusWindow(?id:String):Void { trace("[ElectronBackend] focusWindow"); }
    public function getCurrentWindowId():String return "main";
    
    // === Меню ===
    public function createMenu(menuData:Array<Dynamic>):Void {
        IpcRenderer.send("menu:build", menuData);
    }
    public function onMenuClick(handler:String->Void):Void {
        menuClickHandler = handler;
    }
    public function updateMenuLabel(itemId:String, newLabel:String):Void {}
    public function setMenuItemEnabled(itemId:String, enabled:Bool):Void {}
    
    // === Файлы ===
    public function readFile(path:String, ?onComplete:String->Void, ?onError:String->Void):Void {
        if (onError != null) onError("Not implemented yet");
    }
    public function writeFile(path:String, content:String, ?onComplete:Bool->Void, ?onError:String->Void):Void {}
    public function watchPath(path:String, onChange:String->Void):Void {}
    public function unwatchPath(path:String):Void {}
    
    // === Приложение ===
    public function clearCache():Void { IpcRenderer.send("app:clearCache"); }
    public function reload():Void { IpcRenderer.send("app:reload"); }
    public function quit():Void { IpcRenderer.send("app:quit"); }
    
    public function getArgv():Array<String> {
        // В Electron рендерер не имеет прямого доступа к process.argv
        // Позже получим через IPC
        return [];
    }
    
    public function getAppPath():String {
        // Заглушка: позже получим через IPC или __dirname
        return "./";
    }
    
    // === IPC ===
    public function sendToMain(channel:String, ?data:Dynamic):Void {
        IpcRenderer.send(channel, data);
    }
    
    public function onFromMain(channel:String, handler:Dynamic->Void):Void {
        IpcRenderer.on(channel, function(event, args) handler(args));
    }
}