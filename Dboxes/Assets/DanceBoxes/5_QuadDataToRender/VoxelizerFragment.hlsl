// Voxelizer effect fragment shader
// the base of this code
// https://github.com/keijiro/TestbedHDRP

half4 _EmissionHsvm1;
half4 _EmissionHsvm2;
half3 _TransitionColor;
half3 _LineColor;

float4x4 _BurnMatrix;

half3 LineEmission(FragInputs input)
{
    half2 bcc = input.color.rg;
    half em1 = saturate(input.color.b);
    half em2 = saturate(input.color.b - 1);
    half rand = input.color.a;

    // Cube face color
    half3 face =lerp(_EmissionHsvm1.xyz, _EmissionHsvm2.xyz, rand);
    face *= lerp(_EmissionHsvm1.w, _EmissionHsvm2.w, rand);

    // Cube face attenuation
    face *= lerp(0.75, 1, smoothstep(0, 0.5, length(bcc - 0.5)));

    // Edge detection
    half2 fw = fwidth(bcc);
    half2 edge2 = min(smoothstep(0, fw * 2,     bcc),
                      smoothstep(0, fw * 2, 1 - bcc));
    half edge = 1 - min(edge2.x, edge2.y);

	//return half3(10, 0, 0);/*
    return    face * em1 +
        _TransitionColor * em2 * face +
        edge * _LineColor * em1;//
}


half3 BurnMatrixEmission(FragInputs input)
{
	float3 burnpos;
	burnpos.xyz = input.positionRWS + _WorldSpaceCameraPos;
	//burnpos = mul(float4(input.positionRWS,1), _BurnMatrix);//VERY COOL EFFECT
	burnpos = mul(_BurnMatrix, float4(burnpos.xyz, 1)).xyz;//saturate(mul(float4(burnpos.xyz,1), _BurnMatrix));

	burnpos = abs(burnpos);
	float falloff = length(burnpos);
	
	falloff = saturate(1 - falloff) ;
	falloff *= falloff;
	falloff *= falloff;

	float3 color = _EmissionHsvm1 * falloff;

	return color;//float3(input.color.b, input.color.b, frac(input.color.b));//lerp(_EmissionHsvm1, _EmissionHsvm2, 0.5);//half3(10, 0, 0);
}

half3 SelfEmission(FragInputs input)
{
	return LineEmission(input);// BurnMatrixEmission(input);
}


//
// This fragment shader is copy-pasted from
// HDRP/ShaderPass/ShaderPassGBuffer.hlsl
// There are only two modifications from the original shader.
//
// - Changed the function name.
// - Cancel normal mapping for voxels.
// - Added the self emission term.
//
void VoxelizerFragment(
            PackedVaryingsToPS packedInput,
            OUTPUT_GBUFFER(outGBuffer)
            #ifdef _DEPTHOFFSET_ON
            , out float outputDepth : SV_Depth
            #endif
            )
{
    FragInputs input = UnpackVaryingsMeshToFragInputs(packedInput.vmesh);

    // input.positionSS is SV_Position
    PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

#ifdef VARYINGS_NEED_POSITION_WS
    float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);
#else
    // Unused
    float3 V = float3(1.0, 1.0, 1.0); // Avoid the division by 0
#endif

    SurfaceData surfaceData;
    BuiltinData builtinData;
    GetSurfaceAndBuiltinData(input, V, posInput, surfaceData, builtinData);

    // Custom: Normal map cancelling
	// surfaceData.normalWS = lerp(surfaceData.normalWS, input.worldToTangent[2], input.color.b);
	//  surfaceData.tangentWS = lerp(surfaceData.tangentWS, input.worldToTangent[0], input.color.b);

    // Custom: Self emission term
    builtinData.bakeDiffuseLighting += SelfEmission(input);

#ifdef DEBUG_DISPLAY
    ApplyDebugToSurfaceData(input.worldToTangent, surfaceData);
#endif

    ENCODE_INTO_GBUFFER(surfaceData, builtinData, posInput.positionSS, outGBuffer);

#ifdef _DEPTHOFFSET_ON
    outputDepth = posInput.deviceDepth;
#endif
}
