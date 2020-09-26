module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true,
  },
  // purge: '../../docs/**/*.html',
  theme: {
    extend: {
      backgroundImage: theme => ({
        'pixel-texture': "url('/images/bg-pattern.png')",
      }),
    },
  },
  variants: {},
  plugins: [],
}
