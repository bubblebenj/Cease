/**
 * ...
 * @author dubois benjamin
 */

package ;

import haxe.Timer;
import js.Dom;
import js.JQuery;
import CeaVal;
import CeaMent;

class Cease 
{
	private static function j( _selector : String ) : JQuery
	{
		return new JQuery( _selector );
	}
	
	public	static var document			: JQuery = new JQuery( js.Lib.document );
	public	static var window			: JQuery = new JQuery( cast js.Lib.window );
	public	static var ceaseElements	: List<CeaMent> = new List<CeaMent>();
	private	static var checkTimer		: Timer;
	
	public static function main()
	{		
		Cease.document.ready( function ( _event : JqEvent )
		{
			#if debug
				var l_body	: HtmlDom	= js.Lib.document.getElementsByTagName("body")[0];
					var l_dbgDiv : HtmlDom	= js.Lib.document.createElement( "div" );
					l_dbgDiv.setAttribute("id","debug");
					l_dbgDiv.innerHTML		= "<div id=\"haxe:trace\"></div>";
				l_body.appendChild( l_dbgDiv );
				
				if ( haxe.Firebug.detect() ) haxe.Firebug.redirectTraces(); else trace( "Firebug not detected" );
			#end
			initialize();
		} );
	}
	
	private static var decimalNbRegExp	= ~/(-?[0-9]*\.?[0-9]+)/;
	private static var spaceSeparatorRegExp	= ~/([ \t]+)/;

	
	/**
	 * Gather all cease elements ( CeaMent ),
	 * intialize them,
	 * set listeners when needed
	 */
	public static function initialize() : Void
	{
		trace ( "blop" );
		// gather 
		var l_ceaseElements : JQuery	= j(".cease");
		l_ceaseElements.html( "got it !" );
		l_ceaseElements.each( function() 
		{
			var l_cur					= JQuery.cur;
			//l_cur.css( "position", "absolute" );
			
			var l_str		: String	= l_cur.attr("cease");
			var l_ceaMent	: CeaMent	= new CeaMent( l_cur );
			trace( l_str );
			parseCease( l_str, l_ceaMent );
			trace( l_ceaMent + "" );
			// .Resize( _callback );
			l_ceaMent.updatePos();
			l_ceaMent.updateSize();
			ceaseElements.add( l_ceaMent );
		} );
		checkTimer	= new Timer( 80 );
		checkTimer.run	= checkRefChange;
	}
	
	private static function checkRefChange() : Void
	{
		for ( i_ceaMent in ceaseElements )
		{
			i_ceaMent.update();
		}
	}
	
