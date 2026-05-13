// =================================================================================================
//
//	Starling Framework for Heaps
//	Copyright Gamua GmbH. All Rights Reserved.
//	Ported to Heaps Engine
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.events;

import haxe.ds.StringMap;

/**
 * The EventDispatcher class allows you to dispatch events and listen for them.
 */
class EventDispatcher
{
	var _listeners:StringMap<Array<Event->Void>>;
	
	public function new()
	{
		_listeners = new StringMap();
	}
	
	/**
	 * Registers an event listener at a certain object.
	 */
	public function addEventListener(type:String, listener:Event->Void):Void
	{
		if (_listeners == null)
			_listeners = new StringMap();
		
		if (!_listeners.exists(type))
			_listeners.set(type, []);
		
		var list = _listeners.get(type);
		if (list.indexOf(listener) < 0)
			list.push(listener);
	}
	
	/**
	 * Removes an event listener from the object.
	 */
	public function removeEventListener(type:String, listener:Event->Void):Void
	{
		if (_listeners != null && _listeners.exists(type))
		{
			var list = _listeners.get(type);
			var index = list.indexOf(listener);
			if (index >= 0)
				list.splice(index, 1);
		}
	}
	
	/**
	 * Removes all event listeners with a certain type, or all of them if type is null.
	 */
	public function removeEventListeners(type:String = null):Void
	{
		if (type == null)
			_listeners = new StringMap();
		else if (_listeners != null)
			_listeners.remove(type);
	}
	
	/**
	 * Dispatches an event to all registered listeners.
	 */
	public function dispatchEvent(event:Event):Void
	{
		if (_listeners == null || !_listeners.exists(event.type))
			return;
		
		var list = _listeners.get(event.type);
		if (list == null || list.length == 0)
			return;
		
		// Create a copy to avoid issues when listeners modify the list
		var listenersCopy = list.copy();
		
		for (listener in listenersCopy)
		{
			if (event.isImmediateStopped())
				break;
			
			listener(event);
		}
	}
	
	/**
	 * Checks if there are any listeners registered for a certain event type.
	 */
	public function hasEventListener(type:String):Bool
	{
		return _listeners != null && _listeners.exists(type) && _listeners.get(type).length > 0;
	}
}
