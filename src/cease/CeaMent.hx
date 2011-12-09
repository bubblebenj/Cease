/**
 * ...
 * @author dubois benjamin
 */
package cease;

import js.JQuery;
import cease.CeaVal;

enum CeaAttr {
	SIZE;
	PIVOT;
	POSITION;
}

enum REF_predef
{
	PARENT;
	PREV;
	NEXT;
	DOCUMENT;
	WINDOW;
	SELECTOR( s : String );
}

class CeaMent
{
	public	var target			: JQuery;
	private	var jQref			: JQuery;
	
	private	var m_prevRefSize	: PxCoord;	// for change handling
	private	var m_prevRefPos	: PxCoord;	// for change handling
	
	public	var ref			: REF_predef;
	// size of the object
	public	var	size		: CeaVal;
	// position of the reference point (in the object) to handle the object
	public	var	pivot		: CeaVal;
	// position of the pivot against the ref object pivot or TL (depends of the unit)
	public	var	pos			: CeaVal;
	
	
	public function new( _jQelement : JQuery ) : Void
	{
		size		= null;
		pivot		= null;
		pos			= null;
		target	= _jQelement;
		ref		= null; // What if the parent is the document or the window ?
		m_prevRefSize	= { x : 0, y : 0 };
		m_prevRefPos	= { x : 0, y : 0 };
	}
	
	public function getjQ() : JQuery
	{
		return target;
	}
	
	public function setRef( _ref : REF_predef ) : Void
	{
		ref		= _ref;
		var	l_selectorStr : String = "";
		var l_jQref	= switch ( ref )
		{
			case WINDOW			: Cease.window;
			case DOCUMENT		: Cease.document;
			case PARENT			: getjQ().parent();
			case PREV			: getjQ().prev();
			case NEXT			: getjQ().next();
			case SELECTOR( s )	: { l_selectorStr = s; new JQuery( s ); }
		}
		jQref	= l_jQref;
		
		if ( l_jQref.size() != 1 )
		{
			if ( ref != PARENT )
			{
				if ( l_jQref.size() == 0 )
				{
					trace ( "Invalid value \""+ ref +"\" for attribute \"ref\"" ); 
				}
				else
				{
					trace ( "Invalid number of matched element with selector \""+ l_selectorStr +"\" for attribute \"ref\"" ); 
					trace ( "Multiple ref is not yet supported, your css selector should match one unique element" ); 
				}
				trace( "Using parent as ref instead." );
				setRef( PARENT );
			}
			else // no parent element (don't know if it happens)
			{
				trace ( "This element doesn't have a parent. Using document instead." );
				setRef( DOCUMENT );
			}
		}
	}
	
	public function setSize( _value : { x : X_predef, y : Y_predef } ) : Void
	{
		if ( size == null )
		{
			size = new CeaVal();
		}
		size.set( _value );
	}
	
	public function setPivot( _value : { x : X_predef, y : Y_predef } ) : Void
	{
		if ( pivot == null )
		{
			pivot = new CeaVal();
		}
		pivot.set( _value );
	}
	
	public function setPosition( _value : { x : X_predef, y : Y_predef } ) : Void
	{
		if ( pos == null )
		{
			pos = new CeaVal();
		}
		pos.set( _value );
	}
		
	public function isParentResized() : Bool
	{
		var l_refSize	= getSize( ref );
		//trace ( m_prevRefSize.x+", " +m_prevRefSize.y + " =? " + l_refSize.x +", " + l_refSize.y );
		return ( m_prevRefSize.x != l_refSize.x || m_prevRefSize.y != l_refSize.y );
	}
	
	public function update() : Void
	{
		if ( isParentResized() )
		{
			if ( !updateSize() ) // Update size also update position.
			{
				updatePos();
			}
			//m_prevRefSize	= getSize( ref );
		}
	}
	
	/**
	 * Update jQelement size using computed l_pos.x and l_pos.y.
	 * 
	 * @return true if size updated, else false
	 */
	public function updateSize() : Bool
	{
		if ( size != null )
		{
			var l_coord : PxCoord;
			l_coord	= getPx( SIZE );
			target.width( l_coord.x );
			target.height( l_coord.y );
			
			// At last position should be computed
			//trace ( "new Size : " + size );
			updatePos();
			return true;
		}
		else
		{
			return false;
		}
	}
	
