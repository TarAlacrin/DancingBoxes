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

// Custom vertex shader
PackedVaryingsType OldVertPacker(v2g input)
{

    uint t_idx = input.vertexID / 3;         // Triangle index
    uint v_idx = input.vertexID - t_idx * 3; // Vertex index

    // Time dependent random number seed
    uint seed = _LocalTime + (float)t_idx / _TriangleCount;
    seed = ((seed << 16) + t_idx) * 4;

    // Random triangle on unit sphere
    float3 v1 = RandomPoint(seed + 0);
    float3 v2 = RandomPoint(seed + 1);
    float3 v3 = RandomPoint(seed + 2);

    // Constraint with the extent parameter
    v2 = normalize(v1 + normalize(v2 - v1) * _Extent);
    v3 = normalize(v1 + normalize(v3 - v1) * _Extent);

    // Displacement by noise field
    float l1 = snoise(v1 * _NoiseFrequency + _NoiseOffset);
    float l2 = snoise(v2 * _NoiseFrequency + _NoiseOffset);
    float l3 = snoise(v3 * _NoiseFrequency + _NoiseOffset);

    l1 = abs(l1 * l1 * l1);
    l2 = abs(l2 * l2 * l2);
    l3 = abs(l3 * l3 * l3);

    v1 *= 1 + l1 * _NoiseAmplitude;
    v2 *= 1 + l2 * _NoiseAmplitude;
    v3 *= 1 + l3 * _NoiseAmplitude;

    // Vertex position/normal vector
    float3 pos = v_idx == 0 ? v1 : (v_idx == 1 ? v2 : v3);
    float3 norm = normalize(cross(v2 - v1, v3 - v2));

    // Apply the transform matrix.
    pos = mul(_LocalToWorld, float4(pos, 1)).xyz;
    norm = mul((float3x3)_LocalToWorld, norm);

    // Imitate a common vertex input.
    AttributesMesh am;
    am.positionOS = pos;
#ifdef ATTRIBUTES_NEED_NORMAL
    am.normalOS = norm;
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
    am.color = 0;
#endif
    UNITY_TRANSFER_INSTANCE_ID(input, am);

    // Throw it into the default vertex pipeline.
    VaryingsType varyingsType;
    varyingsType.vmesh = VertMesh(am);
    return PackVaryingsType(varyingsType);
}

uniform float4x4 _TransformationMatrix;


PackedVaryingsType CustomVertPacker(float3 posws, float3 normws)
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
	am.color = 0;
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
	float3 posi = _Data[IN[0].vertexID].position;  //float3(fmod(IN[0].vertexID, 5), fmod(floor(float(IN[0].vertexID)*0.2), 5), floor(float(IN[0].vertexID)*0.04));
	float3 norm = normalize(_Data[IN[0].vertexID].normal);
	//IN[0].vertexID *= 3;


	float3 up = normalize(lerp(float3(0, 0, 1), float3(0, 1, 0), saturate(ceil(length(abs(_Data[IN[0].vertexID].normal) - float3(0, 1, 0))))));
	float3 right = normalize(cross(up, _Data[IN[0].vertexID].normal));
	float3 binormal = up*0.5f;
	float3 tangent = right*0.5f;


	PackedVaryingsType pvtin = CustomVertPacker(posi+tangent -binormal, norm);// OldVertPacker(IN[0]);
	outStream.Append(pvtin);
	pvtin = CustomVertPacker(posi + tangent + binormal, norm);
	outStream.Append(pvtin);
	pvtin = CustomVertPacker(posi - tangent - binormal, norm);
	outStream.Append(pvtin);
	pvtin = CustomVertPacker(posi - tangent + binormal, norm);
	outStream.Append(pvtin);

	outStream.RestartStrip();
}
