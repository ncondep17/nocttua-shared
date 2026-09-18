/**
 * Theme listo para React Native / Expo.
 * Mismos valores que tokens.core.js, expresados como números y objetos de estilo RN.
 * En RN: registra las fuentes con expo-font usando los nombres de familia de `fontFamily`.
 */
import tokens from './tokens.core';

const { color, semantic, fontSize, lineHeight, fontWeight, eyebrow, space, radius, shadow, motion, hit } = tokens;

export const theme = {
  color, semantic, space, radius, fontSize, lineHeight, fontWeight, hit, eyebrow,

  // En RN la familia es el nombre del archivo registrado, sin fallbacks CSS.
  fontFamily: {
    display: 'BodoniModa-Regular',
    ui: 'Onest-Regular',
    uiMedium: 'Onest-Medium',
    mono: 'DMMono-Regular',
    displayApp: 'InstrumentSerif-Regular',
    uiApp: 'DMSans-Regular',
    uiAppMedium: 'DMSans-Medium',
  },

  // Las sombras CSS no existen en RN: equivalentes por plataforma.
  elevation: {
    card: { shadowColor: '#16162B', shadowOpacity: 0.18, shadowRadius: 14, shadowOffset: { width: 0, height: 8 }, elevation: 3 },
    raised: { shadowColor: '#16162B', shadowOpacity: 0.22, shadowRadius: 24, shadowOffset: { width: 0, height: 14 }, elevation: 6 },
    sheet: { shadowColor: '#16162B', shadowOpacity: 0.28, shadowRadius: 30, shadowOffset: { width: 0, height: -8 }, elevation: 12 },
  },

  duration: { fast: motion.durFast, base: motion.durBase, slow: motion.durSlow, chart: motion.durChart },
  webShadow: shadow,
};

/** Estilos de texto compuestos, el atajo que se repite en todas las pantallas. */
export const type = {
  screenTitle: { fontFamily: theme.fontFamily.displayApp, fontSize: fontSize['display-md'], color: semantic.textStrong, lineHeight: fontSize['display-md'] * lineHeight.tight },
  cardTitle: { fontFamily: theme.fontFamily.uiAppMedium, fontSize: fontSize.lg, color: semantic.textStrong },
  body: { fontFamily: theme.fontFamily.uiApp, fontSize: fontSize.base, color: semantic.textBody, lineHeight: fontSize.base * lineHeight.relaxed },
  caption: { fontFamily: theme.fontFamily.uiApp, fontSize: fontSize.sm, color: semantic.textMuted },
  eyebrow: { fontFamily: theme.fontFamily.mono, fontSize: fontSize.xs, letterSpacing: 1.1, textTransform: 'uppercase', color: semantic.textMuted },
  data: { fontFamily: theme.fontFamily.mono, fontSize: fontSize.lg, color: semantic.textStrong },
};

export default theme;
