// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Hanli"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_rongjie_tex("rongjie_tex", 2D) = "white" {}
		_tex("tex", 2D) = "white" {}
		_guangying("guangying", 2D) = "white" {}
		_MetalNormal("Metal Normal", 2D) = "black" {}
		_ReflectionTex("Reflection Tex", 2D) = "black" {}
		_Reflectivity("Reflectivity",Range(0,2)) = 1
		_shadowfanwei("shadowfanwei", Float) = 1
		_shadow_ramp("shadow_ramp", Float) = 0
		_shadowcolor("shadowcolor", Color) = (0,0,0,0)
		_shadowIntensity("shadowIntensity", Range( 0 , 1)) = 0
		_SpecularRange("SpecularRange", Float) = 0.62
		_Specular_ramp("Specular_ramp", Float) = 0.3
		_SpecularMult("SpecularMult", Float) = 1
		_SpecularColor("SpecularColor", Color) = (1,1,1,0)
		_fresnelScale("fresnelScale", Float) = 0
		_fresnelPower("fresnelPower", Float) = 3
		[HDR]_fresnelColor("fresnelColor", Color) = (1,1,1,1)
		[HDR]_bianjie_Color("bianjie_Color", Color) = (1,0,0,1)
		_bianjie_fanwei("bianjie_fanwei", Range( 0 , 1)) = 0.5075928
		_rongjirzhi("rongjirzhi ", Range( 0 , 2)) = 0
		_Outline_color("Outline_color", Color) = (0,0,0,0)
		_Outline_width("Outline_width", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		//add by yangfan 2022-1-17
		_Alpha("Alpha",Range(0,1)) = 1
		//add by yangfan 2021-12-9
		_ClippingCubeMax("Clipping Cube Max",Vector) = (0,0,0)
		_ClippingCubeMin("Clipping Cube Min",Vector) = (0,0,0)
		[HideInInspector] _ClippingCubeMatrixRow0("ClippingCubeMatrixRow0",Vector) = (1,0,0,0)
		[HideInInspector] _ClippingCubeMatrixRow1("ClippingCubeMatrixRow1",Vector) = (0,1,0,0)
		[HideInInspector] _ClippingCubeMatrixRow2("ClippingCubeMatrixRow2",Vector) = (0,0,1,0)
		//add by yangfan 2022-6-17
		_Stencil ("Stencil ID", Float) = 111
		
	}

	SubShader
	{
		Tags{ }
		ZWrite Off
		ZTest LEqual
		Cull Front
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc
		#pragma multi_compile NOT_USING_CUBE_CLIPPING USING_CUBE_CLIPPING //add by yangfan 2021-12-9
		
		
		struct Input
		{
			half filler;
			float3 worldPos;
		};
		uniform float _Outline_width;
		uniform float4 _Outline_color;
		//add by yangfan 2021-12-9
		float3 _ClippingCubeMax;
		float3 _ClippingCubeMin;
		float4 _ClippingCubeMatrixRow0;
		float4 _ClippingCubeMatrixRow1;
		float4 _ClippingCubeMatrixRow2;
		//add by yangfan 2022-1-17
		fixed _Alpha;
		
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = _Outline_width;
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		//add by yangfan 2021-12-9
		float3 toClippingCubeSpace(float3 worldPoint)
		{
			float3 ret = float3(0,0,0);
			ret.x = _ClippingCubeMatrixRow0.x * worldPoint.x + _ClippingCubeMatrixRow0.y * worldPoint.y + _ClippingCubeMatrixRow0.z * worldPoint.z + _ClippingCubeMatrixRow0.w;
			ret.y = _ClippingCubeMatrixRow1.x * worldPoint.x + _ClippingCubeMatrixRow1.y * worldPoint.y + _ClippingCubeMatrixRow1.z * worldPoint.z + _ClippingCubeMatrixRow1.w;
			ret.z = _ClippingCubeMatrixRow2.x * worldPoint.x + _ClippingCubeMatrixRow2.y * worldPoint.y + _ClippingCubeMatrixRow2.z * worldPoint.z + _ClippingCubeMatrixRow2.w;
			return ret;
		}
		float isPointInsideCube(float3 worldPoint)
		{
			float3 pixelPos = toClippingCubeSpace(worldPoint);
			float3 max = _ClippingCubeMax;
			float3 min = _ClippingCubeMin;
			float length = abs(max.x - min.x);
			float3 cubePos = max + (min - max) / 2;
			if(abs(pixelPos.x - cubePos.x) > length / 2){return 1;}
			float width	 = abs(max.z - min.z);
			if(abs(pixelPos.z - cubePos.z) > width / 2){return 1;}
			float height = abs(max.y - min.y);
			if(abs(pixelPos.y - cubePos.y) > height / 2){return 1;}
			return 0;
		}
		//
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Alpha = clamp(_Alpha,0,1);
			o.Emission = _Outline_color.rgb;
			#if USING_CUBE_CLIPPING//add by yangfan 2021-12-9
				if(isPointInsideCube(i.worldPos) == 0){discard;}
			#endif
		}
		//
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"}
		Cull Back
		ZWrite On
		ZTest LEqual
		Blend SrcAlpha OneMinusSrcAlpha
		Stencil
		{
			Ref [_Stencil]
			Comp Always
			Pass Replace
		}
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha noshadow exclude_path:deferred noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd vertex:vertexDataFunc finalcolor:mycolor
		#pragma multi_compile NOT_USING_CUBE_CLIPPING USING_CUBE_CLIPPING
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
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

		uniform sampler2D _tex;
		uniform float4 _tex_ST;
		uniform float _shadowfanwei;
		uniform float _shadow_ramp;
		uniform sampler2D _guangying;
		uniform float4 _guangying_ST;
		uniform float4 _shadowcolor;
		uniform float _shadowIntensity;
		uniform float _fresnelScale;
		uniform float _fresnelPower;
		uniform float4 _fresnelColor;
		uniform float4 _bianjie_Color;
		uniform sampler2D _rongjie_tex;
		uniform float4 _rongjie_tex_ST;
		uniform float _rongjirzhi;
		uniform float _bianjie_fanwei;
		uniform float _SpecularMult;
		uniform float _SpecularRange;
		uniform float _Specular_ramp;
		uniform float4 _SpecularColor;
		uniform float _Cutoff = 0.5;
		fixed _Alpha;
		//add by yangfan 2021-12-9
		float3 _ClippingCubeMax;
		float3 _ClippingCubeMin;
		float4 _ClippingCubeMatrixRow0;
		float4 _ClippingCubeMatrixRow1;
		float4 _ClippingCubeMatrixRow2;
		//
		sampler2D _MetalNormal;
		sampler2D _ReflectionTex;
		float _Reflectivity;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float clampResult126 = clamp( i.uv_texcoord.y , 0.0 , 1.0 );
			float2 uv_rongjie_tex = i.uv_texcoord * _rongjie_tex_ST.xy + _rongjie_tex_ST.zw;
			float temp_output_129_0 = ( ( clampResult126 * tex2D( _rongjie_tex, uv_rongjie_tex ).r ) / _rongjirzhi );
			c.rgb = 0;
			c.a = clamp(_Alpha,0,1);
			clip( temp_output_129_0 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		//add by yangfan 2021-12-9
		float3 toClippingCubeSpace(float3 worldPoint)
		{
			float3 ret = float3(0,0,0);
			ret.x = _ClippingCubeMatrixRow0.x * worldPoint.x + _ClippingCubeMatrixRow0.y * worldPoint.y + _ClippingCubeMatrixRow0.z * worldPoint.z + _ClippingCubeMatrixRow0.w;
			ret.y = _ClippingCubeMatrixRow1.x * worldPoint.x + _ClippingCubeMatrixRow1.y * worldPoint.y + _ClippingCubeMatrixRow1.z * worldPoint.z + _ClippingCubeMatrixRow1.w;
			ret.z = _ClippingCubeMatrixRow2.x * worldPoint.x + _ClippingCubeMatrixRow2.y * worldPoint.y + _ClippingCubeMatrixRow2.z * worldPoint.z + _ClippingCubeMatrixRow2.w;
			return ret;
		}
		float isPointInsideCube(float3 worldPoint)
		{
			float3 pixelPos = toClippingCubeSpace(worldPoint);
			float3 max = _ClippingCubeMax;
			float3 min = _ClippingCubeMin;
			float length = abs(max.x - min.x);
			float3 cubePos = max + (min - max) / 2;
			if(abs(pixelPos.x - cubePos.x) > length / 2){return 1;}
			float width = abs(max.z - min.z);
			if(abs(pixelPos.z - cubePos.z) > width / 2){return 1;}
			float height = abs(max.y - min.y);
			if(abs(pixelPos.y - cubePos.y) > height / 2){return 1;}
			return 0;
		}
		void mycolor (Input i, SurfaceOutputCustomLightingCustom o, inout fixed4 color)
		{
			#if USING_CUBE_CLIPPING
				if(isPointInsideCube(i.worldPos) == 0){discard;}
			#endif
		}
		//
		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float2 uv_tex = i.uv_texcoord * _tex_ST.xy + _tex_ST.zw;
			float4 tex2DNode11 = tex2D( _tex, uv_tex );
			float4 ase_vertex4Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 ase_objectlightDir = normalize( ObjSpaceLightDir(ase_vertex4Pos) );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float dotResult5 = dot( ase_objectlightDir , ase_vertexNormal);
			//使用用半兰伯特漫反射（即将点乘结果的值域映射到[0,1]）--add by yangfan 2022-2-22
			dotResult5 = dotResult5 * 0.5 + 0.5;
			float2 uv_guangying = i.uv_texcoord * _guangying_ST.xy + _guangying_ST.zw;
			float4 tex2DNode21 = tex2D( _guangying, uv_guangying );
			float temp_output_211_0 = saturate( ( pow( ( 1.0 - ( dotResult5 + _shadowfanwei ) ) , _shadow_ramp ) * ( 1.0 - tex2DNode21.g ) ) );
			float4 temp_output_40_0 = ( tex2DNode11 * ( 1.0 - temp_output_211_0 ) );
			float3 worldSpaceViewDir323 = WorldSpaceViewDir( float4( 0,0,0,1 ) );
			float3 temp_cast_0 = (( 1.0 - worldSpaceViewDir323.x )).xxx;
			float dotResult79 = dot( temp_cast_0 , ase_vertexNormal );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV67 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode67 = ( 0.0 + _fresnelScale * pow( 1.0 - fresnelNdotV67, _fresnelPower ) );
			float clampResult91 = clamp( ( ( ( dotResult79 - 0.85 ) * temp_output_211_0 ) * fresnelNode67 ) , 0.0 , 1.0 );
			float clampResult126 = clamp( i.uv_texcoord.y , 0.0 , 1.0 );
			float2 uv_rongjie_tex = i.uv_texcoord * _rongjie_tex_ST.xy + _rongjie_tex_ST.zw;
			float temp_output_129_0 = ( ( clampResult126 * tex2D( _rongjie_tex, uv_rongjie_tex ).r ) / _rongjirzhi );
			float dotResult142 = dot( ase_objectlightDir , ase_vertexNormal );
			float temp_output_307_0 = saturate( ( tex2D( _guangying, uv_guangying ).r * pow( ( dotResult142 + _SpecularRange ) , _Specular_ramp ) ) );
			o.Alpha = clamp(_Alpha,0,1);
			o.Emission = tex2DNode11;//( ( temp_output_40_0 + ( ( tex2DNode11 * _shadowcolor * _shadowIntensity ) * temp_output_211_0 ) ) + ( clampResult91 * _fresnelColor ) + ( _bianjie_Color * step( temp_output_129_0 , _bianjie_fanwei ) ) + ( temp_output_40_0 * ( _SpecularMult * ( temp_output_307_0 * tex2D( _guangying, uv_guangying ).b ) * _SpecularColor ) ) ).rgb;
			//
			float3 finalColor = o.Emission;
			float4 normalColor = tex2D(_MetalNormal, uv_tex);
			float3 normal = i.worldNormal.xyz;
			normal.z += normalColor.y;
			normal = normalize(normal);
			float2 normal2D = float2(normal.x,-normal.y);
			float2 reflectionTexUV = normal2D * 0.5 + 0.5;
			float3 reflectionColor = tex2D(_ReflectionTex, reflectionTexUV).xyz;
			finalColor = lerp(finalColor, reflectionColor, normalColor.z * _Reflectivity);
			//
			//float _rim23112 = max(0.0, (0.1 - dot(float3(-1.0, 0.2, 0.2), i.worldNormal.xyz)));
			//float _rim13113 = max(0.0, (0.1 - dot(float3(1.0, -0.2, 0.2), i.worldNormal.xyz)));
			//float _spe3114 = ((min(pow(_rim13113, 36.0), 1.0) * 0.5) + (min(pow(_rim23112, 36.0), 1.0) * 0.2));
			//finalColor.xyz += float3(_spe3114,_spe3114,_spe3114);
			//
			o.Emission = finalColor;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18000
1920;588;1906;430;-1623.106;-2569.018;1.429818;True;True
Node;AmplifyShaderEditor.ObjSpaceLightDirHlpNode;313;-3470.765,447.3301;Inherit;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;4;-3977.17,964.1236;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;30;-2093.208,385.0789;Inherit;False;Property;_shadowfanwei;shadowfanwei;4;0;Create;True;0;0;False;0;1;0.85;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;5;-2059.602,164.0433;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;300;-1645.297,159.4971;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;20;-2941.452,557.7848;Inherit;True;Property;_guangying;guangying;3;0;Create;True;0;0;False;0;None;45b72aae8fd28bb4da108ddb8ab008c7;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;21;-2282.456,690.7892;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;311;-1443.294,465.3196;Inherit;False;Property;_shadow_ramp;shadow_ramp;5;0;Create;True;0;0;False;0;0;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;316;-1319.781,214.1301;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceViewDirHlpNode;323;-610.8597,-91.28766;Inherit;False;1;0;FLOAT4;0,0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;142;-2742.979,1266.78;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2468.131,1819.984;Inherit;False;Property;_SpecularRange;SpecularRange;8;0;Create;True;0;0;False;0;0.62;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;330;-2615.422,1709.272;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;124;510.2073,3151.469;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;329;-2514.28,1720.983;Inherit;False;Property;_Specular_ramp;Specular_ramp;9;0;Create;True;0;0;False;0;0.3;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;81;-322.9886,-15.83728;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;304;-1194.404,598.6781;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;301;-1164.925,228.3727;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;251;-2817.687,965.6138;Inherit;True;Property;_TextureSample2;Texture Sample 2;7;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;126;802.7095,3199.569;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;306;-2416.728,1401.01;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;79;28.33774,44.41843;Inherit;True;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;-706.7043,274.5855;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;125;779.1756,3459.605;Inherit;True;Property;_rongjie_tex;rongjie_tex;1;0;Create;True;0;0;False;0;-1;2aae62454a24d7d419cadc03db4ae802;2aae62454a24d7d419cadc03db4ae802;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;211;-446.9022,510.1747;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;455.003,597.6024;Inherit;False;Property;_fresnelPower;fresnelPower;13;0;Create;True;0;0;False;0;3;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;1104.305,3395.869;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;1024.076,3675.505;Float;False;Property;_rongjirzhi;rongjirzhi ;17;0;Create;True;0;0;False;0;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;467.0029,510.6024;Inherit;False;Property;_fresnelScale;fresnelScale;12;0;Create;True;0;0;False;0;0;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;325;-2136.396,1219.503;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;112;386.3177,58.26626;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;178;-997.0406,1775.302;Inherit;True;Property;_TextureSample3;Texture Sample 3;7;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;43;-490.8361,1532.219;Inherit;False;Property;_shadowIntensity;shadowIntensity;7;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;-1377.152,1037.743;Inherit;True;Property;_tex;tex;2;0;Create;True;0;0;False;0;-1;None;776d67e59a6e10a448c108c714670158;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;41;-383.9942,1347.033;Inherit;False;Property;_shadowcolor;shadowcolor;6;0;Create;True;0;0;False;0;0,0,0,0;0.5566038,0.4069509,0.4668121,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;307;-1751.317,1395.718;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;67;712.0535,420.1444;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;324;629.9749,106.9841;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;129;1441.576,3558.005;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;99;110.3798,811.1711;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-433.2768,1780.922;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;130;1672.792,3360.699;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;130.4284,1317.284;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;62;204.7363,1803.669;Inherit;False;Property;_SpecularMult;SpecularMult;10;0;Create;True;0;0;False;0;1;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;1039.931,305.1497;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;197;212.9282,1983.514;Inherit;False;Property;_SpecularColor;SpecularColor;11;0;Create;True;0;0;False;0;1,1,1,0;1,0.8513137,0.6367924,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;134;1713.304,3671.836;Float;False;Property;_bianjie_fanwei;bianjie_fanwei;16;0;Create;True;0;0;False;0;0.5075928;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;246;916.7163,1853.811;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;478.9839,722.5899;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;71;1215.852,669.6517;Inherit;False;Property;_fresnelColor;fresnelColor;14;1;[HDR];Create;True;0;0;False;0;1,1,1,1;0.345098,0.5137255,0.6980392,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;479.1,1218.997;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;91;1396.26,520.5349;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;133;1904.36,3312.771;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;131;1476.972,2872.387;Float;False;Property;_bianjie_Color;bianjie_Color;15;1;[HDR];Create;True;0;0;False;0;1,0,0,1;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;1602.574,846.5275;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;141;2777.604,3099.339;Inherit;False;Property;_Outline_width;Outline_width;19;0;Create;True;0;0;False;0;0;0.005;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;900.3175,869.8433;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;140;2666.5,2780.235;Inherit;False;Property;_Outline_color;Outline_color;18;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;1983.462,2460.865;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;1622.079,1614.458;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;138;3039.008,2843.336;Inherit;False;0;True;None;2;3;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;339;2345.161,2919.322;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ConditionalIfNode;308;-1414.407,1861.878;Inherit;True;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;342;2503.873,3090.901;Inherit;False;Constant;_Float2;Float 2;20;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;214;-401.7913,1006.691;Inherit;True;Overlay;True;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;310;-1783.095,2053.427;Inherit;False;Constant;_Float1;Float 1;18;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;2398.604,1650.046;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;341;2569.644,2946.49;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;309;-1780.689,1974.779;Inherit;False;Constant;_Float0;Float 0;18;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2880.001,1545.525;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;jue_se/jue_se01;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;AlphaTest;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0.3;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;313;0
WireConnection;5;1;4;0
WireConnection;300;0;5;0
WireConnection;300;1;30;0
WireConnection;21;0;20;0
WireConnection;316;0;300;0
WireConnection;142;0;313;0
WireConnection;142;1;4;0
WireConnection;330;0;142;0
WireConnection;330;1;56;0
WireConnection;81;0;323;1
WireConnection;304;0;21;2
WireConnection;301;0;316;0
WireConnection;301;1;311;0
WireConnection;251;0;20;0
WireConnection;126;0;124;2
WireConnection;306;0;330;0
WireConnection;306;1;329;0
WireConnection;79;0;81;0
WireConnection;79;1;4;0
WireConnection;299;0;301;0
WireConnection;299;1;304;0
WireConnection;211;0;299;0
WireConnection;128;0;126;0
WireConnection;128;1;125;1
WireConnection;325;0;251;1
WireConnection;325;1;306;0
WireConnection;112;0;79;0
WireConnection;178;0;20;0
WireConnection;307;0;325;0
WireConnection;67;2;68;0
WireConnection;67;3;69;0
WireConnection;324;0;112;0
WireConnection;324;1;211;0
WireConnection;129;0;128;0
WireConnection;129;1;127;0
WireConnection;99;0;211;0
WireConnection;148;0;307;0
WireConnection;148;1;178;3
WireConnection;130;0;129;0
WireConnection;42;0;11;0
WireConnection;42;1;41;0
WireConnection;42;2;43;0
WireConnection;80;0;324;0
WireConnection;80;1;67;0
WireConnection;246;0;62;0
WireConnection;246;1;148;0
WireConnection;246;2;197;0
WireConnection;40;0;11;0
WireConnection;40;1;99;0
WireConnection;44;0;42;0
WireConnection;44;1;211;0
WireConnection;91;0;80;0
WireConnection;133;0;130;0
WireConnection;133;1;134;0
WireConnection;70;0;91;0
WireConnection;70;1;71;0
WireConnection;46;0;40;0
WireConnection;46;1;44;0
WireConnection;132;0;131;0
WireConnection;132;1;133;0
WireConnection;65;0;40;0
WireConnection;65;1;246;0
WireConnection;138;0;140;0
WireConnection;138;1;141;0
WireConnection;308;0;307;0
WireConnection;308;1;56;0
WireConnection;308;2;309;0
WireConnection;308;3;310;0
WireConnection;308;4;310;0
WireConnection;214;0;21;2
WireConnection;214;1;11;0
WireConnection;66;0;46;0
WireConnection;66;1;70;0
WireConnection;66;2;132;0
WireConnection;66;3;65;0
WireConnection;341;0;339;0
WireConnection;341;1;342;0
WireConnection;0;2;66;0
WireConnection;0;10;129;0
WireConnection;0;11;138;0
ASEEND*/
//CHKSM=742E404DD6F1F9112D3A713831E73F3716A69821