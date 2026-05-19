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

import hxd.Event;

/**
 * Простой диспетчер событий в стиле Starling.
 */
class EventDispatcher {
	
	private var _listeners:Map<String, Array<Listener>> = new Map();
	
	public function new() {}
	
	public function addEventListener(type:String, listener:Dynamic->Void, 
	                                 useCapture:Bool = false, priority:Int = 0):Void {
		if (!_listeners.exists(type)) {
			_listeners.set(type, []);
		}
		_listeners.get(type).push({
			listener: listener,
			priority: priority,
			useCapture: useCapture
		});
		// Сортируем по приоритету
		_listeners.get(type).sort((a, b) -> b.priority - a.priority);
	}
	
	public function removeEventListener(type:String, listener:Dynamic->Void, 
	                                    useCapture:Bool = false):Void {
		if (!_listeners.exists(type)) return;
		
		var list = _listeners.get(type);
		for (i in 0...list.length) {
			if (list[i].listener == listener && list[i].useCapture == useCapture) {
				list.splice(i, 1);
				break;
			}
		}
	}
	
	public function dispatchEvent(event:Event):Bool {
		if (!_listeners.exists(event.type)) return false;
		
		for (entry in _listeners.get(event.type)) {
			entry.listener(event);
		}
		return true;
	}
	
	public function hasEventListener(type:String):Bool {
		return _listeners.exists(type) && _listeners.get(type).length > 0;
	}
	
	public function removeAllListeners(?type:String):Void {
		if (type != null) {
			_listeners.remove(type);
		} else {
			_listeners = new Map();
		}
	}
	
	private typedef Listener = {
		var listener:Dynamic->Void;
		var priority:Int;
		var useCapture:Bool;
	}
}