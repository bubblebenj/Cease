/**
 * ...
 * @author dubois benjamin
 */
package cease;

import js.JQuery;

enum E_Unit
{
	RATIO;
	PX;
	PERCENT;
	//EM;
} 
 
enum X_predef
{
	//UNDEFINED;
	LEFT;
	CENTER;
	RIGHT;
	NB( v : Float, unit : E_Unit );
}

enum Y_predef
{
	//UNDEFINED;
	TOP;
	CENTER;
	BOTTOM;
	NB( v : Float, unit : E_Unit );
}

typedef PxCoord =
{
	var x	: Int;
	var y	: Int;
}

class CeaVal 
{
	public	var x ( getX, setX )	: X_predef;
	public	var y ( getY, setY )	: Y_predef;
	
	public function new() : Void
	{
		
	}
	
	// Getter / Setter
	private	function getX()							: X_predef	{ return x; }
	private	function setX( _value : X_predef )		: X_predef	{ x = _value;	return x; }
	
	private function getY()							: Y_predef		{ return y; }
	private	function setY( _value : Y_predef )		: Y_predef	{ y = _value;	return y; }
	
	public function set( _value : { x : X_predef, y : Y_predef } ) : Void
	{
		x = _value.x;
		y = _value.y;
	}
	
	public function toString() : String
	{
		return "{ x : " + x + ", y : " + y + " }";
	}
}