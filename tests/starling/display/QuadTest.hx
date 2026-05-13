// =================================================================================================
//
//	Starling Framework for Heaps - Unit Tests
//	Copyright Gamua GmbH. All Rights Reserved.
//	Ported to Heaps Engine
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.display;

import utest.Test;
import utest.Assert;
import starling.textures.Texture;

class QuadTest extends Test
{
	var quad:Quad;
	
	override public function setup():Void
	{
		quad = new Quad(100, 50);
	}
	
	override public function tearDown():Void
	{
		quad = null;
	}
	
	public function testConstructor():Void
	{
		Assert.equals(100, quad.width);
		Assert.equals(50, quad.height);
		Assert.equals(0xFFFFFF, quad.color);
	}
	
	public function testConstructorWithColor():Void
	{
		var coloredQuad = new Quad(100, 50, 0xFF0000);
		
		Assert.equals(100, coloredQuad.width);
		Assert.equals(50, coloredQuad.height);
		Assert.equals(0xFF0000, coloredQuad.color);
	}
	
	public function testSetColor():Void
	{
		quad.color = 0x00FF00;
		
		Assert.equals(0x00FF00, quad.color);
	}
	
	public function testGetColor():Void
	{
		var color = quad.color;
		
		Assert.equals(0xFFFFFF, color);
	}
	
	public function testInheritsFromDisplayObject():Void
	{
		Assert.isTrue(Std.is(quad, DisplayObject));
		Assert.equals(0, quad.x);
		Assert.equals(0, quad.y);
		Assert.equals(1, quad.scaleX);
		Assert.equals(1, quad.scaleY);
	}
	
	public function testDispose():Void
	{
		// Should not throw
		quad.dispose();
		
		// Can still access properties after dispose
		Assert.equals(100, quad.width);
	}
}