	/**
	 * Update jQelement offset using computed l_pos.x and l_pos.y.
	 * 
	 * @return true if position updated, else false
	 */
	public function updatePos() : Bool
	{
		if ( pos != null )
		{
			var l_offset	: PxCoord;
			
			var l_refOffset	: PxCoord;
			var l_eltPivot	: PxCoord;
			var l_eltPos	: PxCoord;
			
			l_refOffset	= getOffset( ref );
			l_eltPivot	= getPx( PIVOT );
			l_eltPos	= getPx( POSITION );
			l_offset	= { x : l_refOffset.x + l_eltPos.x - l_eltPivot.x,
							y : l_refOffset.y + l_eltPos.y - l_eltPivot.y };
			target.offset( { top : l_offset.y, left : l_offset.x } );
			//trace ( "new position : " + pos );
			return true;
		}
		else
		{
			return false;
		}
	}
	
	public function getPx( _attr : CeaAttr ) : PxCoord
	{
		var _coord : PxCoord;
		_coord	= getPxValues( _attr );
		
		//trace( _attr + " : " + _coord.x +"px "+_coord.y+"px" );
		return _coord;
	}
	
	public function getOffset( _ref : REF_predef ) : PxCoord
	{
		var _offset : PxCoord;
		_offset = switch ( _ref )
		{
			case WINDOW, DOCUMENT :		{ x : 0, y : 0 };
			case PARENT, PREV, NEXT	:	{ x : jQref.offset().left, y : jQref.offset().top };
			case SELECTOR( s ) :		{ x : jQref.offset().left, y : jQref.offset().top };
		}
		return _offset;
	}
	
	public function getSize( _ref ) : PxCoord
	{
		var _size : PxCoord;
		_size = switch ( _ref )
		{
			default	: { x : jQref.width(), y : jQref.height() };
		}
		return _size;
	}
	
	public function getPxValues( _attr : CeaAttr ) : PxCoord
	{
		return { x : xToPixels( _attr ), y : yToPixels( _attr ) };
	}
	
	public	function xToPixels( _attr : CeaAttr )	: Int
	{
		var _rValue		: Int;
		var l_ceaVal	: CeaVal;
		var l_ref		: JQuery; 
		switch ( _attr )
		{
			case SIZE		:
			{
				l_ceaVal	= size;
				l_ref		= jQref;
			}
			case PIVOT		:
			{
				l_ceaVal	= pivot;
				l_ref		= target; // Pivot position is relative to the element itself
			}
			case POSITION	:
			{
				l_ceaVal	= pos;
				l_ref		= jQref;
			}
		}
		//trace ( "val : " + l_ceaVal +" ref : " + l_ref );
		
		var l_unit		: E_Unit;
		var l_rawValue	: Float;
		switch( l_ceaVal.x )
		{
			case LEFT	:
			{
				l_unit		= RATIO;
				l_rawValue	= 0.0;
			}
			case CENTER	:
			{
				l_unit		= RATIO;
				l_rawValue	= 0.5;
			}
			case RIGHT	:
			{
				l_unit		= RATIO;
				l_rawValue	= 1.0;
			}
			case NB(v, unit) :
			{
				l_unit		= unit;
				l_rawValue	= switch (unit)
				{
					case RATIO 		: v;
					case PERCENT	: v * 0.01;
					case PX			: v;
				}
			}
		}
		
		_rValue = Std.int( ( l_unit == PX ) ? l_rawValue : l_rawValue * l_ref.width() );
		return _rValue;
	}
	
	public	function yToPixels( _attr : CeaAttr )	: Int
	{
		var _rValue		: Int;
		var l_ceaVal	: CeaVal;
		var l_ref		: JQuery; 
		switch ( _attr )
		{
			case SIZE		:
			{
				l_ceaVal	= size;
				l_ref		= jQref;
			}
			case PIVOT		:
			{
				l_ceaVal	= pivot;
				l_ref		= target; // Pivot position is relative to the element itself
			}

			case POSITION	:
			{
				l_ceaVal	= pos;
				l_ref		= jQref;
			}
		}
		
		var l_unit		: E_Unit;
		var l_rawValue	: Float;
		switch( l_ceaVal.y )
		{
			case TOP	:
			{
				l_unit		= RATIO;
				l_rawValue	= 0.0;
			}
			case CENTER	:
			{
				l_unit		= RATIO;
				l_rawValue	= 0.5;
			}
			case BOTTOM	:
			{
				l_unit		= RATIO;
				l_rawValue	= 1.0;
			}
			case NB(v, unit) :
			{
				l_unit		= unit;
				l_rawValue	= switch (unit)
				{
					case RATIO 		: v;
					case PERCENT	: v * 0.01;
					case PX			: v;
				}
			}
		}
		
		_rValue = Std.int( ( l_unit == PX ) ? l_rawValue : l_rawValue * l_ref.height() );
		return _rValue;
	}
	
	public function toString() : String
	{
		return "{ target : " + target + ", ref : " + ref + ", size : " + size + ", pivot : " + pivot + ", position : " + pos +" }";
	}
}