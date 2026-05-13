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

package starling.geom;

import utest.Test;
import utest.Assert;

class RectangleTest extends Test
{
	var rect:Rectangle;
	
	override public function setup():Void
	{
		rect = new Rectangle(10, 20, 100, 50);
	}
	
	override public function tearDown():Void
	{
		rect = null;
	}
	
	public function testConstructor():Void
	{
		Assert.equals(10, rect.x);
		Assert.equals(20, rect.y);
		Assert.equals(100, rect.width);
		Assert.equals(50, rect.height);
	}
	
	public function testDefaultConstructor():Void
	{
		var defaultRect = new Rectangle();
		
		Assert.equals(0, defaultRect.x);
		Assert.equals(0, defaultRect.y);
		Assert.equals(0, defaultRect.width);
		Assert.equals(0, defaultRect.height);
	}
	
	public function testRight():Void
	{
		Assert.equals(110, rect.right);
	}
	
	public function testBottom():Void
	{
		Assert.equals(70, rect.bottom);
	}
	
	public function testSetX():Void
	{
		rect.x = 50;
		
		Assert.equals(50, rect.x);
	}
	
	public function testSetY():Void
	{
		rect.y = 100;
		
		Assert.equals(100, rect.y);
	}
	
	public function testSetWidth():Void
	{
		rect.width = 200;
		
		Assert.equals(200, rect.width);
	}
	
	public function testSetHeight():Void
	{
		rect.height = 80;
		
		Assert.equals(80, rect.height);
	}
	
	public function testContainsPoint():Void
	{
		Assert.isTrue(rect.containsPoint(50, 40));
		Assert.isFalse(rect.containsPoint(200, 200));
	}
	
	public function testIntersects():Void
	{
		var intersectingRect = new Rectangle(80, 30, 50, 30);
		var nonIntersectingRect = new Rectangle(200, 200, 50, 50);
		
		Assert.isTrue(rect.intersects(intersectingRect));
		Assert.isFalse(rect.intersects(nonIntersectingRect));
	}
	
	public function testIntersection():Void
	{
		var otherRect = new Rectangle(80, 30, 50, 30);
		var intersection = rect.intersection(otherRect);
		
		Assert.equals(80, intersection.x);
		Assert.equals(30, intersection.y);
		Assert.equals(30, intersection.width);
		Assert.equals(20, intersection.height);
	}
	
	public function testClone():Void
	{
		var clone = rect.clone();
		
		Assert.equals(rect.x, clone.x);
		Assert.equals(rect.y, clone.y);
		Assert.equals(rect.width, clone.width);
		Assert.equals(rect.height, clone.height);
		Assert.notEquals(rect, clone);
	}
	
	public function testSetTo():Void
	{
		rect.setTo(5, 10, 80, 40);
		
		Assert.equals(5, rect.x);
		Assert.equals(10, rect.y);
		Assert.equals(80, rect.width);
		Assert.equals(40, rect.height);
	}
	
	public function testToString():Void
	{
		var str = rect.toString();
		
		Assert.isTrue(str.indexOf("10") >= 0);
		Assert.isTrue(str.indexOf("20") >= 0);
		Assert.isTrue(str.indexOf("100") >= 0);
		Assert.isTrue(str.indexOf("50") >= 0);
	}
	
	public function testLeftAndTop():Void
	{
		Assert.equals(10, rect.left);
		Assert.equals(20, rect.top);
		
		rect.left = 15;
		Assert.equals(15, rect.x);
		
		rect.top = 25;
		Assert.equals(25, rect.y);
	}
}
