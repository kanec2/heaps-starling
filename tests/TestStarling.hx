package;
/*
import starling.core.Starling;
import starling.display.Sprite;
import starling.display.Quad;
import starling.events.Event;
*/
import h3d.scene.Scene;
import hxd.App;

class TestStarling //extends Sprite
{
	var __app_root:App;
	var __app_rootClass:Class<Dynamic>;
	var __root:Scene;
	public function new()
	{
		//super();
		/*
	}
	
	override public function onAdded():Void
	{
		*/
		//var app:App;
		//var ev:hxd.Event;
		__app_rootClass = TestApp;
		//app.s3d.addEventListener()
		//var engine = h3d.Engine.getCurrent();
		//engine.
		initializeRoot();
		trace("TestStarling added to stage");
		
		// Create a simple test - add a colored quad
		//var quad = new Quad(100, 100, 0xFF0000);
		//quad.x = 50;
		//quad.y = 50;
		//addChild(quad);
		
		//trace("Quad added with color: " + quad.color);
	}

	private function initializeRoot():Void
    {
        if (__app_root == null && __app_rootClass != null)
        {
            __app_root = Type.createInstance(__app_rootClass, []);
            //if (__app_root == null || !#if (haxe_ver < 4.2) Std.is #else Std.isOfType #end(__app_root.s3d, DisplayObject)) throw new Error("Invalid root class: " + __app_rootClass);
            //__stage.addChildAt(__root, 0);

            //dispatchEventWith(starling.events.Event.ROOT_CREATED, false, __root);
        }
    }

	static function main() {
		new TestStarling();
	}
}
