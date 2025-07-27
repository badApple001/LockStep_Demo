// Made with Amplify Shader Editor v1.9.4.4
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon/TFD_ToonWaterRipples"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_NoiseMap("NoiseMap", 2D) = "white" {}
		_ScrollingSpeed("Scrolling Speed", Vector) = (0,0.5,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.5
		#pragma surface surf StandardCustomLighting keepalpha addshadow fullforwardshadows nodirlightmap 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
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

		uniform sampler2D _NoiseMap;
		uniform float2 _ScrollingSpeed;
		uniform float _Cutoff = 0.5;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_TexCoord637 = i.uv_texcoord * float2( 2,2 );
			float2 panner639 = ( 1.0 * _Time.y * ( _ScrollingSpeed * float2( 0,0.8 ) ) + uv_TexCoord637);
			float2 uv_TexCoord646 = i.uv_texcoord * float2( 3,2 );
			float2 panner647 = ( 1.0 * _Time.y * _ScrollingSpeed + uv_TexCoord646);
			float4 temp_output_643_0 = ( tex2D( _NoiseMap, panner639 ) + tex2D( _NoiseMap, panner647 ) );
			c.rgb = 0;
			c.a = 1;
			clip( ( temp_output_643_0 * i.vertexColor.a ).r - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float2 uv_TexCoord637 = i.uv_texcoord * float2( 2,2 );
			float2 panner639 = ( 1.0 * _Time.y * ( _ScrollingSpeed * float2( 0,0.8 ) ) + uv_TexCoord637);
			float2 uv_TexCoord646 = i.uv_texcoord * float2( 3,2 );
			float2 panner647 = ( 1.0 * _Time.y * _ScrollingSpeed + uv_TexCoord646);
			float4 temp_output_643_0 = ( tex2D( _NoiseMap, panner639 ) + tex2D( _NoiseMap, panner647 ) );
			o.Emission = ( float4( ase_lightColor.rgb , 0.0 ) * temp_output_643_0 ).rgb;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=19404
Node;AmplifyShaderEditor.Vector2Node;659;-320,-1248;Inherit;False;Property;_ScrollingSpeed;Scrolling Speed;2;0;Create;True;0;0;0;False;0;False;0,0.5;0,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;646;-320,-1088;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;3,2;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;637;-320,-1408;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,2;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;661;-80,-1312;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0.8;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;647;96,-1088;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;639;96,-1408;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.4;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;645;400,-1408;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;640;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;648;400,-1120;Inherit;True;Property;_TextureSample2;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;640;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;643;800,-1248;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;654;816,-976;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;655;887.9727,-1453.222;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;640;400,-1664;Inherit;True;Property;_NoiseMap;NoiseMap;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;653;1056,-1088;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;656;1050.473,-1360.922;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;203;1216,-1296;Float;False;True;-1;3;;0;0;CustomLighting;Toon/TFD_ToonWaterRipples;False;False;False;False;False;False;False;False;True;False;False;False;False;False;True;True;False;False;False;False;True;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;661;0;659;0
WireConnection;647;0;646;0
WireConnection;647;2;659;0
WireConnection;639;0;637;0
WireConnection;639;2;661;0
WireConnection;645;1;639;0
WireConnection;648;1;647;0
WireConnection;643;0;645;0
WireConnection;643;1;648;0
WireConnection;653;0;643;0
WireConnection;653;1;654;4
WireConnection;656;0;655;1
WireConnection;656;1;643;0
WireConnection;203;2;656;0
WireConnection;203;10;653;0
ASEEND*/
//CHKSM=5A9D50E99DAA57FACD693288C1B0C227EBC237EA