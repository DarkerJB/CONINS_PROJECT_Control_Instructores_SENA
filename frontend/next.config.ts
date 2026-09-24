import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  output: "export",              // genera archivos estaticos en /out (despliegue intranet)
  images: { unoptimized: true }, // requerido para export estatico (sin optimizador de servidor)
};

export default nextConfig;
