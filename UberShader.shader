Shader "hidden/preview"
{
    Properties
    {
        Vector1_6BF91A37("Fire Speed", Range(0, 2)) = 0.5
        Vector1_750448C2("Fire Scale", Range(5, 100)) = 30
        Vector1_EE2E80AF("Fire Power", Range(-2, 2)) = -0.4
        Color_822E61BF("Color", Color) = (0.4067733,1,0,1)
        [NoScaleOffset] Texture_9F46BDDC("Texture", 2D) = "white" {}
        Vector2_A8850E15("Direction", Vector) = (0,-1,0,0)
        Vector1_C853D96A("alpha", Float) = 1
    }
    HLSLINCLUDE
    #define USE_LEGACY_UNITY_MATRIX_VARIABLES
    #include "CoreRP/ShaderLibrary/Common.hlsl"
    #include "CoreRP/ShaderLibrary/Packing.hlsl"
    #include "CoreRP/ShaderLibrary/Color.hlsl"
    #include "CoreRP/ShaderLibrary/UnityInstancing.hlsl"
    #include "CoreRP/ShaderLibrary/EntityLighting.hlsl"
    #include "ShaderGraphLibrary/ShaderVariables.hlsl"
    #include "ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
    #include "ShaderGraphLibrary/Functions.hlsl"
    float Vector1_8BA52C24;
    float Vector1_6BF91A37;
    float Vector1_750448C2;
    float Vector1_EE2E80AF;
    float4 Color_822E61BF;
    TEXTURE2D(Texture_9F46BDDC); SAMPLER(samplerTexture_9F46BDDC);
    float2 Vector2_A8850E15;
    float Vector1_C853D96A;
    float4 Color_DA1286EB;
    float4 Color_58821BEE;
    float3 _DotProduct_621DFE7F_B;
    float2 _TilingAndOffset_F2C635D8_UV;
    float2 _TilingAndOffset_F2C635D8_Tiling;
    float3 _DotProduct_E4481B74_B;
    float4 _Clamp_B5D0F23D_Min;
    float4 _Clamp_B5D0F23D_Max;
    struct SurfaceInputs{
    	float3 ViewSpaceViewDirection;
    	half4 uv0;
    };

    void Unity_DotProduct_float(float3 A, float3 B, out float Out)
    {
        Out = dot(A, B);
    }

    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
    {
        Out = lerp(A, B, T);
    }

    void Unity_Multiply_float (float2 A, float2 B, out float2 Out)
    {
        Out = A * B;
    }

    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
    {
        Out = UV * Tiling + Offset;
    }


    inline float unity_noise_randomValue (float2 uv)
    {
        return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
    }

    inline float unity_noise_interpolate (float a, float b, float t)
    {
        return (1.0-t)*a + (t*b);
    }


    inline float unity_valueNoise (float2 uv)
    {
        float2 i = floor(uv);
        float2 f = frac(uv);
        f = f * f * (3.0 - 2.0 * f);

        uv = abs(frac(uv) - 0.5);
        float2 c0 = i + float2(0.0, 0.0);
        float2 c1 = i + float2(1.0, 0.0);
        float2 c2 = i + float2(0.0, 1.0);
        float2 c3 = i + float2(1.0, 1.0);
        float r0 = unity_noise_randomValue(c0);
        float r1 = unity_noise_randomValue(c1);
        float r2 = unity_noise_randomValue(c2);
        float r3 = unity_noise_randomValue(c3);

        float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
        float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
        float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
        return t;
    }
    void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
    {
        float t = 0.0;
        for(int i = 0; i < 3; i++)
        {
            float freq = pow(2.0, float(i));
            float amp = pow(0.5, float(3-i));
            t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        }
        Out = t;
    }

    void Unity_Multiply_float (float4 A, float4 B, out float4 Out)
    {
        Out = A * B;
    }

    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
    {
        Out = A + B;
    }

    void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
    {
        Out = clamp(In, Min, Max);
    }
    struct GraphVertexInput
    {
    	float4 vertex : POSITION;
    	float3 normal : NORMAL;
    	float4 tangent : TANGENT;
    	float4 texcoord0 : TEXCOORD0;
    	UNITY_VERTEX_INPUT_INSTANCE_ID
    };
    struct SurfaceDescription{
    	float4 PreviewOutput;
    };
    GraphVertexInput PopulateVertexData(GraphVertexInput v){
    	return v;
    }
    SurfaceDescription PopulateSurfaceData(SurfaceInputs IN) {
    	SurfaceDescription surface = (SurfaceDescription)0;
    	float2 _Property_680C14C0_Out = Vector2_A8850E15;
    	float4 _UV_872849BC_Out = IN.uv0;
    	if (Vector1_8BA52C24 == 12) { surface.PreviewOutput = half4(_UV_872849BC_Out.x, _UV_872849BC_Out.y, _UV_872849BC_Out.z, 1.0); return surface; }
    	float _DotProduct_621DFE7F_Out;
    	Unity_DotProduct_float((_UV_872849BC_Out.xyz), _DotProduct_621DFE7F_B, _DotProduct_621DFE7F_Out);
    	if (Vector1_8BA52C24 == 18) { surface.PreviewOutput = half4(_DotProduct_621DFE7F_Out, _DotProduct_621DFE7F_Out, _DotProduct_621DFE7F_Out, 1.0); return surface; }
    	float4 _Lerp_C2E9337_Out;
    	Unity_Lerp_float4(Color_DA1286EB, Color_58821BEE, (_DotProduct_621DFE7F_Out.xxxx), _Lerp_C2E9337_Out);
    	if (Vector1_8BA52C24 == 2) { surface.PreviewOutput = half4(_Lerp_C2E9337_Out.x, _Lerp_C2E9337_Out.y, _Lerp_C2E9337_Out.z, 1.0); return surface; }
    	float _Property_A278496_Out = Vector1_750448C2;
    	float _Property_DA1F9147_Out = Vector1_6BF91A37;
    	float2 _Multiply_73FA4A5_Out;
    	Unity_Multiply_float((_Time.y.xx), _Property_680C14C0_Out, _Multiply_73FA4A5_Out);
    	
    	if (Vector1_8BA52C24 == 25) { surface.PreviewOutput = half4(_Multiply_73FA4A5_Out.x, _Multiply_73FA4A5_Out.y, 0.0, 1.0); return surface; }
    	float2 _Multiply_A7EDC92E_Out;
    	Unity_Multiply_float((_Property_DA1F9147_Out.xx), _Multiply_73FA4A5_Out, _Multiply_A7EDC92E_Out);
    	
    	if (Vector1_8BA52C24 == 9) { surface.PreviewOutput = half4(_Multiply_A7EDC92E_Out.x, _Multiply_A7EDC92E_Out.y, 0.0, 1.0); return surface; }
    	float2 _TilingAndOffset_F2C635D8_Out;
    	Unity_TilingAndOffset_float(IN.uv0.xy, _TilingAndOffset_F2C635D8_Tiling, _Multiply_A7EDC92E_Out, _TilingAndOffset_F2C635D8_Out);
    	if (Vector1_8BA52C24 == 7) { surface.PreviewOutput = half4(_TilingAndOffset_F2C635D8_Out.x, _TilingAndOffset_F2C635D8_Out.y, 0.0, 1.0); return surface; }
    	float _SimpleNoise_CDCB9DD4_Out;
    	Unity_SimpleNoise_float(_TilingAndOffset_F2C635D8_Out, _Property_A278496_Out, _SimpleNoise_CDCB9DD4_Out);
    	if (Vector1_8BA52C24 == 16) { surface.PreviewOutput = half4(_SimpleNoise_CDCB9DD4_Out, _SimpleNoise_CDCB9DD4_Out, _SimpleNoise_CDCB9DD4_Out, 1.0); return surface; }
    	float4 _SampleTexture2D_13A8C858_RGBA = SAMPLE_TEXTURE2D(Texture_9F46BDDC, samplerTexture_9F46BDDC, (_SimpleNoise_CDCB9DD4_Out.xx));
    	_SampleTexture2D_13A8C858_RGBA.rgb = UnpackNormalmapRGorAG(_SampleTexture2D_13A8C858_RGBA);
    	float _SampleTexture2D_13A8C858_R = _SampleTexture2D_13A8C858_RGBA.r;
    	float _SampleTexture2D_13A8C858_G = _SampleTexture2D_13A8C858_RGBA.g;
    	float _SampleTexture2D_13A8C858_B = _SampleTexture2D_13A8C858_RGBA.b;
    	float _SampleTexture2D_13A8C858_A = _SampleTexture2D_13A8C858_RGBA.a;
    	if (Vector1_8BA52C24 == 17) { surface.PreviewOutput = half4(_SampleTexture2D_13A8C858_RGBA.x, _SampleTexture2D_13A8C858_RGBA.y, _SampleTexture2D_13A8C858_RGBA.z, 1.0); return surface; }
    	float _DotProduct_E4481B74_Out;
    	Unity_DotProduct_float((_SampleTexture2D_13A8C858_RGBA.xyz), _DotProduct_E4481B74_B, _DotProduct_E4481B74_Out);
    	if (Vector1_8BA52C24 == 19) { surface.PreviewOutput = half4(_DotProduct_E4481B74_Out, _DotProduct_E4481B74_Out, _DotProduct_E4481B74_Out, 1.0); return surface; }
    	float4 _Multiply_6CAF4F1E_Out;
    	Unity_Multiply_float((_SimpleNoise_CDCB9DD4_Out.xxxx), _Lerp_C2E9337_Out, _Multiply_6CAF4F1E_Out);
    	
    	if (Vector1_8BA52C24 == 14) { surface.PreviewOutput = half4(_Multiply_6CAF4F1E_Out.x, _Multiply_6CAF4F1E_Out.y, _Multiply_6CAF4F1E_Out.z, 1.0); return surface; }
    	float4 _Add_65423E77_Out;
    	Unity_Add_float4(_Multiply_6CAF4F1E_Out, _Lerp_C2E9337_Out, _Add_65423E77_Out);
    	if (Vector1_8BA52C24 == 15) { surface.PreviewOutput = half4(_Add_65423E77_Out.x, _Add_65423E77_Out.y, _Add_65423E77_Out.z, 1.0); return surface; }
    	float4 _Add_1316AAB5_Out;
    	Unity_Add_float4((_DotProduct_E4481B74_Out.xxxx), _Add_65423E77_Out, _Add_1316AAB5_Out);
    	if (Vector1_8BA52C24 == 20) { surface.PreviewOutput = half4(_Add_1316AAB5_Out.x, _Add_1316AAB5_Out.y, _Add_1316AAB5_Out.z, 1.0); return surface; }
    	float _Property_6B8FC4FA_Out = Vector1_EE2E80AF;
    	float4 _Add_1BC52DB2_Out;
    	Unity_Add_float4(_Add_1316AAB5_Out, (_Property_6B8FC4FA_Out.xxxx), _Add_1BC52DB2_Out);
    	if (Vector1_8BA52C24 == 21) { surface.PreviewOutput = half4(_Add_1BC52DB2_Out.x, _Add_1BC52DB2_Out.y, _Add_1BC52DB2_Out.z, 1.0); return surface; }
    	float _Property_DBDA1987_Out = Vector1_C853D96A;
    	float4 _Multiply_688B245D_Out;
    	Unity_Multiply_float(_Add_1BC52DB2_Out, (_Property_DBDA1987_Out.xxxx), _Multiply_688B245D_Out);
    	
    	if (Vector1_8BA52C24 == 11) { surface.PreviewOutput = half4(_Multiply_688B245D_Out.x, _Multiply_688B245D_Out.y, _Multiply_688B245D_Out.z, 1.0); return surface; }
    	float4 _Property_C676527E_Out = Color_822E61BF;
    	float4 _Multiply_70B1B712_Out;
    	Unity_Multiply_float(_Multiply_688B245D_Out, _Property_C676527E_Out, _Multiply_70B1B712_Out);
    	
    	if (Vector1_8BA52C24 == 6) { surface.PreviewOutput = half4(_Multiply_70B1B712_Out.x, _Multiply_70B1B712_Out.y, _Multiply_70B1B712_Out.z, 1.0); return surface; }
    	float4 _Clamp_B5D0F23D_Out;
    	Unity_Clamp_float4(_Multiply_688B245D_Out, _Clamp_B5D0F23D_Min, _Clamp_B5D0F23D_Max, _Clamp_B5D0F23D_Out);
    	if (Vector1_8BA52C24 == 22) { surface.PreviewOutput = half4(_Clamp_B5D0F23D_Out.x, _Clamp_B5D0F23D_Out.y, _Clamp_B5D0F23D_Out.z, 1.0); return surface; }
    	if (Vector1_8BA52C24 == 27) { surface.PreviewOutput = half4(IN.ViewSpaceViewDirection.x, IN.ViewSpaceViewDirection.y, IN.ViewSpaceViewDirection.z, 1.0); return surface; }
    	return surface;
    }
    ENDHLSL

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct GraphVertexOutput
            {
                float4 position : POSITION;
                float3 WorldSpaceViewDirection : TEXCOORD0;
    half4 uv0 : TEXCOORD1;

            };

            GraphVertexOutput vert (GraphVertexInput v)
            {
                v = PopulateVertexData(v);

                GraphVertexOutput o;
                float3 positionWS = TransformObjectToWorld(v.vertex);
                o.position = TransformWorldToHClip(positionWS);
                o.WorldSpaceViewDirection = SafeNormalize(_WorldSpaceCameraPos.xyz - mul(GetObjectToWorldMatrix(), float4(v.vertex.xyz, 1.0)).xyz);
    o.uv0 = v.texcoord0;

                return o;
            }

            float4 frag (GraphVertexOutput IN) : SV_Target
            {
                float3 WorldSpaceViewDirection = normalize(IN.WorldSpaceViewDirection);
    float3 ViewSpaceViewDirection = mul((float3x3)UNITY_MATRIX_V,WorldSpaceViewDirection);
    float4 uv0 = IN.uv0;


                SurfaceInputs surfaceInput = (SurfaceInputs)0;;
                surfaceInput.ViewSpaceViewDirection = ViewSpaceViewDirection;
    surfaceInput.uv0 = uv0;


                SurfaceDescription surf = PopulateSurfaceData(surfaceInput);
                return surf.PreviewOutput;

            }
            ENDHLSL
        }
    }
}
