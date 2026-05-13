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

package starling.errors;

/**
 * An AbstractMethodError is thrown when a method that has not been implemented is invoked.
 */
class AbstractMethodError extends Error
{
	public function new(message:String = "Abstract method cannot be called")
	{
		super(message);
	}
}
