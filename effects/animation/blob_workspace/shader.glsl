uniform vec2 umbriel_workspace_axis;

const float kScale  = 420.0;
const float kBlob   = 0.18;
const float kWobble = 0.05;
const float kSoft   = 0.06;

const float kPad = 0.08;

float shapeField(vec2 uv, vec2 origin) {
  vec2 p = (uv - origin) * umbriel_size;
  float maxd = length(umbriel_size * max(origin, 1.0 - origin));
  float r = length(p) / maxd;
  float a = atan(p.y, p.x + 0.0001);
  float lobes = 0.6 * sin(3.0 * a + 0.7) + 0.4 * sin(5.0 * a + 2.1);
  lobes *= smoothstep(0.0, 0.25, r);
  vec2 g = uv * umbriel_size / kScale;
  float blobs = 0.5 + 0.25 * (sin(g.x * 1.7 + 1.3 * sin(g.y * 1.1)) + sin(g.y * 1.9 + 1.2 * sin(g.x * 0.8 + 1.0)));
  return mix(r, blobs, kBlob) + kWobble * lobes;
}

vec4 animation(vec2 uv) {
  vec4 out_ws = umbriel_sample(uv);
  vec4 in_ws = umbriel_sample_incoming(uv);

  float p = umbriel_clamped_progress;
  if (p <= 0.0) { return out_ws; }
  if (p >= 1.0) { return in_ws; }

  vec2 axis = abs(umbriel_workspace_axis);
  vec2 origin = (umbriel_workspace_axis.x + umbriel_workspace_axis.y < 0.0) ? 0.5 + 0.5 * axis : 0.5 - 0.5 * axis;

  float n = shapeField(uv, origin);
  float x = n - mix(-kSoft - kPad, 1.0 + kPad, p);
  float keep = smoothstep(0.0, kSoft, x);
  return out_ws * keep + in_ws * (1.0 - out_ws.a * keep);
}
