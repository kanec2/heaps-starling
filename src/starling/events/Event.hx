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

/**
 * The Event class allows you to create objects that are passed up and down the display list.
 */


/**
 * Событие в стиле Starling для совместимости.
 */
 @:keep
class Event {
	
	// === Стандартные типы событий ===
	@:isVar public static var CANCELLED(get, never):String;
	private static inline function get_CANCELLED():String return "cancelled";
	
	@:isVar public static var CHANGE(get, never):String;
	private static inline function get_CHANGE():String return "change";
	
	@:isVar public static var CONTEXT3D_CREATE(get, never):String;
	private static inline function get_CONTEXT3D_CREATE():String return "context3d_create";
	
	@:isVar public static var ENTER_FRAME(get, never):String;
	private static inline function get_ENTER_FRAME():String return "enter_frame";
	
	@:isVar public static var RESIZE(get, never):String;
	private static inline function get_RESIZE():String return "resize";
	
	// === Свойства события ===
	
	/** Тип события */
	@:isVar public var type(get, never):String;
	private var _type:String;
	private inline function get_type():String return _type;
	
	/** Целевой объект */
	@:isVar public var target(get, set):Dynamic;
	private var _target:Dynamic;
	private inline function get_target():Dynamic return _target;
	private inline function set_target(v:Dynamic):Dynamic {
		_target = v;
		return v;
	}
	
	/** Координаты (для событий ввода) */
	@:isVar public var x(get, set):Float;
	private var _x:Float = 0;
	private inline function get_x():Float return _x;
	private inline function set_x(v:Float):Float { _x = v; return v; }
	
	@:isVar public var y(get, set):Float;
	private var _y:Float = 0;
	private inline function get_y():Float return _y;
	private inline function set_y(v:Float):Float { _y = v; return v; }
	
	/** Дополнительные данные */
	@:isVar public var data(get, set):Dynamic;
	private var _data:Dynamic;
	private inline function get_data():Dynamic return _data;
	private inline function set_data(v:Dynamic):Dynamic { _data = v; return v; }
	
	/** Флаг отмены события */
	@:isVar public var isDefaultPrevented(get, never):Bool;
	private var _prevented:Bool = false;
	private inline function get_isDefaultPrevented():Bool return _prevented;
	
	/**
	 * Создаёт новое событие.
	 */
	@:overload(function(type:String):Void {})
	public function new(type:String, x:Float = 0, y:Float = 0, 
	                   ?data:Dynamic, ?button:Null<Int>) {
		_type = type;
		_x = x;
		_y = y;
		_data = data;
	}
	
	/**
	 * Предотвращает выполнение действия по умолчанию.
	 */
	@:noCompletion
	public function preventDefault():Void {
		_prevented = true;
	}
	
	/**
	 * Создаёт копию события.
	 */
	@:noCompletion
	public function clone():Event {
		return new Event(_type, _x, _y, _data);
	}
	
	/**
	 * Строковое представление.
	 */
	@:noCompletion
	public function toString():String {
		return '[Event type="${_type}" x=${_x} y=${_y}]';
	}
}