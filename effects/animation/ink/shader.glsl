const float kScale = 180.0;
const float kSoft = 0.055;
const float kWarp = 0.85;

float ikHash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float ikNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  return mix(mix(ikHash(i), ikHash(i + vec2(1.0, 0.0)), f.x),
    mix(ikHash(i + vec2(0.0, 1.0)), ikHash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float ikFbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 3; ++i) {
    v += a * ikNoise(p);
    p = p * 2.07 + vec2(13.7, 7.1);
    a *= 0.5;
  }
  return v / 0.875;
}

vec4 animation(vec2 uv) {
  vec4 c = umbriel_sample(uv);
  float visible = umbriel_direction > 0.0 ? umbriel_clamped_progress : 1.0 - umbriel_clamped_progress;
  if (visible >= 1.0) { return c; }
  if (visible <= 0.0) { return vec4(0.0); }

  vec2 p = uv * umbriel_size / kScale;
  vec2 w = vec2(ikFbm(p + vec2(1.7, 9.2)), ikFbm(p + vec2(8.3, 2.8)));
  float n = ikFbm(p + kWarp * (w - 0.5));
  float r = length((uv - 0.5) * 1.6);
  float field = mix(1.0 - r, n, 0.55);
  float threshold = mix(1.05, -0.16, visible);
  float x = field - threshold;
  float mask = smoothstep(0.0, kSoft, x);
  float rim = exp(-x * x / (kSoft * kSoft * 0.35));
  vec3 tint = umbriel_palette_count > 0 ? umbriel_palette_at(0.0).rgb : vec3(0.55, 0.72, 1.0);
  vec3 col = c.rgb * mask + tint * rim * 0.45;
  return vec4(col, c.a * mask);
}
