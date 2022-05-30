Shader "TerrainShader"
{
    Properties
    {
        [NoScaleOffset] _WaterTexture("WaterTexture", 2D) = "white" {}
        [NoScaleOffset]_WaterNormal("WaterNormal", 2D) = "white" {}
        _WaterHeight("WaterHeight", Float) = 0
        [NoScaleOffset]_SandTexture("SandTexture", 2D) = "white" {}
        [NoScaleOffset]_SandNormal("SandNormal", 2D) = "white" {}
        _SandHeight("SandHeight", Float) = 0.3
        [NoScaleOffset]_GrassTexture("GrassTexture", 2D) = "white" {}
        [NoScaleOffset]_GrassNormal("GrassNormal", 2D) = "white" {}
        _GrassHeight("GrassHeight", Float) = 0.48
        [NoScaleOffset]_RockTexture("RockTexture", 2D) = "white" {}
        [NoScaleOffset]_RockNormal("RockNormal", 2D) = "white" {}
        _RockHeight("RockHeight", Float) = 0.6
        _NearbyPickHeight("NearbyPickHeight", Float) = 0
        [NoScaleOffset]_SnowTexture("SnowTexture", 2D) = "white" {}
        [NoScaleOffset]_SnowNormal("SnowNormal", 2D) = "white" {}
        _SnowHeight("SnowHeight", Float) = 0.88
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Geometry"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalLitSubTarget"
            "TerrainCompatible"="True"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz = input.positionWS;
            output.interp1.xyz = input.normalWS;
            output.interp2.xyzw = input.tangentWS;
            output.interp3.xyzw = input.texCoord0;
            output.interp4.xyz = input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz = input.sh;
            #endif
            output.interp8.xyzw = input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw = input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _WaterTexture_TexelSize;
        float _WaterHeight;
        float4 _SandTexture_TexelSize;
        float _SandHeight;
        float4 _GrassTexture_TexelSize;
        float _GrassHeight;
        float4 _RockTexture_TexelSize;
        float _RockHeight;
        float4 _SnowTexture_TexelSize;
        float _SnowHeight;
        float _NearbyPickHeight;
        float4 _WaterNormal_TexelSize;
        float4 _RockNormal_TexelSize;
        float4 _GrassNormal_TexelSize;
        float4 _SandNormal_TexelSize;
        float4 _SnowNormal_TexelSize;
        CBUFFER_END

            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_WaterTexture);
            SAMPLER(sampler_WaterTexture);
            TEXTURE2D(_SandTexture);
            SAMPLER(sampler_SandTexture);
            TEXTURE2D(_GrassTexture);
            SAMPLER(sampler_GrassTexture);
            TEXTURE2D(_RockTexture);
            SAMPLER(sampler_RockTexture);
            TEXTURE2D(_SnowTexture);
            SAMPLER(sampler_SnowTexture);
            TEXTURE2D(_WaterNormal);
            SAMPLER(sampler_WaterNormal);
            TEXTURE2D(_RockNormal);
            SAMPLER(sampler_RockNormal);
            TEXTURE2D(_GrassNormal);
            SAMPLER(sampler_GrassNormal);
            TEXTURE2D(_SandNormal);
            SAMPLER(sampler_SandNormal);
            TEXTURE2D(_SnowNormal);
            SAMPLER(sampler_SnowNormal);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Functions

            void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
            {
                Out = A <= B ? 1 : 0;
            }

            void Unity_InverseLerp_float(float A, float B, float T, out float Out)
            {
                Out = (T - A) / (B - A);
            }

            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
            {
                Out = lerp(A, B, T);
            }

            void Unity_Blend_Exclusion_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
            {
                Out = Blend + Base - (2.0 * Blend * Base);
                Out = lerp(Base, Out, Opacity);
            }

            void Unity_Power_float4(float4 A, float4 B, out float4 Out)
            {
                Out = pow(A, B);
            }

            void Unity_Blend_Screen_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
            {
                Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
                Out = lerp(Base, Out, Opacity);
            }

            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
            {
                Out = Predicate ? True : False;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0 = IN.uv0;
                float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_R_1 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[0];
                float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[1];
                float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_B_3 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[2];
                float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_A_4 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[3];
                float _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0 = _SandHeight;
                float _Comparison_befd0823d3d24995af6d977e0af38232_Out_2;
                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Comparison_befd0823d3d24995af6d977e0af38232_Out_2);
                UnityTexture2D _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0 = UnityBuildTexture2DStructNoScale(_WaterTexture);
                float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend /= dot(Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend, 1.0);
                float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.zy);
                float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xz);
                float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xy);
                float4 _Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0 = Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.x + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.y + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.z;
                UnityTexture2D _Property_36337b09844644179547e9e25c7c4274_Out_0 = UnityBuildTexture2DStructNoScale(_SandTexture);
                float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend /= dot(Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend, 1.0);
                float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_X = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.zy);
                float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xz);
                float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xy);
                float4 _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0 = Triplanar_b5daae74a8384db9b8d43474f55b1cca_X * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.x + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.y + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.z;
                float _Property_bc6acfb4eb504fa188ea556c8f614756_Out_0 = _WaterHeight;
                float _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3;
                Unity_InverseLerp_float(_Property_bc6acfb4eb504fa188ea556c8f614756_Out_0, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3);
                float4 _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3;
                Unity_Lerp_float4(_Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0, _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, (_InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3.xxxx), _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3);
                float _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0 = _GrassHeight;
                float _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2;
                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2);
                UnityTexture2D _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0 = UnityBuildTexture2DStructNoScale(_GrassTexture);
                float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend /= dot(Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend, 1.0);
                float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_X = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.zy);
                float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xz);
                float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xy);
                float4 _Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0 = Triplanar_05b6acc8be54451b8049b91ed12ebc24_X * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.x + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.y + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.z;
                UnityTexture2D _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend /= dot(Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend, 1.0);
                float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_X = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.zy);
                float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Y = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xz);
                float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Z = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xy);
                float4 _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0 = Triplanar_1ed180918dcb4468b12011d31552c9d9_X * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.x + Triplanar_1ed180918dcb4468b12011d31552c9d9_Y * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.y + Triplanar_1ed180918dcb4468b12011d31552c9d9_Z * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.z;
                float4 _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2;
                Unity_Blend_Exclusion_float4(_Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0, _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0, _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, 0.52);
                float _Float_cf64f4c58290409ea67cef8f97bd8453_Out_0 = 2.33;
                float4 _Power_04f1890bf939475b9826ed03816155ce_Out_2;
                Unity_Power_float4(_Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, (_Float_cf64f4c58290409ea67cef8f97bd8453_Out_0.xxxx), _Power_04f1890bf939475b9826ed03816155ce_Out_2);
                float _Property_50b2430cc37d40d9862de7ec154fbd82_Out_0 = _SandHeight;
                float _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3;
                Unity_InverseLerp_float(_Property_50b2430cc37d40d9862de7ec154fbd82_Out_0, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3);
                float4 _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3;
                Unity_Lerp_float4(_Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, _Power_04f1890bf939475b9826ed03816155ce_Out_2, (_InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3.xxxx), _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3);
                float _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0 = _RockHeight;
                float _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2;
                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2);
                UnityTexture2D _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend /= dot(Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend, 1.0);
                float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_X = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.zy);
                float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Y = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xz);
                float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Z = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xy);
                float4 _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0 = Triplanar_358c24aad7c14e0a924836817da2e7b9_X * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.x + Triplanar_358c24aad7c14e0a924836817da2e7b9_Y * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.y + Triplanar_358c24aad7c14e0a924836817da2e7b9_Z * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.z;
                float _Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0 = _GrassHeight;
                float _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3;
                Unity_InverseLerp_float(_Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3);
                float4 _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3;
                Unity_Lerp_float4(_Power_04f1890bf939475b9826ed03816155ce_Out_2, _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, (_InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3.xxxx), _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3);
                float _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0 = _NearbyPickHeight;
                float _Comparison_0c144defb135447fa506399b1e5b782c_Out_2;
                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Comparison_0c144defb135447fa506399b1e5b782c_Out_2);
                UnityTexture2D _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                float3 Triplanar_67e476af87e34432bb1425483e85eeaf_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                float3 Triplanar_67e476af87e34432bb1425483e85eeaf_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                Triplanar_67e476af87e34432bb1425483e85eeaf_Blend /= dot(Triplanar_67e476af87e34432bb1425483e85eeaf_Blend, 1.0);
                float4 Triplanar_67e476af87e34432bb1425483e85eeaf_X = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.zy);
                float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Y = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xz);
                float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Z = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xy);
                float4 _Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0 = Triplanar_67e476af87e34432bb1425483e85eeaf_X * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.x + Triplanar_67e476af87e34432bb1425483e85eeaf_Y * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.y + Triplanar_67e476af87e34432bb1425483e85eeaf_Z * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.z;
                UnityTexture2D _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend /= dot(Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend, 1.0);
                float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.zy);
                float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xz);
                float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xy);
                float4 _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0 = Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.x + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.y + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.z;
                float4 _Blend_18b55f11871e43b0a33d88203ed53708_Out_2;
                Unity_Blend_Screen_float4(_Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0, _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, 0.39);
                float _Property_7e4dc6d5804f488db1d161cc882419e8_Out_0 = _RockHeight;
                float _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3;
                Unity_InverseLerp_float(_Property_7e4dc6d5804f488db1d161cc882419e8_Out_0, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3);
                float4 _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3;
                Unity_Lerp_float4(_Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, (_InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3.xxxx), _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3);
                float _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0 = _SnowHeight;
                float _Comparison_f94a526e09724297a991b6e76aec137f_Out_2;
                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0, _Comparison_f94a526e09724297a991b6e76aec137f_Out_2);
                UnityTexture2D _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend /= dot(Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend, 1.0);
                float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.zy);
                float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xz);
                float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xy);
                float4 _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0 = Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.x + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.y + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.z;
                float _Property_a4d949d8c5254a3e87c67e9c593124af_Out_0 = _NearbyPickHeight;
                float _Property_3964305cc05045849c1082166182507e_Out_0 = _SnowHeight;
                float _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3;
                Unity_InverseLerp_float(_Property_a4d949d8c5254a3e87c67e9c593124af_Out_0, _Property_3964305cc05045849c1082166182507e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3);
                float4 _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3;
                Unity_Lerp_float4(_Blend_18b55f11871e43b0a33d88203ed53708_Out_2, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, (_InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3.xxxx), _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3);
                float4 _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3;
                Unity_Branch_float4(_Comparison_f94a526e09724297a991b6e76aec137f_Out_2, _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3);
                float4 _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3;
                Unity_Branch_float4(_Comparison_0c144defb135447fa506399b1e5b782c_Out_2, _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3);
                float4 _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3;
                Unity_Branch_float4(_Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2, _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3);
                float4 _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3;
                Unity_Branch_float4(_Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2, _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3);
                float4 _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3;
                Unity_Branch_float4(_Comparison_befd0823d3d24995af6d977e0af38232_Out_2, _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3, _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3);
                surface.BaseColor = (_Branch_664fbb7767f64053b62a1c4248a59dba_Out_3.xyz);
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = float3(0, 0, 0);
                surface.Metallic = 0;
                surface.Smoothness = 0;
                surface.Occlusion = 1;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

            #endif



                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                float3 unnormalizedNormalWS = input.normalWS;
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.WorldSpacePosition = input.positionWS;
                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif

            ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }

                // Render State
                Cull Back
                Blend One Zero
                ZTest LEqual
                ZWrite On

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag

                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                #pragma multi_compile_fragment _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
                #pragma multi_compile_fragment _ _LIGHT_LAYERS
                #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                // GraphKeywords: <None>

                // Defines

                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SHADOW_COORD
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                #define _FOG_FRAGMENT 1
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                     float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpaceNormal;
                     float3 TangentSpaceNormal;
                     float3 WorldSpacePosition;
                     float3 AbsoluteWorldSpacePosition;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                     float4 interp3 : INTERP3;
                     float3 interp4 : INTERP4;
                     float2 interp5 : INTERP5;
                     float2 interp6 : INTERP6;
                     float3 interp7 : INTERP7;
                     float4 interp8 : INTERP8;
                     float4 interp9 : INTERP9;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz = input.positionWS;
                    output.interp1.xyz = input.normalWS;
                    output.interp2.xyzw = input.tangentWS;
                    output.interp3.xyzw = input.texCoord0;
                    output.interp4.xyz = input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.interp6.xy = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp7.xyz = input.sh;
                    #endif
                    output.interp8.xyzw = input.fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.interp9.xyzw = input.shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.interp5.xy;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.interp6.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp7.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp8.xyzw;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.interp9.xyzw;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _WaterTexture_TexelSize;
                float _WaterHeight;
                float4 _SandTexture_TexelSize;
                float _SandHeight;
                float4 _GrassTexture_TexelSize;
                float _GrassHeight;
                float4 _RockTexture_TexelSize;
                float _RockHeight;
                float4 _SnowTexture_TexelSize;
                float _SnowHeight;
                float _NearbyPickHeight;
                float4 _WaterNormal_TexelSize;
                float4 _RockNormal_TexelSize;
                float4 _GrassNormal_TexelSize;
                float4 _SandNormal_TexelSize;
                float4 _SnowNormal_TexelSize;
                CBUFFER_END

                    // Object and Global properties
                    SAMPLER(SamplerState_Linear_Repeat);
                    TEXTURE2D(_WaterTexture);
                    SAMPLER(sampler_WaterTexture);
                    TEXTURE2D(_SandTexture);
                    SAMPLER(sampler_SandTexture);
                    TEXTURE2D(_GrassTexture);
                    SAMPLER(sampler_GrassTexture);
                    TEXTURE2D(_RockTexture);
                    SAMPLER(sampler_RockTexture);
                    TEXTURE2D(_SnowTexture);
                    SAMPLER(sampler_SnowTexture);
                    TEXTURE2D(_WaterNormal);
                    SAMPLER(sampler_WaterNormal);
                    TEXTURE2D(_RockNormal);
                    SAMPLER(sampler_RockNormal);
                    TEXTURE2D(_GrassNormal);
                    SAMPLER(sampler_GrassNormal);
                    TEXTURE2D(_SandNormal);
                    SAMPLER(sampler_SandNormal);
                    TEXTURE2D(_SnowNormal);
                    SAMPLER(sampler_SnowNormal);

                    // Graph Includes
                    // GraphIncludes: <None>

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Functions

                    void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
                    {
                        Out = A <= B ? 1 : 0;
                    }

                    void Unity_InverseLerp_float(float A, float B, float T, out float Out)
                    {
                        Out = (T - A) / (B - A);
                    }

                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                    {
                        Out = lerp(A, B, T);
                    }

                    void Unity_Blend_Exclusion_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                    {
                        Out = Blend + Base - (2.0 * Blend * Base);
                        Out = lerp(Base, Out, Opacity);
                    }

                    void Unity_Power_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = pow(A, B);
                    }

                    void Unity_Blend_Screen_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                    {
                        Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
                        Out = lerp(Base, Out, Opacity);
                    }

                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                    {
                        Out = Predicate ? True : False;
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        description.Position = IN.ObjectSpacePosition;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float3 BaseColor;
                        float3 NormalTS;
                        float3 Emission;
                        float Metallic;
                        float Smoothness;
                        float Occlusion;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float4 _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0 = IN.uv0;
                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_R_1 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[0];
                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[1];
                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_B_3 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[2];
                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_A_4 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[3];
                        float _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0 = _SandHeight;
                        float _Comparison_befd0823d3d24995af6d977e0af38232_Out_2;
                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Comparison_befd0823d3d24995af6d977e0af38232_Out_2);
                        UnityTexture2D _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0 = UnityBuildTexture2DStructNoScale(_WaterTexture);
                        float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                        float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                        Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend /= dot(Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend, 1.0);
                        float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.zy);
                        float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xz);
                        float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xy);
                        float4 _Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0 = Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.x + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.y + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.z;
                        UnityTexture2D _Property_36337b09844644179547e9e25c7c4274_Out_0 = UnityBuildTexture2DStructNoScale(_SandTexture);
                        float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                        float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                        Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend /= dot(Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend, 1.0);
                        float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_X = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.zy);
                        float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xz);
                        float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xy);
                        float4 _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0 = Triplanar_b5daae74a8384db9b8d43474f55b1cca_X * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.x + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.y + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.z;
                        float _Property_bc6acfb4eb504fa188ea556c8f614756_Out_0 = _WaterHeight;
                        float _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3;
                        Unity_InverseLerp_float(_Property_bc6acfb4eb504fa188ea556c8f614756_Out_0, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3);
                        float4 _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3;
                        Unity_Lerp_float4(_Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0, _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, (_InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3.xxxx), _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3);
                        float _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0 = _GrassHeight;
                        float _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2;
                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2);
                        UnityTexture2D _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0 = UnityBuildTexture2DStructNoScale(_GrassTexture);
                        float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                        float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                        Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend /= dot(Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend, 1.0);
                        float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_X = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.zy);
                        float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xz);
                        float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xy);
                        float4 _Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0 = Triplanar_05b6acc8be54451b8049b91ed12ebc24_X * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.x + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.y + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.z;
                        UnityTexture2D _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                        float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                        float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                        Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend /= dot(Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend, 1.0);
                        float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_X = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.zy);
                        float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Y = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xz);
                        float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Z = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xy);
                        float4 _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0 = Triplanar_1ed180918dcb4468b12011d31552c9d9_X * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.x + Triplanar_1ed180918dcb4468b12011d31552c9d9_Y * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.y + Triplanar_1ed180918dcb4468b12011d31552c9d9_Z * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.z;
                        float4 _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2;
                        Unity_Blend_Exclusion_float4(_Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0, _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0, _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, 0.52);
                        float _Float_cf64f4c58290409ea67cef8f97bd8453_Out_0 = 2.33;
                        float4 _Power_04f1890bf939475b9826ed03816155ce_Out_2;
                        Unity_Power_float4(_Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, (_Float_cf64f4c58290409ea67cef8f97bd8453_Out_0.xxxx), _Power_04f1890bf939475b9826ed03816155ce_Out_2);
                        float _Property_50b2430cc37d40d9862de7ec154fbd82_Out_0 = _SandHeight;
                        float _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3;
                        Unity_InverseLerp_float(_Property_50b2430cc37d40d9862de7ec154fbd82_Out_0, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3);
                        float4 _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3;
                        Unity_Lerp_float4(_Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, _Power_04f1890bf939475b9826ed03816155ce_Out_2, (_InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3.xxxx), _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3);
                        float _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0 = _RockHeight;
                        float _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2;
                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2);
                        UnityTexture2D _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                        float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                        float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                        Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend /= dot(Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend, 1.0);
                        float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_X = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.zy);
                        float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Y = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xz);
                        float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Z = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xy);
                        float4 _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0 = Triplanar_358c24aad7c14e0a924836817da2e7b9_X * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.x + Triplanar_358c24aad7c14e0a924836817da2e7b9_Y * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.y + Triplanar_358c24aad7c14e0a924836817da2e7b9_Z * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.z;
                        float _Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0 = _GrassHeight;
                        float _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3;
                        Unity_InverseLerp_float(_Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3);
                        float4 _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3;
                        Unity_Lerp_float4(_Power_04f1890bf939475b9826ed03816155ce_Out_2, _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, (_InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3.xxxx), _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3);
                        float _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0 = _NearbyPickHeight;
                        float _Comparison_0c144defb135447fa506399b1e5b782c_Out_2;
                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Comparison_0c144defb135447fa506399b1e5b782c_Out_2);
                        UnityTexture2D _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                        float3 Triplanar_67e476af87e34432bb1425483e85eeaf_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                        float3 Triplanar_67e476af87e34432bb1425483e85eeaf_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                        Triplanar_67e476af87e34432bb1425483e85eeaf_Blend /= dot(Triplanar_67e476af87e34432bb1425483e85eeaf_Blend, 1.0);
                        float4 Triplanar_67e476af87e34432bb1425483e85eeaf_X = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.zy);
                        float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Y = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xz);
                        float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Z = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xy);
                        float4 _Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0 = Triplanar_67e476af87e34432bb1425483e85eeaf_X * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.x + Triplanar_67e476af87e34432bb1425483e85eeaf_Y * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.y + Triplanar_67e476af87e34432bb1425483e85eeaf_Z * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.z;
                        UnityTexture2D _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                        float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                        float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                        Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend /= dot(Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend, 1.0);
                        float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.zy);
                        float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xz);
                        float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xy);
                        float4 _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0 = Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.x + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.y + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.z;
                        float4 _Blend_18b55f11871e43b0a33d88203ed53708_Out_2;
                        Unity_Blend_Screen_float4(_Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0, _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, 0.39);
                        float _Property_7e4dc6d5804f488db1d161cc882419e8_Out_0 = _RockHeight;
                        float _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3;
                        Unity_InverseLerp_float(_Property_7e4dc6d5804f488db1d161cc882419e8_Out_0, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3);
                        float4 _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3;
                        Unity_Lerp_float4(_Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, (_InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3.xxxx), _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3);
                        float _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0 = _SnowHeight;
                        float _Comparison_f94a526e09724297a991b6e76aec137f_Out_2;
                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0, _Comparison_f94a526e09724297a991b6e76aec137f_Out_2);
                        UnityTexture2D _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                        float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                        float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                        Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend /= dot(Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend, 1.0);
                        float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.zy);
                        float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xz);
                        float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xy);
                        float4 _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0 = Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.x + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.y + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.z;
                        float _Property_a4d949d8c5254a3e87c67e9c593124af_Out_0 = _NearbyPickHeight;
                        float _Property_3964305cc05045849c1082166182507e_Out_0 = _SnowHeight;
                        float _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3;
                        Unity_InverseLerp_float(_Property_a4d949d8c5254a3e87c67e9c593124af_Out_0, _Property_3964305cc05045849c1082166182507e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3);
                        float4 _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3;
                        Unity_Lerp_float4(_Blend_18b55f11871e43b0a33d88203ed53708_Out_2, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, (_InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3.xxxx), _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3);
                        float4 _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3;
                        Unity_Branch_float4(_Comparison_f94a526e09724297a991b6e76aec137f_Out_2, _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3);
                        float4 _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3;
                        Unity_Branch_float4(_Comparison_0c144defb135447fa506399b1e5b782c_Out_2, _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3);
                        float4 _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3;
                        Unity_Branch_float4(_Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2, _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3);
                        float4 _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3;
                        Unity_Branch_float4(_Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2, _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3);
                        float4 _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3;
                        Unity_Branch_float4(_Comparison_befd0823d3d24995af6d977e0af38232_Out_2, _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3, _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3);
                        surface.BaseColor = (_Branch_664fbb7767f64053b62a1c4248a59dba_Out_3.xyz);
                        surface.NormalTS = IN.TangentSpaceNormal;
                        surface.Emission = float3(0, 0, 0);
                        surface.Metallic = 0;
                        surface.Smoothness = 0;
                        surface.Occlusion = 1;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs
                    #ifdef HAVE_VFX_MODIFICATION
                    #define VFX_SRP_ATTRIBUTES Attributes
                    #define VFX_SRP_VARYINGS Varyings
                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                    #endif
                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.ObjectSpacePosition = input.positionOS;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                    #ifdef HAVE_VFX_MODIFICATION
                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                    #endif



                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                        float3 unnormalizedNormalWS = input.normalWS;
                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                        output.WorldSpacePosition = input.positionWS;
                        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                        output.uv0 = input.texCoord0;
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                    }

                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

                    // --------------------------------------------------
                    // Visual Effect Vertex Invocations
                    #ifdef HAVE_VFX_MODIFICATION
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                    #endif

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "ShadowCaster"
                        Tags
                        {
                            "LightMode" = "ShadowCaster"
                        }

                        // Render State
                        Cull Back
                        ZTest LEqual
                        ZWrite On
                        ColorMask 0

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 4.5
                        #pragma exclude_renderers gles gles3 glcore
                        #pragma multi_compile_instancing
                        #pragma multi_compile _ DOTS_INSTANCING_ON
                        #pragma vertex vert
                        #pragma fragment frag

                        // DotsInstancingOptions: <None>
                        // HybridV1InjectedBuiltinProperties: <None>

                        // Keywords
                        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                        // GraphKeywords: <None>

                        // Defines

                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define VARYINGS_NEED_NORMAL_WS
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 normalWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 interp0 : INTERP0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.interp0.xyz = input.normalWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.normalWS = input.interp0.xyz;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float4 _WaterTexture_TexelSize;
                        float _WaterHeight;
                        float4 _SandTexture_TexelSize;
                        float _SandHeight;
                        float4 _GrassTexture_TexelSize;
                        float _GrassHeight;
                        float4 _RockTexture_TexelSize;
                        float _RockHeight;
                        float4 _SnowTexture_TexelSize;
                        float _SnowHeight;
                        float _NearbyPickHeight;
                        float4 _WaterNormal_TexelSize;
                        float4 _RockNormal_TexelSize;
                        float4 _GrassNormal_TexelSize;
                        float4 _SandNormal_TexelSize;
                        float4 _SnowNormal_TexelSize;
                        CBUFFER_END

                            // Object and Global properties
                            SAMPLER(SamplerState_Linear_Repeat);
                            TEXTURE2D(_WaterTexture);
                            SAMPLER(sampler_WaterTexture);
                            TEXTURE2D(_SandTexture);
                            SAMPLER(sampler_SandTexture);
                            TEXTURE2D(_GrassTexture);
                            SAMPLER(sampler_GrassTexture);
                            TEXTURE2D(_RockTexture);
                            SAMPLER(sampler_RockTexture);
                            TEXTURE2D(_SnowTexture);
                            SAMPLER(sampler_SnowTexture);
                            TEXTURE2D(_WaterNormal);
                            SAMPLER(sampler_WaterNormal);
                            TEXTURE2D(_RockNormal);
                            SAMPLER(sampler_RockNormal);
                            TEXTURE2D(_GrassNormal);
                            SAMPLER(sampler_GrassNormal);
                            TEXTURE2D(_SandNormal);
                            SAMPLER(sampler_SandNormal);
                            TEXTURE2D(_SnowNormal);
                            SAMPLER(sampler_SnowNormal);

                            // Graph Includes
                            // GraphIncludes: <None>

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Functions
                            // GraphFunctions: <None>

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                description.Position = IN.ObjectSpacePosition;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs
                            #ifdef HAVE_VFX_MODIFICATION
                            #define VFX_SRP_ATTRIBUTES Attributes
                            #define VFX_SRP_VARYINGS Varyings
                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                            #endif
                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.ObjectSpacePosition = input.positionOS;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                            #ifdef HAVE_VFX_MODIFICATION
                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                            #endif







                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                            }

                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                            // --------------------------------------------------
                            // Visual Effect Vertex Invocations
                            #ifdef HAVE_VFX_MODIFICATION
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                            #endif

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "DepthOnly"
                                Tags
                                {
                                    "LightMode" = "DepthOnly"
                                }

                                // Render State
                                Cull Back
                                ZTest LEqual
                                ZWrite On
                                ColorMask 0

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 4.5
                                #pragma exclude_renderers gles gles3 glcore
                                #pragma multi_compile_instancing
                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                #pragma vertex vert
                                #pragma fragment frag

                                // DotsInstancingOptions: <None>
                                // HybridV1InjectedBuiltinProperties: <None>

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines

                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float4 _WaterTexture_TexelSize;
                                float _WaterHeight;
                                float4 _SandTexture_TexelSize;
                                float _SandHeight;
                                float4 _GrassTexture_TexelSize;
                                float _GrassHeight;
                                float4 _RockTexture_TexelSize;
                                float _RockHeight;
                                float4 _SnowTexture_TexelSize;
                                float _SnowHeight;
                                float _NearbyPickHeight;
                                float4 _WaterNormal_TexelSize;
                                float4 _RockNormal_TexelSize;
                                float4 _GrassNormal_TexelSize;
                                float4 _SandNormal_TexelSize;
                                float4 _SnowNormal_TexelSize;
                                CBUFFER_END

                                    // Object and Global properties
                                    SAMPLER(SamplerState_Linear_Repeat);
                                    TEXTURE2D(_WaterTexture);
                                    SAMPLER(sampler_WaterTexture);
                                    TEXTURE2D(_SandTexture);
                                    SAMPLER(sampler_SandTexture);
                                    TEXTURE2D(_GrassTexture);
                                    SAMPLER(sampler_GrassTexture);
                                    TEXTURE2D(_RockTexture);
                                    SAMPLER(sampler_RockTexture);
                                    TEXTURE2D(_SnowTexture);
                                    SAMPLER(sampler_SnowTexture);
                                    TEXTURE2D(_WaterNormal);
                                    SAMPLER(sampler_WaterNormal);
                                    TEXTURE2D(_RockNormal);
                                    SAMPLER(sampler_RockNormal);
                                    TEXTURE2D(_GrassNormal);
                                    SAMPLER(sampler_GrassNormal);
                                    TEXTURE2D(_SandNormal);
                                    SAMPLER(sampler_SandNormal);
                                    TEXTURE2D(_SnowNormal);
                                    SAMPLER(sampler_SnowNormal);

                                    // Graph Includes
                                    // GraphIncludes: <None>

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                    // -- Properties used by SceneSelectionPass
                                    #ifdef SCENESELECTIONPASS
                                    int _ObjectId;
                                    int _PassValue;
                                    #endif

                                    // Graph Functions
                                    // GraphFunctions: <None>

                                    // Custom interpolators pre vertex
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                    // Graph Vertex
                                    struct VertexDescription
                                    {
                                        float3 Position;
                                        float3 Normal;
                                        float3 Tangent;
                                    };

                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                    {
                                        VertexDescription description = (VertexDescription)0;
                                        description.Position = IN.ObjectSpacePosition;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Custom interpolators, pre surface
                                    #ifdef FEATURES_GRAPH_VERTEX
                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                    {
                                    return output;
                                    }
                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                    #endif

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #define VFX_SRP_ATTRIBUTES Attributes
                                    #define VFX_SRP_VARYINGS Varyings
                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                    #endif
                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                        output.ObjectSpacePosition = input.positionOS;

                                        return output;
                                    }
                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                    #ifdef HAVE_VFX_MODIFICATION
                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                    #endif







                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                    #else
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                    #endif
                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                            return output;
                                    }

                                    // --------------------------------------------------
                                    // Main

                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                    // --------------------------------------------------
                                    // Visual Effect Vertex Invocations
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                    #endif

                                    ENDHLSL
                                    }
                                    Pass
                                    {
                                        Name "DepthNormals"
                                        Tags
                                        {
                                            "LightMode" = "DepthNormals"
                                        }

                                        // Render State
                                        Cull Back
                                        ZTest LEqual
                                        ZWrite On

                                        // Debug
                                        // <None>

                                        // --------------------------------------------------
                                        // Pass

                                        HLSLPROGRAM

                                        // Pragmas
                                        #pragma target 4.5
                                        #pragma exclude_renderers gles gles3 glcore
                                        #pragma multi_compile_instancing
                                        #pragma multi_compile _ DOTS_INSTANCING_ON
                                        #pragma vertex vert
                                        #pragma fragment frag

                                        // DotsInstancingOptions: <None>
                                        // HybridV1InjectedBuiltinProperties: <None>

                                        // Keywords
                                        // PassKeywords: <None>
                                        // GraphKeywords: <None>

                                        // Defines

                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_TS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                        #define VARYINGS_NEED_NORMAL_WS
                                        #define VARYINGS_NEED_TANGENT_WS
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                        // custom interpolator pre-include
                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                        // Includes
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                        // --------------------------------------------------
                                        // Structs and Packing

                                        // custom interpolators pre packing
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                        struct Attributes
                                        {
                                             float3 positionOS : POSITION;
                                             float3 normalOS : NORMAL;
                                             float4 tangentOS : TANGENT;
                                             float4 uv1 : TEXCOORD1;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 normalWS;
                                             float4 tangentWS;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };
                                        struct SurfaceDescriptionInputs
                                        {
                                             float3 TangentSpaceNormal;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                             float3 ObjectSpaceNormal;
                                             float3 ObjectSpaceTangent;
                                             float3 ObjectSpacePosition;
                                        };
                                        struct PackedVaryings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 interp0 : INTERP0;
                                             float4 interp1 : INTERP1;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };

                                        PackedVaryings PackVaryings(Varyings input)
                                        {
                                            PackedVaryings output;
                                            ZERO_INITIALIZE(PackedVaryings, output);
                                            output.positionCS = input.positionCS;
                                            output.interp0.xyz = input.normalWS;
                                            output.interp1.xyzw = input.tangentWS;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }

                                        Varyings UnpackVaryings(PackedVaryings input)
                                        {
                                            Varyings output;
                                            output.positionCS = input.positionCS;
                                            output.normalWS = input.interp0.xyz;
                                            output.tangentWS = input.interp1.xyzw;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }


                                        // --------------------------------------------------
                                        // Graph

                                        // Graph Properties
                                        CBUFFER_START(UnityPerMaterial)
                                        float4 _WaterTexture_TexelSize;
                                        float _WaterHeight;
                                        float4 _SandTexture_TexelSize;
                                        float _SandHeight;
                                        float4 _GrassTexture_TexelSize;
                                        float _GrassHeight;
                                        float4 _RockTexture_TexelSize;
                                        float _RockHeight;
                                        float4 _SnowTexture_TexelSize;
                                        float _SnowHeight;
                                        float _NearbyPickHeight;
                                        float4 _WaterNormal_TexelSize;
                                        float4 _RockNormal_TexelSize;
                                        float4 _GrassNormal_TexelSize;
                                        float4 _SandNormal_TexelSize;
                                        float4 _SnowNormal_TexelSize;
                                        CBUFFER_END

                                            // Object and Global properties
                                            SAMPLER(SamplerState_Linear_Repeat);
                                            TEXTURE2D(_WaterTexture);
                                            SAMPLER(sampler_WaterTexture);
                                            TEXTURE2D(_SandTexture);
                                            SAMPLER(sampler_SandTexture);
                                            TEXTURE2D(_GrassTexture);
                                            SAMPLER(sampler_GrassTexture);
                                            TEXTURE2D(_RockTexture);
                                            SAMPLER(sampler_RockTexture);
                                            TEXTURE2D(_SnowTexture);
                                            SAMPLER(sampler_SnowTexture);
                                            TEXTURE2D(_WaterNormal);
                                            SAMPLER(sampler_WaterNormal);
                                            TEXTURE2D(_RockNormal);
                                            SAMPLER(sampler_RockNormal);
                                            TEXTURE2D(_GrassNormal);
                                            SAMPLER(sampler_GrassNormal);
                                            TEXTURE2D(_SandNormal);
                                            SAMPLER(sampler_SandNormal);
                                            TEXTURE2D(_SnowNormal);
                                            SAMPLER(sampler_SnowNormal);

                                            // Graph Includes
                                            // GraphIncludes: <None>

                                            // -- Property used by ScenePickingPass
                                            #ifdef SCENEPICKINGPASS
                                            float4 _SelectionID;
                                            #endif

                                            // -- Properties used by SceneSelectionPass
                                            #ifdef SCENESELECTIONPASS
                                            int _ObjectId;
                                            int _PassValue;
                                            #endif

                                            // Graph Functions
                                            // GraphFunctions: <None>

                                            // Custom interpolators pre vertex
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                            // Graph Vertex
                                            struct VertexDescription
                                            {
                                                float3 Position;
                                                float3 Normal;
                                                float3 Tangent;
                                            };

                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                            {
                                                VertexDescription description = (VertexDescription)0;
                                                description.Position = IN.ObjectSpacePosition;
                                                description.Normal = IN.ObjectSpaceNormal;
                                                description.Tangent = IN.ObjectSpaceTangent;
                                                return description;
                                            }

                                            // Custom interpolators, pre surface
                                            #ifdef FEATURES_GRAPH_VERTEX
                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                            {
                                            return output;
                                            }
                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                            #endif

                                            // Graph Pixel
                                            struct SurfaceDescription
                                            {
                                                float3 NormalTS;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                return surface;
                                            }

                                            // --------------------------------------------------
                                            // Build Graph Inputs
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #define VFX_SRP_ATTRIBUTES Attributes
                                            #define VFX_SRP_VARYINGS Varyings
                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                            #endif
                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                            {
                                                VertexDescriptionInputs output;
                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                output.ObjectSpaceNormal = input.normalOS;
                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                output.ObjectSpacePosition = input.positionOS;

                                                return output;
                                            }
                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                            #ifdef HAVE_VFX_MODIFICATION
                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                            #endif





                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                            #else
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                            #endif
                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                    return output;
                                            }

                                            // --------------------------------------------------
                                            // Main

                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                            // --------------------------------------------------
                                            // Visual Effect Vertex Invocations
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                            #endif

                                            ENDHLSL
                                            }
                                            Pass
                                            {
                                                Name "Meta"
                                                Tags
                                                {
                                                    "LightMode" = "Meta"
                                                }

                                                // Render State
                                                Cull Off

                                                // Debug
                                                // <None>

                                                // --------------------------------------------------
                                                // Pass

                                                HLSLPROGRAM

                                                // Pragmas
                                                #pragma target 4.5
                                                #pragma exclude_renderers gles gles3 glcore
                                                #pragma vertex vert
                                                #pragma fragment frag

                                                // DotsInstancingOptions: <None>
                                                // HybridV1InjectedBuiltinProperties: <None>

                                                // Keywords
                                                #pragma shader_feature _ EDITOR_VISUALIZATION
                                                // GraphKeywords: <None>

                                                // Defines

                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_TS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                #define VARYINGS_NEED_POSITION_WS
                                                #define VARYINGS_NEED_NORMAL_WS
                                                #define VARYINGS_NEED_TEXCOORD0
                                                #define VARYINGS_NEED_TEXCOORD1
                                                #define VARYINGS_NEED_TEXCOORD2
                                                #define FEATURES_GRAPH_VERTEX
                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                #define SHADERPASS SHADERPASS_META
                                                #define _FOG_FRAGMENT 1
                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                // custom interpolator pre-include
                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                // Includes
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                // --------------------------------------------------
                                                // Structs and Packing

                                                // custom interpolators pre packing
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                struct Attributes
                                                {
                                                     float3 positionOS : POSITION;
                                                     float3 normalOS : NORMAL;
                                                     float4 tangentOS : TANGENT;
                                                     float4 uv0 : TEXCOORD0;
                                                     float4 uv1 : TEXCOORD1;
                                                     float4 uv2 : TEXCOORD2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 positionWS;
                                                     float3 normalWS;
                                                     float4 texCoord0;
                                                     float4 texCoord1;
                                                     float4 texCoord2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };
                                                struct SurfaceDescriptionInputs
                                                {
                                                     float3 WorldSpaceNormal;
                                                     float3 WorldSpacePosition;
                                                     float3 AbsoluteWorldSpacePosition;
                                                     float4 uv0;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                     float3 ObjectSpaceNormal;
                                                     float3 ObjectSpaceTangent;
                                                     float3 ObjectSpacePosition;
                                                };
                                                struct PackedVaryings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 interp0 : INTERP0;
                                                     float3 interp1 : INTERP1;
                                                     float4 interp2 : INTERP2;
                                                     float4 interp3 : INTERP3;
                                                     float4 interp4 : INTERP4;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };

                                                PackedVaryings PackVaryings(Varyings input)
                                                {
                                                    PackedVaryings output;
                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                    output.positionCS = input.positionCS;
                                                    output.interp0.xyz = input.positionWS;
                                                    output.interp1.xyz = input.normalWS;
                                                    output.interp2.xyzw = input.texCoord0;
                                                    output.interp3.xyzw = input.texCoord1;
                                                    output.interp4.xyzw = input.texCoord2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }

                                                Varyings UnpackVaryings(PackedVaryings input)
                                                {
                                                    Varyings output;
                                                    output.positionCS = input.positionCS;
                                                    output.positionWS = input.interp0.xyz;
                                                    output.normalWS = input.interp1.xyz;
                                                    output.texCoord0 = input.interp2.xyzw;
                                                    output.texCoord1 = input.interp3.xyzw;
                                                    output.texCoord2 = input.interp4.xyzw;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }


                                                // --------------------------------------------------
                                                // Graph

                                                // Graph Properties
                                                CBUFFER_START(UnityPerMaterial)
                                                float4 _WaterTexture_TexelSize;
                                                float _WaterHeight;
                                                float4 _SandTexture_TexelSize;
                                                float _SandHeight;
                                                float4 _GrassTexture_TexelSize;
                                                float _GrassHeight;
                                                float4 _RockTexture_TexelSize;
                                                float _RockHeight;
                                                float4 _SnowTexture_TexelSize;
                                                float _SnowHeight;
                                                float _NearbyPickHeight;
                                                float4 _WaterNormal_TexelSize;
                                                float4 _RockNormal_TexelSize;
                                                float4 _GrassNormal_TexelSize;
                                                float4 _SandNormal_TexelSize;
                                                float4 _SnowNormal_TexelSize;
                                                CBUFFER_END

                                                    // Object and Global properties
                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                    TEXTURE2D(_WaterTexture);
                                                    SAMPLER(sampler_WaterTexture);
                                                    TEXTURE2D(_SandTexture);
                                                    SAMPLER(sampler_SandTexture);
                                                    TEXTURE2D(_GrassTexture);
                                                    SAMPLER(sampler_GrassTexture);
                                                    TEXTURE2D(_RockTexture);
                                                    SAMPLER(sampler_RockTexture);
                                                    TEXTURE2D(_SnowTexture);
                                                    SAMPLER(sampler_SnowTexture);
                                                    TEXTURE2D(_WaterNormal);
                                                    SAMPLER(sampler_WaterNormal);
                                                    TEXTURE2D(_RockNormal);
                                                    SAMPLER(sampler_RockNormal);
                                                    TEXTURE2D(_GrassNormal);
                                                    SAMPLER(sampler_GrassNormal);
                                                    TEXTURE2D(_SandNormal);
                                                    SAMPLER(sampler_SandNormal);
                                                    TEXTURE2D(_SnowNormal);
                                                    SAMPLER(sampler_SnowNormal);

                                                    // Graph Includes
                                                    // GraphIncludes: <None>

                                                    // -- Property used by ScenePickingPass
                                                    #ifdef SCENEPICKINGPASS
                                                    float4 _SelectionID;
                                                    #endif

                                                    // -- Properties used by SceneSelectionPass
                                                    #ifdef SCENESELECTIONPASS
                                                    int _ObjectId;
                                                    int _PassValue;
                                                    #endif

                                                    // Graph Functions

                                                    void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
                                                    {
                                                        Out = A <= B ? 1 : 0;
                                                    }

                                                    void Unity_InverseLerp_float(float A, float B, float T, out float Out)
                                                    {
                                                        Out = (T - A) / (B - A);
                                                    }

                                                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                    {
                                                        Out = lerp(A, B, T);
                                                    }

                                                    void Unity_Blend_Exclusion_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                                    {
                                                        Out = Blend + Base - (2.0 * Blend * Base);
                                                        Out = lerp(Base, Out, Opacity);
                                                    }

                                                    void Unity_Power_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = pow(A, B);
                                                    }

                                                    void Unity_Blend_Screen_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                                    {
                                                        Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
                                                        Out = lerp(Base, Out, Opacity);
                                                    }

                                                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                    {
                                                        Out = Predicate ? True : False;
                                                    }

                                                    // Custom interpolators pre vertex
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                    // Graph Vertex
                                                    struct VertexDescription
                                                    {
                                                        float3 Position;
                                                        float3 Normal;
                                                        float3 Tangent;
                                                    };

                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                    {
                                                        VertexDescription description = (VertexDescription)0;
                                                        description.Position = IN.ObjectSpacePosition;
                                                        description.Normal = IN.ObjectSpaceNormal;
                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                        return description;
                                                    }

                                                    // Custom interpolators, pre surface
                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                    {
                                                    return output;
                                                    }
                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                    #endif

                                                    // Graph Pixel
                                                    struct SurfaceDescription
                                                    {
                                                        float3 BaseColor;
                                                        float3 Emission;
                                                    };

                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                    {
                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                        float4 _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0 = IN.uv0;
                                                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_R_1 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[0];
                                                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[1];
                                                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_B_3 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[2];
                                                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_A_4 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[3];
                                                        float _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0 = _SandHeight;
                                                        float _Comparison_befd0823d3d24995af6d977e0af38232_Out_2;
                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Comparison_befd0823d3d24995af6d977e0af38232_Out_2);
                                                        UnityTexture2D _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0 = UnityBuildTexture2DStructNoScale(_WaterTexture);
                                                        float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                        float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                        Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend /= dot(Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend, 1.0);
                                                        float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.zy);
                                                        float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xz);
                                                        float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xy);
                                                        float4 _Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0 = Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.x + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.y + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.z;
                                                        UnityTexture2D _Property_36337b09844644179547e9e25c7c4274_Out_0 = UnityBuildTexture2DStructNoScale(_SandTexture);
                                                        float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                        float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                        Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend /= dot(Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend, 1.0);
                                                        float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_X = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.zy);
                                                        float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xz);
                                                        float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xy);
                                                        float4 _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0 = Triplanar_b5daae74a8384db9b8d43474f55b1cca_X * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.x + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.y + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.z;
                                                        float _Property_bc6acfb4eb504fa188ea556c8f614756_Out_0 = _WaterHeight;
                                                        float _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3;
                                                        Unity_InverseLerp_float(_Property_bc6acfb4eb504fa188ea556c8f614756_Out_0, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3);
                                                        float4 _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3;
                                                        Unity_Lerp_float4(_Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0, _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, (_InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3.xxxx), _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3);
                                                        float _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0 = _GrassHeight;
                                                        float _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2;
                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2);
                                                        UnityTexture2D _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0 = UnityBuildTexture2DStructNoScale(_GrassTexture);
                                                        float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                        float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                        Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend /= dot(Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend, 1.0);
                                                        float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_X = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.zy);
                                                        float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xz);
                                                        float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xy);
                                                        float4 _Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0 = Triplanar_05b6acc8be54451b8049b91ed12ebc24_X * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.x + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.y + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.z;
                                                        UnityTexture2D _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                        float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                        float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                        Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend /= dot(Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend, 1.0);
                                                        float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_X = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.zy);
                                                        float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Y = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xz);
                                                        float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Z = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xy);
                                                        float4 _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0 = Triplanar_1ed180918dcb4468b12011d31552c9d9_X * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.x + Triplanar_1ed180918dcb4468b12011d31552c9d9_Y * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.y + Triplanar_1ed180918dcb4468b12011d31552c9d9_Z * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.z;
                                                        float4 _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2;
                                                        Unity_Blend_Exclusion_float4(_Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0, _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0, _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, 0.52);
                                                        float _Float_cf64f4c58290409ea67cef8f97bd8453_Out_0 = 2.33;
                                                        float4 _Power_04f1890bf939475b9826ed03816155ce_Out_2;
                                                        Unity_Power_float4(_Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, (_Float_cf64f4c58290409ea67cef8f97bd8453_Out_0.xxxx), _Power_04f1890bf939475b9826ed03816155ce_Out_2);
                                                        float _Property_50b2430cc37d40d9862de7ec154fbd82_Out_0 = _SandHeight;
                                                        float _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3;
                                                        Unity_InverseLerp_float(_Property_50b2430cc37d40d9862de7ec154fbd82_Out_0, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3);
                                                        float4 _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3;
                                                        Unity_Lerp_float4(_Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, _Power_04f1890bf939475b9826ed03816155ce_Out_2, (_InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3.xxxx), _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3);
                                                        float _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0 = _RockHeight;
                                                        float _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2;
                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2);
                                                        UnityTexture2D _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                        float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                        float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                        Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend /= dot(Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend, 1.0);
                                                        float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_X = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.zy);
                                                        float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Y = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xz);
                                                        float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Z = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xy);
                                                        float4 _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0 = Triplanar_358c24aad7c14e0a924836817da2e7b9_X * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.x + Triplanar_358c24aad7c14e0a924836817da2e7b9_Y * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.y + Triplanar_358c24aad7c14e0a924836817da2e7b9_Z * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.z;
                                                        float _Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0 = _GrassHeight;
                                                        float _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3;
                                                        Unity_InverseLerp_float(_Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3);
                                                        float4 _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3;
                                                        Unity_Lerp_float4(_Power_04f1890bf939475b9826ed03816155ce_Out_2, _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, (_InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3.xxxx), _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3);
                                                        float _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0 = _NearbyPickHeight;
                                                        float _Comparison_0c144defb135447fa506399b1e5b782c_Out_2;
                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Comparison_0c144defb135447fa506399b1e5b782c_Out_2);
                                                        UnityTexture2D _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                        float3 Triplanar_67e476af87e34432bb1425483e85eeaf_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                        float3 Triplanar_67e476af87e34432bb1425483e85eeaf_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                        Triplanar_67e476af87e34432bb1425483e85eeaf_Blend /= dot(Triplanar_67e476af87e34432bb1425483e85eeaf_Blend, 1.0);
                                                        float4 Triplanar_67e476af87e34432bb1425483e85eeaf_X = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.zy);
                                                        float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Y = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xz);
                                                        float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Z = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xy);
                                                        float4 _Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0 = Triplanar_67e476af87e34432bb1425483e85eeaf_X * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.x + Triplanar_67e476af87e34432bb1425483e85eeaf_Y * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.y + Triplanar_67e476af87e34432bb1425483e85eeaf_Z * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.z;
                                                        UnityTexture2D _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                                                        float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                        float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                        Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend /= dot(Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend, 1.0);
                                                        float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.zy);
                                                        float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xz);
                                                        float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xy);
                                                        float4 _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0 = Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.x + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.y + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.z;
                                                        float4 _Blend_18b55f11871e43b0a33d88203ed53708_Out_2;
                                                        Unity_Blend_Screen_float4(_Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0, _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, 0.39);
                                                        float _Property_7e4dc6d5804f488db1d161cc882419e8_Out_0 = _RockHeight;
                                                        float _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3;
                                                        Unity_InverseLerp_float(_Property_7e4dc6d5804f488db1d161cc882419e8_Out_0, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3);
                                                        float4 _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3;
                                                        Unity_Lerp_float4(_Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, (_InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3.xxxx), _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3);
                                                        float _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0 = _SnowHeight;
                                                        float _Comparison_f94a526e09724297a991b6e76aec137f_Out_2;
                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0, _Comparison_f94a526e09724297a991b6e76aec137f_Out_2);
                                                        UnityTexture2D _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                                                        float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                        float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                        Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend /= dot(Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend, 1.0);
                                                        float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.zy);
                                                        float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xz);
                                                        float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xy);
                                                        float4 _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0 = Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.x + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.y + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.z;
                                                        float _Property_a4d949d8c5254a3e87c67e9c593124af_Out_0 = _NearbyPickHeight;
                                                        float _Property_3964305cc05045849c1082166182507e_Out_0 = _SnowHeight;
                                                        float _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3;
                                                        Unity_InverseLerp_float(_Property_a4d949d8c5254a3e87c67e9c593124af_Out_0, _Property_3964305cc05045849c1082166182507e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3);
                                                        float4 _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3;
                                                        Unity_Lerp_float4(_Blend_18b55f11871e43b0a33d88203ed53708_Out_2, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, (_InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3.xxxx), _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3);
                                                        float4 _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3;
                                                        Unity_Branch_float4(_Comparison_f94a526e09724297a991b6e76aec137f_Out_2, _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3);
                                                        float4 _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3;
                                                        Unity_Branch_float4(_Comparison_0c144defb135447fa506399b1e5b782c_Out_2, _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3);
                                                        float4 _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3;
                                                        Unity_Branch_float4(_Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2, _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3);
                                                        float4 _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3;
                                                        Unity_Branch_float4(_Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2, _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3);
                                                        float4 _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3;
                                                        Unity_Branch_float4(_Comparison_befd0823d3d24995af6d977e0af38232_Out_2, _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3, _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3);
                                                        surface.BaseColor = (_Branch_664fbb7767f64053b62a1c4248a59dba_Out_3.xyz);
                                                        surface.Emission = float3(0, 0, 0);
                                                        return surface;
                                                    }

                                                    // --------------------------------------------------
                                                    // Build Graph Inputs
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                    #define VFX_SRP_VARYINGS Varyings
                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                    #endif
                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                    {
                                                        VertexDescriptionInputs output;
                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                        output.ObjectSpaceNormal = input.normalOS;
                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                        output.ObjectSpacePosition = input.positionOS;

                                                        return output;
                                                    }
                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                    {
                                                        SurfaceDescriptionInputs output;
                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                    #ifdef HAVE_VFX_MODIFICATION
                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                    #endif



                                                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                        float3 unnormalizedNormalWS = input.normalWS;
                                                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                        output.WorldSpacePosition = input.positionWS;
                                                        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                                                        output.uv0 = input.texCoord0;
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                    #else
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                    #endif
                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                            return output;
                                                    }

                                                    // --------------------------------------------------
                                                    // Main

                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                    // --------------------------------------------------
                                                    // Visual Effect Vertex Invocations
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                    #endif

                                                    ENDHLSL
                                                    }
                                                    Pass
                                                    {
                                                        Name "SceneSelectionPass"
                                                        Tags
                                                        {
                                                            "LightMode" = "SceneSelectionPass"
                                                        }

                                                        // Render State
                                                        Cull Off

                                                        // Debug
                                                        // <None>

                                                        // --------------------------------------------------
                                                        // Pass

                                                        HLSLPROGRAM

                                                        // Pragmas
                                                        #pragma target 4.5
                                                        #pragma exclude_renderers gles gles3 glcore
                                                        #pragma vertex vert
                                                        #pragma fragment frag

                                                        // DotsInstancingOptions: <None>
                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                        // Keywords
                                                        // PassKeywords: <None>
                                                        // GraphKeywords: <None>

                                                        // Defines

                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_TS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define FEATURES_GRAPH_VERTEX
                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                        #define SCENESELECTIONPASS 1
                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                        // custom interpolator pre-include
                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                        // Includes
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                        // --------------------------------------------------
                                                        // Structs and Packing

                                                        // custom interpolators pre packing
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                        struct Attributes
                                                        {
                                                             float3 positionOS : POSITION;
                                                             float3 normalOS : NORMAL;
                                                             float4 tangentOS : TANGENT;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct SurfaceDescriptionInputs
                                                        {
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                             float3 ObjectSpaceNormal;
                                                             float3 ObjectSpaceTangent;
                                                             float3 ObjectSpacePosition;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };

                                                        PackedVaryings PackVaryings(Varyings input)
                                                        {
                                                            PackedVaryings output;
                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                            output.positionCS = input.positionCS;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }

                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                        {
                                                            Varyings output;
                                                            output.positionCS = input.positionCS;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }


                                                        // --------------------------------------------------
                                                        // Graph

                                                        // Graph Properties
                                                        CBUFFER_START(UnityPerMaterial)
                                                        float4 _WaterTexture_TexelSize;
                                                        float _WaterHeight;
                                                        float4 _SandTexture_TexelSize;
                                                        float _SandHeight;
                                                        float4 _GrassTexture_TexelSize;
                                                        float _GrassHeight;
                                                        float4 _RockTexture_TexelSize;
                                                        float _RockHeight;
                                                        float4 _SnowTexture_TexelSize;
                                                        float _SnowHeight;
                                                        float _NearbyPickHeight;
                                                        float4 _WaterNormal_TexelSize;
                                                        float4 _RockNormal_TexelSize;
                                                        float4 _GrassNormal_TexelSize;
                                                        float4 _SandNormal_TexelSize;
                                                        float4 _SnowNormal_TexelSize;
                                                        CBUFFER_END

                                                            // Object and Global properties
                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                            TEXTURE2D(_WaterTexture);
                                                            SAMPLER(sampler_WaterTexture);
                                                            TEXTURE2D(_SandTexture);
                                                            SAMPLER(sampler_SandTexture);
                                                            TEXTURE2D(_GrassTexture);
                                                            SAMPLER(sampler_GrassTexture);
                                                            TEXTURE2D(_RockTexture);
                                                            SAMPLER(sampler_RockTexture);
                                                            TEXTURE2D(_SnowTexture);
                                                            SAMPLER(sampler_SnowTexture);
                                                            TEXTURE2D(_WaterNormal);
                                                            SAMPLER(sampler_WaterNormal);
                                                            TEXTURE2D(_RockNormal);
                                                            SAMPLER(sampler_RockNormal);
                                                            TEXTURE2D(_GrassNormal);
                                                            SAMPLER(sampler_GrassNormal);
                                                            TEXTURE2D(_SandNormal);
                                                            SAMPLER(sampler_SandNormal);
                                                            TEXTURE2D(_SnowNormal);
                                                            SAMPLER(sampler_SnowNormal);

                                                            // Graph Includes
                                                            // GraphIncludes: <None>

                                                            // -- Property used by ScenePickingPass
                                                            #ifdef SCENEPICKINGPASS
                                                            float4 _SelectionID;
                                                            #endif

                                                            // -- Properties used by SceneSelectionPass
                                                            #ifdef SCENESELECTIONPASS
                                                            int _ObjectId;
                                                            int _PassValue;
                                                            #endif

                                                            // Graph Functions
                                                            // GraphFunctions: <None>

                                                            // Custom interpolators pre vertex
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                            // Graph Vertex
                                                            struct VertexDescription
                                                            {
                                                                float3 Position;
                                                                float3 Normal;
                                                                float3 Tangent;
                                                            };

                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                            {
                                                                VertexDescription description = (VertexDescription)0;
                                                                description.Position = IN.ObjectSpacePosition;
                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                return description;
                                                            }

                                                            // Custom interpolators, pre surface
                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                            {
                                                            return output;
                                                            }
                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                            #endif

                                                            // Graph Pixel
                                                            struct SurfaceDescription
                                                            {
                                                            };

                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                            {
                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                return surface;
                                                            }

                                                            // --------------------------------------------------
                                                            // Build Graph Inputs
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                            #define VFX_SRP_VARYINGS Varyings
                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                            #endif
                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                            {
                                                                VertexDescriptionInputs output;
                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                output.ObjectSpacePosition = input.positionOS;

                                                                return output;
                                                            }
                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                            {
                                                                SurfaceDescriptionInputs output;
                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                            #endif







                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                            #else
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                            #endif
                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                    return output;
                                                            }

                                                            // --------------------------------------------------
                                                            // Main

                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                            // --------------------------------------------------
                                                            // Visual Effect Vertex Invocations
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                            #endif

                                                            ENDHLSL
                                                            }
                                                            Pass
                                                            {
                                                                Name "ScenePickingPass"
                                                                Tags
                                                                {
                                                                    "LightMode" = "Picking"
                                                                }

                                                                // Render State
                                                                Cull Back

                                                                // Debug
                                                                // <None>

                                                                // --------------------------------------------------
                                                                // Pass

                                                                HLSLPROGRAM

                                                                // Pragmas
                                                                #pragma target 4.5
                                                                #pragma exclude_renderers gles gles3 glcore
                                                                #pragma vertex vert
                                                                #pragma fragment frag

                                                                // DotsInstancingOptions: <None>
                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                // Keywords
                                                                // PassKeywords: <None>
                                                                // GraphKeywords: <None>

                                                                // Defines

                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_TS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define FEATURES_GRAPH_VERTEX
                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                #define SCENEPICKINGPASS 1
                                                                #define ALPHA_CLIP_THRESHOLD 1
                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                // custom interpolator pre-include
                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                // Includes
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                // --------------------------------------------------
                                                                // Structs and Packing

                                                                // custom interpolators pre packing
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                struct Attributes
                                                                {
                                                                     float3 positionOS : POSITION;
                                                                     float3 normalOS : NORMAL;
                                                                     float4 tangentOS : TANGENT;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct Varyings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct SurfaceDescriptionInputs
                                                                {
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                     float3 ObjectSpaceNormal;
                                                                     float3 ObjectSpaceTangent;
                                                                     float3 ObjectSpacePosition;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };

                                                                PackedVaryings PackVaryings(Varyings input)
                                                                {
                                                                    PackedVaryings output;
                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                    output.positionCS = input.positionCS;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }

                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                {
                                                                    Varyings output;
                                                                    output.positionCS = input.positionCS;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }


                                                                // --------------------------------------------------
                                                                // Graph

                                                                // Graph Properties
                                                                CBUFFER_START(UnityPerMaterial)
                                                                float4 _WaterTexture_TexelSize;
                                                                float _WaterHeight;
                                                                float4 _SandTexture_TexelSize;
                                                                float _SandHeight;
                                                                float4 _GrassTexture_TexelSize;
                                                                float _GrassHeight;
                                                                float4 _RockTexture_TexelSize;
                                                                float _RockHeight;
                                                                float4 _SnowTexture_TexelSize;
                                                                float _SnowHeight;
                                                                float _NearbyPickHeight;
                                                                float4 _WaterNormal_TexelSize;
                                                                float4 _RockNormal_TexelSize;
                                                                float4 _GrassNormal_TexelSize;
                                                                float4 _SandNormal_TexelSize;
                                                                float4 _SnowNormal_TexelSize;
                                                                CBUFFER_END

                                                                    // Object and Global properties
                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                    TEXTURE2D(_WaterTexture);
                                                                    SAMPLER(sampler_WaterTexture);
                                                                    TEXTURE2D(_SandTexture);
                                                                    SAMPLER(sampler_SandTexture);
                                                                    TEXTURE2D(_GrassTexture);
                                                                    SAMPLER(sampler_GrassTexture);
                                                                    TEXTURE2D(_RockTexture);
                                                                    SAMPLER(sampler_RockTexture);
                                                                    TEXTURE2D(_SnowTexture);
                                                                    SAMPLER(sampler_SnowTexture);
                                                                    TEXTURE2D(_WaterNormal);
                                                                    SAMPLER(sampler_WaterNormal);
                                                                    TEXTURE2D(_RockNormal);
                                                                    SAMPLER(sampler_RockNormal);
                                                                    TEXTURE2D(_GrassNormal);
                                                                    SAMPLER(sampler_GrassNormal);
                                                                    TEXTURE2D(_SandNormal);
                                                                    SAMPLER(sampler_SandNormal);
                                                                    TEXTURE2D(_SnowNormal);
                                                                    SAMPLER(sampler_SnowNormal);

                                                                    // Graph Includes
                                                                    // GraphIncludes: <None>

                                                                    // -- Property used by ScenePickingPass
                                                                    #ifdef SCENEPICKINGPASS
                                                                    float4 _SelectionID;
                                                                    #endif

                                                                    // -- Properties used by SceneSelectionPass
                                                                    #ifdef SCENESELECTIONPASS
                                                                    int _ObjectId;
                                                                    int _PassValue;
                                                                    #endif

                                                                    // Graph Functions
                                                                    // GraphFunctions: <None>

                                                                    // Custom interpolators pre vertex
                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                    // Graph Vertex
                                                                    struct VertexDescription
                                                                    {
                                                                        float3 Position;
                                                                        float3 Normal;
                                                                        float3 Tangent;
                                                                    };

                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                    {
                                                                        VertexDescription description = (VertexDescription)0;
                                                                        description.Position = IN.ObjectSpacePosition;
                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                        return description;
                                                                    }

                                                                    // Custom interpolators, pre surface
                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                    {
                                                                    return output;
                                                                    }
                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                    #endif

                                                                    // Graph Pixel
                                                                    struct SurfaceDescription
                                                                    {
                                                                    };

                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                    {
                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                        return surface;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Build Graph Inputs
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                    #endif
                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                    {
                                                                        VertexDescriptionInputs output;
                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                        return output;
                                                                    }
                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                    {
                                                                        SurfaceDescriptionInputs output;
                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                    #endif







                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                    #else
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                    #endif
                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                            return output;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Main

                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                    // --------------------------------------------------
                                                                    // Visual Effect Vertex Invocations
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                    #endif

                                                                    ENDHLSL
                                                                    }
                                                                    Pass
                                                                    {
                                                                        // Name: <None>
                                                                        Tags
                                                                        {
                                                                            "LightMode" = "Universal2D"
                                                                        }

                                                                        // Render State
                                                                        Cull Back
                                                                        Blend One Zero
                                                                        ZTest LEqual
                                                                        ZWrite On

                                                                        // Debug
                                                                        // <None>

                                                                        // --------------------------------------------------
                                                                        // Pass

                                                                        HLSLPROGRAM

                                                                        // Pragmas
                                                                        #pragma target 4.5
                                                                        #pragma exclude_renderers gles gles3 glcore
                                                                        #pragma vertex vert
                                                                        #pragma fragment frag

                                                                        // DotsInstancingOptions: <None>
                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                        // Keywords
                                                                        // PassKeywords: <None>
                                                                        // GraphKeywords: <None>

                                                                        // Defines

                                                                        #define _NORMALMAP 1
                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                        #define FEATURES_GRAPH_VERTEX
                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                        #define SHADERPASS SHADERPASS_2D
                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                        // custom interpolator pre-include
                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                        // Includes
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                        // --------------------------------------------------
                                                                        // Structs and Packing

                                                                        // custom interpolators pre packing
                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                        struct Attributes
                                                                        {
                                                                             float3 positionOS : POSITION;
                                                                             float3 normalOS : NORMAL;
                                                                             float4 tangentOS : TANGENT;
                                                                             float4 uv0 : TEXCOORD0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct Varyings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 positionWS;
                                                                             float3 normalWS;
                                                                             float4 texCoord0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct SurfaceDescriptionInputs
                                                                        {
                                                                             float3 WorldSpaceNormal;
                                                                             float3 WorldSpacePosition;
                                                                             float3 AbsoluteWorldSpacePosition;
                                                                             float4 uv0;
                                                                        };
                                                                        struct VertexDescriptionInputs
                                                                        {
                                                                             float3 ObjectSpaceNormal;
                                                                             float3 ObjectSpaceTangent;
                                                                             float3 ObjectSpacePosition;
                                                                        };
                                                                        struct PackedVaryings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 interp0 : INTERP0;
                                                                             float3 interp1 : INTERP1;
                                                                             float4 interp2 : INTERP2;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };

                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                        {
                                                                            PackedVaryings output;
                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                            output.positionCS = input.positionCS;
                                                                            output.interp0.xyz = input.positionWS;
                                                                            output.interp1.xyz = input.normalWS;
                                                                            output.interp2.xyzw = input.texCoord0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }

                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                        {
                                                                            Varyings output;
                                                                            output.positionCS = input.positionCS;
                                                                            output.positionWS = input.interp0.xyz;
                                                                            output.normalWS = input.interp1.xyz;
                                                                            output.texCoord0 = input.interp2.xyzw;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }


                                                                        // --------------------------------------------------
                                                                        // Graph

                                                                        // Graph Properties
                                                                        CBUFFER_START(UnityPerMaterial)
                                                                        float4 _WaterTexture_TexelSize;
                                                                        float _WaterHeight;
                                                                        float4 _SandTexture_TexelSize;
                                                                        float _SandHeight;
                                                                        float4 _GrassTexture_TexelSize;
                                                                        float _GrassHeight;
                                                                        float4 _RockTexture_TexelSize;
                                                                        float _RockHeight;
                                                                        float4 _SnowTexture_TexelSize;
                                                                        float _SnowHeight;
                                                                        float _NearbyPickHeight;
                                                                        float4 _WaterNormal_TexelSize;
                                                                        float4 _RockNormal_TexelSize;
                                                                        float4 _GrassNormal_TexelSize;
                                                                        float4 _SandNormal_TexelSize;
                                                                        float4 _SnowNormal_TexelSize;
                                                                        CBUFFER_END

                                                                            // Object and Global properties
                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                            TEXTURE2D(_WaterTexture);
                                                                            SAMPLER(sampler_WaterTexture);
                                                                            TEXTURE2D(_SandTexture);
                                                                            SAMPLER(sampler_SandTexture);
                                                                            TEXTURE2D(_GrassTexture);
                                                                            SAMPLER(sampler_GrassTexture);
                                                                            TEXTURE2D(_RockTexture);
                                                                            SAMPLER(sampler_RockTexture);
                                                                            TEXTURE2D(_SnowTexture);
                                                                            SAMPLER(sampler_SnowTexture);
                                                                            TEXTURE2D(_WaterNormal);
                                                                            SAMPLER(sampler_WaterNormal);
                                                                            TEXTURE2D(_RockNormal);
                                                                            SAMPLER(sampler_RockNormal);
                                                                            TEXTURE2D(_GrassNormal);
                                                                            SAMPLER(sampler_GrassNormal);
                                                                            TEXTURE2D(_SandNormal);
                                                                            SAMPLER(sampler_SandNormal);
                                                                            TEXTURE2D(_SnowNormal);
                                                                            SAMPLER(sampler_SnowNormal);

                                                                            // Graph Includes
                                                                            // GraphIncludes: <None>

                                                                            // -- Property used by ScenePickingPass
                                                                            #ifdef SCENEPICKINGPASS
                                                                            float4 _SelectionID;
                                                                            #endif

                                                                            // -- Properties used by SceneSelectionPass
                                                                            #ifdef SCENESELECTIONPASS
                                                                            int _ObjectId;
                                                                            int _PassValue;
                                                                            #endif

                                                                            // Graph Functions

                                                                            void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A <= B ? 1 : 0;
                                                                            }

                                                                            void Unity_InverseLerp_float(float A, float B, float T, out float Out)
                                                                            {
                                                                                Out = (T - A) / (B - A);
                                                                            }

                                                                            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                                            {
                                                                                Out = lerp(A, B, T);
                                                                            }

                                                                            void Unity_Blend_Exclusion_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                                                            {
                                                                                Out = Blend + Base - (2.0 * Blend * Base);
                                                                                Out = lerp(Base, Out, Opacity);
                                                                            }

                                                                            void Unity_Power_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = pow(A, B);
                                                                            }

                                                                            void Unity_Blend_Screen_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                                                            {
                                                                                Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
                                                                                Out = lerp(Base, Out, Opacity);
                                                                            }

                                                                            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                            {
                                                                                Out = Predicate ? True : False;
                                                                            }

                                                                            // Custom interpolators pre vertex
                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                            // Graph Vertex
                                                                            struct VertexDescription
                                                                            {
                                                                                float3 Position;
                                                                                float3 Normal;
                                                                                float3 Tangent;
                                                                            };

                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                            {
                                                                                VertexDescription description = (VertexDescription)0;
                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                return description;
                                                                            }

                                                                            // Custom interpolators, pre surface
                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                            {
                                                                            return output;
                                                                            }
                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                            #endif

                                                                            // Graph Pixel
                                                                            struct SurfaceDescription
                                                                            {
                                                                                float3 BaseColor;
                                                                            };

                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                            {
                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                float4 _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0 = IN.uv0;
                                                                                float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_R_1 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[0];
                                                                                float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[1];
                                                                                float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_B_3 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[2];
                                                                                float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_A_4 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[3];
                                                                                float _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0 = _SandHeight;
                                                                                float _Comparison_befd0823d3d24995af6d977e0af38232_Out_2;
                                                                                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Comparison_befd0823d3d24995af6d977e0af38232_Out_2);
                                                                                UnityTexture2D _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0 = UnityBuildTexture2DStructNoScale(_WaterTexture);
                                                                                float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend /= dot(Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend, 1.0);
                                                                                float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.zy);
                                                                                float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xz);
                                                                                float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xy);
                                                                                float4 _Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0 = Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.x + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.y + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.z;
                                                                                UnityTexture2D _Property_36337b09844644179547e9e25c7c4274_Out_0 = UnityBuildTexture2DStructNoScale(_SandTexture);
                                                                                float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend /= dot(Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend, 1.0);
                                                                                float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_X = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.zy);
                                                                                float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xz);
                                                                                float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xy);
                                                                                float4 _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0 = Triplanar_b5daae74a8384db9b8d43474f55b1cca_X * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.x + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.y + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.z;
                                                                                float _Property_bc6acfb4eb504fa188ea556c8f614756_Out_0 = _WaterHeight;
                                                                                float _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3;
                                                                                Unity_InverseLerp_float(_Property_bc6acfb4eb504fa188ea556c8f614756_Out_0, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3);
                                                                                float4 _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3;
                                                                                Unity_Lerp_float4(_Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0, _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, (_InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3.xxxx), _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3);
                                                                                float _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0 = _GrassHeight;
                                                                                float _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2;
                                                                                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2);
                                                                                UnityTexture2D _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0 = UnityBuildTexture2DStructNoScale(_GrassTexture);
                                                                                float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend /= dot(Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend, 1.0);
                                                                                float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_X = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.zy);
                                                                                float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xz);
                                                                                float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xy);
                                                                                float4 _Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0 = Triplanar_05b6acc8be54451b8049b91ed12ebc24_X * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.x + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.y + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.z;
                                                                                UnityTexture2D _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                                                float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend /= dot(Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend, 1.0);
                                                                                float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_X = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.zy);
                                                                                float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Y = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xz);
                                                                                float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Z = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xy);
                                                                                float4 _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0 = Triplanar_1ed180918dcb4468b12011d31552c9d9_X * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.x + Triplanar_1ed180918dcb4468b12011d31552c9d9_Y * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.y + Triplanar_1ed180918dcb4468b12011d31552c9d9_Z * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.z;
                                                                                float4 _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2;
                                                                                Unity_Blend_Exclusion_float4(_Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0, _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0, _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, 0.52);
                                                                                float _Float_cf64f4c58290409ea67cef8f97bd8453_Out_0 = 2.33;
                                                                                float4 _Power_04f1890bf939475b9826ed03816155ce_Out_2;
                                                                                Unity_Power_float4(_Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, (_Float_cf64f4c58290409ea67cef8f97bd8453_Out_0.xxxx), _Power_04f1890bf939475b9826ed03816155ce_Out_2);
                                                                                float _Property_50b2430cc37d40d9862de7ec154fbd82_Out_0 = _SandHeight;
                                                                                float _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3;
                                                                                Unity_InverseLerp_float(_Property_50b2430cc37d40d9862de7ec154fbd82_Out_0, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3);
                                                                                float4 _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3;
                                                                                Unity_Lerp_float4(_Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, _Power_04f1890bf939475b9826ed03816155ce_Out_2, (_InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3.xxxx), _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3);
                                                                                float _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0 = _RockHeight;
                                                                                float _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2;
                                                                                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2);
                                                                                UnityTexture2D _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                                                float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend /= dot(Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend, 1.0);
                                                                                float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_X = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.zy);
                                                                                float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Y = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xz);
                                                                                float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Z = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xy);
                                                                                float4 _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0 = Triplanar_358c24aad7c14e0a924836817da2e7b9_X * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.x + Triplanar_358c24aad7c14e0a924836817da2e7b9_Y * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.y + Triplanar_358c24aad7c14e0a924836817da2e7b9_Z * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.z;
                                                                                float _Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0 = _GrassHeight;
                                                                                float _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3;
                                                                                Unity_InverseLerp_float(_Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3);
                                                                                float4 _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3;
                                                                                Unity_Lerp_float4(_Power_04f1890bf939475b9826ed03816155ce_Out_2, _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, (_InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3.xxxx), _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3);
                                                                                float _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0 = _NearbyPickHeight;
                                                                                float _Comparison_0c144defb135447fa506399b1e5b782c_Out_2;
                                                                                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Comparison_0c144defb135447fa506399b1e5b782c_Out_2);
                                                                                UnityTexture2D _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                                                float3 Triplanar_67e476af87e34432bb1425483e85eeaf_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                float3 Triplanar_67e476af87e34432bb1425483e85eeaf_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                Triplanar_67e476af87e34432bb1425483e85eeaf_Blend /= dot(Triplanar_67e476af87e34432bb1425483e85eeaf_Blend, 1.0);
                                                                                float4 Triplanar_67e476af87e34432bb1425483e85eeaf_X = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.zy);
                                                                                float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Y = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xz);
                                                                                float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Z = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xy);
                                                                                float4 _Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0 = Triplanar_67e476af87e34432bb1425483e85eeaf_X * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.x + Triplanar_67e476af87e34432bb1425483e85eeaf_Y * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.y + Triplanar_67e476af87e34432bb1425483e85eeaf_Z * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.z;
                                                                                UnityTexture2D _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                                                                                float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend /= dot(Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend, 1.0);
                                                                                float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.zy);
                                                                                float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xz);
                                                                                float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xy);
                                                                                float4 _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0 = Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.x + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.y + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.z;
                                                                                float4 _Blend_18b55f11871e43b0a33d88203ed53708_Out_2;
                                                                                Unity_Blend_Screen_float4(_Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0, _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, 0.39);
                                                                                float _Property_7e4dc6d5804f488db1d161cc882419e8_Out_0 = _RockHeight;
                                                                                float _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3;
                                                                                Unity_InverseLerp_float(_Property_7e4dc6d5804f488db1d161cc882419e8_Out_0, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3);
                                                                                float4 _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3;
                                                                                Unity_Lerp_float4(_Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, (_InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3.xxxx), _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3);
                                                                                float _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0 = _SnowHeight;
                                                                                float _Comparison_f94a526e09724297a991b6e76aec137f_Out_2;
                                                                                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0, _Comparison_f94a526e09724297a991b6e76aec137f_Out_2);
                                                                                UnityTexture2D _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                                                                                float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend /= dot(Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend, 1.0);
                                                                                float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.zy);
                                                                                float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xz);
                                                                                float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xy);
                                                                                float4 _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0 = Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.x + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.y + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.z;
                                                                                float _Property_a4d949d8c5254a3e87c67e9c593124af_Out_0 = _NearbyPickHeight;
                                                                                float _Property_3964305cc05045849c1082166182507e_Out_0 = _SnowHeight;
                                                                                float _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3;
                                                                                Unity_InverseLerp_float(_Property_a4d949d8c5254a3e87c67e9c593124af_Out_0, _Property_3964305cc05045849c1082166182507e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3);
                                                                                float4 _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3;
                                                                                Unity_Lerp_float4(_Blend_18b55f11871e43b0a33d88203ed53708_Out_2, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, (_InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3.xxxx), _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3);
                                                                                float4 _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3;
                                                                                Unity_Branch_float4(_Comparison_f94a526e09724297a991b6e76aec137f_Out_2, _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3);
                                                                                float4 _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3;
                                                                                Unity_Branch_float4(_Comparison_0c144defb135447fa506399b1e5b782c_Out_2, _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3);
                                                                                float4 _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3;
                                                                                Unity_Branch_float4(_Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2, _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3);
                                                                                float4 _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3;
                                                                                Unity_Branch_float4(_Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2, _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3);
                                                                                float4 _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3;
                                                                                Unity_Branch_float4(_Comparison_befd0823d3d24995af6d977e0af38232_Out_2, _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3, _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3);
                                                                                surface.BaseColor = (_Branch_664fbb7767f64053b62a1c4248a59dba_Out_3.xyz);
                                                                                return surface;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Build Graph Inputs
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                            #endif
                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                            {
                                                                                VertexDescriptionInputs output;
                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                return output;
                                                                            }
                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                            {
                                                                                SurfaceDescriptionInputs output;
                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                            #endif



                                                                                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                                                float3 unnormalizedNormalWS = input.normalWS;
                                                                                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                                                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                                                                                output.uv0 = input.texCoord0;
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                            #else
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                            #endif
                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                    return output;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Main

                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                            // --------------------------------------------------
                                                                            // Visual Effect Vertex Invocations
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                            #endif

                                                                            ENDHLSL
                                                                            }
    }
        SubShader
                                                                            {
                                                                                Tags
                                                                                {
                                                                                    "RenderPipeline" = "UniversalPipeline"
                                                                                    "RenderType" = "Opaque"
                                                                                    "UniversalMaterialType" = "Lit"
                                                                                    "Queue" = "Geometry"
                                                                                    "ShaderGraphShader" = "true"
                                                                                    "ShaderGraphTargetId" = "UniversalLitSubTarget"
                                                                                }
                                                                                Pass
                                                                                {
                                                                                    Name "Universal Forward"
                                                                                    Tags
                                                                                    {
                                                                                        "LightMode" = "UniversalForward"
                                                                                    }

                                                                                // Render State
                                                                                Cull Back
                                                                                Blend One Zero
                                                                                ZTest LEqual
                                                                                ZWrite On

                                                                                // Debug
                                                                                // <None>

                                                                                // --------------------------------------------------
                                                                                // Pass

                                                                                HLSLPROGRAM

                                                                                // Pragmas
                                                                                #pragma target 2.0
                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                #pragma multi_compile_instancing
                                                                                #pragma multi_compile_fog
                                                                                #pragma instancing_options renderinglayer
                                                                                #pragma vertex vert
                                                                                #pragma fragment frag

                                                                                // DotsInstancingOptions: <None>
                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                // Keywords
                                                                                #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
                                                                                #pragma multi_compile _ LIGHTMAP_ON
                                                                                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                                                                                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                                                                                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                                                                                #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                                                                                #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
                                                                                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                                                                                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                                                                                #pragma multi_compile_fragment _ _SHADOWS_SOFT
                                                                                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                                                                                #pragma multi_compile _ SHADOWS_SHADOWMASK
                                                                                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                                                                                #pragma multi_compile_fragment _ _LIGHT_LAYERS
                                                                                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                                                                                #pragma multi_compile_fragment _ _LIGHT_COOKIES
                                                                                #pragma multi_compile _ _CLUSTERED_RENDERING
                                                                                // GraphKeywords: <None>

                                                                                // Defines

                                                                                #define _NORMALMAP 1
                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                                #define VARYINGS_NEED_TANGENT_WS
                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                #define VARYINGS_NEED_VIEWDIRECTION_WS
                                                                                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                #define VARYINGS_NEED_SHADOW_COORD
                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                #define SHADERPASS SHADERPASS_FORWARD
                                                                                #define _FOG_FRAGMENT 1
                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                // custom interpolator pre-include
                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                // Includes
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                // --------------------------------------------------
                                                                                // Structs and Packing

                                                                                // custom interpolators pre packing
                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                struct Attributes
                                                                                {
                                                                                     float3 positionOS : POSITION;
                                                                                     float3 normalOS : NORMAL;
                                                                                     float4 tangentOS : TANGENT;
                                                                                     float4 uv0 : TEXCOORD0;
                                                                                     float4 uv1 : TEXCOORD1;
                                                                                     float4 uv2 : TEXCOORD2;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct Varyings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 positionWS;
                                                                                     float3 normalWS;
                                                                                     float4 tangentWS;
                                                                                     float4 texCoord0;
                                                                                     float3 viewDirectionWS;
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                     float2 staticLightmapUV;
                                                                                    #endif
                                                                                    #if defined(DYNAMICLIGHTMAP_ON)
                                                                                     float2 dynamicLightmapUV;
                                                                                    #endif
                                                                                    #if !defined(LIGHTMAP_ON)
                                                                                     float3 sh;
                                                                                    #endif
                                                                                     float4 fogFactorAndVertexLight;
                                                                                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                                     float4 shadowCoord;
                                                                                    #endif
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct SurfaceDescriptionInputs
                                                                                {
                                                                                     float3 WorldSpaceNormal;
                                                                                     float3 TangentSpaceNormal;
                                                                                     float3 WorldSpacePosition;
                                                                                     float3 AbsoluteWorldSpacePosition;
                                                                                     float4 uv0;
                                                                                };
                                                                                struct VertexDescriptionInputs
                                                                                {
                                                                                     float3 ObjectSpaceNormal;
                                                                                     float3 ObjectSpaceTangent;
                                                                                     float3 ObjectSpacePosition;
                                                                                };
                                                                                struct PackedVaryings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 interp0 : INTERP0;
                                                                                     float3 interp1 : INTERP1;
                                                                                     float4 interp2 : INTERP2;
                                                                                     float4 interp3 : INTERP3;
                                                                                     float3 interp4 : INTERP4;
                                                                                     float2 interp5 : INTERP5;
                                                                                     float2 interp6 : INTERP6;
                                                                                     float3 interp7 : INTERP7;
                                                                                     float4 interp8 : INTERP8;
                                                                                     float4 interp9 : INTERP9;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };

                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                {
                                                                                    PackedVaryings output;
                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.interp0.xyz = input.positionWS;
                                                                                    output.interp1.xyz = input.normalWS;
                                                                                    output.interp2.xyzw = input.tangentWS;
                                                                                    output.interp3.xyzw = input.texCoord0;
                                                                                    output.interp4.xyz = input.viewDirectionWS;
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                    output.interp5.xy = input.staticLightmapUV;
                                                                                    #endif
                                                                                    #if defined(DYNAMICLIGHTMAP_ON)
                                                                                    output.interp6.xy = input.dynamicLightmapUV;
                                                                                    #endif
                                                                                    #if !defined(LIGHTMAP_ON)
                                                                                    output.interp7.xyz = input.sh;
                                                                                    #endif
                                                                                    output.interp8.xyzw = input.fogFactorAndVertexLight;
                                                                                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                                    output.interp9.xyzw = input.shadowCoord;
                                                                                    #endif
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }

                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                {
                                                                                    Varyings output;
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.positionWS = input.interp0.xyz;
                                                                                    output.normalWS = input.interp1.xyz;
                                                                                    output.tangentWS = input.interp2.xyzw;
                                                                                    output.texCoord0 = input.interp3.xyzw;
                                                                                    output.viewDirectionWS = input.interp4.xyz;
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                    output.staticLightmapUV = input.interp5.xy;
                                                                                    #endif
                                                                                    #if defined(DYNAMICLIGHTMAP_ON)
                                                                                    output.dynamicLightmapUV = input.interp6.xy;
                                                                                    #endif
                                                                                    #if !defined(LIGHTMAP_ON)
                                                                                    output.sh = input.interp7.xyz;
                                                                                    #endif
                                                                                    output.fogFactorAndVertexLight = input.interp8.xyzw;
                                                                                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                                    output.shadowCoord = input.interp9.xyzw;
                                                                                    #endif
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }


                                                                                // --------------------------------------------------
                                                                                // Graph

                                                                                // Graph Properties
                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                float4 _WaterTexture_TexelSize;
                                                                                float _WaterHeight;
                                                                                float4 _SandTexture_TexelSize;
                                                                                float _SandHeight;
                                                                                float4 _GrassTexture_TexelSize;
                                                                                float _GrassHeight;
                                                                                float4 _RockTexture_TexelSize;
                                                                                float _RockHeight;
                                                                                float4 _SnowTexture_TexelSize;
                                                                                float _SnowHeight;
                                                                                float _NearbyPickHeight;
                                                                                float4 _WaterNormal_TexelSize;
                                                                                float4 _RockNormal_TexelSize;
                                                                                float4 _GrassNormal_TexelSize;
                                                                                float4 _SandNormal_TexelSize;
                                                                                float4 _SnowNormal_TexelSize;
                                                                                CBUFFER_END

                                                                                    // Object and Global properties
                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                    TEXTURE2D(_WaterTexture);
                                                                                    SAMPLER(sampler_WaterTexture);
                                                                                    TEXTURE2D(_SandTexture);
                                                                                    SAMPLER(sampler_SandTexture);
                                                                                    TEXTURE2D(_GrassTexture);
                                                                                    SAMPLER(sampler_GrassTexture);
                                                                                    TEXTURE2D(_RockTexture);
                                                                                    SAMPLER(sampler_RockTexture);
                                                                                    TEXTURE2D(_SnowTexture);
                                                                                    SAMPLER(sampler_SnowTexture);
                                                                                    TEXTURE2D(_WaterNormal);
                                                                                    SAMPLER(sampler_WaterNormal);
                                                                                    TEXTURE2D(_RockNormal);
                                                                                    SAMPLER(sampler_RockNormal);
                                                                                    TEXTURE2D(_GrassNormal);
                                                                                    SAMPLER(sampler_GrassNormal);
                                                                                    TEXTURE2D(_SandNormal);
                                                                                    SAMPLER(sampler_SandNormal);
                                                                                    TEXTURE2D(_SnowNormal);
                                                                                    SAMPLER(sampler_SnowNormal);

                                                                                    // Graph Includes
                                                                                    // GraphIncludes: <None>

                                                                                    // -- Property used by ScenePickingPass
                                                                                    #ifdef SCENEPICKINGPASS
                                                                                    float4 _SelectionID;
                                                                                    #endif

                                                                                    // -- Properties used by SceneSelectionPass
                                                                                    #ifdef SCENESELECTIONPASS
                                                                                    int _ObjectId;
                                                                                    int _PassValue;
                                                                                    #endif

                                                                                    // Graph Functions

                                                                                    void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A <= B ? 1 : 0;
                                                                                    }

                                                                                    void Unity_InverseLerp_float(float A, float B, float T, out float Out)
                                                                                    {
                                                                                        Out = (T - A) / (B - A);
                                                                                    }

                                                                                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                                                    {
                                                                                        Out = lerp(A, B, T);
                                                                                    }

                                                                                    void Unity_Blend_Exclusion_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                                                                    {
                                                                                        Out = Blend + Base - (2.0 * Blend * Base);
                                                                                        Out = lerp(Base, Out, Opacity);
                                                                                    }

                                                                                    void Unity_Power_float4(float4 A, float4 B, out float4 Out)
                                                                                    {
                                                                                        Out = pow(A, B);
                                                                                    }

                                                                                    void Unity_Blend_Screen_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                                                                    {
                                                                                        Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
                                                                                        Out = lerp(Base, Out, Opacity);
                                                                                    }

                                                                                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                                    {
                                                                                        Out = Predicate ? True : False;
                                                                                    }

                                                                                    // Custom interpolators pre vertex
                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                    // Graph Vertex
                                                                                    struct VertexDescription
                                                                                    {
                                                                                        float3 Position;
                                                                                        float3 Normal;
                                                                                        float3 Tangent;
                                                                                    };

                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                    {
                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                        return description;
                                                                                    }

                                                                                    // Custom interpolators, pre surface
                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                    {
                                                                                    return output;
                                                                                    }
                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                    #endif

                                                                                    // Graph Pixel
                                                                                    struct SurfaceDescription
                                                                                    {
                                                                                        float3 BaseColor;
                                                                                        float3 NormalTS;
                                                                                        float3 Emission;
                                                                                        float Metallic;
                                                                                        float Smoothness;
                                                                                        float Occlusion;
                                                                                    };

                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                    {
                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                        float4 _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0 = IN.uv0;
                                                                                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_R_1 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[0];
                                                                                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[1];
                                                                                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_B_3 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[2];
                                                                                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_A_4 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[3];
                                                                                        float _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0 = _SandHeight;
                                                                                        float _Comparison_befd0823d3d24995af6d977e0af38232_Out_2;
                                                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Comparison_befd0823d3d24995af6d977e0af38232_Out_2);
                                                                                        UnityTexture2D _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0 = UnityBuildTexture2DStructNoScale(_WaterTexture);
                                                                                        float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                        float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                        Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend /= dot(Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend, 1.0);
                                                                                        float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.zy);
                                                                                        float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xz);
                                                                                        float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xy);
                                                                                        float4 _Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0 = Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.x + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.y + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.z;
                                                                                        UnityTexture2D _Property_36337b09844644179547e9e25c7c4274_Out_0 = UnityBuildTexture2DStructNoScale(_SandTexture);
                                                                                        float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                        float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                        Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend /= dot(Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend, 1.0);
                                                                                        float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_X = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.zy);
                                                                                        float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xz);
                                                                                        float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xy);
                                                                                        float4 _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0 = Triplanar_b5daae74a8384db9b8d43474f55b1cca_X * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.x + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.y + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.z;
                                                                                        float _Property_bc6acfb4eb504fa188ea556c8f614756_Out_0 = _WaterHeight;
                                                                                        float _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3;
                                                                                        Unity_InverseLerp_float(_Property_bc6acfb4eb504fa188ea556c8f614756_Out_0, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3);
                                                                                        float4 _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3;
                                                                                        Unity_Lerp_float4(_Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0, _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, (_InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3.xxxx), _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3);
                                                                                        float _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0 = _GrassHeight;
                                                                                        float _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2;
                                                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2);
                                                                                        UnityTexture2D _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0 = UnityBuildTexture2DStructNoScale(_GrassTexture);
                                                                                        float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                        float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                        Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend /= dot(Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend, 1.0);
                                                                                        float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_X = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.zy);
                                                                                        float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xz);
                                                                                        float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xy);
                                                                                        float4 _Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0 = Triplanar_05b6acc8be54451b8049b91ed12ebc24_X * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.x + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.y + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.z;
                                                                                        UnityTexture2D _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                                                        float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                        float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                        Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend /= dot(Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend, 1.0);
                                                                                        float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_X = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.zy);
                                                                                        float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Y = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xz);
                                                                                        float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Z = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xy);
                                                                                        float4 _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0 = Triplanar_1ed180918dcb4468b12011d31552c9d9_X * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.x + Triplanar_1ed180918dcb4468b12011d31552c9d9_Y * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.y + Triplanar_1ed180918dcb4468b12011d31552c9d9_Z * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.z;
                                                                                        float4 _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2;
                                                                                        Unity_Blend_Exclusion_float4(_Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0, _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0, _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, 0.52);
                                                                                        float _Float_cf64f4c58290409ea67cef8f97bd8453_Out_0 = 2.33;
                                                                                        float4 _Power_04f1890bf939475b9826ed03816155ce_Out_2;
                                                                                        Unity_Power_float4(_Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, (_Float_cf64f4c58290409ea67cef8f97bd8453_Out_0.xxxx), _Power_04f1890bf939475b9826ed03816155ce_Out_2);
                                                                                        float _Property_50b2430cc37d40d9862de7ec154fbd82_Out_0 = _SandHeight;
                                                                                        float _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3;
                                                                                        Unity_InverseLerp_float(_Property_50b2430cc37d40d9862de7ec154fbd82_Out_0, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3);
                                                                                        float4 _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3;
                                                                                        Unity_Lerp_float4(_Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, _Power_04f1890bf939475b9826ed03816155ce_Out_2, (_InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3.xxxx), _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3);
                                                                                        float _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0 = _RockHeight;
                                                                                        float _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2;
                                                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2);
                                                                                        UnityTexture2D _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                                                        float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                        float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                        Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend /= dot(Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend, 1.0);
                                                                                        float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_X = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.zy);
                                                                                        float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Y = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xz);
                                                                                        float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Z = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xy);
                                                                                        float4 _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0 = Triplanar_358c24aad7c14e0a924836817da2e7b9_X * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.x + Triplanar_358c24aad7c14e0a924836817da2e7b9_Y * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.y + Triplanar_358c24aad7c14e0a924836817da2e7b9_Z * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.z;
                                                                                        float _Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0 = _GrassHeight;
                                                                                        float _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3;
                                                                                        Unity_InverseLerp_float(_Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3);
                                                                                        float4 _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3;
                                                                                        Unity_Lerp_float4(_Power_04f1890bf939475b9826ed03816155ce_Out_2, _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, (_InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3.xxxx), _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3);
                                                                                        float _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0 = _NearbyPickHeight;
                                                                                        float _Comparison_0c144defb135447fa506399b1e5b782c_Out_2;
                                                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Comparison_0c144defb135447fa506399b1e5b782c_Out_2);
                                                                                        UnityTexture2D _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                                                        float3 Triplanar_67e476af87e34432bb1425483e85eeaf_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                        float3 Triplanar_67e476af87e34432bb1425483e85eeaf_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                        Triplanar_67e476af87e34432bb1425483e85eeaf_Blend /= dot(Triplanar_67e476af87e34432bb1425483e85eeaf_Blend, 1.0);
                                                                                        float4 Triplanar_67e476af87e34432bb1425483e85eeaf_X = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.zy);
                                                                                        float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Y = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xz);
                                                                                        float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Z = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xy);
                                                                                        float4 _Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0 = Triplanar_67e476af87e34432bb1425483e85eeaf_X * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.x + Triplanar_67e476af87e34432bb1425483e85eeaf_Y * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.y + Triplanar_67e476af87e34432bb1425483e85eeaf_Z * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.z;
                                                                                        UnityTexture2D _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                                                                                        float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                        float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                        Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend /= dot(Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend, 1.0);
                                                                                        float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.zy);
                                                                                        float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xz);
                                                                                        float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xy);
                                                                                        float4 _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0 = Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.x + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.y + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.z;
                                                                                        float4 _Blend_18b55f11871e43b0a33d88203ed53708_Out_2;
                                                                                        Unity_Blend_Screen_float4(_Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0, _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, 0.39);
                                                                                        float _Property_7e4dc6d5804f488db1d161cc882419e8_Out_0 = _RockHeight;
                                                                                        float _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3;
                                                                                        Unity_InverseLerp_float(_Property_7e4dc6d5804f488db1d161cc882419e8_Out_0, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3);
                                                                                        float4 _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3;
                                                                                        Unity_Lerp_float4(_Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, (_InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3.xxxx), _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3);
                                                                                        float _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0 = _SnowHeight;
                                                                                        float _Comparison_f94a526e09724297a991b6e76aec137f_Out_2;
                                                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0, _Comparison_f94a526e09724297a991b6e76aec137f_Out_2);
                                                                                        UnityTexture2D _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                                                                                        float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                        float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                        Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend /= dot(Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend, 1.0);
                                                                                        float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.zy);
                                                                                        float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xz);
                                                                                        float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xy);
                                                                                        float4 _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0 = Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.x + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.y + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.z;
                                                                                        float _Property_a4d949d8c5254a3e87c67e9c593124af_Out_0 = _NearbyPickHeight;
                                                                                        float _Property_3964305cc05045849c1082166182507e_Out_0 = _SnowHeight;
                                                                                        float _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3;
                                                                                        Unity_InverseLerp_float(_Property_a4d949d8c5254a3e87c67e9c593124af_Out_0, _Property_3964305cc05045849c1082166182507e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3);
                                                                                        float4 _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3;
                                                                                        Unity_Lerp_float4(_Blend_18b55f11871e43b0a33d88203ed53708_Out_2, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, (_InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3.xxxx), _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3);
                                                                                        float4 _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3;
                                                                                        Unity_Branch_float4(_Comparison_f94a526e09724297a991b6e76aec137f_Out_2, _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3);
                                                                                        float4 _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3;
                                                                                        Unity_Branch_float4(_Comparison_0c144defb135447fa506399b1e5b782c_Out_2, _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3);
                                                                                        float4 _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3;
                                                                                        Unity_Branch_float4(_Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2, _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3);
                                                                                        float4 _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3;
                                                                                        Unity_Branch_float4(_Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2, _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3);
                                                                                        float4 _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3;
                                                                                        Unity_Branch_float4(_Comparison_befd0823d3d24995af6d977e0af38232_Out_2, _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3, _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3);
                                                                                        surface.BaseColor = (_Branch_664fbb7767f64053b62a1c4248a59dba_Out_3.xyz);
                                                                                        surface.NormalTS = IN.TangentSpaceNormal;
                                                                                        surface.Emission = float3(0, 0, 0);
                                                                                        surface.Metallic = 0;
                                                                                        surface.Smoothness = 0;
                                                                                        surface.Occlusion = 1;
                                                                                        return surface;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Build Graph Inputs
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                    #endif
                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                    {
                                                                                        VertexDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                        return output;
                                                                                    }
                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                    {
                                                                                        SurfaceDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                    #endif



                                                                                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                                                        float3 unnormalizedNormalWS = input.normalWS;
                                                                                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                                                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                                                                                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                                                                                        output.uv0 = input.texCoord0;
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                    #else
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                    #endif
                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                            return output;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Main

                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

                                                                                    // --------------------------------------------------
                                                                                    // Visual Effect Vertex Invocations
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                    #endif

                                                                                    ENDHLSL
                                                                                    }
                                                                                    Pass
                                                                                    {
                                                                                        Name "ShadowCaster"
                                                                                        Tags
                                                                                        {
                                                                                            "LightMode" = "ShadowCaster"
                                                                                        }

                                                                                        // Render State
                                                                                        Cull Back
                                                                                        ZTest LEqual
                                                                                        ZWrite On
                                                                                        ColorMask 0

                                                                                        // Debug
                                                                                        // <None>

                                                                                        // --------------------------------------------------
                                                                                        // Pass

                                                                                        HLSLPROGRAM

                                                                                        // Pragmas
                                                                                        #pragma target 2.0
                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                        #pragma multi_compile_instancing
                                                                                        #pragma vertex vert
                                                                                        #pragma fragment frag

                                                                                        // DotsInstancingOptions: <None>
                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                        // Keywords
                                                                                        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                                                                                        // GraphKeywords: <None>

                                                                                        // Defines

                                                                                        #define _NORMALMAP 1
                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                        // custom interpolator pre-include
                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                        // Includes
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                        // --------------------------------------------------
                                                                                        // Structs and Packing

                                                                                        // custom interpolators pre packing
                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                        struct Attributes
                                                                                        {
                                                                                             float3 positionOS : POSITION;
                                                                                             float3 normalOS : NORMAL;
                                                                                             float4 tangentOS : TANGENT;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct Varyings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 normalWS;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct SurfaceDescriptionInputs
                                                                                        {
                                                                                        };
                                                                                        struct VertexDescriptionInputs
                                                                                        {
                                                                                             float3 ObjectSpaceNormal;
                                                                                             float3 ObjectSpaceTangent;
                                                                                             float3 ObjectSpacePosition;
                                                                                        };
                                                                                        struct PackedVaryings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 interp0 : INTERP0;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };

                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                        {
                                                                                            PackedVaryings output;
                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.interp0.xyz = input.normalWS;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }

                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                        {
                                                                                            Varyings output;
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.normalWS = input.interp0.xyz;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }


                                                                                        // --------------------------------------------------
                                                                                        // Graph

                                                                                        // Graph Properties
                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                        float4 _WaterTexture_TexelSize;
                                                                                        float _WaterHeight;
                                                                                        float4 _SandTexture_TexelSize;
                                                                                        float _SandHeight;
                                                                                        float4 _GrassTexture_TexelSize;
                                                                                        float _GrassHeight;
                                                                                        float4 _RockTexture_TexelSize;
                                                                                        float _RockHeight;
                                                                                        float4 _SnowTexture_TexelSize;
                                                                                        float _SnowHeight;
                                                                                        float _NearbyPickHeight;
                                                                                        float4 _WaterNormal_TexelSize;
                                                                                        float4 _RockNormal_TexelSize;
                                                                                        float4 _GrassNormal_TexelSize;
                                                                                        float4 _SandNormal_TexelSize;
                                                                                        float4 _SnowNormal_TexelSize;
                                                                                        CBUFFER_END

                                                                                            // Object and Global properties
                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                            TEXTURE2D(_WaterTexture);
                                                                                            SAMPLER(sampler_WaterTexture);
                                                                                            TEXTURE2D(_SandTexture);
                                                                                            SAMPLER(sampler_SandTexture);
                                                                                            TEXTURE2D(_GrassTexture);
                                                                                            SAMPLER(sampler_GrassTexture);
                                                                                            TEXTURE2D(_RockTexture);
                                                                                            SAMPLER(sampler_RockTexture);
                                                                                            TEXTURE2D(_SnowTexture);
                                                                                            SAMPLER(sampler_SnowTexture);
                                                                                            TEXTURE2D(_WaterNormal);
                                                                                            SAMPLER(sampler_WaterNormal);
                                                                                            TEXTURE2D(_RockNormal);
                                                                                            SAMPLER(sampler_RockNormal);
                                                                                            TEXTURE2D(_GrassNormal);
                                                                                            SAMPLER(sampler_GrassNormal);
                                                                                            TEXTURE2D(_SandNormal);
                                                                                            SAMPLER(sampler_SandNormal);
                                                                                            TEXTURE2D(_SnowNormal);
                                                                                            SAMPLER(sampler_SnowNormal);

                                                                                            // Graph Includes
                                                                                            // GraphIncludes: <None>

                                                                                            // -- Property used by ScenePickingPass
                                                                                            #ifdef SCENEPICKINGPASS
                                                                                            float4 _SelectionID;
                                                                                            #endif

                                                                                            // -- Properties used by SceneSelectionPass
                                                                                            #ifdef SCENESELECTIONPASS
                                                                                            int _ObjectId;
                                                                                            int _PassValue;
                                                                                            #endif

                                                                                            // Graph Functions
                                                                                            // GraphFunctions: <None>

                                                                                            // Custom interpolators pre vertex
                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                            // Graph Vertex
                                                                                            struct VertexDescription
                                                                                            {
                                                                                                float3 Position;
                                                                                                float3 Normal;
                                                                                                float3 Tangent;
                                                                                            };

                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                            {
                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                return description;
                                                                                            }

                                                                                            // Custom interpolators, pre surface
                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                            {
                                                                                            return output;
                                                                                            }
                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                            #endif

                                                                                            // Graph Pixel
                                                                                            struct SurfaceDescription
                                                                                            {
                                                                                            };

                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                            {
                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                return surface;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Build Graph Inputs
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                            #endif
                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                            {
                                                                                                VertexDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                return output;
                                                                                            }
                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                            {
                                                                                                SurfaceDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                            #endif







                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                            #else
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                            #endif
                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                    return output;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Main

                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                                                                                            // --------------------------------------------------
                                                                                            // Visual Effect Vertex Invocations
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                            #endif

                                                                                            ENDHLSL
                                                                                            }
                                                                                            Pass
                                                                                            {
                                                                                                Name "DepthOnly"
                                                                                                Tags
                                                                                                {
                                                                                                    "LightMode" = "DepthOnly"
                                                                                                }

                                                                                                // Render State
                                                                                                Cull Back
                                                                                                ZTest LEqual
                                                                                                ZWrite On
                                                                                                ColorMask 0

                                                                                                // Debug
                                                                                                // <None>

                                                                                                // --------------------------------------------------
                                                                                                // Pass

                                                                                                HLSLPROGRAM

                                                                                                // Pragmas
                                                                                                #pragma target 2.0
                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                #pragma multi_compile_instancing
                                                                                                #pragma vertex vert
                                                                                                #pragma fragment frag

                                                                                                // DotsInstancingOptions: <None>
                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                // Keywords
                                                                                                // PassKeywords: <None>
                                                                                                // GraphKeywords: <None>

                                                                                                // Defines

                                                                                                #define _NORMALMAP 1
                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                // custom interpolator pre-include
                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                // Includes
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                // --------------------------------------------------
                                                                                                // Structs and Packing

                                                                                                // custom interpolators pre packing
                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                struct Attributes
                                                                                                {
                                                                                                     float3 positionOS : POSITION;
                                                                                                     float3 normalOS : NORMAL;
                                                                                                     float4 tangentOS : TANGENT;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct Varyings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct SurfaceDescriptionInputs
                                                                                                {
                                                                                                };
                                                                                                struct VertexDescriptionInputs
                                                                                                {
                                                                                                     float3 ObjectSpaceNormal;
                                                                                                     float3 ObjectSpaceTangent;
                                                                                                     float3 ObjectSpacePosition;
                                                                                                };
                                                                                                struct PackedVaryings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };

                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                {
                                                                                                    PackedVaryings output;
                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }

                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                {
                                                                                                    Varyings output;
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }


                                                                                                // --------------------------------------------------
                                                                                                // Graph

                                                                                                // Graph Properties
                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                float4 _WaterTexture_TexelSize;
                                                                                                float _WaterHeight;
                                                                                                float4 _SandTexture_TexelSize;
                                                                                                float _SandHeight;
                                                                                                float4 _GrassTexture_TexelSize;
                                                                                                float _GrassHeight;
                                                                                                float4 _RockTexture_TexelSize;
                                                                                                float _RockHeight;
                                                                                                float4 _SnowTexture_TexelSize;
                                                                                                float _SnowHeight;
                                                                                                float _NearbyPickHeight;
                                                                                                float4 _WaterNormal_TexelSize;
                                                                                                float4 _RockNormal_TexelSize;
                                                                                                float4 _GrassNormal_TexelSize;
                                                                                                float4 _SandNormal_TexelSize;
                                                                                                float4 _SnowNormal_TexelSize;
                                                                                                CBUFFER_END

                                                                                                    // Object and Global properties
                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                    TEXTURE2D(_WaterTexture);
                                                                                                    SAMPLER(sampler_WaterTexture);
                                                                                                    TEXTURE2D(_SandTexture);
                                                                                                    SAMPLER(sampler_SandTexture);
                                                                                                    TEXTURE2D(_GrassTexture);
                                                                                                    SAMPLER(sampler_GrassTexture);
                                                                                                    TEXTURE2D(_RockTexture);
                                                                                                    SAMPLER(sampler_RockTexture);
                                                                                                    TEXTURE2D(_SnowTexture);
                                                                                                    SAMPLER(sampler_SnowTexture);
                                                                                                    TEXTURE2D(_WaterNormal);
                                                                                                    SAMPLER(sampler_WaterNormal);
                                                                                                    TEXTURE2D(_RockNormal);
                                                                                                    SAMPLER(sampler_RockNormal);
                                                                                                    TEXTURE2D(_GrassNormal);
                                                                                                    SAMPLER(sampler_GrassNormal);
                                                                                                    TEXTURE2D(_SandNormal);
                                                                                                    SAMPLER(sampler_SandNormal);
                                                                                                    TEXTURE2D(_SnowNormal);
                                                                                                    SAMPLER(sampler_SnowNormal);

                                                                                                    // Graph Includes
                                                                                                    // GraphIncludes: <None>

                                                                                                    // -- Property used by ScenePickingPass
                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                    float4 _SelectionID;
                                                                                                    #endif

                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                    int _ObjectId;
                                                                                                    int _PassValue;
                                                                                                    #endif

                                                                                                    // Graph Functions
                                                                                                    // GraphFunctions: <None>

                                                                                                    // Custom interpolators pre vertex
                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                    // Graph Vertex
                                                                                                    struct VertexDescription
                                                                                                    {
                                                                                                        float3 Position;
                                                                                                        float3 Normal;
                                                                                                        float3 Tangent;
                                                                                                    };

                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                    {
                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                        return description;
                                                                                                    }

                                                                                                    // Custom interpolators, pre surface
                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                    {
                                                                                                    return output;
                                                                                                    }
                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                    #endif

                                                                                                    // Graph Pixel
                                                                                                    struct SurfaceDescription
                                                                                                    {
                                                                                                    };

                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                    {
                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                        return surface;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Build Graph Inputs
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                    #endif
                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                    {
                                                                                                        VertexDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                        return output;
                                                                                                    }
                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                    {
                                                                                                        SurfaceDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                    #endif







                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                    #else
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                    #endif
                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                            return output;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Main

                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                                                                                    // --------------------------------------------------
                                                                                                    // Visual Effect Vertex Invocations
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                    #endif

                                                                                                    ENDHLSL
                                                                                                    }
                                                                                                    Pass
                                                                                                    {
                                                                                                        Name "DepthNormals"
                                                                                                        Tags
                                                                                                        {
                                                                                                            "LightMode" = "DepthNormals"
                                                                                                        }

                                                                                                        // Render State
                                                                                                        Cull Back
                                                                                                        ZTest LEqual
                                                                                                        ZWrite On

                                                                                                        // Debug
                                                                                                        // <None>

                                                                                                        // --------------------------------------------------
                                                                                                        // Pass

                                                                                                        HLSLPROGRAM

                                                                                                        // Pragmas
                                                                                                        #pragma target 2.0
                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                        #pragma multi_compile_instancing
                                                                                                        #pragma vertex vert
                                                                                                        #pragma fragment frag

                                                                                                        // DotsInstancingOptions: <None>
                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                        // Keywords
                                                                                                        // PassKeywords: <None>
                                                                                                        // GraphKeywords: <None>

                                                                                                        // Defines

                                                                                                        #define _NORMALMAP 1
                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                        #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                        // custom interpolator pre-include
                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                        // Includes
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                        // --------------------------------------------------
                                                                                                        // Structs and Packing

                                                                                                        // custom interpolators pre packing
                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                        struct Attributes
                                                                                                        {
                                                                                                             float3 positionOS : POSITION;
                                                                                                             float3 normalOS : NORMAL;
                                                                                                             float4 tangentOS : TANGENT;
                                                                                                             float4 uv1 : TEXCOORD1;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct Varyings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float3 normalWS;
                                                                                                             float4 tangentWS;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct SurfaceDescriptionInputs
                                                                                                        {
                                                                                                             float3 TangentSpaceNormal;
                                                                                                        };
                                                                                                        struct VertexDescriptionInputs
                                                                                                        {
                                                                                                             float3 ObjectSpaceNormal;
                                                                                                             float3 ObjectSpaceTangent;
                                                                                                             float3 ObjectSpacePosition;
                                                                                                        };
                                                                                                        struct PackedVaryings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float3 interp0 : INTERP0;
                                                                                                             float4 interp1 : INTERP1;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };

                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                        {
                                                                                                            PackedVaryings output;
                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.interp0.xyz = input.normalWS;
                                                                                                            output.interp1.xyzw = input.tangentWS;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }

                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                        {
                                                                                                            Varyings output;
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.normalWS = input.interp0.xyz;
                                                                                                            output.tangentWS = input.interp1.xyzw;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }


                                                                                                        // --------------------------------------------------
                                                                                                        // Graph

                                                                                                        // Graph Properties
                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                        float4 _WaterTexture_TexelSize;
                                                                                                        float _WaterHeight;
                                                                                                        float4 _SandTexture_TexelSize;
                                                                                                        float _SandHeight;
                                                                                                        float4 _GrassTexture_TexelSize;
                                                                                                        float _GrassHeight;
                                                                                                        float4 _RockTexture_TexelSize;
                                                                                                        float _RockHeight;
                                                                                                        float4 _SnowTexture_TexelSize;
                                                                                                        float _SnowHeight;
                                                                                                        float _NearbyPickHeight;
                                                                                                        float4 _WaterNormal_TexelSize;
                                                                                                        float4 _RockNormal_TexelSize;
                                                                                                        float4 _GrassNormal_TexelSize;
                                                                                                        float4 _SandNormal_TexelSize;
                                                                                                        float4 _SnowNormal_TexelSize;
                                                                                                        CBUFFER_END

                                                                                                            // Object and Global properties
                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                            TEXTURE2D(_WaterTexture);
                                                                                                            SAMPLER(sampler_WaterTexture);
                                                                                                            TEXTURE2D(_SandTexture);
                                                                                                            SAMPLER(sampler_SandTexture);
                                                                                                            TEXTURE2D(_GrassTexture);
                                                                                                            SAMPLER(sampler_GrassTexture);
                                                                                                            TEXTURE2D(_RockTexture);
                                                                                                            SAMPLER(sampler_RockTexture);
                                                                                                            TEXTURE2D(_SnowTexture);
                                                                                                            SAMPLER(sampler_SnowTexture);
                                                                                                            TEXTURE2D(_WaterNormal);
                                                                                                            SAMPLER(sampler_WaterNormal);
                                                                                                            TEXTURE2D(_RockNormal);
                                                                                                            SAMPLER(sampler_RockNormal);
                                                                                                            TEXTURE2D(_GrassNormal);
                                                                                                            SAMPLER(sampler_GrassNormal);
                                                                                                            TEXTURE2D(_SandNormal);
                                                                                                            SAMPLER(sampler_SandNormal);
                                                                                                            TEXTURE2D(_SnowNormal);
                                                                                                            SAMPLER(sampler_SnowNormal);

                                                                                                            // Graph Includes
                                                                                                            // GraphIncludes: <None>

                                                                                                            // -- Property used by ScenePickingPass
                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                            float4 _SelectionID;
                                                                                                            #endif

                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                            int _ObjectId;
                                                                                                            int _PassValue;
                                                                                                            #endif

                                                                                                            // Graph Functions
                                                                                                            // GraphFunctions: <None>

                                                                                                            // Custom interpolators pre vertex
                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                            // Graph Vertex
                                                                                                            struct VertexDescription
                                                                                                            {
                                                                                                                float3 Position;
                                                                                                                float3 Normal;
                                                                                                                float3 Tangent;
                                                                                                            };

                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                            {
                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                return description;
                                                                                                            }

                                                                                                            // Custom interpolators, pre surface
                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                            {
                                                                                                            return output;
                                                                                                            }
                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                            #endif

                                                                                                            // Graph Pixel
                                                                                                            struct SurfaceDescription
                                                                                                            {
                                                                                                                float3 NormalTS;
                                                                                                            };

                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                            {
                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                                                                                return surface;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Build Graph Inputs
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                            #endif
                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                            {
                                                                                                                VertexDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                return output;
                                                                                                            }
                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                            {
                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                            #endif





                                                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                            #else
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                            #endif
                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                    return output;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Main

                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                                                                                            // --------------------------------------------------
                                                                                                            // Visual Effect Vertex Invocations
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                            #endif

                                                                                                            ENDHLSL
                                                                                                            }
                                                                                                            Pass
                                                                                                            {
                                                                                                                Name "Meta"
                                                                                                                Tags
                                                                                                                {
                                                                                                                    "LightMode" = "Meta"
                                                                                                                }

                                                                                                                // Render State
                                                                                                                Cull Off

                                                                                                                // Debug
                                                                                                                // <None>

                                                                                                                // --------------------------------------------------
                                                                                                                // Pass

                                                                                                                HLSLPROGRAM

                                                                                                                // Pragmas
                                                                                                                #pragma target 2.0
                                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                #pragma vertex vert
                                                                                                                #pragma fragment frag

                                                                                                                // DotsInstancingOptions: <None>
                                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                // Keywords
                                                                                                                #pragma shader_feature _ EDITOR_VISUALIZATION
                                                                                                                // GraphKeywords: <None>

                                                                                                                // Defines

                                                                                                                #define _NORMALMAP 1
                                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                                                #define VARYINGS_NEED_TEXCOORD1
                                                                                                                #define VARYINGS_NEED_TEXCOORD2
                                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                #define SHADERPASS SHADERPASS_META
                                                                                                                #define _FOG_FRAGMENT 1
                                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                // custom interpolator pre-include
                                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                // Includes
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                // --------------------------------------------------
                                                                                                                // Structs and Packing

                                                                                                                // custom interpolators pre packing
                                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                struct Attributes
                                                                                                                {
                                                                                                                     float3 positionOS : POSITION;
                                                                                                                     float3 normalOS : NORMAL;
                                                                                                                     float4 tangentOS : TANGENT;
                                                                                                                     float4 uv0 : TEXCOORD0;
                                                                                                                     float4 uv1 : TEXCOORD1;
                                                                                                                     float4 uv2 : TEXCOORD2;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct Varyings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float3 positionWS;
                                                                                                                     float3 normalWS;
                                                                                                                     float4 texCoord0;
                                                                                                                     float4 texCoord1;
                                                                                                                     float4 texCoord2;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct SurfaceDescriptionInputs
                                                                                                                {
                                                                                                                     float3 WorldSpaceNormal;
                                                                                                                     float3 WorldSpacePosition;
                                                                                                                     float3 AbsoluteWorldSpacePosition;
                                                                                                                     float4 uv0;
                                                                                                                };
                                                                                                                struct VertexDescriptionInputs
                                                                                                                {
                                                                                                                     float3 ObjectSpaceNormal;
                                                                                                                     float3 ObjectSpaceTangent;
                                                                                                                     float3 ObjectSpacePosition;
                                                                                                                };
                                                                                                                struct PackedVaryings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float3 interp0 : INTERP0;
                                                                                                                     float3 interp1 : INTERP1;
                                                                                                                     float4 interp2 : INTERP2;
                                                                                                                     float4 interp3 : INTERP3;
                                                                                                                     float4 interp4 : INTERP4;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };

                                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                                {
                                                                                                                    PackedVaryings output;
                                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.interp0.xyz = input.positionWS;
                                                                                                                    output.interp1.xyz = input.normalWS;
                                                                                                                    output.interp2.xyzw = input.texCoord0;
                                                                                                                    output.interp3.xyzw = input.texCoord1;
                                                                                                                    output.interp4.xyzw = input.texCoord2;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }

                                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                {
                                                                                                                    Varyings output;
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.positionWS = input.interp0.xyz;
                                                                                                                    output.normalWS = input.interp1.xyz;
                                                                                                                    output.texCoord0 = input.interp2.xyzw;
                                                                                                                    output.texCoord1 = input.interp3.xyzw;
                                                                                                                    output.texCoord2 = input.interp4.xyzw;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }


                                                                                                                // --------------------------------------------------
                                                                                                                // Graph

                                                                                                                // Graph Properties
                                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                                float4 _WaterTexture_TexelSize;
                                                                                                                float _WaterHeight;
                                                                                                                float4 _SandTexture_TexelSize;
                                                                                                                float _SandHeight;
                                                                                                                float4 _GrassTexture_TexelSize;
                                                                                                                float _GrassHeight;
                                                                                                                float4 _RockTexture_TexelSize;
                                                                                                                float _RockHeight;
                                                                                                                float4 _SnowTexture_TexelSize;
                                                                                                                float _SnowHeight;
                                                                                                                float _NearbyPickHeight;
                                                                                                                float4 _WaterNormal_TexelSize;
                                                                                                                float4 _RockNormal_TexelSize;
                                                                                                                float4 _GrassNormal_TexelSize;
                                                                                                                float4 _SandNormal_TexelSize;
                                                                                                                float4 _SnowNormal_TexelSize;
                                                                                                                CBUFFER_END

                                                                                                                    // Object and Global properties
                                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                    TEXTURE2D(_WaterTexture);
                                                                                                                    SAMPLER(sampler_WaterTexture);
                                                                                                                    TEXTURE2D(_SandTexture);
                                                                                                                    SAMPLER(sampler_SandTexture);
                                                                                                                    TEXTURE2D(_GrassTexture);
                                                                                                                    SAMPLER(sampler_GrassTexture);
                                                                                                                    TEXTURE2D(_RockTexture);
                                                                                                                    SAMPLER(sampler_RockTexture);
                                                                                                                    TEXTURE2D(_SnowTexture);
                                                                                                                    SAMPLER(sampler_SnowTexture);
                                                                                                                    TEXTURE2D(_WaterNormal);
                                                                                                                    SAMPLER(sampler_WaterNormal);
                                                                                                                    TEXTURE2D(_RockNormal);
                                                                                                                    SAMPLER(sampler_RockNormal);
                                                                                                                    TEXTURE2D(_GrassNormal);
                                                                                                                    SAMPLER(sampler_GrassNormal);
                                                                                                                    TEXTURE2D(_SandNormal);
                                                                                                                    SAMPLER(sampler_SandNormal);
                                                                                                                    TEXTURE2D(_SnowNormal);
                                                                                                                    SAMPLER(sampler_SnowNormal);

                                                                                                                    // Graph Includes
                                                                                                                    // GraphIncludes: <None>

                                                                                                                    // -- Property used by ScenePickingPass
                                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                                    float4 _SelectionID;
                                                                                                                    #endif

                                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                                    int _ObjectId;
                                                                                                                    int _PassValue;
                                                                                                                    #endif

                                                                                                                    // Graph Functions

                                                                                                                    void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                        Out = A <= B ? 1 : 0;
                                                                                                                    }

                                                                                                                    void Unity_InverseLerp_float(float A, float B, float T, out float Out)
                                                                                                                    {
                                                                                                                        Out = (T - A) / (B - A);
                                                                                                                    }

                                                                                                                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                                                                                    {
                                                                                                                        Out = lerp(A, B, T);
                                                                                                                    }

                                                                                                                    void Unity_Blend_Exclusion_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                                                                                                    {
                                                                                                                        Out = Blend + Base - (2.0 * Blend * Base);
                                                                                                                        Out = lerp(Base, Out, Opacity);
                                                                                                                    }

                                                                                                                    void Unity_Power_float4(float4 A, float4 B, out float4 Out)
                                                                                                                    {
                                                                                                                        Out = pow(A, B);
                                                                                                                    }

                                                                                                                    void Unity_Blend_Screen_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                                                                                                    {
                                                                                                                        Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
                                                                                                                        Out = lerp(Base, Out, Opacity);
                                                                                                                    }

                                                                                                                    void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                                                                    {
                                                                                                                        Out = Predicate ? True : False;
                                                                                                                    }

                                                                                                                    // Custom interpolators pre vertex
                                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                    // Graph Vertex
                                                                                                                    struct VertexDescription
                                                                                                                    {
                                                                                                                        float3 Position;
                                                                                                                        float3 Normal;
                                                                                                                        float3 Tangent;
                                                                                                                    };

                                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                        return description;
                                                                                                                    }

                                                                                                                    // Custom interpolators, pre surface
                                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                    {
                                                                                                                    return output;
                                                                                                                    }
                                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                    #endif

                                                                                                                    // Graph Pixel
                                                                                                                    struct SurfaceDescription
                                                                                                                    {
                                                                                                                        float3 BaseColor;
                                                                                                                        float3 Emission;
                                                                                                                    };

                                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                        float4 _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0 = IN.uv0;
                                                                                                                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_R_1 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[0];
                                                                                                                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[1];
                                                                                                                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_B_3 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[2];
                                                                                                                        float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_A_4 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[3];
                                                                                                                        float _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0 = _SandHeight;
                                                                                                                        float _Comparison_befd0823d3d24995af6d977e0af38232_Out_2;
                                                                                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Comparison_befd0823d3d24995af6d977e0af38232_Out_2);
                                                                                                                        UnityTexture2D _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0 = UnityBuildTexture2DStructNoScale(_WaterTexture);
                                                                                                                        float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                        float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                        Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend /= dot(Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend, 1.0);
                                                                                                                        float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.zy);
                                                                                                                        float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xz);
                                                                                                                        float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xy);
                                                                                                                        float4 _Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0 = Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.x + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.y + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.z;
                                                                                                                        UnityTexture2D _Property_36337b09844644179547e9e25c7c4274_Out_0 = UnityBuildTexture2DStructNoScale(_SandTexture);
                                                                                                                        float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                        float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                        Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend /= dot(Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend, 1.0);
                                                                                                                        float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_X = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.zy);
                                                                                                                        float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xz);
                                                                                                                        float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xy);
                                                                                                                        float4 _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0 = Triplanar_b5daae74a8384db9b8d43474f55b1cca_X * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.x + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.y + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.z;
                                                                                                                        float _Property_bc6acfb4eb504fa188ea556c8f614756_Out_0 = _WaterHeight;
                                                                                                                        float _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3;
                                                                                                                        Unity_InverseLerp_float(_Property_bc6acfb4eb504fa188ea556c8f614756_Out_0, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3);
                                                                                                                        float4 _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3;
                                                                                                                        Unity_Lerp_float4(_Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0, _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, (_InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3.xxxx), _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3);
                                                                                                                        float _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0 = _GrassHeight;
                                                                                                                        float _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2;
                                                                                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2);
                                                                                                                        UnityTexture2D _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0 = UnityBuildTexture2DStructNoScale(_GrassTexture);
                                                                                                                        float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                        float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                        Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend /= dot(Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend, 1.0);
                                                                                                                        float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_X = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.zy);
                                                                                                                        float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xz);
                                                                                                                        float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xy);
                                                                                                                        float4 _Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0 = Triplanar_05b6acc8be54451b8049b91ed12ebc24_X * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.x + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.y + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.z;
                                                                                                                        UnityTexture2D _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                                                                                        float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                        float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                        Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend /= dot(Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend, 1.0);
                                                                                                                        float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_X = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.zy);
                                                                                                                        float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Y = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xz);
                                                                                                                        float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Z = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xy);
                                                                                                                        float4 _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0 = Triplanar_1ed180918dcb4468b12011d31552c9d9_X * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.x + Triplanar_1ed180918dcb4468b12011d31552c9d9_Y * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.y + Triplanar_1ed180918dcb4468b12011d31552c9d9_Z * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.z;
                                                                                                                        float4 _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2;
                                                                                                                        Unity_Blend_Exclusion_float4(_Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0, _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0, _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, 0.52);
                                                                                                                        float _Float_cf64f4c58290409ea67cef8f97bd8453_Out_0 = 2.33;
                                                                                                                        float4 _Power_04f1890bf939475b9826ed03816155ce_Out_2;
                                                                                                                        Unity_Power_float4(_Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, (_Float_cf64f4c58290409ea67cef8f97bd8453_Out_0.xxxx), _Power_04f1890bf939475b9826ed03816155ce_Out_2);
                                                                                                                        float _Property_50b2430cc37d40d9862de7ec154fbd82_Out_0 = _SandHeight;
                                                                                                                        float _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3;
                                                                                                                        Unity_InverseLerp_float(_Property_50b2430cc37d40d9862de7ec154fbd82_Out_0, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3);
                                                                                                                        float4 _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3;
                                                                                                                        Unity_Lerp_float4(_Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, _Power_04f1890bf939475b9826ed03816155ce_Out_2, (_InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3.xxxx), _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3);
                                                                                                                        float _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0 = _RockHeight;
                                                                                                                        float _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2;
                                                                                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2);
                                                                                                                        UnityTexture2D _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                                                                                        float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                        float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                        Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend /= dot(Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend, 1.0);
                                                                                                                        float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_X = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.zy);
                                                                                                                        float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Y = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xz);
                                                                                                                        float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Z = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xy);
                                                                                                                        float4 _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0 = Triplanar_358c24aad7c14e0a924836817da2e7b9_X * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.x + Triplanar_358c24aad7c14e0a924836817da2e7b9_Y * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.y + Triplanar_358c24aad7c14e0a924836817da2e7b9_Z * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.z;
                                                                                                                        float _Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0 = _GrassHeight;
                                                                                                                        float _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3;
                                                                                                                        Unity_InverseLerp_float(_Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3);
                                                                                                                        float4 _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3;
                                                                                                                        Unity_Lerp_float4(_Power_04f1890bf939475b9826ed03816155ce_Out_2, _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, (_InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3.xxxx), _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3);
                                                                                                                        float _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0 = _NearbyPickHeight;
                                                                                                                        float _Comparison_0c144defb135447fa506399b1e5b782c_Out_2;
                                                                                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Comparison_0c144defb135447fa506399b1e5b782c_Out_2);
                                                                                                                        UnityTexture2D _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                                                                                        float3 Triplanar_67e476af87e34432bb1425483e85eeaf_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                        float3 Triplanar_67e476af87e34432bb1425483e85eeaf_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                        Triplanar_67e476af87e34432bb1425483e85eeaf_Blend /= dot(Triplanar_67e476af87e34432bb1425483e85eeaf_Blend, 1.0);
                                                                                                                        float4 Triplanar_67e476af87e34432bb1425483e85eeaf_X = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.zy);
                                                                                                                        float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Y = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xz);
                                                                                                                        float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Z = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xy);
                                                                                                                        float4 _Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0 = Triplanar_67e476af87e34432bb1425483e85eeaf_X * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.x + Triplanar_67e476af87e34432bb1425483e85eeaf_Y * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.y + Triplanar_67e476af87e34432bb1425483e85eeaf_Z * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.z;
                                                                                                                        UnityTexture2D _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                                                                                                                        float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                        float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                        Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend /= dot(Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend, 1.0);
                                                                                                                        float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.zy);
                                                                                                                        float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xz);
                                                                                                                        float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xy);
                                                                                                                        float4 _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0 = Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.x + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.y + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.z;
                                                                                                                        float4 _Blend_18b55f11871e43b0a33d88203ed53708_Out_2;
                                                                                                                        Unity_Blend_Screen_float4(_Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0, _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, 0.39);
                                                                                                                        float _Property_7e4dc6d5804f488db1d161cc882419e8_Out_0 = _RockHeight;
                                                                                                                        float _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3;
                                                                                                                        Unity_InverseLerp_float(_Property_7e4dc6d5804f488db1d161cc882419e8_Out_0, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3);
                                                                                                                        float4 _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3;
                                                                                                                        Unity_Lerp_float4(_Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, (_InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3.xxxx), _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3);
                                                                                                                        float _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0 = _SnowHeight;
                                                                                                                        float _Comparison_f94a526e09724297a991b6e76aec137f_Out_2;
                                                                                                                        Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0, _Comparison_f94a526e09724297a991b6e76aec137f_Out_2);
                                                                                                                        UnityTexture2D _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                                                                                                                        float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                        float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                        Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend /= dot(Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend, 1.0);
                                                                                                                        float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.zy);
                                                                                                                        float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xz);
                                                                                                                        float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xy);
                                                                                                                        float4 _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0 = Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.x + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.y + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.z;
                                                                                                                        float _Property_a4d949d8c5254a3e87c67e9c593124af_Out_0 = _NearbyPickHeight;
                                                                                                                        float _Property_3964305cc05045849c1082166182507e_Out_0 = _SnowHeight;
                                                                                                                        float _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3;
                                                                                                                        Unity_InverseLerp_float(_Property_a4d949d8c5254a3e87c67e9c593124af_Out_0, _Property_3964305cc05045849c1082166182507e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3);
                                                                                                                        float4 _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3;
                                                                                                                        Unity_Lerp_float4(_Blend_18b55f11871e43b0a33d88203ed53708_Out_2, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, (_InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3.xxxx), _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3);
                                                                                                                        float4 _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3;
                                                                                                                        Unity_Branch_float4(_Comparison_f94a526e09724297a991b6e76aec137f_Out_2, _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3);
                                                                                                                        float4 _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3;
                                                                                                                        Unity_Branch_float4(_Comparison_0c144defb135447fa506399b1e5b782c_Out_2, _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3);
                                                                                                                        float4 _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3;
                                                                                                                        Unity_Branch_float4(_Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2, _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3);
                                                                                                                        float4 _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3;
                                                                                                                        Unity_Branch_float4(_Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2, _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3);
                                                                                                                        float4 _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3;
                                                                                                                        Unity_Branch_float4(_Comparison_befd0823d3d24995af6d977e0af38232_Out_2, _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3, _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3);
                                                                                                                        surface.BaseColor = (_Branch_664fbb7767f64053b62a1c4248a59dba_Out_3.xyz);
                                                                                                                        surface.Emission = float3(0, 0, 0);
                                                                                                                        return surface;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Build Graph Inputs
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                    #endif
                                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                    {
                                                                                                                        VertexDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                                        return output;
                                                                                                                    }
                                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                    {
                                                                                                                        SurfaceDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                    #endif



                                                                                                                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                                                                                        float3 unnormalizedNormalWS = input.normalWS;
                                                                                                                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                                                                                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                                                        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                                                                                                                        output.uv0 = input.texCoord0;
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                    #else
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                    #endif
                                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                            return output;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Main

                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Visual Effect Vertex Invocations
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                    #endif

                                                                                                                    ENDHLSL
                                                                                                                    }
                                                                                                                    Pass
                                                                                                                    {
                                                                                                                        Name "SceneSelectionPass"
                                                                                                                        Tags
                                                                                                                        {
                                                                                                                            "LightMode" = "SceneSelectionPass"
                                                                                                                        }

                                                                                                                        // Render State
                                                                                                                        Cull Off

                                                                                                                        // Debug
                                                                                                                        // <None>

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Pass

                                                                                                                        HLSLPROGRAM

                                                                                                                        // Pragmas
                                                                                                                        #pragma target 2.0
                                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                        #pragma multi_compile_instancing
                                                                                                                        #pragma vertex vert
                                                                                                                        #pragma fragment frag

                                                                                                                        // DotsInstancingOptions: <None>
                                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                        // Keywords
                                                                                                                        // PassKeywords: <None>
                                                                                                                        // GraphKeywords: <None>

                                                                                                                        // Defines

                                                                                                                        #define _NORMALMAP 1
                                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                                        #define SCENESELECTIONPASS 1
                                                                                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                        // custom interpolator pre-include
                                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                        // Includes
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Structs and Packing

                                                                                                                        // custom interpolators pre packing
                                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                        struct Attributes
                                                                                                                        {
                                                                                                                             float3 positionOS : POSITION;
                                                                                                                             float3 normalOS : NORMAL;
                                                                                                                             float4 tangentOS : TANGENT;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct Varyings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct SurfaceDescriptionInputs
                                                                                                                        {
                                                                                                                        };
                                                                                                                        struct VertexDescriptionInputs
                                                                                                                        {
                                                                                                                             float3 ObjectSpaceNormal;
                                                                                                                             float3 ObjectSpaceTangent;
                                                                                                                             float3 ObjectSpacePosition;
                                                                                                                        };
                                                                                                                        struct PackedVaryings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };

                                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                                        {
                                                                                                                            PackedVaryings output;
                                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }

                                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                        {
                                                                                                                            Varyings output;
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }


                                                                                                                        // --------------------------------------------------
                                                                                                                        // Graph

                                                                                                                        // Graph Properties
                                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                                        float4 _WaterTexture_TexelSize;
                                                                                                                        float _WaterHeight;
                                                                                                                        float4 _SandTexture_TexelSize;
                                                                                                                        float _SandHeight;
                                                                                                                        float4 _GrassTexture_TexelSize;
                                                                                                                        float _GrassHeight;
                                                                                                                        float4 _RockTexture_TexelSize;
                                                                                                                        float _RockHeight;
                                                                                                                        float4 _SnowTexture_TexelSize;
                                                                                                                        float _SnowHeight;
                                                                                                                        float _NearbyPickHeight;
                                                                                                                        float4 _WaterNormal_TexelSize;
                                                                                                                        float4 _RockNormal_TexelSize;
                                                                                                                        float4 _GrassNormal_TexelSize;
                                                                                                                        float4 _SandNormal_TexelSize;
                                                                                                                        float4 _SnowNormal_TexelSize;
                                                                                                                        CBUFFER_END

                                                                                                                            // Object and Global properties
                                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                            TEXTURE2D(_WaterTexture);
                                                                                                                            SAMPLER(sampler_WaterTexture);
                                                                                                                            TEXTURE2D(_SandTexture);
                                                                                                                            SAMPLER(sampler_SandTexture);
                                                                                                                            TEXTURE2D(_GrassTexture);
                                                                                                                            SAMPLER(sampler_GrassTexture);
                                                                                                                            TEXTURE2D(_RockTexture);
                                                                                                                            SAMPLER(sampler_RockTexture);
                                                                                                                            TEXTURE2D(_SnowTexture);
                                                                                                                            SAMPLER(sampler_SnowTexture);
                                                                                                                            TEXTURE2D(_WaterNormal);
                                                                                                                            SAMPLER(sampler_WaterNormal);
                                                                                                                            TEXTURE2D(_RockNormal);
                                                                                                                            SAMPLER(sampler_RockNormal);
                                                                                                                            TEXTURE2D(_GrassNormal);
                                                                                                                            SAMPLER(sampler_GrassNormal);
                                                                                                                            TEXTURE2D(_SandNormal);
                                                                                                                            SAMPLER(sampler_SandNormal);
                                                                                                                            TEXTURE2D(_SnowNormal);
                                                                                                                            SAMPLER(sampler_SnowNormal);

                                                                                                                            // Graph Includes
                                                                                                                            // GraphIncludes: <None>

                                                                                                                            // -- Property used by ScenePickingPass
                                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                                            float4 _SelectionID;
                                                                                                                            #endif

                                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                                            int _ObjectId;
                                                                                                                            int _PassValue;
                                                                                                                            #endif

                                                                                                                            // Graph Functions
                                                                                                                            // GraphFunctions: <None>

                                                                                                                            // Custom interpolators pre vertex
                                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                            // Graph Vertex
                                                                                                                            struct VertexDescription
                                                                                                                            {
                                                                                                                                float3 Position;
                                                                                                                                float3 Normal;
                                                                                                                                float3 Tangent;
                                                                                                                            };

                                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                                return description;
                                                                                                                            }

                                                                                                                            // Custom interpolators, pre surface
                                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                            {
                                                                                                                            return output;
                                                                                                                            }
                                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                            #endif

                                                                                                                            // Graph Pixel
                                                                                                                            struct SurfaceDescription
                                                                                                                            {
                                                                                                                            };

                                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                                return surface;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Build Graph Inputs
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                            #endif
                                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                            {
                                                                                                                                VertexDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                                return output;
                                                                                                                            }
                                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                            {
                                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                            #endif







                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                            #else
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                            #endif
                                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                                    return output;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Main

                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Visual Effect Vertex Invocations
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                            #endif

                                                                                                                            ENDHLSL
                                                                                                                            }
                                                                                                                            Pass
                                                                                                                            {
                                                                                                                                Name "ScenePickingPass"
                                                                                                                                Tags
                                                                                                                                {
                                                                                                                                    "LightMode" = "Picking"
                                                                                                                                }

                                                                                                                                // Render State
                                                                                                                                Cull Back

                                                                                                                                // Debug
                                                                                                                                // <None>

                                                                                                                                // --------------------------------------------------
                                                                                                                                // Pass

                                                                                                                                HLSLPROGRAM

                                                                                                                                // Pragmas
                                                                                                                                #pragma target 2.0
                                                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                                #pragma multi_compile_instancing
                                                                                                                                #pragma vertex vert
                                                                                                                                #pragma fragment frag

                                                                                                                                // DotsInstancingOptions: <None>
                                                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                                // Keywords
                                                                                                                                // PassKeywords: <None>
                                                                                                                                // GraphKeywords: <None>

                                                                                                                                // Defines

                                                                                                                                #define _NORMALMAP 1
                                                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                                                #define SCENEPICKINGPASS 1
                                                                                                                                #define ALPHA_CLIP_THRESHOLD 1
                                                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                                // custom interpolator pre-include
                                                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                                // Includes
                                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                                // --------------------------------------------------
                                                                                                                                // Structs and Packing

                                                                                                                                // custom interpolators pre packing
                                                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                                struct Attributes
                                                                                                                                {
                                                                                                                                     float3 positionOS : POSITION;
                                                                                                                                     float3 normalOS : NORMAL;
                                                                                                                                     float4 tangentOS : TANGENT;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                                    #endif
                                                                                                                                };
                                                                                                                                struct Varyings
                                                                                                                                {
                                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                                    #endif
                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                                    #endif
                                                                                                                                };
                                                                                                                                struct SurfaceDescriptionInputs
                                                                                                                                {
                                                                                                                                };
                                                                                                                                struct VertexDescriptionInputs
                                                                                                                                {
                                                                                                                                     float3 ObjectSpaceNormal;
                                                                                                                                     float3 ObjectSpaceTangent;
                                                                                                                                     float3 ObjectSpacePosition;
                                                                                                                                };
                                                                                                                                struct PackedVaryings
                                                                                                                                {
                                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                                    #endif
                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                                    #endif
                                                                                                                                };

                                                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                                                {
                                                                                                                                    PackedVaryings output;
                                                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                                    #endif
                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                                    #endif
                                                                                                                                    return output;
                                                                                                                                }

                                                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                                {
                                                                                                                                    Varyings output;
                                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                                    #endif
                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                                    #endif
                                                                                                                                    return output;
                                                                                                                                }


                                                                                                                                // --------------------------------------------------
                                                                                                                                // Graph

                                                                                                                                // Graph Properties
                                                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                                                float4 _WaterTexture_TexelSize;
                                                                                                                                float _WaterHeight;
                                                                                                                                float4 _SandTexture_TexelSize;
                                                                                                                                float _SandHeight;
                                                                                                                                float4 _GrassTexture_TexelSize;
                                                                                                                                float _GrassHeight;
                                                                                                                                float4 _RockTexture_TexelSize;
                                                                                                                                float _RockHeight;
                                                                                                                                float4 _SnowTexture_TexelSize;
                                                                                                                                float _SnowHeight;
                                                                                                                                float _NearbyPickHeight;
                                                                                                                                float4 _WaterNormal_TexelSize;
                                                                                                                                float4 _RockNormal_TexelSize;
                                                                                                                                float4 _GrassNormal_TexelSize;
                                                                                                                                float4 _SandNormal_TexelSize;
                                                                                                                                float4 _SnowNormal_TexelSize;
                                                                                                                                CBUFFER_END

                                                                                                                                    // Object and Global properties
                                                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                                    TEXTURE2D(_WaterTexture);
                                                                                                                                    SAMPLER(sampler_WaterTexture);
                                                                                                                                    TEXTURE2D(_SandTexture);
                                                                                                                                    SAMPLER(sampler_SandTexture);
                                                                                                                                    TEXTURE2D(_GrassTexture);
                                                                                                                                    SAMPLER(sampler_GrassTexture);
                                                                                                                                    TEXTURE2D(_RockTexture);
                                                                                                                                    SAMPLER(sampler_RockTexture);
                                                                                                                                    TEXTURE2D(_SnowTexture);
                                                                                                                                    SAMPLER(sampler_SnowTexture);
                                                                                                                                    TEXTURE2D(_WaterNormal);
                                                                                                                                    SAMPLER(sampler_WaterNormal);
                                                                                                                                    TEXTURE2D(_RockNormal);
                                                                                                                                    SAMPLER(sampler_RockNormal);
                                                                                                                                    TEXTURE2D(_GrassNormal);
                                                                                                                                    SAMPLER(sampler_GrassNormal);
                                                                                                                                    TEXTURE2D(_SandNormal);
                                                                                                                                    SAMPLER(sampler_SandNormal);
                                                                                                                                    TEXTURE2D(_SnowNormal);
                                                                                                                                    SAMPLER(sampler_SnowNormal);

                                                                                                                                    // Graph Includes
                                                                                                                                    // GraphIncludes: <None>

                                                                                                                                    // -- Property used by ScenePickingPass
                                                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                                                    float4 _SelectionID;
                                                                                                                                    #endif

                                                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                                                    int _ObjectId;
                                                                                                                                    int _PassValue;
                                                                                                                                    #endif

                                                                                                                                    // Graph Functions
                                                                                                                                    // GraphFunctions: <None>

                                                                                                                                    // Custom interpolators pre vertex
                                                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                                    // Graph Vertex
                                                                                                                                    struct VertexDescription
                                                                                                                                    {
                                                                                                                                        float3 Position;
                                                                                                                                        float3 Normal;
                                                                                                                                        float3 Tangent;
                                                                                                                                    };

                                                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                                    {
                                                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                                        return description;
                                                                                                                                    }

                                                                                                                                    // Custom interpolators, pre surface
                                                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                                    {
                                                                                                                                    return output;
                                                                                                                                    }
                                                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                                    #endif

                                                                                                                                    // Graph Pixel
                                                                                                                                    struct SurfaceDescription
                                                                                                                                    {
                                                                                                                                    };

                                                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                                    {
                                                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                                        return surface;
                                                                                                                                    }

                                                                                                                                    // --------------------------------------------------
                                                                                                                                    // Build Graph Inputs
                                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                                    #endif
                                                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                                    {
                                                                                                                                        VertexDescriptionInputs output;
                                                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                                                        return output;
                                                                                                                                    }
                                                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                                    {
                                                                                                                                        SurfaceDescriptionInputs output;
                                                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                                    #endif







                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                                    #else
                                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                                    #endif
                                                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                                            return output;
                                                                                                                                    }

                                                                                                                                    // --------------------------------------------------
                                                                                                                                    // Main

                                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                                                    // --------------------------------------------------
                                                                                                                                    // Visual Effect Vertex Invocations
                                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                                    #endif

                                                                                                                                    ENDHLSL
                                                                                                                                    }
                                                                                                                                    Pass
                                                                                                                                    {
                                                                                                                                        // Name: <None>
                                                                                                                                        Tags
                                                                                                                                        {
                                                                                                                                            "LightMode" = "Universal2D"
                                                                                                                                        }

                                                                                                                                        // Render State
                                                                                                                                        Cull Back
                                                                                                                                        Blend One Zero
                                                                                                                                        ZTest LEqual
                                                                                                                                        ZWrite On

                                                                                                                                        // Debug
                                                                                                                                        // <None>

                                                                                                                                        // --------------------------------------------------
                                                                                                                                        // Pass

                                                                                                                                        HLSLPROGRAM

                                                                                                                                        // Pragmas
                                                                                                                                        #pragma target 2.0
                                                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                                        #pragma multi_compile_instancing
                                                                                                                                        #pragma vertex vert
                                                                                                                                        #pragma fragment frag

                                                                                                                                        // DotsInstancingOptions: <None>
                                                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                                        // Keywords
                                                                                                                                        // PassKeywords: <None>
                                                                                                                                        // GraphKeywords: <None>

                                                                                                                                        // Defines

                                                                                                                                        #define _NORMALMAP 1
                                                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                                        #define SHADERPASS SHADERPASS_2D
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                                        // custom interpolator pre-include
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                                        // Includes
                                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                                        // --------------------------------------------------
                                                                                                                                        // Structs and Packing

                                                                                                                                        // custom interpolators pre packing
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                                        struct Attributes
                                                                                                                                        {
                                                                                                                                             float3 positionOS : POSITION;
                                                                                                                                             float3 normalOS : NORMAL;
                                                                                                                                             float4 tangentOS : TANGENT;
                                                                                                                                             float4 uv0 : TEXCOORD0;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                                            #endif
                                                                                                                                        };
                                                                                                                                        struct Varyings
                                                                                                                                        {
                                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                                             float3 positionWS;
                                                                                                                                             float3 normalWS;
                                                                                                                                             float4 texCoord0;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                                            #endif
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                                            #endif
                                                                                                                                        };
                                                                                                                                        struct SurfaceDescriptionInputs
                                                                                                                                        {
                                                                                                                                             float3 WorldSpaceNormal;
                                                                                                                                             float3 WorldSpacePosition;
                                                                                                                                             float3 AbsoluteWorldSpacePosition;
                                                                                                                                             float4 uv0;
                                                                                                                                        };
                                                                                                                                        struct VertexDescriptionInputs
                                                                                                                                        {
                                                                                                                                             float3 ObjectSpaceNormal;
                                                                                                                                             float3 ObjectSpaceTangent;
                                                                                                                                             float3 ObjectSpacePosition;
                                                                                                                                        };
                                                                                                                                        struct PackedVaryings
                                                                                                                                        {
                                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                                             float3 interp0 : INTERP0;
                                                                                                                                             float3 interp1 : INTERP1;
                                                                                                                                             float4 interp2 : INTERP2;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                                            #endif
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                                            #endif
                                                                                                                                        };

                                                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                                                        {
                                                                                                                                            PackedVaryings output;
                                                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                                            output.interp0.xyz = input.positionWS;
                                                                                                                                            output.interp1.xyz = input.normalWS;
                                                                                                                                            output.interp2.xyzw = input.texCoord0;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                                            #endif
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                                            #endif
                                                                                                                                            return output;
                                                                                                                                        }

                                                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                                        {
                                                                                                                                            Varyings output;
                                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                                            output.positionWS = input.interp0.xyz;
                                                                                                                                            output.normalWS = input.interp1.xyz;
                                                                                                                                            output.texCoord0 = input.interp2.xyzw;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                                            #endif
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                                            #endif
                                                                                                                                            return output;
                                                                                                                                        }


                                                                                                                                        // --------------------------------------------------
                                                                                                                                        // Graph

                                                                                                                                        // Graph Properties
                                                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                                                        float4 _WaterTexture_TexelSize;
                                                                                                                                        float _WaterHeight;
                                                                                                                                        float4 _SandTexture_TexelSize;
                                                                                                                                        float _SandHeight;
                                                                                                                                        float4 _GrassTexture_TexelSize;
                                                                                                                                        float _GrassHeight;
                                                                                                                                        float4 _RockTexture_TexelSize;
                                                                                                                                        float _RockHeight;
                                                                                                                                        float4 _SnowTexture_TexelSize;
                                                                                                                                        float _SnowHeight;
                                                                                                                                        float _NearbyPickHeight;
                                                                                                                                        float4 _WaterNormal_TexelSize;
                                                                                                                                        float4 _RockNormal_TexelSize;
                                                                                                                                        float4 _GrassNormal_TexelSize;
                                                                                                                                        float4 _SandNormal_TexelSize;
                                                                                                                                        float4 _SnowNormal_TexelSize;
                                                                                                                                        CBUFFER_END

                                                                                                                                            // Object and Global properties
                                                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                                            TEXTURE2D(_WaterTexture);
                                                                                                                                            SAMPLER(sampler_WaterTexture);
                                                                                                                                            TEXTURE2D(_SandTexture);
                                                                                                                                            SAMPLER(sampler_SandTexture);
                                                                                                                                            TEXTURE2D(_GrassTexture);
                                                                                                                                            SAMPLER(sampler_GrassTexture);
                                                                                                                                            TEXTURE2D(_RockTexture);
                                                                                                                                            SAMPLER(sampler_RockTexture);
                                                                                                                                            TEXTURE2D(_SnowTexture);
                                                                                                                                            SAMPLER(sampler_SnowTexture);
                                                                                                                                            TEXTURE2D(_WaterNormal);
                                                                                                                                            SAMPLER(sampler_WaterNormal);
                                                                                                                                            TEXTURE2D(_RockNormal);
                                                                                                                                            SAMPLER(sampler_RockNormal);
                                                                                                                                            TEXTURE2D(_GrassNormal);
                                                                                                                                            SAMPLER(sampler_GrassNormal);
                                                                                                                                            TEXTURE2D(_SandNormal);
                                                                                                                                            SAMPLER(sampler_SandNormal);
                                                                                                                                            TEXTURE2D(_SnowNormal);
                                                                                                                                            SAMPLER(sampler_SnowNormal);

                                                                                                                                            // Graph Includes
                                                                                                                                            // GraphIncludes: <None>

                                                                                                                                            // -- Property used by ScenePickingPass
                                                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                                                            float4 _SelectionID;
                                                                                                                                            #endif

                                                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                                                            int _ObjectId;
                                                                                                                                            int _PassValue;
                                                                                                                                            #endif

                                                                                                                                            // Graph Functions

                                                                                                                                            void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
                                                                                                                                            {
                                                                                                                                                Out = A <= B ? 1 : 0;
                                                                                                                                            }

                                                                                                                                            void Unity_InverseLerp_float(float A, float B, float T, out float Out)
                                                                                                                                            {
                                                                                                                                                Out = (T - A) / (B - A);
                                                                                                                                            }

                                                                                                                                            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                                                                                                            {
                                                                                                                                                Out = lerp(A, B, T);
                                                                                                                                            }

                                                                                                                                            void Unity_Blend_Exclusion_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                                                                                                                            {
                                                                                                                                                Out = Blend + Base - (2.0 * Blend * Base);
                                                                                                                                                Out = lerp(Base, Out, Opacity);
                                                                                                                                            }

                                                                                                                                            void Unity_Power_float4(float4 A, float4 B, out float4 Out)
                                                                                                                                            {
                                                                                                                                                Out = pow(A, B);
                                                                                                                                            }

                                                                                                                                            void Unity_Blend_Screen_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                                                                                                                            {
                                                                                                                                                Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
                                                                                                                                                Out = lerp(Base, Out, Opacity);
                                                                                                                                            }

                                                                                                                                            void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                                                                                                                                            {
                                                                                                                                                Out = Predicate ? True : False;
                                                                                                                                            }

                                                                                                                                            // Custom interpolators pre vertex
                                                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                                            // Graph Vertex
                                                                                                                                            struct VertexDescription
                                                                                                                                            {
                                                                                                                                                float3 Position;
                                                                                                                                                float3 Normal;
                                                                                                                                                float3 Tangent;
                                                                                                                                            };

                                                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                                            {
                                                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                                                return description;
                                                                                                                                            }

                                                                                                                                            // Custom interpolators, pre surface
                                                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                                            {
                                                                                                                                            return output;
                                                                                                                                            }
                                                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                                            #endif

                                                                                                                                            // Graph Pixel
                                                                                                                                            struct SurfaceDescription
                                                                                                                                            {
                                                                                                                                                float3 BaseColor;
                                                                                                                                            };

                                                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                                            {
                                                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                                                float4 _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0 = IN.uv0;
                                                                                                                                                float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_R_1 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[0];
                                                                                                                                                float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[1];
                                                                                                                                                float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_B_3 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[2];
                                                                                                                                                float _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_A_4 = _UV_2c1b9e2610234a11b172fc0a4853c803_Out_0[3];
                                                                                                                                                float _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0 = _SandHeight;
                                                                                                                                                float _Comparison_befd0823d3d24995af6d977e0af38232_Out_2;
                                                                                                                                                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Comparison_befd0823d3d24995af6d977e0af38232_Out_2);
                                                                                                                                                UnityTexture2D _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0 = UnityBuildTexture2DStructNoScale(_WaterTexture);
                                                                                                                                                float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                                                float3 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                                                Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend /= dot(Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend, 1.0);
                                                                                                                                                float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.zy);
                                                                                                                                                float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xz);
                                                                                                                                                float4 Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z = SAMPLE_TEXTURE2D(_Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.tex, _Property_eb049b84b9ef40fcbc86b634d2063ca1_Out_0.samplerstate, Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_UV.xy);
                                                                                                                                                float4 _Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0 = Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_X * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.x + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Y * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.y + Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Z * Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Blend.z;
                                                                                                                                                UnityTexture2D _Property_36337b09844644179547e9e25c7c4274_Out_0 = UnityBuildTexture2DStructNoScale(_SandTexture);
                                                                                                                                                float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                                                float3 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                                                Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend /= dot(Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend, 1.0);
                                                                                                                                                float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_X = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.zy);
                                                                                                                                                float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xz);
                                                                                                                                                float4 Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z = SAMPLE_TEXTURE2D(_Property_36337b09844644179547e9e25c7c4274_Out_0.tex, _Property_36337b09844644179547e9e25c7c4274_Out_0.samplerstate, Triplanar_b5daae74a8384db9b8d43474f55b1cca_UV.xy);
                                                                                                                                                float4 _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0 = Triplanar_b5daae74a8384db9b8d43474f55b1cca_X * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.x + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Y * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.y + Triplanar_b5daae74a8384db9b8d43474f55b1cca_Z * Triplanar_b5daae74a8384db9b8d43474f55b1cca_Blend.z;
                                                                                                                                                float _Property_bc6acfb4eb504fa188ea556c8f614756_Out_0 = _WaterHeight;
                                                                                                                                                float _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3;
                                                                                                                                                Unity_InverseLerp_float(_Property_bc6acfb4eb504fa188ea556c8f614756_Out_0, _Property_175cb4ff035b4714ba0c9170e979fce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3);
                                                                                                                                                float4 _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3;
                                                                                                                                                Unity_Lerp_float4(_Triplanar_e04daf4fecee4e13b40ce5d6e8755ce9_Out_0, _Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, (_InverseLerp_75b5acf6beb1485787af87a87532a44b_Out_3.xxxx), _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3);
                                                                                                                                                float _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0 = _GrassHeight;
                                                                                                                                                float _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2;
                                                                                                                                                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2);
                                                                                                                                                UnityTexture2D _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0 = UnityBuildTexture2DStructNoScale(_GrassTexture);
                                                                                                                                                float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                                                float3 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                                                Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend /= dot(Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend, 1.0);
                                                                                                                                                float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_X = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.zy);
                                                                                                                                                float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xz);
                                                                                                                                                float4 Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z = SAMPLE_TEXTURE2D(_Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.tex, _Property_6801b186d8574c3eb7a0ef336417e12c_Out_0.samplerstate, Triplanar_05b6acc8be54451b8049b91ed12ebc24_UV.xy);
                                                                                                                                                float4 _Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0 = Triplanar_05b6acc8be54451b8049b91ed12ebc24_X * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.x + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Y * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.y + Triplanar_05b6acc8be54451b8049b91ed12ebc24_Z * Triplanar_05b6acc8be54451b8049b91ed12ebc24_Blend.z;
                                                                                                                                                UnityTexture2D _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                                                                                                                float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                                                float3 Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                                                Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend /= dot(Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend, 1.0);
                                                                                                                                                float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_X = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.zy);
                                                                                                                                                float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Y = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xz);
                                                                                                                                                float4 Triplanar_1ed180918dcb4468b12011d31552c9d9_Z = SAMPLE_TEXTURE2D(_Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.tex, _Property_2d16bcb5a6024d07ac4818370bcab5e1_Out_0.samplerstate, Triplanar_1ed180918dcb4468b12011d31552c9d9_UV.xy);
                                                                                                                                                float4 _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0 = Triplanar_1ed180918dcb4468b12011d31552c9d9_X * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.x + Triplanar_1ed180918dcb4468b12011d31552c9d9_Y * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.y + Triplanar_1ed180918dcb4468b12011d31552c9d9_Z * Triplanar_1ed180918dcb4468b12011d31552c9d9_Blend.z;
                                                                                                                                                float4 _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2;
                                                                                                                                                Unity_Blend_Exclusion_float4(_Triplanar_05b6acc8be54451b8049b91ed12ebc24_Out_0, _Triplanar_1ed180918dcb4468b12011d31552c9d9_Out_0, _Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, 0.52);
                                                                                                                                                float _Float_cf64f4c58290409ea67cef8f97bd8453_Out_0 = 2.33;
                                                                                                                                                float4 _Power_04f1890bf939475b9826ed03816155ce_Out_2;
                                                                                                                                                Unity_Power_float4(_Blend_0c6a387eee0f424a9efbc963fe029586_Out_2, (_Float_cf64f4c58290409ea67cef8f97bd8453_Out_0.xxxx), _Power_04f1890bf939475b9826ed03816155ce_Out_2);
                                                                                                                                                float _Property_50b2430cc37d40d9862de7ec154fbd82_Out_0 = _SandHeight;
                                                                                                                                                float _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3;
                                                                                                                                                Unity_InverseLerp_float(_Property_50b2430cc37d40d9862de7ec154fbd82_Out_0, _Property_5e3bea8b66c1423c8b6a0aeea0f25f2e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3);
                                                                                                                                                float4 _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3;
                                                                                                                                                Unity_Lerp_float4(_Triplanar_b5daae74a8384db9b8d43474f55b1cca_Out_0, _Power_04f1890bf939475b9826ed03816155ce_Out_2, (_InverseLerp_b0b953dcf7de409e8906f0e4a63b6645_Out_3.xxxx), _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3);
                                                                                                                                                float _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0 = _RockHeight;
                                                                                                                                                float _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2;
                                                                                                                                                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2);
                                                                                                                                                UnityTexture2D _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                                                                                                                float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                                                float3 Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                                                Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend /= dot(Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend, 1.0);
                                                                                                                                                float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_X = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.zy);
                                                                                                                                                float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Y = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xz);
                                                                                                                                                float4 Triplanar_358c24aad7c14e0a924836817da2e7b9_Z = SAMPLE_TEXTURE2D(_Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.tex, _Property_ebc91ebe93ad45dbb6b046d6ac059ec4_Out_0.samplerstate, Triplanar_358c24aad7c14e0a924836817da2e7b9_UV.xy);
                                                                                                                                                float4 _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0 = Triplanar_358c24aad7c14e0a924836817da2e7b9_X * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.x + Triplanar_358c24aad7c14e0a924836817da2e7b9_Y * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.y + Triplanar_358c24aad7c14e0a924836817da2e7b9_Z * Triplanar_358c24aad7c14e0a924836817da2e7b9_Blend.z;
                                                                                                                                                float _Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0 = _GrassHeight;
                                                                                                                                                float _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3;
                                                                                                                                                Unity_InverseLerp_float(_Property_f16eb5c1dfaf454d9abba38c8e0f61c1_Out_0, _Property_eee8173015f24d9d9711ea08d04b7ce0_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3);
                                                                                                                                                float4 _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3;
                                                                                                                                                Unity_Lerp_float4(_Power_04f1890bf939475b9826ed03816155ce_Out_2, _Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, (_InverseLerp_031cb13acaae4024a62bd3ce267dc4b4_Out_3.xxxx), _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3);
                                                                                                                                                float _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0 = _NearbyPickHeight;
                                                                                                                                                float _Comparison_0c144defb135447fa506399b1e5b782c_Out_2;
                                                                                                                                                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Comparison_0c144defb135447fa506399b1e5b782c_Out_2);
                                                                                                                                                UnityTexture2D _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0 = UnityBuildTexture2DStructNoScale(_RockTexture);
                                                                                                                                                float3 Triplanar_67e476af87e34432bb1425483e85eeaf_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                                                float3 Triplanar_67e476af87e34432bb1425483e85eeaf_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                                                Triplanar_67e476af87e34432bb1425483e85eeaf_Blend /= dot(Triplanar_67e476af87e34432bb1425483e85eeaf_Blend, 1.0);
                                                                                                                                                float4 Triplanar_67e476af87e34432bb1425483e85eeaf_X = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.zy);
                                                                                                                                                float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Y = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xz);
                                                                                                                                                float4 Triplanar_67e476af87e34432bb1425483e85eeaf_Z = SAMPLE_TEXTURE2D(_Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.tex, _Property_a45a0842f59f47ec9b4dda797ee51a10_Out_0.samplerstate, Triplanar_67e476af87e34432bb1425483e85eeaf_UV.xy);
                                                                                                                                                float4 _Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0 = Triplanar_67e476af87e34432bb1425483e85eeaf_X * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.x + Triplanar_67e476af87e34432bb1425483e85eeaf_Y * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.y + Triplanar_67e476af87e34432bb1425483e85eeaf_Z * Triplanar_67e476af87e34432bb1425483e85eeaf_Blend.z;
                                                                                                                                                UnityTexture2D _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                                                                                                                                                float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                                                float3 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                                                Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend /= dot(Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend, 1.0);
                                                                                                                                                float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.zy);
                                                                                                                                                float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xz);
                                                                                                                                                float4 Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z = SAMPLE_TEXTURE2D(_Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.tex, _Property_613e56b9efcf4be3bc520a4fadbdff16_Out_0.samplerstate, Triplanar_bbaefbd874494b309ad5b1f2371b32b6_UV.xy);
                                                                                                                                                float4 _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0 = Triplanar_bbaefbd874494b309ad5b1f2371b32b6_X * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.x + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Y * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.y + Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Z * Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Blend.z;
                                                                                                                                                float4 _Blend_18b55f11871e43b0a33d88203ed53708_Out_2;
                                                                                                                                                Unity_Blend_Screen_float4(_Triplanar_67e476af87e34432bb1425483e85eeaf_Out_0, _Triplanar_bbaefbd874494b309ad5b1f2371b32b6_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, 0.39);
                                                                                                                                                float _Property_7e4dc6d5804f488db1d161cc882419e8_Out_0 = _RockHeight;
                                                                                                                                                float _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3;
                                                                                                                                                Unity_InverseLerp_float(_Property_7e4dc6d5804f488db1d161cc882419e8_Out_0, _Property_cf1eec2216eb4739b5dbdd3ed0f9e3dd_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3);
                                                                                                                                                float4 _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3;
                                                                                                                                                Unity_Lerp_float4(_Triplanar_358c24aad7c14e0a924836817da2e7b9_Out_0, _Blend_18b55f11871e43b0a33d88203ed53708_Out_2, (_InverseLerp_7f641dcec5ea4153972fd95aa7a55699_Out_3.xxxx), _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3);
                                                                                                                                                float _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0 = _SnowHeight;
                                                                                                                                                float _Comparison_f94a526e09724297a991b6e76aec137f_Out_2;
                                                                                                                                                Unity_Comparison_LessOrEqual_float(_Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _Property_a1ef2d42e92c448ba6e25afc60467ce4_Out_0, _Comparison_f94a526e09724297a991b6e76aec137f_Out_2);
                                                                                                                                                UnityTexture2D _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0 = UnityBuildTexture2DStructNoScale(_SnowTexture);
                                                                                                                                                float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV = IN.AbsoluteWorldSpacePosition * 0.2;
                                                                                                                                                float3 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(1, floor(log2(Min_float()) / log2(1 / sqrt(3)))));
                                                                                                                                                Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend /= dot(Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend, 1.0);
                                                                                                                                                float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.zy);
                                                                                                                                                float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xz);
                                                                                                                                                float4 Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z = SAMPLE_TEXTURE2D(_Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.tex, _Property_fd8bfd020fd14fcf8120917c48a0a38f_Out_0.samplerstate, Triplanar_c1da3431507f406ebb47d21d99bc4d5b_UV.xy);
                                                                                                                                                float4 _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0 = Triplanar_c1da3431507f406ebb47d21d99bc4d5b_X * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.x + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Y * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.y + Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Z * Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Blend.z;
                                                                                                                                                float _Property_a4d949d8c5254a3e87c67e9c593124af_Out_0 = _NearbyPickHeight;
                                                                                                                                                float _Property_3964305cc05045849c1082166182507e_Out_0 = _SnowHeight;
                                                                                                                                                float _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3;
                                                                                                                                                Unity_InverseLerp_float(_Property_a4d949d8c5254a3e87c67e9c593124af_Out_0, _Property_3964305cc05045849c1082166182507e_Out_0, _Split_2a7e3020c5f04e91b2e5f0fac674ad4b_G_2, _InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3);
                                                                                                                                                float4 _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3;
                                                                                                                                                Unity_Lerp_float4(_Blend_18b55f11871e43b0a33d88203ed53708_Out_2, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, (_InverseLerp_72df7b85b55b4089bf4941c01d1f71ed_Out_3.xxxx), _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3);
                                                                                                                                                float4 _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3;
                                                                                                                                                Unity_Branch_float4(_Comparison_f94a526e09724297a991b6e76aec137f_Out_2, _Lerp_7f797d90d95545cabfa599ddb04d75a2_Out_3, _Triplanar_c1da3431507f406ebb47d21d99bc4d5b_Out_0, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3);
                                                                                                                                                float4 _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3;
                                                                                                                                                Unity_Branch_float4(_Comparison_0c144defb135447fa506399b1e5b782c_Out_2, _Lerp_807510f0573a4877b32fd9bc01ffda59_Out_3, _Branch_a25a3bdcfc804931a1165a136aa2f55c_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3);
                                                                                                                                                float4 _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3;
                                                                                                                                                Unity_Branch_float4(_Comparison_ad3663811b5545339d6539ba9fe3aeda_Out_2, _Lerp_914329ed79fc4772b674a79f25b6572a_Out_3, _Branch_58867438d2ec475f9d457113f14cdbf1_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3);
                                                                                                                                                float4 _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3;
                                                                                                                                                Unity_Branch_float4(_Comparison_52a87e9cfb1f435fae316a2de466fa3c_Out_2, _Lerp_045d1158f79f4430a2dc300c42a0c623_Out_3, _Branch_a43bc3a2c80943f893c639dbc9c4b431_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3);
                                                                                                                                                float4 _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3;
                                                                                                                                                Unity_Branch_float4(_Comparison_befd0823d3d24995af6d977e0af38232_Out_2, _Lerp_2f4870bb14c4418f9dda34ead96fd985_Out_3, _Branch_122a9b1eaddd4e85a3cb32108ec46cdf_Out_3, _Branch_664fbb7767f64053b62a1c4248a59dba_Out_3);
                                                                                                                                                surface.BaseColor = (_Branch_664fbb7767f64053b62a1c4248a59dba_Out_3.xyz);
                                                                                                                                                return surface;
                                                                                                                                            }

                                                                                                                                            // --------------------------------------------------
                                                                                                                                            // Build Graph Inputs
                                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                                            #endif
                                                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                                            {
                                                                                                                                                VertexDescriptionInputs output;
                                                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                                                return output;
                                                                                                                                            }
                                                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                                            {
                                                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                                            #endif



                                                                                                                                                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                                                                                                                float3 unnormalizedNormalWS = input.normalWS;
                                                                                                                                                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                                                                                                                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                                                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                                                                                output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                                                                                                                                                output.uv0 = input.texCoord0;
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                                            #else
                                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                                            #endif
                                                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                                                    return output;
                                                                                                                                            }

                                                                                                                                            // --------------------------------------------------
                                                                                                                                            // Main

                                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                                                                                            // --------------------------------------------------
                                                                                                                                            // Visual Effect Vertex Invocations
                                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                                            #endif

                                                                                                                                            ENDHLSL
                                                                                                                                            }
                                                                            }
                                                                                CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
                                                                                                                                                CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                                                                                                FallBack "Hidden/Shader Graph/FallbackError"
}