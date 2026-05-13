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

package starling.utils;

import utest.Test;
import utest.Assert;

class ColorTest extends Test
{
	override public function setup():Void
	{
	}
	
	override public function tearDown():Void
	{
	}
	
	public function testRgbRed():Void
	{
		var hex = Color.rgb(255, 0, 0);
		
		Assert.equals(0xFF0000, hex);
	}
	
	public function testRgbGreen():Void
	{
		var hex = Color.rgb(0, 255, 0);
		
		Assert.equals(0x00FF00, hex);
	}
	
	public function testRgbBlue():Void
	{
		var hex = Color.rgb(0, 0, 255);
		
		Assert.equals(0x0000FF, hex);
	}
	
	public function testRgbWhite():Void
	{
		var hex = Color.rgb(255, 255, 255);
		
		Assert.equals(0xFFFFFF, hex);
	}
	
	public function testRgbBlack():Void
	{
		var hex = Color.rgb(0, 0, 0);
		
		Assert.equals(0x000000, hex);
	}
	
	public function testRgba():Void
	{
		var hex = Color.rgba(255, 0, 0, 128);
		
		Assert.equals(0x80FF0000, hex);
	}
	
	public function testGetRed():Void
	{
		Assert.equals(255, Color.getRed(0xFF0000));
		Assert.equals(0, Color.getRed(0x00FF00));
		Assert.equals(0, Color.getRed(0x0000FF));
	}
	
	public function testGetGreen():Void
	{
		Assert.equals(0, Color.getGreen(0xFF0000));
		Assert.equals(255, Color.getGreen(0x00FF00));
		Assert.equals(0, Color.getGreen(0x0000FF));
	}
	
	public function testGetBlue():Void
	{
		Assert.equals(0, Color.getBlue(0xFF0000));
		Assert.equals(0, Color.getBlue(0x00FF00));
		Assert.equals(255, Color.getBlue(0x0000FF));
	}
	
	public function testGetAlpha():Void
	{
		Assert.equals(255, Color.getAlpha(0xFFFFFFFF));
		Assert.equals(0, Color.getAlpha(0x00FFFFFF));
		Assert.equals(128, Color.getAlpha(0x80FFFFFF));
	}
	
	public function testColorConstants():Void
	{
		Assert.equals(0xFFFFFF, Color.WHITE);
		Assert.equals(0x000000, Color.BLACK);
		Assert.equals(0xFF0000, Color.RED);
		Assert.equals(0x00FF00, Color.GREEN);
		Assert.equals(0x0000FF, Color.BLUE);
	}
	
	public function testMixedColor():Void
	{
		var hex = Color.rgb(128, 64, 32);
		
		Assert.equals(128, Color.getRed(hex));
		Assert.equals(64, Color.getGreen(hex));
		Assert.equals(32, Color.getBlue(hex));
	}
}
