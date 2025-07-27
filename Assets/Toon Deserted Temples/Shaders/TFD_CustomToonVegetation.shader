// Made with Amplify Shader Editor v1.9.4.4
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon/TFD_CustomToonVegetation"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_TextureSample("Texture Sample", 2D) = "white" {}
		_TextureRamp("Texture Ramp", 2D) = "white" {}
		_WindDirection("WindDirection", Vector) = (1,0,0.5,0)
		_WindSpeed("Wind Speed", Range( 0 , 1)) = 0.7
		_WindJitter("Wind Jitter", Range( 0 , 1)) = 0.25
		_WindStrenght("Wind Strenght", Range( 0 , 2)) = 0.9
		_NoiseTexture("NoiseTexture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float3 _WindDirection;
		uniform sampler2D _NoiseTexture;
		uniform float _WindSpeed;
		uniform float _WindJitter;
		uniform float _WindStrenght;
		uniform sampler2D _TextureSample;
		uniform float4 _TextureSample_ST;
		uniform sampler2D _TextureRamp;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 WindDirection140 = _WindDirection;
			float3 temp_output_144_0 = float3( (WindDirection140).xy ,  0.0 );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 panner150 = ( 1.0 * _Time.y * ( temp_output_144_0 * _WindSpeed * 8.0 ).xy + (ase_worldPos).xy);
			float4 WorldNoise158 = ( tex2Dlod( _NoiseTexture, float4( ( ( panner150 * _WindJitter ) / float2( 10,10 ) ), 0, 0.0) ) * _WindStrenght * 0.5 );
			float4 transform167 = mul(unity_WorldToObject,( float4( WindDirection140 , 0.0 ) * ( ( v.color.r * WorldNoise158 ) + ( WorldNoise158 * v.color.a ) ) ));
			float4 VertexOffset255 = transform167;
			v.vertex.xyz += VertexOffset255.xyz;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_TextureSample = i.uv_texcoord * _TextureSample_ST.xy + _TextureSample_ST.zw;
			float4 tex2DNode97 = tex2D( _TextureSample, uv_TextureSample );
			float OpacityMask258 = tex2DNode97.a;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult92 = dot( ase_worldNormal , ase_worldlightDir );
			float temp_output_93_0 = (dotResult92*0.495 + 0.5);
			float2 temp_cast_0 = (temp_output_93_0).xx;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			UnityGI gi107 = gi;
			float3 diffNorm107 = ase_normWorldNormal;
			gi107 = UnityGI_Base( data, 1, diffNorm107 );
			float3 indirectDiffuse107 = gi107.indirect.diffuse + diffNorm107 * 0.0001;
			float3 RampColor266 = ( ase_lightColor.rgb + indirectDiffuse107 );
			float3 temp_output_87_0 = ( ase_lightAtten * ase_lightColor.rgb * ase_lightColor.a );
			float3 break89 = temp_output_87_0;
			float3 temp_cast_2 = (1.0).xxx;
			#ifdef UNITY_PASS_FORWARDBASE
				float3 staticSwitch98 = temp_cast_2;
			#else
				float3 staticSwitch98 = temp_output_87_0;
			#endif
			float4 CustomLighting261 = ( ( ( ( tex2D( _TextureRamp, temp_cast_0 ) * float4( RampColor266 , 0.0 ) ) * ( temp_output_93_0 * max( max( break89.x , break89.y ) , break89.z ) ) ) * ( float4( staticSwitch98 , 0.0 ) * tex2DNode97 ) ) + ( float4( ( ase_lightColor.rgb * ase_lightColor.a * indirectDiffuse107 ) , 0.0 ) * tex2DNode97 ) );
			c.rgb = CustomLighting261.rgb;
			c.a = 1;
			clip( OpacityMask258 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows dithercrossfade vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=19404
Node;AmplifyShaderEditor.Vector3Node;139;586.6912,79.50455;Float;False;Property;_WindDirection;WindDirection;3;0;Create;True;0;0;0;False;0;False;1,0,0.5;1.5,0.2,1.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;257;-1363.648,770.892;Inherit;False;2115.348;746.7375;World Noise;16;150;151;153;144;146;145;149;148;147;152;157;156;154;155;143;141;Vertex Offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;140;780.1455,79.5983;Inherit;False;WindDirection;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;141;-1313.648,1010.535;Inherit;False;140;WindDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;143;-1090.052,1011.348;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;148;-930.6168,820.892;Inherit;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;146;-955.3007,1177.298;Float;False;Property;_WindSpeed;Wind Speed;4;0;Create;True;0;0;0;False;0;False;0.7;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;144;-931.1566,1010.977;Inherit;False;World;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;147;-935.1427,1267.269;Inherit;False;Constant;_WindSpeedMultiplier;WindSpeed Multiplier;5;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-621.0767,1158.85;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;149;-629.0137,1075.971;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-479.847,1259.011;Float;False;Property;_WindJitter;Wind Jitter;5;0;Create;True;0;0;0;False;0;False;0.25;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;150;-437.477,1135.841;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-192.5052,1135.821;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;260;-1237.37,1634.095;Inherit;False;1986.327;944.298;Custom Lighting;27;92;88;90;93;99;96;100;103;102;104;97;258;105;98;86;87;259;107;85;94;95;91;89;265;266;267;268;Lighting;0.7778307,1,0.04245281,1;0;0
Node;AmplifyShaderEditor.LightAttenuation;85;-1164.108,2116.327;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;86;-1136.909,2213.928;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;153;13.76415,1136.238;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;10,10;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;157;168.9082,1402.63;Inherit;False;Constant;_WindStrenghtMultiplier;WindStrenght Multiplier;7;0;Create;True;0;0;0;False;0;False;0.5;0.7;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;167.1472,1309.696;Inherit;False;Property;_WindStrenght;Wind Strenght;6;0;Create;True;0;0;0;False;0;False;0.9;0.7;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-858.3348,2166.563;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;88;-996.1782,1863.004;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;90;-973.1783,1710.004;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.IndirectDiffuseLighting;107;-1187.37,2427.899;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;154;160,1104;Inherit;True;Property;_NoiseTexture;NoiseTexture;7;0;Create;True;0;0;0;False;0;False;-1;None;ab84892f7ee2abe4cbfea2792f904f90;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;582.6993,1290.308;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;89;-680.1268,2015.945;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DotProductOpNode;92;-728.1782,1769.004;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;265;-576,2400;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;256;-649.1707,260.8789;Inherit;False;1400.237;424;Vertex Offset;8;165;161;160;159;162;164;166;167;;1,0,0.9449339,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;158;787.4974,1285.671;Inherit;False;WorldNoise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;91;-510.2688,1999.609;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;93;-509.4925,1769.407;Inherit;True;3;0;FLOAT;1;False;1;FLOAT;0.495;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;266;-448,2400;Inherit;False;RampColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-665.0991,2241.156;Inherit;False;Constant;_Value;Value;1;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;-353.3666,446.6589;Inherit;False;158;WorldNoise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;95;-344.9574,2038.259;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;162;-599.1705,376.6377;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;99;-213.955,1684.095;Inherit;True;Property;_TextureRamp;Texture Ramp;2;0;Create;True;0;0;0;False;0;False;-1;None;4ad8c21978cf8a842bba8230cf956f9a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;268;-160,1888;Inherit;False;266;RampColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;98;-327.3812,2161.861;Inherit;False;Property;_UNITY_PASS_FORWARDBASE2;UNITY_PASS_FORWARDBASE;1;0;Create;False;0;0;0;True;0;False;0;0;0;False;UNITY_PASS_FORWARDBASE;Toggle;2;UNITY_PASS_FORWARDBASE;Key1;Fetch;False;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;-104.8056,551.8788;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;-101.8056,310.8789;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;97;-208,2352;Inherit;True;Property;_TextureSample;Texture Sample;1;0;Create;True;0;0;0;False;0;False;-1;None;522fcb2b5717c7640b460ee9ff73a78a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;267;128,1824;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-160,2000;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;152.8219,2086.005;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;164;98.41057,427.1879;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;166;81.96335,342.6977;Inherit;False;140;WindDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;-864,2336;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;256,1968;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;165;364.5175,372.0068;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;152.8921,2202.759;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;416,2016;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;167;524.0667,371.9294;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;105;608,2080;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;255;776.4514,365.8864;Inherit;False;VertexOffset;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;258;128,2448;Inherit;False;OpacityMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;261;784,2080;Inherit;False;CustomLighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;264;1197.327,1390.324;Inherit;False;255;VertexOffset;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;1195.327,1243.324;Inherit;False;258;OpacityMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;1196.043,1316.632;Inherit;False;261;CustomLighting;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1514.107,1091.686;Float;False;True;-1;2;;0;0;CustomLighting;Toon/TFD_CustomToonVegetation;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;15.82;0,0,0,0;VertexOffset;False;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;140;0;139;0
WireConnection;143;0;141;0
WireConnection;144;0;143;0
WireConnection;145;0;144;0
WireConnection;145;1;146;0
WireConnection;145;2;147;0
WireConnection;149;0;148;0
WireConnection;150;0;149;0
WireConnection;150;2;145;0
WireConnection;151;0;150;0
WireConnection;151;1;152;0
WireConnection;153;0;151;0
WireConnection;87;0;85;0
WireConnection;87;1;86;1
WireConnection;87;2;86;2
WireConnection;154;1;153;0
WireConnection;155;0;154;0
WireConnection;155;1;156;0
WireConnection;155;2;157;0
WireConnection;89;0;87;0
WireConnection;92;0;90;0
WireConnection;92;1;88;0
WireConnection;265;0;86;1
WireConnection;265;1;107;0
WireConnection;158;0;155;0
WireConnection;91;0;89;0
WireConnection;91;1;89;1
WireConnection;93;0;92;0
WireConnection;266;0;265;0
WireConnection;95;0;91;0
WireConnection;95;1;89;2
WireConnection;99;1;93;0
WireConnection;98;1;87;0
WireConnection;98;0;94;0
WireConnection;160;0;159;0
WireConnection;160;1;162;4
WireConnection;161;0;162;1
WireConnection;161;1;159;0
WireConnection;267;0;99;0
WireConnection;267;1;268;0
WireConnection;96;0;93;0
WireConnection;96;1;95;0
WireConnection;102;0;98;0
WireConnection;102;1;97;0
WireConnection;164;0;161;0
WireConnection;164;1;160;0
WireConnection;259;0;86;1
WireConnection;259;1;86;2
WireConnection;259;2;107;0
WireConnection;100;0;267;0
WireConnection;100;1;96;0
WireConnection;165;0;166;0
WireConnection;165;1;164;0
WireConnection;104;0;259;0
WireConnection;104;1;97;0
WireConnection;103;0;100;0
WireConnection;103;1;102;0
WireConnection;167;0;165;0
WireConnection;105;0;103;0
WireConnection;105;1;104;0
WireConnection;255;0;167;0
WireConnection;258;0;97;4
WireConnection;261;0;105;0
WireConnection;0;10;263;0
WireConnection;0;13;262;0
WireConnection;0;11;264;0
ASEEND*/
//CHKSM=796751256F0A1628D6C6AB1AA5CDCB1A86E44244