package ;

/**
 * ...
 * @author bdubois
 */
import js.JQuery;
import math.CV2D;
import math.Registers;
import CTypes;

enum X
{
	LEFT;
	CENTER;
	RIGHT;
	INT( v : Int );
	FLOAT( v : Float );
}

enum Y
{
	TOP;
	CENTER;
	BOTTOM;
	INT( v : Int );
	FLOAT( v : Float );
}

enum E_Unit
{
	RATIO;
	PX;
	PERCENTAGE;
}

class Coordinate
{
	private var m_V2D				: CV2D;
	public	var x ( getX, never )	: Float;
	public	var y ( getY, never )	: Float;
	public	var unit				: E_Unit;
	
	private function getX() : Float
	{
		return m_V2D.x;
	}
	
	private function getY() : Float
	{
		return m_V2D.y;
	}
	
	public static function toCV2D( _x : X, _y : Y ) : CV2D
	{
		return new CV2D( 0, 0 );
	}
}




class C2DInterface
{
	private var m_2DObject	: C2DQuad;
	private var m_RefObj	: C2DQuad;
	
	public function new( _Object : C2DQuad, ?_RefObj : C2DQuad ) 
	{
		Set2DObject( _Object );
		m_WaitObjSize		= false;
		m_WaitRefObjSize	= false;
		
		if ( _RefObj == null )
		{
			m_RefObj		= null;
		}
		else
		{
			SetRefObj( _RefObj );
			//m_Parent.AddElement( m_2DObject );
		}
	}
	
	public function Set2DObject( _Object : C2DQuad )
	{
		m_2DObject = _Object;
	}
	
	public function Get2DObject() : C2DQuad
	{
		return m_2DObject;
	}
	
	public function SetRefObj( _RefObj : C2DQuad )
	{
		m_RefObj = _RefObj;
	}
	
	public function GetRefObj() : C2DQuad
	{
		return m_RefObj;
	}
	
	private function getWindowSize() : CV2D
	{
		var r_CV2D : CV2D = new CV2D( 0, 0 );
		//r_CV2D.x	= js.Document.
		return r_CV2D;
	}
	
	public function SetEltSize( _xy : Coordinate ) : Void
	{
		var l_x 			: Float;
		var l_y 			: Float;
		
		var l_Size			: CV2D	= new CV2D( _xy.x, _xy.y );
		var l_NewSize		: CV2D	= new CV2D( 0, 0 );
		
		var l_RefObjSize	: CV2D	= new CV2D( 0, 0 );
		if ( m_RefObj == null )
		{
			//l_RefObjSize.Set( Glb.GetSystem().m_Display.GetAspectRatio(), 1 );
		}
		else
		{
			l_RefObjSize.Copy( m_RefObj.GetSize() );
		}
		
		
		// Converting percentage to ratio ( between 0 and 1 )
		if ( _Unit == PERCENTAGE )
		{
			l_Size.Set(	_Size.x * 0.01,
						_Size.y * 0.01 );
			_Unit = RATIO;
		}
		
		// Converting ratio to pixels
		if ( _Unit == RATIO )
		{
			/*\ if element size is (0, 0) will wait to fit parent size (keeping image ratio) */
			if ( CV2D.AreAbsEqual( l_Size, CV2D.ZERO ) &&  CV2D.AreAbsEqual( m_2DObject.GetSize(), CV2D.ZERO ) )
			{
				m_WaitObjSize = true;
				return;
			}
			else
			{
				if ( CV2D.AreAbsEqual( l_Size, CV2D.ZERO ) )	// fit inside parent keeping image ratio
				{
					var l_ImgRatio	= m_2DObject.GetSize().x / m_2DObject.GetSize().y;
					if ( l_RefObjSize.x / l_RefObjSize.y > l_ImgRatio ) // Fit to parent height
					{
						l_Size.Set(	l_RefObjSize.y * l_ImgRatio,	l_RefObjSize.y );
					}
					else															// Fit to parent width
					{
						l_Size.Set(	l_RefObjSize.x,					l_RefObjSize.y / l_ImgRatio );
					}
				}
				else	
				{
					l_Size.Set(	l_Size.x * l_RefObjSize.x,
								l_Size.y * l_RefObjSize.y );
				}
			}
			// convert parent ratio to pixels
			l_Size.Set(	l_Size.x * Glb.GetSystem().m_Display.m_Height ,
						l_Size.y * Glb.GetSystem().m_Display.m_Height );
		}
		
		m_WaitObjSize = false;
		// Now size is in pixels (if not already)
		if ( CV2D.AreAbsEqual( m_2DObject.GetSize(), CV2D.ZERO ) )
		{
			l_NewSize.Copy( l_Size );
		}
		else
		{
			// X
			if (l_Size.x == 0 )
			{
				if ( m_2DObject.GetSize().x == 0 )		{	l_x = 0; }	
				else
				{	if ( m_2DObject.GetSize().y == 0 )	{	l_x = m_2DObject.GetSize().x * l_Size.y / m_2DObject.GetSize().y;	}
				
					else					{	l_x = m_2DObject.GetSize().x;	}
				}	
			}else							{	l_x = l_Size.x;	}
			//
			// Y
			if ( l_Size.y == 0 )
			{
				if ( m_2DObject.GetSize().y == 0 )		{	l_y = 0; }	
				else
				{	if ( m_2DObject.GetSize().x == 0 )	{	l_y = m_2DObject.GetSize().y * l_Size.x / m_2DObject.GetSize().x;	}
					
					else					{	l_y = m_2DObject.GetSize().y;	}
				}
			}else							{	l_y = l_Size.y;	}
			//
			l_NewSize.Set( l_x, l_y );
		}
		l_NewSize.Set(	l_NewSize.x / Glb.GetSystem().m_Display.m_Height,
						l_NewSize.y / Glb.GetSystem().m_Display.m_Height );
		m_2DObject.SetSize( l_NewSize );
	}
	
