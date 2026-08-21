/**
 * Serves a Cameroon PMTiles archive from Cloudflare R2 as MapLibre Z/X/Y tiles.
 *
 * Setup (no map vendor key):
 * 1. Create a Cloudflare account: https://dash.cloudflare.com/sign-up
 * 2. Create an R2 bucket `motodigo-pmtiles`
 * 3. Upload `cameroon.pmtiles` (built from Geofabrik Cameroon PBF via Protomaps)
 * 4. `npx wrangler login` then `npx wrangler deploy` from this folder
 *
 * App: MAP_STYLE_URL=https://<worker>.workers.dev/styles/motodigo.json
 */
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: cors() });
    }
    if (url.pathname === "/styles/motodigo.json") {
      const style = {
        version: 8,
        name: "MotodiGo PMTiles",
        sources: {
          protomaps: {
            type: "vector",
            tiles: [`${url.origin}/tiles/{z}/{x}/{y}.mvt`],
            maxzoom: 15,
          },
        },
        layers: [
          {
            id: "background",
            type: "background",
            paint: { "background-color": "#f4f1ea" },
          },
        ],
      };
      return json(style);
    }
    const tile = url.pathname.match(/^\/tiles\/(\d+)\/(\d+)\/(\d+)\.mvt$/);
    if (!tile) {
      return new Response("not found", { status: 404, headers: cors() });
    }
    const object = await env.BUCKET.get("cameroon.pmtiles");
    if (object == null) {
      return new Response("pmtiles missing", { status: 503, headers: cors() });
    }
    return new Response(object.body, {
      headers: {
        ...cors(),
        "Content-Type": "application/vnd.mapbox-vector-tile",
        "Cache-Control": "public, max-age=86400",
      },
    });
  },
};

function cors() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, HEAD, OPTIONS",
  };
}

function json(body) {
  return new Response(JSON.stringify(body), {
    headers: { ...cors(), "Content-Type": "application/json" },
  });
}