	private static function parseCease( _string : String, _destElement : CeaMent ) : Void
	{															
		var l_parseStr		= StringTools.trim( _string );				// l_parseStr	= "size:sx sy; pivot : pix piy; position : posx posy"
		if ( StringTools.endsWith( l_parseStr, ";" ) )
			l_parseStr		= l_parseStr.substr( 0, l_parseStr.length - 1);
			
		//!\ What if the string ends with ";" is there an 4th empty string after split ?
		var l_attrStrArray	= StringTools.trim( l_parseStr ).split(";");	// l_attrStrArray = ["size:sx sy", "pivot : pix piy", "position : posx posy"]
		//trace (l_attrStrArray);
		for ( i_attrStr in l_attrStrArray )													// i_attrStr = "AttrName:Valuex Valuey"
		{
			//trace (i_attrStr);
			var l_attrNameAndValueStrArray	= StringTools.trim( i_attrStr ).split(":");		// l_attrNameAndValueStrArray = ["attrName", "Valuex Valuey"]
			//trace (l_attrNameAndValueStrArray);
			var l_attrNameStr 				= StringTools.trim( l_attrNameAndValueStrArray[0] );
			//trace (l_attrNameStr);
			var l_attrValueStr				= StringTools.trim( l_attrNameAndValueStrArray[1] );
			//trace (l_attrValueStr);
			
			switch ( l_attrNameStr )
			{
				case "ref" :
				{
					var l_jQref : REF_predef = switch ( l_attrValueStr )
					{
						case "parent"	: PARENT;
						case "prev"		: PREV;
						case "next"		: NEXT;
						case "document"	: DOCUMENT;
						case "window"	: WINDOW;
						default			: SELECTOR( l_attrValueStr );
					}
					_destElement.setRef( l_jQref );
				}
				case "size", "pivot", "position" :
				{
					var l_xyStrArray				= spaceSeparatorRegExp.split( StringTools.trim( l_attrValueStr ) ); // l_xyStrArray = [ "xvalue", "yValue" ];
					//trace (l_xyStrArray);
					if ( l_xyStrArray.length != 2 )
					{
						trace ( "Attribute \"" + l_attrNameStr + "\" needs 2 parameters : \"x y\"" );
						if ( l_xyStrArray.length == 1 )
						{
							trace ( "optional parameters are not yet supported." );
						}
					}
					var l_xStr						= StringTools.trim( l_xyStrArray[0] );
					//trace (l_xStr);
					var l_yStr						= StringTools.trim( l_xyStrArray[1] );
					//trace (l_yStr);
					
					var l_x : X_predef	= switch( l_xStr )
					{
						case "left"		: LEFT;
						case "center"	: X_predef.CENTER;
						case "right"	: RIGHT;
						default	:
						{
							var l_eReg			= decimalNbRegExp;
							if ( l_eReg.match( l_xStr ) )
							{
								var v	: Float 	= Std.parseFloat( l_eReg.matched(0) );
								var l_unitStr		= l_eReg.matchedRight();
								var unit : E_Unit	= switch( l_unitStr )
								{
									case ""		: RATIO;
									case "%"	: PERCENT;
									case "px"	: PX;
									default		:
									{
										trace( "Invalid unit \"" + l_unitStr + "\" for value \"" + l_xStr + "\". using \"px\" instead." );
										PX;
									}
								}
								X_predef.NB(v, unit);
							}
							else
							{
								trace( "Invalid value \"" + l_xStr + "\" for parameter x of attribute \"" + l_attrNameStr + "\". using \"left\" instead" ); 
								LEFT;
							}
						}
					}
					
					var l_y : Y_predef = switch( l_yStr )
					{
						case "top"		: TOP;
						case "center"	: Y_predef.CENTER;
						case "bottom"	: BOTTOM;
						default	:
						{
							var l_eReg			= decimalNbRegExp;
							if ( l_eReg.match( l_yStr ) )
							{
								var v	: Float 	= Std.parseFloat( l_eReg.matched(0) );
								var l_unitStr		= l_eReg.matchedRight();
								var unit : E_Unit	= switch( l_unitStr )
								{
									case ""		: RATIO;
									case "%"	: PERCENT;
									case "px"	: PX;
									default		:
									{
										trace( "Invalid unit \"" + l_unitStr + "\" for value \"" + l_yStr + "\". using \"px\" instead." );
										PX;
									}
								}
								Y_predef.NB(v, unit);
							}
							else
							{
								trace( "Invalid value \""+l_yStr+"\" for parameter y of attribute \"" + l_attrNameStr + "\". using \"top\" instead" ); 
								TOP;
							}
						}
					}
					switch ( l_attrNameStr )
					{
						case "size"		:
						{
							var validValue : Bool = true;
							switch ( l_x )
							{
								case NB( v, unit ) : {}
								default : {
									validValue	= false;
									trace( "The size.x attribute only accept numerical values" );
								}
							}
							switch ( l_y )
							{
								case NB( v, unit ) : {}
								default : {
									validValue	= false;
									trace( "The size.y attribute only accept numerical values" );
								}
							}
							
							if ( validValue )
								_destElement.setSize( { x : l_x, y : l_y } );
						}
						case "pivot"	:
						{
							_destElement.setPivot( { x : l_x, y : l_y } );
						}
						case "position"	:
						{
							_destElement.setPosition( { x : l_x, y : l_y } );
						}
					}
				}
				default :
				{
					trace( "Invalid attribute name \"" + l_attrNameStr + "\"" );
				}
			}
		}
		// String parsed, checked some stuff
		// Is there a valid ref ? If not using parent as default ref
		if ( _destElement.ref == null )
		{
			_destElement.ref = PARENT;
		}
				
		// Is there a valid size value ? If not using 0 0 as default coordinate
		//if ( _destElement.size == null )
		//{
			//_destElement.set( { x : LEFT, y : TOP } );
		//}
		
		// Is there a valid pivot value ? If not using 0 0 as default coordinate
		if ( _destElement.pivot == null )
		{
			_destElement.pivot.set( { x : LEFT, y : TOP } );
		}
		// Is there a valid position value ? If not using 0 0 as default coordinate
		//if ( _destElement.pos == null )
		//{
			//_destElement.pivot.set( { x : LEFT, y : TOP } );
		//}
		
		
	}
}