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

package starling.textures;

import utest.Test;
import utest.Assert;

class TextureTest extends Test
{
	var texture:Texture;
	
	override public function setup():Void
	{
		texture = Texture.empty(100, 50);
	}
	
	override public function tearDown():Void
	{
		texture = null;
	}
	
	public function testEmptyTexture():Void
	{
		Assert.notNull(texture);
		Assert.equals(100, texture.width);
		Assert.equals(50, texture.height);
		Assert.equals(1.0, texture.scale);
	}
	
	public function testFromColor():Void
	{
		var colorTexture = Texture.fromColor(0xFF0000, 80, 60);
		
		Assert.notNull(colorTexture);
		Assert.equals(80, colorTexture.width);
		Assert.equals(60, colorTexture.height);
	}
	
	public function testSubTexture():Void
	{
		var rect = {x: 10, y: 10, width: 50, height: 30};
		var subTexture = texture.subTexture(rect);
		
		Assert.notNull(subTexture);
		Assert.notNull(subTexture.base);
	}
	
	public function testDispose():Void
	{
		// Should not throw
		texture.dispose();
	}
	
	public function testScaleProperty():Void
	{
		// Scale is read-only in base class, but should default to 1.0
		Assert.equals(1.0, texture.scale);
	}
	
	public function testWidthHeightProperties():Void
	{
		Assert.isTrue(texture.width > 0);
		Assert.isTrue(texture.height > 0);
	}
}
