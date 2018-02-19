Shader "PBR Master"
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
	SubShader
	{
		Tags{ "RenderPipeline" = "LightweightPipeline"}
		Tags
		{
			"RenderType"="Transparent"
			"Queue"="Transparent"
		}
		
		Pass
		{
			Tags{"LightMode" = "LightweightForward"}
			
					Blend SrcAlpha OneMinusSrcAlpha
		
					Cull Back
		
					ZTest LEqual
		
					ZWrite Off
		
		
			HLSLPROGRAM
		    // Required to compile gles 2.0 with standard srp library
		    #pragma prefer_hlslcc gles
			#pragma target 3.0
		
		    // -------------------------------------
		    // Lightweight Pipeline keywords
		    // We have no good approach exposed to skip shader variants, e.g, ideally we would like to skip _CASCADE for all puctual lights
		    // Lightweight combines light classification and shadows keywords to reduce shader variants.
		    // Lightweight shader library declares defines based on these keywords to avoid having to check them in the shaders
		    // Core.hlsl defines _MAIN_LIGHT_DIRECTIONAL and _MAIN_LIGHT_SPOT (point lights can't be main light)
		    // Shadow.hlsl defines _SHADOWS_ENABLED, _SHADOWS_SOFT, _SHADOWS_CASCADE, _SHADOWS_PERSPECTIVE
		    #pragma multi_compile _ _MAIN_LIGHT_DIRECTIONAL_SHADOW _MAIN_LIGHT_DIRECTIONAL_SHADOW_CASCADE _MAIN_LIGHT_DIRECTIONAL_SHADOW_SOFT _MAIN_LIGHT_DIRECTIONAL_SHADOW_CASCADE_SOFT _MAIN_LIGHT_SPOT_SHADOW _MAIN_LIGHT_SPOT_SHADOW_SOFT
		    #pragma multi_compile _ _MAIN_LIGHT_COOKIE
		    #pragma multi_compile _ _ADDITIONAL_LIGHTS
		    #pragma multi_compile _ _VERTEX_LIGHTS
		    #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
		    #pragma multi_compile _ FOG_LINEAR FOG_EXP2
		
		    // -------------------------------------
		    // Unity defined keywords
		    #pragma multi_compile _ UNITY_SINGLE_PASS_STEREO STEREO_INSTANCING_ON STEREO_MULTIVIEW_ON
		    #pragma multi_compile _ DIRLIGHTMAP_COMBINED LIGHTMAP_ON
		
		    //--------------------------------------
		    // GPU Instancing
		    #pragma multi_compile_instancing
		
		    // LW doesn't support dynamic GI. So we save 30% shader variants if we assume
		    // LIGHTMAP_ON when DIRLIGHTMAP_COMBINED is set
		    #ifdef DIRLIGHTMAP_COMBINED
		    #define LIGHTMAP_ON
		    #endif
		
		    #pragma vertex vert
			#pragma fragment frag
		
			
		
			#include "LWRP/ShaderLibrary/Core.hlsl"
			#include "LWRP/ShaderLibrary/Lighting.hlsl"
			#include "CoreRP/ShaderLibrary/Color.hlsl"
			#include "CoreRP/ShaderLibrary/UnityInstancing.hlsl"
			#include "ShaderGraphLibrary/Functions.hlsl"
		
								float Vector1_6BF91A37;
							float Vector1_750448C2;
							float Vector1_EE2E80AF;
							float4 Color_822E61BF;
							TEXTURE2D(Texture_9F46BDDC); SAMPLER(samplerTexture_9F46BDDC);
							float2 Vector2_A8850E15;
							float Vector1_C853D96A;
							float2 _TilingAndOffset_F2C635D8_UV;
							float2 _TilingAndOffset_F2C635D8_Tiling;
							float3 _DotProduct_E4481B74_B;
							float4 Color_DA1286EB;
							float4 Color_58821BEE;
							float3 _DotProduct_621DFE7F_B;
							float4 _Clamp_B5D0F23D_Min;
							float4 _Clamp_B5D0F23D_Max;
							float4 _PBRMaster_FA27B14C_Albedo;
							float3 _PBRMaster_FA27B14C_Normal;
							float _PBRMaster_FA27B14C_Metallic;
							float _PBRMaster_FA27B14C_Smoothness;
							float _PBRMaster_FA27B14C_Occlusion;
							float _PBRMaster_FA27B14C_AlphaClipThreshold;
					
							struct SurfaceInputs{
								half4 uv0;
							};
					
					
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
					
					        void Unity_DotProduct_float(float3 A, float3 B, out float Out)
					        {
					            Out = dot(A, B);
					        }
					
					        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
					        {
					            Out = lerp(A, B, T);
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
								float4 texcoord1 : TEXCOORD1;
								UNITY_VERTEX_INPUT_INSTANCE_ID
							};
					
							struct SurfaceDescription{
								float3 Albedo;
								float3 Normal;
								float3 Emission;
								float Metallic;
								float Smoothness;
								float Occlusion;
								float Alpha;
								float AlphaClipThreshold;
							};
					
							GraphVertexInput PopulateVertexData(GraphVertexInput v){
								return v;
							}
					
							SurfaceDescription PopulateSurfaceData(SurfaceInputs IN) {
								SurfaceDescription surface = (SurfaceDescription)0;
								float _Property_DA1F9147_Out = Vector1_6BF91A37;
								float2 _Property_680C14C0_Out = Vector2_A8850E15;
								float2 _Multiply_73FA4A5_Out;
								Unity_Multiply_float((_Time.y.xx), _Property_680C14C0_Out, _Multiply_73FA4A5_Out);
								
								float2 _Multiply_A7EDC92E_Out;
								Unity_Multiply_float((_Property_DA1F9147_Out.xx), _Multiply_73FA4A5_Out, _Multiply_A7EDC92E_Out);
								
								float2 _TilingAndOffset_F2C635D8_Out;
								Unity_TilingAndOffset_float(IN.uv0.xy, _TilingAndOffset_F2C635D8_Tiling, _Multiply_A7EDC92E_Out, _TilingAndOffset_F2C635D8_Out);
								float _Property_A278496_Out = Vector1_750448C2;
								float _SimpleNoise_CDCB9DD4_Out;
								Unity_SimpleNoise_float(_TilingAndOffset_F2C635D8_Out, _Property_A278496_Out, _SimpleNoise_CDCB9DD4_Out);
								float4 _SampleTexture2D_13A8C858_RGBA = SAMPLE_TEXTURE2D(Texture_9F46BDDC, samplerTexture_9F46BDDC, (_SimpleNoise_CDCB9DD4_Out.xx));
								_SampleTexture2D_13A8C858_RGBA.rgb = UnpackNormalmapRGorAG(_SampleTexture2D_13A8C858_RGBA);
								float _SampleTexture2D_13A8C858_R = _SampleTexture2D_13A8C858_RGBA.r;
								float _SampleTexture2D_13A8C858_G = _SampleTexture2D_13A8C858_RGBA.g;
								float _SampleTexture2D_13A8C858_B = _SampleTexture2D_13A8C858_RGBA.b;
								float _SampleTexture2D_13A8C858_A = _SampleTexture2D_13A8C858_RGBA.a;
								float _DotProduct_E4481B74_Out;
								Unity_DotProduct_float((_SampleTexture2D_13A8C858_RGBA.xyz), _DotProduct_E4481B74_B, _DotProduct_E4481B74_Out);
								float4 _UV_872849BC_Out = IN.uv0;
								float _DotProduct_621DFE7F_Out;
								Unity_DotProduct_float((_UV_872849BC_Out.xyz), _DotProduct_621DFE7F_B, _DotProduct_621DFE7F_Out);
								float4 _Lerp_C2E9337_Out;
								Unity_Lerp_float4(Color_DA1286EB, Color_58821BEE, (_DotProduct_621DFE7F_Out.xxxx), _Lerp_C2E9337_Out);
								float4 _Multiply_6CAF4F1E_Out;
								Unity_Multiply_float((_SimpleNoise_CDCB9DD4_Out.xxxx), _Lerp_C2E9337_Out, _Multiply_6CAF4F1E_Out);
								
								float4 _Add_65423E77_Out;
								Unity_Add_float4(_Multiply_6CAF4F1E_Out, _Lerp_C2E9337_Out, _Add_65423E77_Out);
								float4 _Add_1316AAB5_Out;
								Unity_Add_float4((_DotProduct_E4481B74_Out.xxxx), _Add_65423E77_Out, _Add_1316AAB5_Out);
								float _Property_6B8FC4FA_Out = Vector1_EE2E80AF;
								float4 _Add_1BC52DB2_Out;
								Unity_Add_float4(_Add_1316AAB5_Out, (_Property_6B8FC4FA_Out.xxxx), _Add_1BC52DB2_Out);
								float _Property_DBDA1987_Out = Vector1_C853D96A;
								float4 _Multiply_688B245D_Out;
								Unity_Multiply_float(_Add_1BC52DB2_Out, (_Property_DBDA1987_Out.xxxx), _Multiply_688B245D_Out);
								
								float4 _Property_C676527E_Out = Color_822E61BF;
								float4 _Multiply_70B1B712_Out;
								Unity_Multiply_float(_Multiply_688B245D_Out, _Property_C676527E_Out, _Multiply_70B1B712_Out);
								
								float4 _Clamp_B5D0F23D_Out;
								Unity_Clamp_float4(_Multiply_688B245D_Out, _Clamp_B5D0F23D_Min, _Clamp_B5D0F23D_Max, _Clamp_B5D0F23D_Out);
								surface.Albedo = _PBRMaster_FA27B14C_Albedo;
								surface.Normal = _PBRMaster_FA27B14C_Normal;
								surface.Emission = (_Multiply_70B1B712_Out.xyz);
								surface.Metallic = _PBRMaster_FA27B14C_Metallic;
								surface.Smoothness = _PBRMaster_FA27B14C_Smoothness;
								surface.Occlusion = _PBRMaster_FA27B14C_Occlusion;
								surface.Alpha = (_Clamp_B5D0F23D_Out).x;
								surface.AlphaClipThreshold = _PBRMaster_FA27B14C_AlphaClipThreshold;
								return surface;
							}
					
		
		
			struct GraphVertexOutput
		    {
		        float4 clipPos                : SV_POSITION;
		        float4 lightmapUVOrVertexSH   : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1; // x: fogFactor, yzw: vertex light
		    	float4 shadowCoord            : TEXCOORD2;
		        			float3 WorldSpaceNormal : TEXCOORD3;
					float3 WorldSpaceTangent : TEXCOORD4;
					float3 WorldSpaceBiTangent : TEXCOORD5;
					float3 WorldSpaceViewDirection : TEXCOORD6;
					float3 WorldSpacePosition : TEXCOORD7;
					half4 uv0 : TEXCOORD8;
					half4 uv1 : TEXCOORD9;
		
		        UNITY_VERTEX_INPUT_INSTANCE_ID
		    };
		
		    GraphVertexOutput vert (GraphVertexInput v)
			{
			    v = PopulateVertexData(v);
		
		        GraphVertexOutput o = (GraphVertexOutput)0;
		
		        UNITY_SETUP_INSTANCE_ID(v);
		    	UNITY_TRANSFER_INSTANCE_ID(v, o);
		
		        			o.WorldSpaceNormal = mul(v.normal,(float3x3)UNITY_MATRIX_I_M);
					o.WorldSpaceTangent = mul((float3x3)UNITY_MATRIX_M,v.tangent);
					o.WorldSpaceBiTangent = normalize(cross(o.WorldSpaceNormal, o.WorldSpaceTangent.xyz) * v.tangent.w);
					o.WorldSpaceViewDirection = SafeNormalize(_WorldSpaceCameraPos.xyz - mul(GetObjectToWorldMatrix(), float4(v.vertex.xyz, 1.0)).xyz);
					o.WorldSpacePosition = mul(UNITY_MATRIX_M,v.vertex);
					o.uv0 = v.texcoord0;
					o.uv1 = v.texcoord1;
		
		
				float3 lwWNormal = TransformObjectToWorldNormal(v.normal);
				float3 lwWorldPos = TransformObjectToWorld(v.vertex.xyz);
				float4 clipPos = TransformWorldToHClip(lwWorldPos);
		
		 		// We either sample GI from lightmap or SH. lightmap UV and vertex SH coefficients
			    // are packed in lightmapUVOrVertexSH to save interpolator.
			    // The following funcions initialize
			    OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH);
			    OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH);
		
			    half3 vertexLight = VertexLighting(lwWorldPos, lwWNormal);
			    half fogFactor = ComputeFogFactor(clipPos.z);
			    o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
			    o.clipPos = clipPos;
		
		#if defined(_SHADOWS_ENABLED) && !defined(_SHADOWS_CASCADE)
			    o.shadowCoord = ComputeShadowCoord(lwWorldPos);
		#else
				o.shadowCoord = float4(0, 0, 0, 0);
		#endif
		
				return o;
			}
		
			half4 frag (GraphVertexOutput IN) : SV_Target
		    {
		    	UNITY_SETUP_INSTANCE_ID(IN);
		
		    				float3 WorldSpaceNormal = normalize(IN.WorldSpaceNormal);
					float3 WorldSpaceTangent = IN.WorldSpaceTangent;
					float3 WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
					float3 WorldSpaceViewDirection = normalize(IN.WorldSpaceViewDirection);
					float3 WorldSpacePosition = IN.WorldSpacePosition;
					float4 uv0 = IN.uv0;
					float4 uv1 = IN.uv1;
		
		
		        SurfaceInputs surfaceInput = (SurfaceInputs)0;
		        			surfaceInput.uv0 = uv0;
		
		
		        SurfaceDescription surf = PopulateSurfaceData(surfaceInput);
		
				float3 Albedo = float3(0.5, 0.5, 0.5);
				float3 Specular = float3(0, 0, 0);
				float Metallic = 1;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = 0;
				float Smoothness = 0.5;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0;
		
		        			Albedo = surf.Albedo;
					Normal = surf.Normal;
					Emission = surf.Emission;
					Metallic = surf.Metallic;
					Smoothness = surf.Smoothness;
					Occlusion = surf.Occlusion;
					Alpha = surf.Alpha;
					AlphaClipThreshold = surf.AlphaClipThreshold;
		
		
				InputData inputData;
				inputData.positionWS = WorldSpacePosition;
		
		#ifdef _NORMALMAP
			    inputData.normalWS = TangentToWorldNormal(Normal, WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal);
		#else
			    inputData.normalWS = normalize(WorldSpaceNormal);
		#endif
		
		#ifdef SHADER_API_MOBILE
			    // viewDirection should be normalized here, but we avoid doing it as it's close enough and we save some ALU.
			    inputData.viewDirectionWS = WorldSpaceViewDirection;
		#else
			    inputData.viewDirectionWS = normalize(WorldSpaceViewDirection);
		#endif
		
		#ifdef _SHADOWS_ENABLED
			    inputData.shadowCoord = IN.shadowCoord;
		#else
			    inputData.shadowCoord = float4(0, 0, 0, 0);
		#endif
		
			    inputData.fogCoord = IN.fogFactorAndVertexLight.x;
			    inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
			    inputData.bakedGI = SampleGI(IN.lightmapUVOrVertexSH, inputData.normalWS);
		
				half4 color = LightweightFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);
		
				// Computes fog factor per-vertex
		    	ApplyFog(color.rgb, IN.fogFactorAndVertexLight.x);
		
		#if _AlphaClip
				clip(Alpha - AlphaClipThreshold);
		#endif
				return color;
		    }
		
			ENDHLSL
		}
		
		Pass
		{
		    Tags{"LightMode" = "ShadowCaster"}
		
		    ZWrite On ZTest LEqual
		
		    HLSLPROGRAM
		    // Required to compile gles 2.0 with standard srp library
		    #pragma prefer_hlslcc gles
		    #pragma target 2.0
		
		    //--------------------------------------
		    // GPU Instancing
		    #pragma multi_compile_instancing
		
		    #pragma vertex ShadowPassVertex
		    #pragma fragment ShadowPassFragment
		
		    #include "LWRP/ShaderLibrary/LightweightPassShadow.hlsl"
		    ENDHLSL
		}
		
		Pass
		{
		    Tags{"LightMode" = "DepthOnly"}
		
		    ZWrite On
		    ColorMask 0
		
		    HLSLPROGRAM
		    // Required to compile gles 2.0 with standard srp library
		    #pragma prefer_hlslcc gles
		    #pragma target 2.0
		    #pragma vertex vert
		    #pragma fragment frag
		
		    #include "LWRP/ShaderLibrary/Core.hlsl"
		
		    float4 vert(float4 pos : POSITION) : SV_POSITION
		    {
		        return TransformObjectToHClip(pos.xyz);
		    }
		
		    half4 frag() : SV_TARGET
		    {
		        return 0;
		    }
		    ENDHLSL
		}
		
		// This pass it not used during regular rendering, only for lightmap baking.
		Pass
		{
		    Tags{"LightMode" = "Meta"}
		
		    Cull Off
		
		    HLSLPROGRAM
		    // Required to compile gles 2.0 with standard srp library
		    #pragma prefer_hlslcc gles
		
		    #pragma vertex LightweightVertexMeta
		    #pragma fragment LightweightFragmentMeta
		
		    #pragma shader_feature _SPECULAR_SETUP
		    #pragma shader_feature _EMISSION
		    #pragma shader_feature _METALLICSPECGLOSSMAP
		    #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
		    #pragma shader_feature EDITOR_VISUALIZATION
		
		    #pragma shader_feature _SPECGLOSSMAP
		
		    #include "LWRP/ShaderLibrary/LightweightPassMeta.hlsl"
		    ENDHLSL
		}
	}
	
}
