const float kScale = 240.0;
const float kSoft = 0.06;

float meHash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float meNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  return mix(mix(meHash(i), meHash(i + vec2(1.0, 0.0)), f.x),
    mix(meHash(i + vec2(0.0, 1.0)), meHash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float meFbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 3; ++i) {
    v += a * meNoise(p);
    p = p * 2.05 + vec2(11.3, 5.9);
    a *= 0.5;
  }
  return v / 0.875;
}

vec4 animation(vec2 uv) {
  vec4 c = umbriel_sample(uv);
  float visible = umbriel_direction > 0.0 ? umbriel_clamped_progress : 1.0 - umbriel_clamped_progress;
  if (visible >= 1.0) { return c; }
  if (visible <= 0.0) { return vec4(0.0); }

  float t = umbriel_time;
  vec2 px = uv * umbriel_size;
  float n = meFbm(px / kScale);
  float drip = 0.055 * sin(uv.x * 9.0 + 1.2) +
    0.035 * sin(uv.x * 21.0 - 0.7) +
    0.04 * (n - 0.5) +
    0.012 * sin(uv.x * 37.0 + t * 1.5);
  float field = 1.0 - uv.y + drip;

  float threshold = mix(1.22, -0.22, visible);
  float x = field - threshold;
  float mask = smoothstep(0.0, kSoft, x);
  float rim = exp(-x * x / (kSoft * kSoft * 0.4));
  vec3 tint = umbriel_palette_count > 0 ? umbriel_palette_at(0.0).rgb : vec3(0.75, 0.85, 1.0);
  tint = mix(tint, vec3(1.0), 0.35);
  vec3 col = c.rgb * mask + tint * rim * 0.6;
  return vec4(col, c.a * mask);
}
