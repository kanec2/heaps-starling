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

class DisplayObjectContainerTest extends Test
{
	var container:DisplayObjectContainer;
	var child1:DisplayObject;
	var child2:DisplayObject;
	
	override public function setup():Void
	{
		container = new DisplayObjectContainer();
		child1 = new DisplayObject();
		child2 = new DisplayObject();
	}
	
	override public function tearDown():Void
	{
		container = null;
		child1 = null;
		child2 = null;
	}
	
	public function testDefaultValues():Void
	{
		Assert.equals(0, container.numChildren);
	}
	
	public function testAddChild():Void
	{
		container.addChild(child1);
		
		Assert.equals(1, container.numChildren);
		Assert.notNull(child1.parent);
		Assert.isTrue(container.contains(child1));
	}
	
	public function testAddChildDispatchesEvent():Void
	{
		var addedCalled = false;
		
		function onAdded(event:Event):Void
		{
			addedCalled = true;
		}
		
		child1.addEventListener(Event.ADDED, onAdded);
		container.addChild(child1);
		
		Assert.isTrue(addedCalled);
	}
	
	public function testAddChildAt():Void
	{
		container.addChild(child1);
		container.addChildAt(child2, 0);
		
		Assert.equals(2, container.numChildren);
		Assert.equals(child2, container.getChildAt(0));
		Assert.equals(child1, container.getChildAt(1));
	}
	
	public function testAddChildAtInvalidIndex():Void
	{
		Assert.raises(function() container.addChildAt(child1, -1));
		Assert.raises(function() container.addChildAt(child1, 1));
	}
	
	public function testRemoveChild():Void
	{
		container.addChild(child1);
		container.removeChild(child1);
		
		Assert.equals(0, container.numChildren);
		Assert.isNull(child1.parent);
		Assert.isFalse(container.contains(child1));
	}
	
	public function testRemoveChildDispatchesEvent():Void
	{
		var removedCalled = false;
		
		function onRemoved(event:Event):Void
		{
			removedCalled = true;
		}
		
		child1.addEventListener(Event.REMOVED, onRemoved);
		container.addChild(child1);
		container.removeChild(child1);
		
		Assert.isTrue(removedCalled);
	}
	
	public function testRemoveChildAt():Void
	{
		container.addChild(child1);
		container.addChild(child2);
		
		container.removeChildAt(0);
		
		Assert.equals(1, container.numChildren);
		Assert.equals(child2, container.getChildAt(0));
	}
	
	public function testRemoveChildren():Void
	{
		container.addChild(child1);
		container.addChild(child2);
		
		container.removeChildren();
		
		Assert.equals(0, container.numChildren);
	}
	
	public function testGetChildIndex():Void
	{
		container.addChild(child1);
		container.addChild(child2);
		
		Assert.equals(0, container.getChildIndex(child1));
		Assert.equals(1, container.getChildIndex(child2));
	}
	
	public function testSetChildIndex():Void
	{
		container.addChild(child1);
		container.addChild(child2);
		
		container.setChildIndex(child1, 1);
		
		Assert.equals(1, container.getChildIndex(child1));
		Assert.equals(0, container.getChildIndex(child2));
	}
	
	public function testSwapChildren():Void
	{
		container.addChild(child1);
		container.addChild(child2);
		
		container.swapChildren(child1, child2);
		
		Assert.equals(1, container.getChildIndex(child1));
		Assert.equals(0, container.getChildIndex(child2));
	}
	
	public function testSwapChildrenAt():Void
	{
		container.addChild(child1);
		container.addChild(child2);
		
		container.swapChildrenAt(0, 1);
		
		Assert.equals(1, container.getChildIndex(child1));
		Assert.equals(0, container.getChildIndex(child2));
	}
	
	public function testContains():Void
	{
		container.addChild(child1);
		
		Assert.isTrue(container.contains(child1));
		Assert.isFalse(container.contains(child2));
	}
	
	public function testGetChildAt():Void
	{
		container.addChild(child1);
		
		Assert.equals(child1, container.getChildAt(0));
	}
	
	public function testGetChildAtInvalidIndex():Void
	{
		Assert.raises(function() container.getChildAt(-1));
		Assert.raises(function() container.getChildAt(0));
	}
	
	public function testRemoveFromParent():Void
	{
		var parent = new DisplayObjectContainer();
		parent.addChild(container);
		container.addChild(child1);
		
		child1.removeFromParent();
		
		Assert.equals(1, container.numChildren);
		Assert.isNull(child1.parent);
	}
	
	public function testAddChildRemovesFromPreviousParent():Void
	{
		var parent1 = new DisplayObjectContainer();
		var parent2 = new DisplayObjectContainer();
		
		parent1.addChild(child1);
		parent2.addChild(child1);
		
		Assert.equals(0, parent1.numChildren);
		Assert.equals(1, parent2.numChildren);
		Assert.equals(parent2, child1.parent);
	}
	
	public function testNumChildrenUpdates():Void
	{
		Assert.equals(0, container.numChildren);
		
		container.addChild(child1);
		Assert.equals(1, container.numChildren);
		
		container.addChild(child2);
		Assert.equals(2, container.numChildren);
		
		container.removeChild(child1);
		Assert.equals(1, container.numChildren);
	}
}
