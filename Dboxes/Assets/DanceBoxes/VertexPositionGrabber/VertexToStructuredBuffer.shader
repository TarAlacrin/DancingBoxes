//https://github.com/przemyslawzaworski
//Assign displacement map (R) to properties.
 
Shader "Vertex To Structured Buffer"
{
Properties
    {
    }
Subshader
    {
Pass
        {
			ZTest Always
			Cull Off
			ZWrite Off
			Fog { Mode off }
		CGPROGRAM
			#include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
			#pragma geometry geom
            #pragma target 5.0
			 
			struct tridata {
				float4 p1;
				float4 p2;
				float4 p3;
			};
            uniform AppendStructuredBuffer<tridata> WATriVertexPositionBuffer : register(u7);
			uniform float4x4 _TransformationAdjuster;

			struct APPDATA
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			    uint id : SV_VertexID;    
				float4 col : COLOR;
            };

			struct v2g {
				float4 pos : SV_POSITION;
				float4 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD0;
				fixed4 col : COLOR;
			};

			struct g2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 col : COLOR;
			};
 
			v2g vert (APPDATA IN)
            {
				v2g vs;
				vs.worldPos = float4(mul(unity_ObjectToWorld, IN.vertex).xyz, 1);
				vs.worldPos = mul(_TransformationAdjuster,vs.worldPos).xyzw;

				vs.worldPos.w = IN.id;
				vs.pos = UnityObjectToClipPos(IN.vertex);
				vs.uv = IN.uv;
				vs.col = IN.col;

                return vs;
            }

			void geomSubFunc(v2g inp, inout TriangleStream<g2f> tristream)
			{
				g2f newg2f;
				newg2f.pos = inp.pos;
				newg2f.uv = inp.uv;
				newg2f.col = inp.col;
				tristream.Append(newg2f);
			}

			[maxvertexcount(3)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> tristream) {
				tridata t;
				t.p1 = input[0].worldPos;
				t.p2 = input[1].worldPos;
				t.p3 = input[2].worldPos;

				WATriVertexPositionBuffer.Append(t);

				//geomSubFunc(input[0], tristream);
				//geomSubFunc(input[1], tristream);
				//geomSubFunc(input[2], tristream);
				//tristream.RestartStrip();
				 
			}
 
			float4 frag (g2f ps) : SV_TARGET
            {
                return float4(1,1,1,1);
            }
 
ENDCG
        }
    }
}