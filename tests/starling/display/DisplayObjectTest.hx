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
import starling.events.Event;

class DisplayObjectTest extends Test
{
	var object:DisplayObject;
	
	override public function setup():Void
	{
		object = new DisplayObject();
	}
	
	override public function tearDown():Void
	{
		object = null;
	}
	
	public function testDefaultValues():Void
	{
		Assert.equals(0.0, object.x);
		Assert.equals(0.0, object.y);
		Assert.equals(0.0, object.width);
		Assert.equals(0.0, object.height);
		Assert.equals(1.0, object.scaleX);
		Assert.equals(1.0, object.scaleY);
		Assert.equals(0.0, object.rotation);
		Assert.equals(1.0, object.alpha);
		Assert.isTrue(object.visible);
		Assert.isTrue(object.touchable);
		Assert.equals("", object.name);
		Assert.isNull(object.parent);
	}
	
	public function testSetPosition():Void
	{
		object.x = 100;
		object.y = 200;
		
		Assert.equals(100, object.x);
		Assert.equals(200, object.y);
	}
	
	public function testSetSize():Void
	{
		object.width = 50;
		object.height = 75;
		
		Assert.equals(50, object.width);
		Assert.equals(75, object.height);
	}
	
	public function testSetScale():Void
	{
		object.scaleX = 2.0;
		object.scaleY = 3.0;
		
		Assert.equals(2.0, object.scaleX);
		Assert.equals(3.0, object.scaleY);
	}
	
	public function testSetRotation():Void
	{
		object.rotation = Math.PI / 2;
		
		Assert.equals(Math.PI / 2, object.rotation);
	}
	
	public function testSetAlpha():Void
	{
		object.alpha = 0.5;
		
		Assert.equals(0.5, object.alpha);
	}
	
	public function testSetVisible():Void
	{
		object.visible = false;
		
		Assert.isFalse(object.visible);
	}
	
	public function testSetTouchable():Void
	{
		object.touchable = false;
		
		Assert.isFalse(object.touchable);
	}
	
	public function testSetName():Void
	{
		object.name = "MyObject";
		
		Assert.equals("MyObject", object.name);
	}
	
	public function testLocalToGlobal():Void
	{
		object.x = 10;
		object.y = 20;
		object.rotation = 0;
		object.scaleX = 1;
		object.scaleY = 1;
		
		var localPoint = {x: 5, y: 5};
		var globalPoint = object.localToGlobal(localPoint);
		
		Assert.equals(15, globalPoint.x);
		Assert.equals(25, globalPoint.y);
	}
	
	public function testGlobalToLocal():Void
	{
		object.x = 10;
		object.y = 20;
		
		var globalPoint = {x: 25, y: 45};
		var localPoint = object.globalToLocal(globalPoint);
		
		Assert.equals(15, localPoint.x);
		Assert.equals(25, localPoint.y);
	}
	
	public function testGetBoundsSelf():Void
	{
		object.width = 100;
		object.height = 50;
		
		var bounds = object.getBounds(object);
		
		Assert.equals(0, bounds.x);
		Assert.equals(0, bounds.y);
		Assert.equals(100, bounds.width);
		Assert.equals(50, bounds.height);
	}
	
	public function testHitTestInside():Void
	{
		object.width = 100;
		object.height = 50;
		
		var point = {x: 50, y: 25};
		
		Assert.isTrue(object.hitTest(point));
	}
	
	public function testHitTestOutside():Void
	{
		object.width = 100;
		object.height = 50;
		
		var point1 = {x: 150, y: 25};
		var point2 = {x: 50, y: 60};
		var point3 = {x: -10, y: 25};
		var point4 = {x: 50, y: -10};
		
		Assert.isFalse(object.hitTest(point1));
		Assert.isFalse(object.hitTest(point2));
		Assert.isFalse(object.hitTest(point3));
		Assert.isFalse(object.hitTest(point4));
	}
	
	public function testHitTestOnEdge():Void
	{
		object.width = 100;
		object.height = 50;
		
		var point1 = {x: 0, y: 0};
		var point2 = {x: 100, y: 50};
		
		Assert.isTrue(object.hitTest(point1));
		Assert.isTrue(object.hitTest(point2));
	}
	
	public function testRemoveFromParent():Void
	{
		var container = new Sprite();
		container.addChild(object);
		
		Assert.notNull(object.parent);
		Assert.equals(1, container.numChildren);
		
		object.removeFromParent();
		
		Assert.isNull(object.parent);
		Assert.equals(0, container.numChildren);
	}
	
	public function testEventDispatching():Void
	{
		var addedCalled = false;
		
		function onAdded(event:Event):Void
		{
			addedCalled = true;
		}
		
		object.addEventListener(Event.ADDED, onAdded);
		object.dispatchEvent(new Event(Event.ADDED));
		
		Assert.isTrue(addedCalled);
	}
}
