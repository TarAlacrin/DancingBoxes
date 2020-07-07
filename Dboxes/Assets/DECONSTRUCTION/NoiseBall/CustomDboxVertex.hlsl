//Shouts out to keijiro takahashi for his noise ball 4 repository showing how vert-fragment shaders can be integrated into unity's high def render pipeline properly

#include "SimplexNoise3D.hlsl"

uint _TriangleCount;
float _LocalTime;
float _Extent;
float _NoiseAmplitude;
float _NoiseFrequency;
float3 _NoiseOffset;
float4x4 _LocalToWorld;

// Random point on an unit sphere
float3 RandomPoint(uint seed)
{
    float u = Hash(seed * 2 + 0) * PI * 2;
    float z = Hash(seed * 2 + 1) * 2 - 1;
    return float3(float2(cos(u), sin(u)) * sqrt(1 - z * z), z);
}

// Vertex input attributes
struct Attributes
{
    uint vertexID : SV_VertexID;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2g
{
	uint vertexID : TEXCOORD0;
};

v2g CustomVert(Attributes input)
{
	v2g at;
	at.vertexID = input.vertexID;
	return at;
}


uniform float4x4 _TransformationMatrix;


PackedVaryingsType CustomVertPacker(float3 posws, float3 normws, float4 uvposagerand)
{
	// Imitate a common vertex input.
	AttributesMesh am;

	float3 posPostTrans = mul(_TransformationMatrix, float4(posws, 1)).xyz;
	float3 nrmPostTrans = mul(_TransformationMatrix, float4(normws, 0)).xyz;

	am.positionOS = posPostTrans;
#ifdef ATTRIBUTES_NEED_NORMAL
	am.normalOS = nrmPostTrans;
#endif
#ifdef ATTRIBUTES_NEED_TANGENT
	am.tangentOS = 0;
#endif
#ifdef ATTRIBUTES_NEED_TEXCOORD0
	am.uv0 = 0;
#endif
#ifdef ATTRIBUTES_NEED_TEXCOORD1
	am.uv1 = 0;
#endif
#ifdef ATTRIBUTES_NEED_TEXCOORD2
	am.uv2 = 0;
#endif
#ifdef ATTRIBUTES_NEED_TEXCOORD3
	am.uv3 = 0;
#endif
#ifdef ATTRIBUTES_NEED_COLOR
	am.color = uvposagerand;// float4(uvposrand.x, uvposrand.y, uvposrand.z,0);
#endif
	UNITY_TRANSFER_INSTANCE_ID(input, am);

	// Throw it into the default vertex pipeline.
	VaryingsType varyingsType;
	varyingsType.vmesh = VertMesh(am);
	return PackVaryingsType(varyingsType);
}


struct inputData {
	float3 position;
	float3 normal;
	float age;
};

StructuredBuffer< inputData> _Data;




[maxvertexcount(4)]
void Geom(point v2g IN[1], inout TriangleStream<PackedVaryingsType> outStream)
{
	float3 posi = _Data[IN[0].vertexID].position;  //need to test this, its probably not very performant to keep looking up the value in the _Data array
	float3 norm = normalize(_Data[IN[0].vertexID].normal);

	uint dim = 96;
	uint seed = posi.x + posi.y * dim + posi.z * dim *dim;//IN[0].vertexID * 881;
	seed *= 881;
	float rand = Hash(seed);


	float3 up = normalize(lerp(float3(0, 0, 1), float3(0, 1, 0), saturate(ceil(length(abs(_Data[IN[0].vertexID].normal) - float3(0, 1, 0))))));
	float3 right = normalize(cross(up, _Data[IN[0].vertexID].normal));
	float3 binormal = up*0.5f;
	float3 tangent = right*0.5f;


	PackedVaryingsType pvtin = CustomVertPacker(posi+tangent -binormal, norm, float4(1,0, _Data[IN[0].vertexID].age, rand));
	outStream.Append(pvtin);
	pvtin = CustomVertPacker(posi + tangent + binormal, norm, float4(1, 1, _Data[IN[0].vertexID].age, rand));
	outStream.Append(pvtin);
	pvtin = CustomVertPacker(posi - tangent - binormal, norm, float4(0, 0, _Data[IN[0].vertexID].age, rand));
	outStream.Append(pvtin);
	pvtin = CustomVertPacker(posi - tangent + binormal, norm, float4(0, 1, _Data[IN[0].vertexID].age, rand));
	outStream.Append(pvtin);

	outStream.RestartStrip();
}





