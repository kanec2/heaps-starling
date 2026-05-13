package;

import starling.core.Starling;
import starling.display.Sprite;
import starling.display.Quad;
import starling.events.Event;

class TestStarling extends Sprite
{
	public function new()
	{
		super();
	}
	
	override public function onAdded():Void
	{
		trace("TestStarling added to stage");
		
		// Create a simple test - add a colored quad
		var quad = new Quad(100, 100, 0xFF0000);
		quad.x = 50;
		quad.y = 50;
		addChild(quad);
		
		trace("Quad added with color: " + quad.color);
	}
}