	public function SetEltPivot( _coordinate : Coordinate ) : Void
	{
		var l_Pos : CV2D = new CV2D( 0, 0 );
		switch ( _Type )
		{
			case CENTER	: l_Pos.Set( 0.5, 0.5 );
			case TL		: l_Pos.Set( 0  , 0   );
			case CUSTOM	: l_Pos.Copy( _Pos );
		}
		m_2DObject.SetPivot( l_Pos );
	}
	
	public function SetEltPos( _Unit : E_Unit, _Pos : CV2D, ?_UseParentPivotAsRef : Bool = false ) : Void
	{
		//le probleme est que la position de l'objet ne peut etre fait en ratio du parent si celui-ci a un taille nulle
		
		var l_RefObjSize	: CV2D	= new CV2D( 0, 0 );
		var l_RefObjPos		: CV2D	= new CV2D( 0, 0 );
		if ( m_RefObj == null )
		{
			l_RefObjSize.Set( Glb.GetSystem().m_Display.GetAspectRatio(), 1 );
			l_RefObjPos.Set( 0, 0 );
		}
		else
		{
			l_RefObjSize.Copy( m_RefObj.GetSize() );
			if ( _UseParentPivotAsRef )
			{
				l_RefObjPos.Copy( m_RefObj.GetPosition() );
			}
			else
			{
				l_RefObjPos.Copy( m_RefObj.GetTL() );
			}
		}
		
		var l_Pos			: CV2D	= new CV2D( _Pos.x, _Pos.y );
		
		// Convert to ratio
		if ( _Unit == PERCENTAGE )
		{
			l_Pos.Set( _Pos.x * 0.01, _Pos.y * 0.01 );
			_Unit	= RATIO;
		}
		
		// Convert to pixels
		if ( _Unit == RATIO )
		{
			if ( l_RefObjSize.x == 0 || l_RefObjSize.y == 0 )
			{
				m_WaitRefObjSize = true;
				l_Pos.Set(	l_Pos.x * Glb.GetSystem().m_Display.m_Height,
							l_Pos.y * Glb.GetSystem().m_Display.m_Height );
			}
			else
			{
				l_Pos.Set(	l_RefObjSize.x * l_Pos.x * Glb.GetSystem().m_Display.m_Height,
							l_RefObjSize.y * l_Pos.y * Glb.GetSystem().m_Display.m_Height );
			}
		}
		
		// Convert to homogenous screen unit
		l_Pos.Set(	l_Pos.x / Glb.GetSystem().m_Display.m_Height,
					l_Pos.y / Glb.GetSystem().m_Display.m_Height );
		
		// Add parent origin
		l_Pos.Set(	l_Pos.x + l_RefObjPos.x,
					l_Pos.y + l_RefObjPos.y );
					
		m_2DObject.SetPosition( new CV2D( l_Pos.x, l_Pos.y ) );
	}
	
	public function Update() : Result
	{
		m_2DObject.Update();
		if ( m_WaitObjSize && m_2DObject.GetSize().x != 0 && m_2DObject.GetSize().y != 0 )
		{
			m_WaitObjSize = false;
			SetEltSize( RATIO, CV2D.ZERO ); // The element will fit parent size keeping aspect ratio
											// Was not possible before knowing image aspect ratio
		}
		
		if ( m_WaitRefObjSize && m_RefObj.GetSize().x != 0 && m_RefObj.GetSize().y != 0 )
		{
			m_WaitRefObjSize = false;
			SetEltPos( RATIO, m_2DObject.GetPosition() );
		}
		return SUCCESS;
	}
	
	public function NeedUpdate() : Bool
	{
		return m_WaitObjSize || m_WaitRefObjSize;
	}
	
	private var m_WaitRefObjSize	: Bool;
	private var m_WaitObjSize	: Bool;
}