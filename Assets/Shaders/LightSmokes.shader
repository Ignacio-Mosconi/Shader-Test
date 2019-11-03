Shader "Surface/LightSmokes"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        CGPROGRAM
        #pragma surface surf Lambert

        #include "UnityCG.cginc"

        struct Input
        {
            float2 uv_BackgroundTexture;
        };

        sampler2D _BackgroundTexture;
        fixed4 _LightColors[10];
        float _Intensities[10];
        float _Radiuses[10];
        float _AngularSpeeds[10];
        int _NumberOfLights;
        float2 _Center;
        float _EmissionIntensity;

        float3 mod289(float3 x)
        {
            return (x - floor(x * (1.0 / 289.0)) * 289.0);
        }

        float4 mod289(float4 x) 
        {
            return (x - floor(x * (1.0 / 289.0)) * 289.0);
        }

        float4 mod(float4 x, float y)
        {
            return (x - floor(x * (1.0 / y)) * y);
        }

        float4 permute(float4 x) 
        {
            return (mod289(((x * 34.0) + 1.0) * x));
        }

        float4 taylorInvSqrt(float4 r)
        {
            return (1.79284291400159 - 0.85373472095314 * r);
        }

        float snoise(float3 v)
        { 
            const float2 C = float2(1.0 / 6.0, 1.0 / 3.0);
            const float4 D = float4(0.0, 0.5, 1.0, 2.0);

            // First corner
            float3 fragmentData = floor(v + dot(v, C.yyy));
            float3 x0 = v - fragmentData + dot(fragmentData, C.xxx);

            // Other corners
            float3 g = step(x0.yzx, x0.xyz);
            float3 l = 1.0 - g;
            float3 i1 = min(g.xyz, l.zxy);
            float3 i2 = max(g.xyz, l.zxy);

            float3 x1 = x0 - i1 + C.xxx;
            float3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
            float3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

            // Permutations
            fragmentData = mod289(fragmentData); 
            float4 p = permute(permute(permute( 
                        fragmentData.z + float4(0.0, i1.z, i2.z, 1.0))
                        + fragmentData.y + float4(0.0, i1.y, i2.y, 1.0)) 
                        + fragmentData.x + float4(0.0, i1.x, i2.x, 1.0));

            // Gradients: 7x7 points over a square, mapped onto an octahedron.
            // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
            float n_ = 0.142857142857; // 1.0/7.0
            float3 ns = n_ * D.wyz - D.xzx;

            float4 j = mod(p , 49.0);

            float4 x_ = floor(j * ns.z);
            float4 y_ = mod(j, 7.0);

            float4 x = x_ * ns.x + ns.yyyy;
            float4 y = y_ * ns.x + ns.yyyy;
            float4 h = 1.0 - abs(x) - abs(y);

            float4 b0 = float4(x.xy, y.xy);
            float4 b1 = float4(x.zw, y.zw);

            float4 s0 = floor(b0) * 2.0 + 1.0;
            float4 s1 = floor(b1) * 2.0 + 1.0;
            float4 sh = -step(h, float4(0.0, 0.0, 0.0, 0.0));

            float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
            float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

            float3 p0 = float3(a0.xy, h.x);
            float3 p1 = float3(a0.zw, h.y);
            float3 p2 = float3(a1.xy, h.z);
            float3 p3 = float3(a1.zw, h.w);

            //Normalise gradients
            float4 norm = taylorInvSqrt(float4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
            p0 *= norm.x;
            p1 *= norm.y;
            p2 *= norm.z;
            p3 *= norm.w;

            // Mix final noise value
            float4 m = max(0.6 - float4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
            m = m * m;
            
            return (42.0 * dot(m * m, float4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3))));
        }

        float normnoise(float noise) 
        {
            return (0.5 * (noise + 1.0));
        }

        float clouds(float2 uv) 
        {
            uv += float2(_Time.y * 0.05, _Time.y * 0.01);
            
            float2 offset1 = float2(3.0, 2.0);
            float2 offset2 = float2(0.0, 0.0);
            float2 offset3 = float2(-10, 5.0);
            float2 offset4 = float2(-10, 20.0);
            float2 offset5 = float2(40.0, -20.0);
            float2 offset6 = float2(12.0, -100.0);
            float scale1 = 2.0;
            float scale2 = 4.0;
            float scale3 = 8.0;
            float scale4 = 16.0;
            float scale5 = 32.0;
            float scale6 = 64.0;
            
            return normnoise(snoise(float3((uv + offset1) * scale1, _Time.y * 0.5)) * 0.8 + 
                            snoise(float3((uv + offset2) * scale2, _Time.y * 0.4)) * 0.4 +
                            snoise(float3((uv + offset3) * scale3, _Time.y * 0.1)) * 0.2 +
                            snoise(float3((uv + offset4) * scale4, _Time.y * 0.7)) * 0.1 +
                            snoise(float3((uv + offset5) * scale5, _Time.y * 0.2)) * 0.05 +
                            snoise(float3((uv + offset6) * scale6, _Time.y * 0.3)) * 0.025);
        }

        void surf(Input IN, inout SurfaceOutput o) 
        {
            fixed4 textureColor = tex2D(_BackgroundTexture, IN.uv_BackgroundTexture);
            float2 uv = IN.uv_BackgroundTexture;
            float3 lightsColor;

            for (int i = 0; i < _NumberOfLights; i++)
            {
                float2 light = float2(cos(_Time.y * _AngularSpeeds[i]) * _Radiuses[i], sin(_Time.y * _AngularSpeeds[i]) * _Radiuses[i]) + _Center;
                float dist = distance(uv, light);
                float cloudIntensity = _Intensities[i] * (1.0 - 2.5 * dist);
                float lightIntensity = _Intensities[i] / (100.0 * dist);
                float finalCloud = float3(cloudIntensity * clouds(uv), cloudIntensity * clouds(uv), cloudIntensity * clouds(uv));
                
                lightsColor += (lightIntensity + finalCloud) * _LightColors[i];
            }

            o.Albedo = lightsColor + textureColor;
            o.Emission = lightsColor * _EmissionIntensity;
        }
        ENDCG
    }
}