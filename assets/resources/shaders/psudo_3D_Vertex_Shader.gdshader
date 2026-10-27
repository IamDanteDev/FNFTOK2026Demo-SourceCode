shader_type canvas_item;

uniform float amty;
uniform float amtx;
uniform float sideb;
uniform float sidea;
uniform float toprightw;
uniform bool horizontal;
uniform bool experemental;

uniform float vertex1;
uniform float vertex2;
uniform float vertex3;
uniform float vertex4;



void vertex()
{

//	top left point
	if(UV==vec2(0.0,0.0))
	{
		VERTEX += vec2(amtx * vertex1, amty * vertex1);
	}

//	top right point
	if(UV==vec2(1.0,0.0))
	{
		VERTEX += vec2(amtx * vertex2, amty * vertex2);
	}

//	bottom left point
	if(UV==vec2(0.0,1.0))
	{
		VERTEX += vec2(amtx * vertex3, amty * vertex3);
	}

//	bottom right point
	if(UV==vec2(1.0,1.0))
	{
		VERTEX += vec2(amtx * vertex4, amty * vertex4);
	}

}


