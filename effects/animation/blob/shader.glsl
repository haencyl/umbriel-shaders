const vec2  kOrigin = vec2(0.5, 0.5);
const float kScale  = 260.0;
const float kBlob   = 0.22;
const float kWobble = 0.06;
const float kSoft   = 0.06;

const float kPad = 0.08;

float shapeField(vec2 uv) {
  vec2 p = (uv - kOrigin) * umbriel_size;
  float maxd = length(umbriel_size * max(kOrigin, 1.0 - kOrigin));
  float r = length(p) / maxd;
  float a = atan(p.y, p.x + 0.0001);
  float lobes = 0.6 * sin(3.0 * a + 0.7) + 0.4 * sin(5.0 * a + 2.1);
  lobes *= smoothstep(0.0, 0.25, r);
  vec2 g = uv * umbriel_size / kScale;
  float blobs = 0.5 + 0.25 * (sin(g.x * 1.7 + 1.3 * sin(g.y * 1.1)) + sin(g.y * 1.9 + 1.2 * sin(g.x * 0.8 + 1.0)));
  return mix(r, blobs, kBlob) + kWobble * lobes;
}

vec4 animation(vec2 uv) {
  vec4 c = umbriel_sample(uv);

  float visible = umbriel_direction > 0.0 ? umbriel_clamped_progress : 1.0 - umbriel_clamped_progress;
  if (visible >= 1.0) { return c; }
  if (visible <= 0.0) { return vec4(0.0); }

  float n = 1.0 - shapeField(uv);
  float x = n - mix(1.0 + kPad, -kSoft - kPad, visible);
  return c * smoothstep(0.0, kSoft, x);
}
