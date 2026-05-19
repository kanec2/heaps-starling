package hide.modules;
import hide.core.Ide;


typedef MenuItemDef = {
    var label:String;
    @:optional var id:String;
    @:optional var type:String;
    @:optional var submenu:Array<MenuItemDef>;
}

class MenuSystem {
    var ide:Ide;
    var commands:Map<String, Void->Void>;

    public function new(ide:Ide) {
        this.ide = ide;
        commands = new Map();
        trace("[MenuSystem] System created!");
    }

    public function loadFromXml():Void {
        trace("[MenuSystem] Start loading menu...");
        
        var buildMenu = function() {
            trace("[MenuSystem] Building menu from XML...");
            var xmlEl = js.Browser.document.getElementById("mainmenu");
            if (xmlEl == null) {
                trace("[MenuSystem] ⚠️ mainmenu XML not found!");
                return;
            }

            var menuData:Array<MenuItemDef> = [];
            for (i in 0...xmlEl.children.length) {
                var item = parseMenuItem(cast xmlEl.children[i]);
                trace("[MenuSystem] Parsed item: label='" + item.label + "', id='" + item.id + "'"); // 👈 НОВОЕ
                menuData.push(item);
            }

            trace("[MenuSystem] 📤 Sending to Main: " + haxe.Json.stringify(menuData)); // 👈 НОВОЕ
            ide.getBackend().createMenu(menuData);
            ide.getBackend().onMenuClick(handleCommand);
        };

        var readyState = js.Browser.document.readyState;
        if (readyState == "complete" || readyState == "interactive") {
            buildMenu();
        } else {
            js.Browser.document.addEventListener("DOMContentLoaded", function(_) { buildMenu(); });
        }
    }

    public function registerCommand(id:String, handler:Void->Void):Void {
        commands.set(id, handler);
    }

    function handleCommand(id:String):Void {
        if (commands.exists(id)) {
            trace("[MenuSystem] ▶ Executing: " + id);
            commands.get(id)();
        } else {
            trace("[MenuSystem] ⚠️ Unknown command: " + id);
        }
    }

    function parseMenuItem(el:js.html.Element):MenuItemDef {
        var item:MenuItemDef = {
            label: el.getAttribute("label") != null ? el.getAttribute("label") : "Item",
            id: el.getAttribute("onclick"),
            type: el.getAttribute("type")
        };

        if (el.children != null && el.children.length > 0) {
            var submenu = [];
            for (i in 0...el.children.length) {
                submenu.push(parseMenuItem(cast el.children[i]));
            }
            item.submenu = submenu;
        }
        return item;
    }
}