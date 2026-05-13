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

class ImageTest extends Test
{
	var image:Image;
	var texture:Texture;
	
	override public function setup():Void
	{
		texture = Texture.empty(100, 50);
		image = new Image(texture);
	}
	
	override public function tearDown():Void
	{
		image = null;
		texture = null;
	}
	
	public function testConstructorWithTexture():Void
	{
		Assert.notNull(image.texture);
		Assert.equals(100, image.width);
		Assert.equals(50, image.height);
	}
	
	public function testConstructorWithoutTexture():Void
	{
		var emptyImage = new Image();
		
		Assert.isNull(emptyImage.texture);
		Assert.equals(0, emptyImage.width);
		Assert.equals(0, emptyImage.height);
	}
	
	public function testSetTexture():Void
	{
		var newTexture = Texture.empty(80, 40);
		image.texture = newTexture;
		
		Assert.equals(newTexture, image.texture);
		Assert.equals(80, image.width);
		Assert.equals(40, image.height);
	}
	
	public function testGetTexture():Void
	{
		Assert.equals(texture, image.texture);
	}
	
	public function testSetSmoothing():Void
	{
		image.smoothing = "bilinear";
		
		Assert.equals("bilinear", image.smoothing);
	}
	
	public function testDefaultSmoothing():Void
	{
		Assert.equals("none", image.smoothing);
	}
	
	public function testInheritsFromQuad():Void
	{
		Assert.isTrue(Std.is(image, Quad));
		Assert.isTrue(Std.is(image, DisplayObject));
	}
	
	public function testSetColor():Void
	{
		image.color = 0xFF0000;
		
		Assert.equals(0xFF0000, image.color);
	}
	
	public function testSetTextureRect():Void
	{
		var rect = {x: 10, y: 10, width: 50, height: 30};
		image.setTextureRect(rect);
		
		// Texture should be changed to SubTexture
		Assert.notNull(image.texture);
	}
	
	public function testResetTextureRect():Void
	{
		// Should not throw
		image.resetTextureRect();
	}
	
	public function testInheritDisplayObjectProperties():Void
	{
		image.x = 50;
		image.y = 25;
		image.rotation = Math.PI / 4;
		
		Assert.equals(50, image.x);
		Assert.equals(25, image.y);
		Assert.equals(Math.PI / 4, image.rotation);
	}
}
