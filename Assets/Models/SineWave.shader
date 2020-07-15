﻿Shader "Custom/SineWave" {
	Properties{
		_MainTex("Albedo (RGB)", 2D) = "black" {}
		_Amp("Amplitude", float) = 0.3
		_Frq("Frequency", float) = 10
		_Spd("Speed", float) = 100
		_o1x("origin1_x", Range(-0.5,0.5)) = 0
		_o1y("origin1_y", Range(-0.5,0.5)) = 0
		_o2x("origin2_x", Range(-0.5,0.5)) = 0
		_o2y("origin2_y", Range(-0.5,0.5)) = 0
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			#pragma surface surf Lambert vertex:vert
			#pragma target 3.0

			sampler2D _MainTex;
			float _Amp;
			float _Frq;
			float _Spd;
			float _o1x;
			float _o1y;
			float _o2x;
			float _o2y;

			struct Input {
				float2 uv_MainTex;
				float3 customVert;
			};

			struct WaveData {
				float height;
				float2 normal;
			};

			static const float PI = 3.14159265f;

			WaveData sin_wave(float2 c) {
				WaveData wave;
				float c_dist = sqrt(c.x * c.x + c.y * c.y);
				wave.height = _Amp * sin(2 * PI * _Frq * (_Time.y - (c_dist / _Spd)));
				float temp_cosin = -_Amp * 2 * PI * _Frq * cos(2 * PI * _Frq * (_Time.y - c_dist / _Spd)) / c_dist / _Spd;
				wave.normal = float2(-temp_cosin * c.x, -temp_cosin * c.y);

				return wave;
			}

			void vert(inout appdata_full v, out Input o)
			{
				UNITY_INITIALIZE_OUTPUT(Input, o);

				float2 c1 = float2(v.vertex.x - _o1x, v.vertex.z - _o1y);
				WaveData wave_c1 = sin_wave(c1);
				float amp1 = wave_c1.height;
				float2 del_amp1 = wave_c1.normal;


				float2 c2 = float2(v.vertex.x - _o2x, v.vertex.z - _o2y);
				WaveData wave_c2 = sin_wave(c2);
				float amp2 = wave_c2.height;
				float2 del_amp2 = wave_c2.normal;

				v.vertex.xyz = float3(v.vertex.x, v.vertex.y + amp1 + amp2, v.vertex.z);
				v.normal = normalize(float3(v.normal.x + del_amp1.x + del_amp2.x, v.normal.y, v.normal.z + del_amp1.y + del_amp2.y));

				o.customVert = v.vertex.xyz;
			}

			void surf(Input IN, inout SurfaceOutput o) {
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
				float temp = (IN.customVert.y + 1);
				//float temp = (IN.customVert.y);
				o.Albedo = c.rgb + float3(temp - 1 + 0.1, 0.1 , 1 - temp + 0.1);
				o.Alpha = c.a;
			}
			ENDCG
		}
			FallBack "Diffuse"
}