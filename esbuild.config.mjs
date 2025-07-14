import { filePlugin } from "esbuild-plugin-file";

export default {
  plugins: [
    filePlugin({
      include: /\.(png|jpg|jpeg|gif|svg)$/,
      name: "[name]-[hash]",
      publicPath: "/assets/",
      outdir: "app/assets/builds"
    })
  ]
}
