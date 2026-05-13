// =================================================================================================
//
//	Starling Framework for Heaps - Unit Tests Runner
//	Copyright Gamua GmbH. All Rights Reserved.
//	Ported to Heaps Engine
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

import utest.Runner;
import utest.ui.Report;

import starling.events.EventDispatcherTest;
import starling.display.DisplayObjectTest;
import starling.display.DisplayObjectContainerTest;
import starling.display.QuadTest;
import starling.display.ImageTest;
import starling.textures.TextureTest;
import starling.geom.RectangleTest;
import starling.utils.ColorTest;

class TestRunner
{
	static function main():Void
	{
		var runner = new Runner();
		
		// Event tests
		runner.addCase(new EventDispatcherTest());
		
		// Display tests
		runner.addCase(new DisplayObjectTest());
		runner.addCase(new DisplayObjectContainerTest());
		runner.addCase(new QuadTest());
		runner.addCase(new ImageTest());
		
		// Texture tests
		runner.addCase(new TextureTest());
		
		// Geometry tests
		runner.addCase(new RectangleTest());
		
		// Utility tests
		runner.addCase(new ColorTest());
		
		// Add reports
		new Report(runner);
		
		// Run all tests
		runner.run();
	}
}
