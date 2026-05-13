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

package starling.events;

import utest.Test;
import utest.Assert;

class EventDispatcherTest extends Test
{
	var dispatcher:EventDispatcher;
	
	override public function setup():Void
	{
		dispatcher = new EventDispatcher();
	}
	
	override public function tearDown():Void
	{
		dispatcher = null;
	}
	
	public function testAddEventListener():Void
	{
		var listenerCalled = false;
		
		function listener(event:Event):Void
		{
			listenerCalled = true;
		}
		
		dispatcher.addEventListener("test", listener);
		Assert.isTrue(dispatcher.hasEventListener("test"));
		
		dispatcher.dispatchEvent(new Event("test"));
		Assert.isTrue(listenerCalled, "Listener should have been called");
	}
	
	public function testRemoveEventListener():Void
	{
		var listenerCalled = false;
		
		function listener(event:Event):Void
		{
			listenerCalled = true;
		}
		
		dispatcher.addEventListener("test", listener);
		dispatcher.removeEventListener("test", listener);
		
		Assert.isFalse(dispatcher.hasEventListener("test"));
		
		dispatcher.dispatchEvent(new Event("test"));
		Assert.isFalse(listenerCalled, "Listener should not have been called after removal");
	}
	
	public function testRemoveEventListeners():Void
	{
		function listener1(event:Event):Void {}
		function listener2(event:Event):Void {}
		
		dispatcher.addEventListener("test", listener1);
		dispatcher.addEventListener("test", listener2);
		
		Assert.isTrue(dispatcher.hasEventListener("test"));
		
		dispatcher.removeEventListeners("test");
		
		Assert.isFalse(dispatcher.hasEventListener("test"));
	}
	
	public function testRemoveAllEventListeners():Void
	{
		function listener1(event:Event):Void {}
		function listener2(event:Event):Void {}
		
		dispatcher.addEventListener("test1", listener1);
		dispatcher.addEventListener("test2", listener2);
		
		dispatcher.removeEventListeners(null);
		
		Assert.isFalse(dispatcher.hasEventListener("test1"));
		Assert.isFalse(dispatcher.hasEventListener("test2"));
	}
	
	public function testDispatchEvent():Void
	{
		var eventCount = 0;
		
		function listener(event:Event):Void
		{
			eventCount++;
			Assert.equals("test", event.type);
		}
		
		dispatcher.addEventListener("test", listener);
		dispatcher.addEventListener("test", listener);
		
		dispatcher.dispatchEvent(new Event("test"));
		
		Assert.equals(2, eventCount, "Both listeners should have been called");
	}
	
	public function testDispatchEventWithBubbles():Void
	{
		var event = new Event("test", true);
		
		Assert.isTrue(event.bubbles);
		Assert.equals("test", event.type);
	}
	
	public function testStopPropagation():Void
	{
		var firstCalled = false;
		var secondCalled = false;
		
		function firstListener(event:Event):Void
		{
			firstCalled = true;
			event.stopPropagation();
		}
		
		function secondListener(event:Event):Void
		{
			secondCalled = true;
		}
		
		dispatcher.addEventListener("test", firstListener);
		dispatcher.addEventListener("test", secondListener);
		
		dispatcher.dispatchEvent(new Event("test"));
		
		Assert.isTrue(firstCalled);
		Assert.isFalse(secondCalled, "Second listener should not be called after stopPropagation");
	}
	
	public function testStopImmediatePropagation():Void
	{
		var sameListenerCallCount = 0;
		
		function listener(event:Event):Void
		{
			sameListenerCallCount++;
			event.stopImmediatePropagation();
		}
		
		dispatcher.addEventListener("test", listener);
		dispatcher.addEventListener("test", listener);
		
		dispatcher.dispatchEvent(new Event("test"));
		
		Assert.equals(1, sameListenerCallCount, "Listener should only be called once after stopImmediatePropagation");
	}
	
	public function testEventClone():Void
	{
		var originalEvent = new Event("test", true, {data: "test"});
		var clonedEvent = originalEvent.clone();
		
		Assert.equals(originalEvent.type, clonedEvent.type);
		Assert.equals(originalEvent.bubbles, clonedEvent.bubbles);
		Assert.notEquals(originalEvent, clonedEvent, "Clone should be a different instance");
	}
	
	public function testHasEventListener():Void
	{
		Assert.isFalse(dispatcher.hasEventListener("nonexistent"));
		
		function listener(event:Event):Void {}
		dispatcher.addEventListener("test", listener);
		
		Assert.isTrue(dispatcher.hasEventListener("test"));
		Assert.isFalse(dispatcher.hasEventListener("other"));
	}
	
	public function testMultipleEventTypes():Void
	{
		var type1Called = false;
		var type2Called = false;
		
		function listener1(event:Event):Void
		{
			type1Called = true;
		}
		
		function listener2(event:Event):Void
		{
			type2Called = true;
		}
		
		dispatcher.addEventListener("type1", listener1);
		dispatcher.addEventListener("type2", listener2);
		
		dispatcher.dispatchEvent(new Event("type1"));
		
		Assert.isTrue(type1Called);
		Assert.isFalse(type2Called);
		
		dispatcher.dispatchEvent(new Event("type2"));
		Assert.isTrue(type2Called);
	}
}
