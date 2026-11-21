uniform vec2 umbriel_workspace_axis;

const float kScale = 340.0;
const float kPixel = 1.0;
const float kBand  = 0.16;
const float kSweep = 0.60;

const float kPad = 0.03;

float bHash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float bNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  return mix(mix(bHash(i), bHash(i + vec2(1.0, 0.0)), f.x),
    mix(bHash(i + vec2(0.0, 1.0)), bHash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float bFbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 4; ++i) {
    v += a * bNoise(p);
    p = p * 2.03 + vec2(17.1, 9.2);
    a *= 0.5;
  }
  return v / 0.9375;
}

vec4 animation(vec2 uv) {
  vec3 pA = umbriel_palette_count > 0 ? umbriel_palette_at(0.0).rgb : vec3(0.92, 0.22, 0.06);
  vec3 pB = umbriel_palette_count > 1 ? umbriel_palette_at(1.0 / float(umbriel_palette_count)).rgb : vec3(1.0, 0.72, 0.18);
  vec3 kChar = pA * 0.12;
  vec3 kEmber = pA;
  vec3 kHot = pB;
  vec3 kCore = mix(pB, vec3(1.0), 0.65);
  vec4 out_ws = umbriel_sample(uv);
  vec4 in_ws = umbriel_sample_incoming(uv);

  float p = umbriel_clamped_progress;
  if (p <= 0.0) { return out_ws; }
  if (p >= 1.0) { return in_ws; }
  float burn = p;

  float coordinate = dot(uv, abs(umbriel_workspace_axis));
  if (umbriel_workspace_axis.x + umbriel_workspace_axis.y < 0.0) {
    coordinate = 1.0 - coordinate;
  }

  vec2 q = floor(uv * umbriel_size / kPixel) * kPixel;
  float n = smoothstep(0.2, 0.8, bFbm(q / kScale));
  n = mix(n, coordinate, kSweep);
  n += (bHash(q) - 0.5) * 0.03;

  float x = n - mix(-kBand - kPad, 1.0 + kPad, burn);
  float alive = smoothstep(0.0, 0.012, x);
  float heat = 1.0 - clamp(x / kBand, 0.0, 1.0);

  vec3 rgb = out_ws.rgb / max(out_ws.a, 0.0001);
  vec3 col = mix(rgb, kChar, smoothstep(0.0, 0.3, heat));
  col = mix(col, kEmber, smoothstep(0.25, 0.6, heat));
  col = mix(col, kHot, smoothstep(0.6, 0.9, heat));
  col = mix(col, kCore, smoothstep(0.9, 1.0, heat));

  float a = out_ws.a * alive;
  return vec4(col * a, a) + in_ws * (1.0 - a);
}
