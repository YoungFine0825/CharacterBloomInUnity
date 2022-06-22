Shader "Custom/PartnerBloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
		_BloomColor("Bloom Color",Color) = (1,1,1,1)
		_BlurSize(" Partner Blur Size",Float) = 1
		_LuminanceThreshold("_LuminanceThreshold",Float) = 0
		_StencilRef("Stencil Ref",Range(0,256)) = 111 
		_CompareFunction("Compare Function",Int) = 3
		[HideInInspector]_CombiningTex("Combining Tex",2D) = "black" {}
		[HideInInspector]_PartnerMask("Partner Mask",2D) = "white" {}
		[HideInInspector]_CombiningFactor("Combining Factor",Float) = 1
		[HideInInspector]_MainTexColor("Main Tex Color",Color) = (1,1,1,1)
		[HideInInspector]_LowBloomedTex("Low Bloomed Tex",2D) = "black" {}
    }
    SubShader
    {

        CGINCLUDE
		    #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

			struct v2fBlur
            {
                float4 pos :SV_POSITION;
                half2 uv[5]:TEXCOORD0;
            };

            fixed luminance(fixed4 color)
            {
                return color.r * 0.2125 + color.g * 0.7145 + color.b * 0.0721;
            }

            float _LuminanceThreshold;
			half4 _MainTex_TexelSize;
            float _BlurSize;
			sampler2D _MainTex;
			float4 _MainTex_ST;

            v2fBlur vertBlurVertical(appdata_img v)
            {
                v2fBlur o;
                o.pos = UnityObjectToClipPos(v.vertex);

                half2 uv = v.texcoord;

                o.uv[0] = uv;
                o.uv[1] = uv + float2(0,_MainTex_TexelSize.y * 1.0) * _BlurSize;
                o.uv[2] = uv - float2(0,_MainTex_TexelSize.y * 1.0) * _BlurSize;
                o.uv[3] = uv + float2(0,_MainTex_TexelSize.y * 2.0) * _BlurSize;
                o.uv[4] = uv - float2(0,_MainTex_TexelSize.y * 2.0) * _BlurSize;
                return o;
            }

            v2fBlur vertBlurHorizonal(appdata_img v)
            {
                v2fBlur o;
                o.pos = UnityObjectToClipPos(v.vertex);

                half2 uv = v.texcoord;

                o.uv[0] = uv;
                o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0,0) * _BlurSize;
                o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0,0) * _BlurSize;
                o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0,0) * _BlurSize;
                o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0,0) * _BlurSize;
                return o;
            }
			
			fixed4 fragBlur(v2fBlur i) : SV_Target
            {
                float weight[3] = {0.4026,0.2442,0.0545};
				//
				fixed4 mainTexColor = tex2D(_MainTex,i.uv[0]);
				//
                fixed4 sum = mainTexColor * weight[0];
				//
                for(int idx = 1;idx < 3;idx++)
                {
                    sum += tex2D(_MainTex,i.uv[idx]) * weight[idx];
                    sum += tex2D(_MainTex,i.uv[idx * 2]) * weight[idx];
                }
                return fixed4(sum.rgb,1.0);
            }

        ENDCG
        // No culling or depth
        Cull Off 
		ZWrite Off 
		ZTest Always
		//ÌáÈ¡ÆÁÄ»ÉÏ»ï°éÏñËØ
        Pass
        {
			/**/
			Stencil
			{
				Ref [_StencilRef]
				Comp [_CompareFunction]
				Pass Keep
			}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
        //ÌáÈ¡Í¼ÏñÁÁ¶È
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }
			fixed4 _BloomColor;
			sampler2D _PartnerMask;

            fixed4 frag (v2f i) : SV_Target
            {
				/*
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed lum = luminance(col);
                fixed val = clamp(lum - _LuminanceThreshold,0,1);
                return col * val * _BloomColor;*/
				//
				float4 col = tex2D(_MainTex, i.uv);
				float colDot = dot(col.xyz, float3(0.29899999, 0.58700001, 0.114));
				col.rgb *= ( ( (colDot * colDot) * colDot ) * colDot );
				fixed mask = tex2D(_PartnerMask,i.uv).a;
				col.rgb = lerp(fixed3(0,0,0),col.rgb,mask);
				return col;
            }
            ENDCG
        }

        Pass
        {
            NAME "GAUSSIAN_BLUR_VERTICAL"
            CGPROGRAM

            #pragma vertex vertBlurVertical
            #pragma fragment fragBlur

            ENDCG
        }

        Pass
        {
            NAME "GAUSSIAN_BLUR_HORIZONNAL"
            CGPROGRAM

            #pragma vertex vertBlurHorizonal
            #pragma fragment fragBlur

            ENDCG
        }
		//
		/*µþ¼ÓÄ£ºýÍ¼*/
        Pass 
        {
			/*
			Stencil
			{
				Ref [_StencilRef]
				Comp [_CompareFunction]
				Pass Keep
			}*/
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2fBloom
            {
                float4 vertex :SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2fBloom vert (appdata_img v)
            {
                v2fBloom o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord;
                return o;
            }

			sampler2D _CombiningTex;
			sampler2D _PartnerMask;
			float _CombiningFactor;
			fixed4 _BloomColor;
			fixed4 _MainTexColor;

            fixed4 frag (v2fBloom i) : SV_Target
            {
				fixed combiningMask = tex2D(_PartnerMask,i.uv.xy).a;
				fixed3 screenColor = tex2D(_MainTex,i.uv.xy).rgb;
				fixed3 combiningColor = tex2D(_CombiningTex,i.uv.xy).rgb * _BloomColor.rgb;
				fixed3 finalCol = lerp(screenColor,combiningColor,_CombiningFactor);
				finalCol = lerp(screenColor,finalCol,combiningMask);
                return fixed4(finalCol,1);
            }
            ENDCG
        }
		//
		/*µþ¼ÓÁÁ¶ÈÍ¼*/
        Pass 
        {
			/*
			Stencil
			{
				Ref [_StencilRef]
				Comp [_CompareFunction]
				Pass Keep
			}*/
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2fBloom
            {
                float4 vertex :SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2fBloom vert (appdata_img v)
            {
                v2fBloom o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord;
                return o;
            }

			sampler2D _CombiningTex;
			float _CombiningFactor;
			fixed4 _BloomColor;
			fixed4 _MainTexColor;

            fixed4 frag (v2fBloom i) : SV_Target
            {
				fixed3 screenColor = tex2D(_MainTex,i.uv.xy).rgb * _MainTexColor.rgb;
				float3 factor = float3(_CombiningFactor,_CombiningFactor,_CombiningFactor);
				fixed3 combiningColor = tex2D(_CombiningTex,i.uv.xy).rgb * _BloomColor.rgb * factor;
				fixed3 finalCol = combiningColor + screenColor;
                return fixed4(finalCol,1);
            }
            ENDCG
        }
		//
		/*±ßÔµ¹â*/
        Pass 
        {
			/**/
			Stencil
			{
				Ref [_StencilRef]
				Comp NotEqual
				Pass Keep
			}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2fBloom
            {
                float4 vertex :SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2fBloom vert (appdata_img v)
            {
                v2fBloom o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord;
                return o;
            }

			sampler2D _CombiningTex;
			sampler2D _PartnerMask;
			float _CombiningFactor;

            fixed4 frag (v2fBloom i) : SV_Target
            {
				fixed combiningMask = max(0,1 - tex2D(_PartnerMask,i.uv.xy).a);
				fixed3 screenColor = tex2D(_MainTex,i.uv.xy).rgb;
				float3 factor = float3(_CombiningFactor,_CombiningFactor,_CombiningFactor);
				fixed3 combiningColor = tex2D(_CombiningTex,i.uv.xy).rgb * factor;
				fixed3 finalCol = combiningColor + screenColor;
				//finalCol = lerp(screenColor,finalCol,combiningMask);
                return fixed4(finalCol,1);
            }
            ENDCG
        }
    }
}
