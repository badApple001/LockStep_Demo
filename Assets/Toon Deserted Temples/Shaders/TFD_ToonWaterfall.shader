// Made with Amplify Shader Editor v1.9.4.4
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon/TFD_ToonWaterfall"
{
	Properties
	{
		_BaseColor("Base Color", Color) = (0.8313726,0.8313726,0.8313726,1)
		_Highlights1Color("Highlights 1 Color", Color) = (0.5896226,0.9331943,1,1)
		_Highlights2Color("Highlights 2 Color", Color) = (0,0.5954423,0.6792453,1)
		_ShallowColor("Shallow Color", Color) = (0,0.6117647,1,1)
		_DeepColor("Deep Color", Color) = (0,0.3333333,0.8509804,1)
		_ShallowColorDepth("Shallow Color Depth", Range( 0 , 30)) = 2.75
		_FresnelColor("Fresnel Color", Color) = (0.8313726,0.8313726,0.8313726,1)
		_FresnelIntensity("Fresnel Intensity", Range( 0 , 1)) = 0.4
		_EdgeFade("Edge Fade", Range( 0 , 1)) = 1
		_Opacity("Opacity", Range( 0 , 1)) = 1
		_OpacityDepth("Opacity Depth", Range( 0 , 30)) = 6.5
		_SurfaceFoamIntensity("Surface Foam Intensity", Range( -0.4 , 0.4)) = 0.05
		_SurfaceFoamScrollSpeed("Surface Foam Scroll Speed", Range( -1 , 1)) = -0.025
		_SurfaceFoamScale("Surface Foam Scale", Range( 0 , 40)) = 1
		_EdgeFoamColor("Edge Foam Color", Color) = (1,1,1,1)
		_EdgeFoamHardness("Edge Foam Hardness", Range( 0 , 1)) = 0.33
		_EdgeFoamDistance("Edge Foam Distance", Range( 0 , 1)) = 1
		_EdgeFoamOpacity("Edge Foam Opacity", Range( 0 , 1)) = 0.65
		_EdgeFoamScale("Edge Foam Scale", Range( 0 , 1)) = 0.2
		_EdgeFoamSpeed("Edge Foam Speed", Range( 0 , 1)) = 0.125
		_ReflectionsOpacity("Reflections Opacity", Range( 0 , 1)) = 0.65
		_ReflectionsScale("Reflections Scale", Range( 1 , 40)) = 4.8
		_ReflectionsScrollSpeed("Reflections Scroll Speed", Range( -1 , 1)) = -1
		_ReflectionsCutoff("Reflections Cutoff", Range( 0 , 1)) = 0.35
		_ReflectionsCutoffScale("Reflections Cutoff Scale", Range( 1 , 40)) = 3
		_ReflectionsCutoffScrollSpeed("Reflections Cutoff Scroll Speed", Range( -1 , 1)) = -0.025
		_RefractionIntensity("Refraction Intensity", Range( 0 , 1)) = 1
		_RefractionScrollSpeed("Refraction Scroll Speed", Range( -1 , 1)) = -0.025
		_RefractionCutoffScale("Refraction Cutoff Scale", Range( 0 , 40)) = 1
		[Normal]_NormalMap("Normal Map", 2D) = "bump" {}
		_NoiseTexture1("Noise Texture 1", 2D) = "white" {}
		_NoiseTexture2("Noise Texture 2", 2D) = "white" {}
		_NoiseTexture3("Noise Texture 3", 2D) = "white" {}
		_FlowSpeed("Flow Speed", Vector) = (42.69,10.39,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ "_BeforeWater" }
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 3.5
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha addshadow fullforwardshadows nodirlightmap vertex:vertexDataFunc 
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float4 screenPos;
			float2 vertexToFrag366;
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

		uniform float4 _Highlights1Color;
		uniform sampler2D _NoiseTexture2;
		uniform float2 _FlowSpeed;
		uniform float4 _Highlights2Color;
		uniform sampler2D _NoiseTexture3;
		uniform sampler2D _NoiseTexture1;
		uniform sampler2D _NormalMap;
		uniform float _ReflectionsScrollSpeed;
		uniform float _ReflectionsScale;
		uniform float _ReflectionsOpacity;
		uniform float _SurfaceFoamScrollSpeed;
		uniform float _SurfaceFoamScale;
		uniform float _SurfaceFoamIntensity;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _BeforeWater )
		uniform float _RefractionIntensity;
		uniform float _RefractionScrollSpeed;
		uniform float _RefractionCutoffScale;
		uniform float4 _ShallowColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _EdgeFoamSpeed;
		uniform float _EdgeFoamScale;
		uniform float _EdgeFoamDistance;
		uniform float _EdgeFoamHardness;
		uniform float _EdgeFoamOpacity;
		uniform float _Opacity;
		uniform float _OpacityDepth;
		uniform float4 _DeepColor;
		uniform float _ShallowColorDepth;
		uniform float4 _FresnelColor;
		uniform float _FresnelIntensity;
		uniform float4 _BaseColor;
		uniform float4 _EdgeFoamColor;
		uniform float _ReflectionsCutoffScrollSpeed;
		uniform float _ReflectionsCutoffScale;
		uniform float _ReflectionsCutoff;
		uniform float _EdgeFade;


inline float4 ASE_ComputeGrabScreenPos( float4 pos )
{
	#if UNITY_UV_STARTS_AT_TOP
	float scale = -1.0;
	#else
	float scale = 1.0;
	#endif
	float4 o = pos;
	o.y = pos.w * 0.5f;
	o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
	return o;
}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			o.vertexToFrag366 = ( (ase_worldPos).xz * float2( 0.025,0.025 ) );
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
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 GlobalUV368 = i.vertexToFrag366;
			float screenDepth163 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth163 = abs( ( screenDepth163 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( tex2D( _NoiseTexture1, ( ( _EdgeFoamSpeed * _Time.y ) + ( GlobalUV368 * (30.0 + (_EdgeFoamScale - 0.0) * (1.0 - 30.0) / (1.0 - 0.0)) ) ) ).r * (0.0 + (_EdgeFoamDistance - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) ) ) );
			float clampResult208 = clamp( distanceDepth163 , 0.0 , 1.0 );
			float clampResult160 = clamp( pow( clampResult208 , (1.0 + (_EdgeFoamHardness - 0.0) * (10.0 - 1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
			float temp_output_156_0 = ( ( 1.0 - clampResult160 ) * _EdgeFoamOpacity );
			float screenDepth191 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth191 = abs( ( screenDepth191 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( (0.0 + (_EdgeFoamDistance - 0.0) * (15.0 - 0.0) / (1.0 - 0.0)) ) );
			float clampResult207 = clamp( distanceDepth191 , 0.0 , 1.0 );
			float EdgeFoamSpeed435 = _EdgeFoamSpeed;
			float EdgeFoam626 = ( temp_output_156_0 + ( ( 1.0 - clampResult207 ) * ( (0.0 + (_EdgeFoamOpacity - 0.0) * (0.85 - 0.0) / (1.0 - 0.0)) * tex2D( _NoiseTexture1, ( ( _Time.y * EdgeFoamSpeed435 ) + ( (15.0 + (_EdgeFoamScale - 0.0) * (1.0 - 15.0) / (1.0 - 0.0)) * GlobalUV368 ) ) ).r ) ) );
			float screenDepth294 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth294 = abs( ( screenDepth294 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _OpacityDepth ) );
			float clampResult295 = clamp( distanceDepth294 , 0.0 , 1.0 );
			float clampResult299 = clamp( ( EdgeFoam626 + _Opacity + clampResult295 ) , 0.0 , 1.0 );
			float screenDepth634 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth634 = abs( ( screenDepth634 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _EdgeFade ) );
			float3 ase_worldPos = i.worldPos;
			float3 normalizeResult232 = normalize( ( _WorldSpaceCameraPos - ase_worldPos ) );
			float2 temp_cast_15 = (_ReflectionsCutoffScrollSpeed).xx;
			float2 panner342 = ( 1.0 * _Time.y * temp_cast_15 + ( GlobalUV368 * (2.0 + (_ReflectionsCutoffScale - 0.0) * (10.0 - 2.0) / (10.0 - 0.0)) ));
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult108 = dot( reflect( -normalizeResult232 , (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, panner342 ) ) )) ) , ase_worldlightDir );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float2 temp_cast_16 = (_ReflectionsScrollSpeed).xx;
			float2 panner40 = ( 1.0 * _Time.y * temp_cast_16 + ( _ReflectionsScale * GlobalUV368 ));
			float Turbulence291 = ( UnpackNormal( tex2D( _NormalMap, panner40 ) ).g * (0.0 + (_ReflectionsOpacity - 0.0) * (8.0 - 0.0) / (1.0 - 0.0)) * i.vertexColor.r );
			float3 clampResult120 = clamp( ( ( pow( dotResult108 , exp( (0.0 + (_ReflectionsCutoff - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) ) ) * ase_lightColor.rgb ) * Turbulence291 ) , float3( 0,0,0 ) , float3( 1,1,1 ) );
			float3 ReflexionsCutoff612 = clampResult120;
			float3 lerpResult90 = lerp( ( ReflexionsCutoff612 * float3( i.uv_texcoord ,  0.0 ) ) , ( ase_lightColor.rgb * ( ReflexionsCutoff612 * ase_lightAtten ) ) , ( 1.0 - ase_lightAtten ));
			float3 Lighting1616 = lerpResult90;
			c.rgb = Lighting1616;
			c.a = ( clampResult299 * saturate( distanceDepth634 ) );
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
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult860 = dot( ase_normWorldNormal , ase_worldlightDir );
			float NormalCalc863 = dotResult860;
			float2 FlowSpeed794 = _FlowSpeed;
			float2 uv_TexCoord648 = i.uv_texcoord * float2( 4,1 );
			float2 panner644 = ( 1.1 * _Time.y * ( FlowSpeed794 * float2( 0,1.31 ) ) + uv_TexCoord648);
			float2 uv_TexCoord700 = i.uv_texcoord * float2( 3,1 );
			float2 panner701 = ( 1.1 * _Time.y * ( FlowSpeed794 * float2( 0,-0.32 ) ) + uv_TexCoord700);
			float2 uv_TexCoord677 = i.uv_texcoord * float2( 2,1 );
			float2 panner678 = ( 1.1 * _Time.y * ( FlowSpeed794 * float2( 0,2 ) ) + uv_TexCoord677);
			float2 panner819 = ( 1.1 * _Time.y * ( FlowSpeed794 * float2( 0,2.6 ) ) + i.uv_texcoord);
			float4 blendOpSrc825 = tex2D( _NoiseTexture3, panner678 );
			float4 blendOpDest825 = ( NormalCalc863 * tex2D( _NoiseTexture3, panner819 ) );
			float4 lerpBlendMode825 = lerp(blendOpDest825,( blendOpSrc825 + blendOpDest825 ),NormalCalc863);
			float4 blendOpSrc686 = ( _Highlights1Color * 5.0 * ( NormalCalc863 * ( tex2D( _NoiseTexture2, panner644 ) * tex2D( _NoiseTexture2, panner701 ) ) ) );
			float4 blendOpDest686 = ( _Highlights2Color * 2.0 * ( saturate( lerpBlendMode825 )) );
			float4 lerpResult657 = lerp( float4( 0,0,0,0 ) , ( saturate( ( blendOpSrc686 + blendOpDest686 ) )) , i.vertexColor.a);
			float4 VerticalReflections660 = lerpResult657;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 appendResult31 = (float2(( ase_screenPosNorm.x + 0.01 ) , ( ase_screenPosNorm.y + 0.01 )));
			float2 temp_cast_1 = (_ReflectionsScrollSpeed).xx;
			float2 GlobalUV368 = i.vertexToFrag366;
			float2 panner40 = ( 1.0 * _Time.y * temp_cast_1 + ( _ReflectionsScale * GlobalUV368 ));
			float Turbulence291 = ( UnpackNormal( tex2D( _NormalMap, panner40 ) ).g * (0.0 + (_ReflectionsOpacity - 0.0) * (8.0 - 0.0) / (1.0 - 0.0)) * i.vertexColor.r );
			float4 lerpResult24 = lerp( ase_screenPosNorm , float4( appendResult31, 0.0 , 0.0 ) , Turbulence291);
			float4 Lighting2619 = ( 0.0 * tex2D( _NoiseTexture1, lerpResult24.xy ) );
			float temp_output_608_0 = (-0.2 + (_SurfaceFoamScrollSpeed - -1.0) * (0.2 - -0.2) / (1.0 - -1.0));
			float2 temp_cast_3 = (temp_output_608_0).xx;
			float2 temp_output_495_0 = ( GlobalUV368 * (1.0 + (_SurfaceFoamScale - 0.0) * (10.0 - 1.0) / (40.0 - 0.0)) );
			float2 panner498 = ( 1.0 * _Time.y * temp_cast_3 + temp_output_495_0);
			float4 tex2DNode483 = tex2D( _NoiseTexture1, panner498 );
			float lerpResult550 = lerp( step( tex2DNode483.r , 1.0 ) , ( 1.0 - tex2DNode483.r ) , 1.0);
			float2 temp_cast_4 = (temp_output_608_0).xx;
			float2 panner496 = ( -1.0 * _Time.y * temp_cast_4 + ( temp_output_495_0 * 0.777 ));
			float Foam487 = ( ( lerpResult550 * -tex2D( _NoiseTexture1, panner496 ).r ) * -_SurfaceFoamIntensity * i.vertexColor.r );
			float4 temp_cast_5 = (Foam487).xxxx;
			float2 temp_cast_6 = (_RefractionScrollSpeed).xx;
			float2 temp_output_422_0 = ( GlobalUV368 * (1.0 + (_RefractionCutoffScale - 0.0) * (10.0 - 1.0) / (40.0 - 0.0)) );
			float2 panner423 = ( 1.0 * _Time.y * temp_cast_6 + temp_output_422_0);
			float2 temp_cast_7 = (_RefractionScrollSpeed).xx;
			float2 panner470 = ( -1.0 * _Time.y * temp_cast_7 + temp_output_422_0);
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor395 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BeforeWater,( float4( ( (0.0 + (_RefractionIntensity - 0.0) * (0.4 - 0.0) / (1.0 - 0.0)) * BlendNormals( UnpackScaleNormal( tex2D( _NormalMap, panner423 ), 5.7 ) , UnpackScaleNormal( tex2D( _NormalMap, panner470 ), 2.3 ) ) ) , 0.0 ) + ase_grabScreenPosNorm ).xy);
			float4 Refractions378 = screenColor395;
			float screenDepth163 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth163 = abs( ( screenDepth163 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( tex2D( _NoiseTexture1, ( ( _EdgeFoamSpeed * _Time.y ) + ( GlobalUV368 * (30.0 + (_EdgeFoamScale - 0.0) * (1.0 - 30.0) / (1.0 - 0.0)) ) ) ).r * (0.0 + (_EdgeFoamDistance - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) ) ) );
			float clampResult208 = clamp( distanceDepth163 , 0.0 , 1.0 );
			float clampResult160 = clamp( pow( clampResult208 , (1.0 + (_EdgeFoamHardness - 0.0) * (10.0 - 1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
			float temp_output_156_0 = ( ( 1.0 - clampResult160 ) * _EdgeFoamOpacity );
			float screenDepth191 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth191 = abs( ( screenDepth191 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( (0.0 + (_EdgeFoamDistance - 0.0) * (15.0 - 0.0) / (1.0 - 0.0)) ) );
			float clampResult207 = clamp( distanceDepth191 , 0.0 , 1.0 );
			float EdgeFoamSpeed435 = _EdgeFoamSpeed;
			float EdgeFoam626 = ( temp_output_156_0 + ( ( 1.0 - clampResult207 ) * ( (0.0 + (_EdgeFoamOpacity - 0.0) * (0.85 - 0.0) / (1.0 - 0.0)) * tex2D( _NoiseTexture1, ( ( _Time.y * EdgeFoamSpeed435 ) + ( (15.0 + (_EdgeFoamScale - 0.0) * (1.0 - 15.0) / (1.0 - 0.0)) * GlobalUV368 ) ) ).r ) ) );
			float screenDepth294 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth294 = abs( ( screenDepth294 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _OpacityDepth ) );
			float clampResult295 = clamp( distanceDepth294 , 0.0 , 1.0 );
			float clampResult299 = clamp( ( EdgeFoam626 + _Opacity + clampResult295 ) , 0.0 , 1.0 );
			float Opacity405 = clampResult299;
			float4 lerpResult462 = lerp( Refractions378 , _ShallowColor , Opacity405);
			float4 lerpResult473 = lerp( Refractions378 , _DeepColor , Opacity405);
			float screenDepth146 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth146 = abs( ( screenDepth146 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _ShallowColorDepth ) );
			float clampResult211 = clamp( distanceDepth146 , 0.0 , 1.0 );
			float4 lerpResult142 = lerp( lerpResult462 , lerpResult473 , clampResult211);
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV136 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode136 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV136, (0.0 + (_FresnelIntensity - 1.0) * (10.0 - 0.0) / (0.0 - 1.0)) ) );
			float clampResult209 = clamp( fresnelNode136 , 0.0 , 1.0 );
			float4 lerpResult133 = lerp( lerpResult142 , _FresnelColor , clampResult209);
			float4 WaterColor622 = ( lerpResult133 + ( _BaseColor * i.vertexColor.b ) );
			float4 blendOpSrc502 = temp_cast_5;
			float4 blendOpDest502 = WaterColor622;
			float4 blendOpSrc300 = Lighting2619;
			float4 blendOpDest300 = ( blendOpSrc502 + blendOpDest502 );
			float EdgeFoamBlend629 = temp_output_156_0;
			float4 blendOpSrc658 = VerticalReflections660;
			float4 blendOpDest658 = ( ( blendOpSrc300 + blendOpDest300 ) + ( EdgeFoamBlend629 * _EdgeFoamColor ) + ( _EdgeFoamColor * EdgeFoam626 ) );
			float3 temp_cast_10 = (1.0).xxx;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 lerpResult7 = lerp( temp_cast_10 , ase_lightColor.rgb , 1.0);
			float3 normalizeResult232 = normalize( ( _WorldSpaceCameraPos - ase_worldPos ) );
			float2 temp_cast_12 = (_ReflectionsCutoffScrollSpeed).xx;
			float2 panner342 = ( 1.0 * _Time.y * temp_cast_12 + ( GlobalUV368 * (2.0 + (_ReflectionsCutoffScale - 0.0) * (10.0 - 2.0) / (10.0 - 0.0)) ));
			float dotResult108 = dot( reflect( -normalizeResult232 , (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, panner342 ) ) )) ) , ase_worldlightDir );
			float3 clampResult120 = clamp( ( ( pow( dotResult108 , exp( (0.0 + (_ReflectionsCutoff - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) ) ) * ase_lightColor.rgb ) * Turbulence291 ) , float3( 0,0,0 ) , float3( 1,1,1 ) );
			float3 ReflexionsCutoff612 = clampResult120;
			o.Emission = ( ( ( saturate( ( blendOpSrc658 + blendOpDest658 ) )) * float4( lerpResult7 , 0.0 ) ) + float4( ReflexionsCutoff612 , 0.0 ) ).rgb;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=19404
Node;AmplifyShaderEditor.CommentaryNode;372;1394.915,-4196.619;Inherit;False;844.5542;236.5325;Global UV's;4;363;364;365;366;Global UV's;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;363;1440,-4144;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;364;1648,-4144;Inherit;False;FLOAT2;0;2;1;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;365;1824,-4144;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.025,0.025;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;631;1403.001,-2070.273;Inherit;False;3315.78;661.7512;Edge Foam;40;183;374;180;177;327;175;176;172;174;433;325;170;167;435;163;162;437;198;373;332;324;208;335;196;197;158;191;161;434;195;334;207;193;160;189;157;188;156;185;186;Edge Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexToFragmentNode;366;2016,-4144;Inherit;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;368;2297.268,-4147.682;Inherit;False;GlobalUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;183;1453.001,-1581.784;Float;False;Property;_EdgeFoamScale;Edge Foam Scale;18;0;Create;True;0;0;0;False;0;False;0.2;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;374;1778.808,-1821.333;Inherit;False;368;GlobalUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;180;1682.296,-1904.183;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;177;1682.298,-1995.783;Float;False;Property;_EdgeFoamSpeed;Edge Foam Speed;19;0;Create;True;0;0;0;False;0;False;0.125;0.125;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;327;1779.221,-1744.231;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;30;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;173;1872.842,-4449.66;Float;True;Property;_NoiseTexture1;Noise Texture 1;30;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;2005.488,-1928.484;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;176;2004.795,-1821.884;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;431;2119.558,-4448.989;Inherit;False;NoiseMap1;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;172;2414.085,-1752.975;Float;False;Property;_EdgeFoamDistance;Edge Foam Distance;16;0;Create;True;0;0;0;False;0;False;1;0.04;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;174;2244.092,-1929.584;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;433;2208,-2016;Inherit;False;431;NoiseMap1;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TFHCRemapNode;325;2753.037,-1895.265;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;170;2372.664,-2015.278;Inherit;True;Property;_TextureSample3;Texture Sample 3;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;3029.252,-1995.603;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;435;2003.849,-2015.103;Inherit;False;EdgeFoamSpeed;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;163;3207.802,-2020.012;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;162;2970.003,-1878.812;Float;False;Property;_EdgeFoamHardness;Edge Foam Hardness;15;0;Create;True;0;0;0;False;0;False;0.33;0.33;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;437;2687.507,-1610.817;Inherit;False;435;EdgeFoamSpeed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;198;2717.701,-1700.222;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;2484.411,-1522.731;Inherit;False;368;GlobalUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;332;2289.757,-1617.522;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;15;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;324;3301.299,-1909.817;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;208;3484.735,-2020.273;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;335;3092.653,-1792.669;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;2922.375,-1656.482;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;2922.373,-1545.83;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;474;1395.82,126.7491;Inherit;False;2421.923;476.1914;Refractions;17;416;425;407;398;392;399;394;395;470;439;423;421;422;419;420;418;611;Refractions;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;158;3658.348,-1906.567;Float;False;Property;_EdgeFoamOpacity;Edge Foam Opacity;17;0;Create;True;0;0;0;False;0;False;0.65;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;191;3496.722,-1816.385;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;161;3788.302,-2019.112;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;434;3422.046,-1680.288;Inherit;False;431;NoiseMap1;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;195;3304.423,-1655.444;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;418;1445.82,282.5991;Float;False;Property;_RefractionCutoffScale;Refraction Cutoff Scale;28;0;Create;True;0;0;0;False;0;False;1;5;0;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;45;1397.173,-4450.278;Float;True;Property;_NormalMap;Normal Map;29;1;[Normal];Create;True;0;0;0;False;0;False;None;None;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ClampOpNode;207;3784.348,-1815.567;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;334;3990.347,-1735.567;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;160;4015.9,-1929.812;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;193;3651.8,-1679.212;Inherit;True;Property;_TextureSample4;Texture Sample 4;38;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;419;1742.559,279.9692;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;40;False;3;FLOAT;1;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;420;1742.949,197.9581;Inherit;False;368;GlobalUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;426;1642.45,-4450.488;Inherit;False;NormalMap;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.OneMinusNode;189;4195.001,-1814.085;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;157;4195.628,-1927.829;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;4193.796,-1735.743;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;421;1822.383,460.3339;Float;False;Property;_RefractionScrollSpeed;Refraction Scroll Speed;27;0;Create;True;0;0;0;False;0;False;-0.025;-0.025;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;422;1947.298,201.6361;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;615;1397.09,-590.3231;Inherit;False;2912.429;589.1261;Reflections Cutoff;26;107;120;117;505;115;116;242;232;218;428;342;231;230;234;108;106;104;103;109;215;341;340;228;370;344;339;Reflections Cutoff;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;4384.972,-1927.418;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;4383.386,-1816.352;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;439;2170.142,336.104;Inherit;False;426;NormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;470;2171.124,418.278;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;423;2167.392,200.069;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;339;1447.09,-238.5895;Float;False;Property;_ReflectionsCutoffScale;Reflections Cutoff Scale;24;0;Create;True;0;0;0;False;0;False;3;5;1;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;186;4572.783,-1840.485;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;293;-1200,-1120;Float;False;Property;_OpacityDepth;Opacity Depth;10;0;Create;True;0;0;0;False;0;False;6.5;6.5;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;416;2401.042,176.7491;Inherit;True;Property;_TextureSample7;Texture Sample 5;27;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;5.7;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;425;2401.487,375.9399;Inherit;True;Property;_TextureSample8;Texture Sample 5;27;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;2.3;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;398;2733.381,175.223;Float;False;Property;_RefractionIntensity;Refraction Intensity;26;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;605;1402.267,704.1461;Inherit;False;2405.97;488.6509;Surface Foam;23;494;497;482;483;478;551;552;550;554;476;555;475;498;496;557;556;493;492;491;495;606;608;894;Surface Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;507;1397.34,-1230.91;Inherit;False;1322.382;460.061;Turbulence;11;39;37;336;38;427;40;42;371;247;43;896;Turbulence;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;344;1765.224,-238.2081;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;2;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;370;1766.302,-323.0511;Inherit;False;368;GlobalUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;626;4754.541,-1841.351;Inherit;False;EdgeFoam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;294;-880,-1136;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;407;2792.894,294.4081;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;611;3042.084,168.6961;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;491;1452.267,863.9088;Float;False;Property;_SurfaceFoamScale;Surface Foam Scale;13;0;Create;True;0;0;0;False;0;False;1;5;0;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;812;3456,-4448;Inherit;False;Property;_FlowSpeed;Flow Speed;33;0;Create;True;0;0;0;False;0;False;42.69,10.39;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;43;1448.907,-1106.275;Float;False;Property;_ReflectionsScale;Reflections Scale;21;0;Create;True;0;0;0;False;0;False;4.8;6;1;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;371;1500.764,-1029.615;Inherit;False;368;GlobalUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;341;2046.978,-259.461;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;340;1954.061,-139.0246;Float;False;Property;_ReflectionsCutoffScrollSpeed;Reflections Cutoff Scroll Speed;25;0;Create;True;0;0;0;False;0;False;-0.025;-0.025;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;228;2041.272,-422.3221;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;230;2223.982,-540.3228;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;296;-880,-1232;Float;False;Property;_Opacity;Opacity;9;0;Create;True;0;0;0;False;0;False;1;0.65;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;295;-592,-1168;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;392;3277.708,271.1711;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;627;-592,-1264;Inherit;False;626;EdgeFoam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;399;3149.36,395.3168;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;493;1762.396,772.2692;Inherit;False;368;GlobalUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;492;1762.006,863.2809;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;40;False;3;FLOAT;1;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;494;1729.829,1066.644;Float;False;Property;_SurfaceFoamScrollSpeed;Surface Foam Scroll Speed;12;0;Create;True;0;0;0;False;0;False;-0.025;-0.025;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;794;3696,-4448;Inherit;False;FlowSpeed;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;885;1408,1920;Inherit;False;2692;1236;Comment;38;799;823;815;804;800;648;700;824;820;821;701;644;809;808;818;819;677;810;807;817;678;790;865;811;859;864;789;673;853;672;687;682;825;674;671;656;686;657;Vertical Reflections;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;247;1447.34,-942.994;Float;False;Property;_ReflectionsScrollSpeed;Reflections Scroll Speed;22;0;Create;True;0;0;0;False;0;False;-1;0.035;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;1756.286,-1107.647;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;231;2557.771,-445.4329;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;428;2261.608,-337.0813;Inherit;False;426;NormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;342;2260.071,-254.0279;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;297;-400,-1264;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;394;3475.048,270.8542;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;495;1974.743,815.9459;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;608;2148.726,993.7018;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;-0.2;False;4;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;557;1975.424,934.3608;Inherit;False;Constant;_Scale;Scale;33;0;Create;True;0;0;0;False;0;False;0.777;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;799;1472,2256;Inherit;False;794;FlowSpeed;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;427;1933.075,-1180.582;Inherit;False;426;NormalMap;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;40;1931.38,-1107.214;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;38;1760,-976;Float;False;Property;_ReflectionsOpacity;Reflections Opacity;20;0;Create;True;0;0;0;False;0;False;0.65;0.31;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;232;2842.04,-416.6785;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;218;2488.033,-336.4475;Inherit;True;Property;_TextureSample5;Texture Sample 5;40;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;886;1390,-2982.796;Inherit;False;1620;791.7959;Water Color;22;137;150;144;323;146;402;406;472;471;145;473;211;462;136;209;142;135;883;133;881;884;882;Water Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;299;-256,-1264;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;395;3615.317,270.538;Float;False;Global;_BeforeWater;BeforeWater;34;0;Create;True;0;0;0;True;0;False;Object;-1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;498;2375.837,779.3781;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;556;2166.425,880.3607;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;621;1398.495,-3857.467;Inherit;False;1432.128;792.9407;Lighting;20;93;94;614;376;91;87;95;90;329;250;304;432;24;26;31;27;28;292;29;890;Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;791;2352,-4448;Float;True;Property;_NoiseTexture2;Noise Texture 2;31;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;861;2864,-4288;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;862;2880,-4448;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;823;1808,2896;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,2.6;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;39;2203.256,-1181.943;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;336;2048,-976;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;2891.405,-119.5714;Float;False;Property;_ReflectionsCutoff;Reflections Cutoff;23;0;Create;True;0;0;0;False;0;False;0.35;0.45;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;242;3037.51,-416.3245;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;215;2790.225,-334.0784;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;497;2378.587,915.4149;Inherit;False;431;NoiseMap1;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;892;1929.522,-4668.783;Inherit;True;Property;_NoiseTexture3;Noise Texture 3;32;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.VertexColorNode;896;2336,-976;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;150;1455.082,-2530.878;Float;False;Property;_ShallowColorDepth;Shallow Color Depth;5;0;Create;True;0;0;0;False;0;False;2.75;4;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;378;3865.706,270.4731;Float;False;Refractions;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;405;0,-1312;Inherit;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;1493.971,-2445.688;Float;False;Property;_FresnelIntensity;Fresnel Intensity;7;0;Create;True;0;0;0;False;0;False;0.4;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;483;2614.947,754.1461;Inherit;True;Property;_TextureSample6;Texture Sample 4;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;496;2379.569,997.5868;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;482;2940.429,852.1158;Float;False;Constant;_Step;Step;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;792;2608,-4448;Inherit;False;NoiseMap2;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DotProductOpNode;860;3104,-4448;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;800;1952,2192;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,1.31;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;824;2176,3072;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;804;1952,2320;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,-0.32;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;820;2096,2896;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;815;1808,2704;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;26;1424,-3456;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;1440,-3184;Float;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;2541.723,-1134.128;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;648;1920,2048;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;4,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;700;1920,2432;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;3,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;104;3228.605,-210.1964;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;109;2982.695,-272.8159;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ReflectOpNode;234;3223.294,-410.9876;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;893;2208,-4672;Inherit;False;NoiseMap3;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ColorNode;144;1440,-2928;Float;False;Property;_ShallowColor;Shallow Color;3;0;Create;True;0;0;0;False;0;False;0,0.6117647,1,1;0.3960784,0.6039216,0.5524715,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;146;1760.964,-2556.355;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;406;1801.526,-2832.393;Inherit;False;405;Opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;471;1803.672,-2639.254;Inherit;False;405;Opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;145;1440,-2704;Float;False;Property;_DeepColor;Deep Color;4;0;Create;True;0;0;0;False;0;False;0,0.3333333,0.8509804,1;0.3396226,0.254717,0.2963979,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;402;1802.02,-2932.796;Inherit;False;378;Refractions;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;472;1802.18,-2739.055;Inherit;False;378;Refractions;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;323;1804.295,-2445.318;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;552;2612.764,965.7958;Inherit;True;Property;_TextureSample9;Texture Sample 4;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;551;2940.776,930.1139;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;478;3104,768;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;1672.251,-3316.528;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;1673.251,-3201.529;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;863;3232,-4448;Inherit;False;NormalCalc;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;821;2176,2816;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;644;2208,2192;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,1;False;1;FLOAT;1.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;701;2208,2416;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,1;False;1;FLOAT;1.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;677;2096,2640;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;819;2448,2896;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,1.17;False;1;FLOAT;1.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;291;2768,-1136;Inherit;False;Turbulence;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;108;3424.693,-374.8152;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ExpOpNode;106;3422.604,-266.1964;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;809;2208,2112;Inherit;False;792;NoiseMap2;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;808;2208,2336;Inherit;False;792;NoiseMap2;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;818;2448,2816;Inherit;False;893;NoiseMap3;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LerpOp;473;2039.427,-2732.656;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;211;2034.707,-2588.117;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;462;2038.67,-2904.389;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;136;2023.71,-2442.647;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;476;2941.378,1092.658;Float;False;Property;_SurfaceFoamIntensity;Surface Foam Intensity;11;0;Create;True;0;0;0;False;0;False;0.05;0;-0.4;0.4;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;554;2940.741,1009.826;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;550;3248,768;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;1801.251,-3315.528;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;810;2432,2112;Inherit;True;Property;_TextureSample15;Texture Sample 10;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;807;2432,2336;Inherit;True;Property;_TextureSample14;Texture Sample 10;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;817;2672,2832;Inherit;True;Property;_TextureSample11;Texture Sample 10;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;865;2672,2752;Inherit;False;863;NormalCalc;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;678;2448,2640;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,1.17;False;1;FLOAT;1.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;292;1804.721,-3196.852;Inherit;False;291;Turbulence;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;107;3582.693,-352.8162;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;116;3583.664,-232.0431;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.VertexColorNode;883;2496,-2400;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;881;2480,-2576;Float;False;Property;_BaseColor;Base Color;0;0;Create;True;0;0;0;False;0;False;0.8313726,0.8313726,0.8313726,1;0.8313726,0.8313726,0.8313726,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;790;2448,2560;Inherit;False;893;NoiseMap3;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LerpOp;142;2238.433,-2757.585;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;209;2266.447,-2443.123;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;135;2211.401,-2628.943;Float;False;Property;_FresnelColor;Fresnel Color;6;0;Create;True;0;0;0;False;0;False;0.8313726,0.8313726,0.8313726,1;0.8313726,0.8313726,0.8313726,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;555;3456,800;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;606;3456,896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;24;2107.045,-3333.332;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;432;2074.844,-3416.326;Inherit;False;431;NoiseMap1;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;811;2784,2224;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;864;2768,2144;Inherit;False;863;NormalCalc;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;789;2672,2560;Inherit;True;Property;_TextureSample10;Texture Sample 10;32;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;859;2976,2704;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;3792.663,-291.041;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;505;3763.005,-181.69;Inherit;False;291;Turbulence;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;884;2720,-2576;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;894;3440,1024;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;133;2528,-2912;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;475;3632,880;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;304;2423.803,-3489.27;Float;False;Constant;_Float4;Float 4;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;250;2285.309,-3416.643;Inherit;True;Property;_TextureSample1;Texture Sample 1;28;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;673;2992,1968;Inherit;False;Property;_Highlights1Color;Highlights 1 Color;1;0;Create;True;0;0;0;False;0;False;0.5896226,0.9331943,1,1;0.5896226,0.9331943,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;853;2976,2224;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;672;3008,2144;Inherit;False;Constant;_VertReflectionsOpacity_1;VertReflections Opacity_1;33;0;Create;True;0;0;0;False;0;False;5;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;687;2992,2320;Inherit;False;Property;_Highlights2Color;Highlights 2 Color;2;0;Create;True;0;0;0;False;0;False;0,0.5954423,0.6792453,1;0,0.5954423,0.6792453,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;825;3168,2640;Inherit;True;LinearDodge;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;682;3008,2496;Inherit;False;Constant;_VertReflectionsOpacity_2;VertReflections Opacity_2;33;0;Create;True;0;0;0;False;0;False;2;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;3958.693,-246.2604;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;882;2864,-2752;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;329;2663.804,-3441.27;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;674;3392,2320;Inherit;False;3;3;0;COLOR;1,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;671;3392,2176;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;622;3040,-2880;Inherit;False;WaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;120;4131.524,-246.2799;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;487;3984,880;Inherit;False;Foam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;629;4754.471,-1928.355;Inherit;False;EdgeFoamBlend;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;619;2889.047,-3440.813;Inherit;False;Lighting2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;508;-1888,-1728;Inherit;False;487;Foam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;625;-1888,-1648;Inherit;False;622;WaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;686;3632,2240;Inherit;True;LinearDodge;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;612;4377.008,-251.5557;Inherit;False;ReflexionsCutoff;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;656;3664,2464;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;620;-1584,-1760;Inherit;False;619;Lighting2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;630;-1392,-1600;Inherit;False;629;EdgeFoamBlend;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;628;-1392,-1424;Inherit;False;626;EdgeFoam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;502;-1616,-1664;Inherit;False;LinearDodge;False;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;155;-1616,-1520;Float;False;Property;_EdgeFoamColor;Edge Foam Color;14;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,1,0.1185064,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;657;3936,2320;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;94;1568,-3616;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;614;1808,-3808;Inherit;False;612;ReflexionsCutoff;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-1152,-1600;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-1152,-1488;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;300;-1280,-1744;Inherit;False;LinearDodge;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;376;1568,-3776;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;93;1840,-3712;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;890;2160,-3664;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;660;4160,2320;Inherit;False;VerticalReflections;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;2423.803,-3697.27;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;2423.803,-3793.27;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;10;-752,-1440;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;11;-560,-1344;Float;False;Constant;_LightColorInfluence;Light Color Influence;17;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-448,-1456;Float;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-960,-1632;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;661;-1296,-1840;Inherit;False;660;VerticalReflections;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;633;-880,-1024;Inherit;False;Property;_EdgeFade;Edge Fade;8;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;95;2160,-3552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;90;2631.804,-3745.27;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;7;-256,-1440;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendOpsNode;658;-816,-1680;Inherit;False;LinearDodge;True;3;0;COLOR;1,1,1,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;634;-528,-1040;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;64,-1680;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;613;0,-1392;Inherit;False;612;ReflexionsCutoff;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;616;2889.047,-3744.813;Inherit;False;Lighting1;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;635;-256,-1104;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;617;240,-1312;Inherit;False;616;Lighting1;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;3;336,-1552;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;636;32,-1216;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;203;752,-1536;Float;False;True;-1;3;;0;0;CustomLighting;Toon/TFD_ToonWaterfall;False;False;False;False;False;False;False;False;True;False;False;False;False;False;True;True;False;False;False;False;True;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;364;0;363;0
WireConnection;365;0;364;0
WireConnection;366;0;365;0
WireConnection;368;0;366;0
WireConnection;327;0;183;0
WireConnection;175;0;177;0
WireConnection;175;1;180;0
WireConnection;176;0;374;0
WireConnection;176;1;327;0
WireConnection;431;0;173;0
WireConnection;174;0;175;0
WireConnection;174;1;176;0
WireConnection;325;0;172;0
WireConnection;170;0;433;0
WireConnection;170;1;174;0
WireConnection;167;0;170;1
WireConnection;167;1;325;0
WireConnection;435;0;177;0
WireConnection;163;0;167;0
WireConnection;332;0;183;0
WireConnection;324;0;162;0
WireConnection;208;0;163;0
WireConnection;335;0;172;0
WireConnection;196;0;198;0
WireConnection;196;1;437;0
WireConnection;197;0;332;0
WireConnection;197;1;373;0
WireConnection;191;0;335;0
WireConnection;161;0;208;0
WireConnection;161;1;324;0
WireConnection;195;0;196;0
WireConnection;195;1;197;0
WireConnection;207;0;191;0
WireConnection;334;0;158;0
WireConnection;160;0;161;0
WireConnection;193;0;434;0
WireConnection;193;1;195;0
WireConnection;419;0;418;0
WireConnection;426;0;45;0
WireConnection;189;0;207;0
WireConnection;157;0;160;0
WireConnection;188;0;334;0
WireConnection;188;1;193;1
WireConnection;422;0;420;0
WireConnection;422;1;419;0
WireConnection;156;0;157;0
WireConnection;156;1;158;0
WireConnection;185;0;189;0
WireConnection;185;1;188;0
WireConnection;470;0;422;0
WireConnection;470;2;421;0
WireConnection;423;0;422;0
WireConnection;423;2;421;0
WireConnection;186;0;156;0
WireConnection;186;1;185;0
WireConnection;416;0;439;0
WireConnection;416;1;423;0
WireConnection;425;0;439;0
WireConnection;425;1;470;0
WireConnection;344;0;339;0
WireConnection;626;0;186;0
WireConnection;294;0;293;0
WireConnection;407;0;416;0
WireConnection;407;1;425;0
WireConnection;611;0;398;0
WireConnection;341;0;370;0
WireConnection;341;1;344;0
WireConnection;295;0;294;0
WireConnection;392;0;611;0
WireConnection;392;1;407;0
WireConnection;492;0;491;0
WireConnection;794;0;812;0
WireConnection;42;0;43;0
WireConnection;42;1;371;0
WireConnection;231;0;230;0
WireConnection;231;1;228;0
WireConnection;342;0;341;0
WireConnection;342;2;340;0
WireConnection;297;0;627;0
WireConnection;297;1;296;0
WireConnection;297;2;295;0
WireConnection;394;0;392;0
WireConnection;394;1;399;0
WireConnection;495;0;493;0
WireConnection;495;1;492;0
WireConnection;608;0;494;0
WireConnection;40;0;42;0
WireConnection;40;2;247;0
WireConnection;232;0;231;0
WireConnection;218;0;428;0
WireConnection;218;1;342;0
WireConnection;299;0;297;0
WireConnection;395;0;394;0
WireConnection;498;0;495;0
WireConnection;498;2;608;0
WireConnection;556;0;495;0
WireConnection;556;1;557;0
WireConnection;823;0;799;0
WireConnection;39;0;427;0
WireConnection;39;1;40;0
WireConnection;336;0;38;0
WireConnection;242;0;232;0
WireConnection;215;0;218;0
WireConnection;378;0;395;0
WireConnection;405;0;299;0
WireConnection;483;0;497;0
WireConnection;483;1;498;0
WireConnection;496;0;556;0
WireConnection;496;2;608;0
WireConnection;792;0;791;0
WireConnection;860;0;862;0
WireConnection;860;1;861;0
WireConnection;800;0;799;0
WireConnection;824;0;823;0
WireConnection;804;0;799;0
WireConnection;815;0;799;0
WireConnection;37;0;39;2
WireConnection;37;1;336;0
WireConnection;37;2;896;1
WireConnection;104;0;103;0
WireConnection;234;0;242;0
WireConnection;234;1;215;0
WireConnection;893;0;892;0
WireConnection;146;0;150;0
WireConnection;323;0;137;0
WireConnection;552;0;497;0
WireConnection;552;1;496;0
WireConnection;551;0;483;1
WireConnection;478;0;483;1
WireConnection;478;1;482;0
WireConnection;27;0;26;1
WireConnection;27;1;29;0
WireConnection;28;0;26;2
WireConnection;28;1;29;0
WireConnection;863;0;860;0
WireConnection;821;0;815;0
WireConnection;644;0;648;0
WireConnection;644;2;800;0
WireConnection;701;0;700;0
WireConnection;701;2;804;0
WireConnection;819;0;820;0
WireConnection;819;2;824;0
WireConnection;291;0;37;0
WireConnection;108;0;234;0
WireConnection;108;1;109;0
WireConnection;106;0;104;0
WireConnection;473;0;472;0
WireConnection;473;1;145;0
WireConnection;473;2;471;0
WireConnection;211;0;146;0
WireConnection;462;0;402;0
WireConnection;462;1;144;0
WireConnection;462;2;406;0
WireConnection;136;3;323;0
WireConnection;554;0;552;1
WireConnection;550;0;478;0
WireConnection;550;1;551;0
WireConnection;550;2;482;0
WireConnection;31;0;27;0
WireConnection;31;1;28;0
WireConnection;810;0;809;0
WireConnection;810;1;644;0
WireConnection;807;0;808;0
WireConnection;807;1;701;0
WireConnection;817;0;818;0
WireConnection;817;1;819;0
WireConnection;678;0;677;0
WireConnection;678;2;821;0
WireConnection;107;0;108;0
WireConnection;107;1;106;0
WireConnection;142;0;462;0
WireConnection;142;1;473;0
WireConnection;142;2;211;0
WireConnection;209;0;136;0
WireConnection;555;0;550;0
WireConnection;555;1;554;0
WireConnection;606;0;476;0
WireConnection;24;0;26;0
WireConnection;24;1;31;0
WireConnection;24;2;292;0
WireConnection;811;0;810;0
WireConnection;811;1;807;0
WireConnection;789;0;790;0
WireConnection;789;1;678;0
WireConnection;859;0;865;0
WireConnection;859;1;817;0
WireConnection;115;0;107;0
WireConnection;115;1;116;1
WireConnection;884;0;881;0
WireConnection;884;1;883;3
WireConnection;133;0;142;0
WireConnection;133;1;135;0
WireConnection;133;2;209;0
WireConnection;475;0;555;0
WireConnection;475;1;606;0
WireConnection;475;2;894;1
WireConnection;250;0;432;0
WireConnection;250;1;24;0
WireConnection;853;0;864;0
WireConnection;853;1;811;0
WireConnection;825;0;789;0
WireConnection;825;1;859;0
WireConnection;825;2;865;0
WireConnection;117;0;115;0
WireConnection;117;1;505;0
WireConnection;882;0;133;0
WireConnection;882;1;884;0
WireConnection;329;0;304;0
WireConnection;329;1;250;0
WireConnection;674;0;687;0
WireConnection;674;1;682;0
WireConnection;674;2;825;0
WireConnection;671;0;673;0
WireConnection;671;1;672;0
WireConnection;671;2;853;0
WireConnection;622;0;882;0
WireConnection;120;0;117;0
WireConnection;487;0;475;0
WireConnection;629;0;156;0
WireConnection;619;0;329;0
WireConnection;686;0;671;0
WireConnection;686;1;674;0
WireConnection;612;0;120;0
WireConnection;502;0;508;0
WireConnection;502;1;625;0
WireConnection;657;1;686;0
WireConnection;657;2;656;4
WireConnection;153;0;630;0
WireConnection;153;1;155;0
WireConnection;184;0;155;0
WireConnection;184;1;628;0
WireConnection;300;0;620;0
WireConnection;300;1;502;0
WireConnection;890;0;614;0
WireConnection;890;1;94;0
WireConnection;660;0;657;0
WireConnection;91;0;93;1
WireConnection;91;1;890;0
WireConnection;87;0;614;0
WireConnection;87;1;376;0
WireConnection;12;0;300;0
WireConnection;12;1;153;0
WireConnection;12;2;184;0
WireConnection;95;0;94;0
WireConnection;90;0;87;0
WireConnection;90;1;91;0
WireConnection;90;2;95;0
WireConnection;7;0;8;0
WireConnection;7;1;10;1
WireConnection;7;2;11;0
WireConnection;658;0;661;0
WireConnection;658;1;12;0
WireConnection;634;0;633;0
WireConnection;5;0;658;0
WireConnection;5;1;7;0
WireConnection;616;0;90;0
WireConnection;635;0;634;0
WireConnection;3;0;5;0
WireConnection;3;1;613;0
WireConnection;636;0;299;0
WireConnection;636;1;635;0
WireConnection;203;2;3;0
WireConnection;203;9;636;0
WireConnection;203;13;617;0
ASEEND*/
//CHKSM=73F94093D60070C456ADBC0AF4C607B6FA219D38