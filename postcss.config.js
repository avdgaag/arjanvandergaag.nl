module.exports = {
  plugins: [
    require("tailwindcss")("./tailwind.js"),
    require("autoprefixer"),
    require("cssnano")({
      preset: "default",
    }),
    require("@fullhuman/postcss-purgecss")({
      content: ["./output/**/*.html"],
      extractors: [
        {
          extractor: {
            extract: function(content) {
              return content.match(/[A-Za-z0-9-_:\/]+/g) || [];
            },
          },
          extensions: ["html"],
        },
      ],
    }),
  ],
};
