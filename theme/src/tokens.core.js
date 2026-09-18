/**
 * Nocttua — design tokens (fuente única de verdad).
 * Valores planos, sin dependencias: los consume tailwind.config.js (web)
 * y src/theme/tokens.native.js (React Native / Expo).
 *
 * Regla de marca: el ámbar es señal, nunca cuerpo de texto.
 * Bebé A = violeta, Bebé B = terracota. Nunca al revés.
 */

export const color = {
  // Crema · papel y superficies claras
  cremaPaper: '#FBF7F0',
  cremaMist: '#F4EFE6',
  cremaSand: '#EFE9DF',
  cremaBase: '#E7E1D6',
  cremaHairline: '#F0EAE0',
  cremaLine: '#E4DCD0',
  cremaLineStrong: '#DCD4C8',

  // Noche · la marca en oscuro
  noche900: '#16162B',
  noche800: '#22224A',
  noche700: '#2C2C52',
  noche600: '#33335F',
  noche500: '#4A4A7A',

  // Violeta · acento principal
  violeta600: '#6B5DD3',
  violeta400: '#A79FE0',
  violeta300: '#B9AFEA',
  violeta200: '#C9C1D8',
  violeta100: '#E8DFF6',
  violeta50: '#F6F1FB',

  // Ámbar · señal cálida
  ambar700: '#B08A55',
  ambar500: '#F0A868',
  ambar200: '#EFDCC4',
  ambar100: '#FDE8D7',
  ambar50: '#FFF9F0',

  // Verde · va bien
  verde600: '#3F7A62',
  verde400: '#7FB09A',
  verde200: '#C9DED4',
  verde100: '#DCEDE4',
  verde50: '#F3F7F4',

  // Coral · alerta · terracota · bebé B
  coral700: '#C0533C',
  coral500: '#D9705A',
  coral100: '#FBE4DF',
  terracota500: '#C2703F',
  terracota100: '#FDF3EA',

  // Tinta · texto sobre crema
  tintaFuerte: '#16162B',
  tintaMedia: '#3A3550',
  tintaCuerpo: '#4A4459',
  tintaSuave: '#6E6878',
  tintaTenue: '#8A8299',
  tintaApagada: '#A9A2B5',

  // Texto sobre noche
  sobreNocheFuerte: '#FBF7F0',
  sobreNocheSuave: '#B9B2C9',
  sobreNocheTenue: '#8E87B5',
  sobreNocheApagado: '#7C769A',

  white: '#FFFFFF',
};

/** Alias semánticos: usa estos en producto, no los crudos de arriba. */
export const semantic = {
  surfacePage: color.cremaBase,
  surfaceCard: color.white,
  surfaceCardAlt: color.cremaPaper,
  surfaceSunken: color.cremaSand,
  surfaceNight: color.noche900,
  surfaceNightRaised: color.noche800,
  surfaceAccentSoft: color.violeta50,
  surfaceWarmSoft: color.ambar50,
  surfaceGoodSoft: color.verde50,
  surfaceAlertSoft: color.coral100,

  borderHairline: color.cremaHairline,
  borderDefault: color.cremaLine,
  borderStrong: color.cremaLineStrong,
  borderAccent: color.violeta200,
  borderNight: color.noche600,

  textStrong: color.tintaFuerte,
  textBody: color.tintaCuerpo,
  textMuted: color.tintaTenue,
  textFaint: color.tintaApagada,
  textOnNight: color.sobreNocheFuerte,
  textOnNightMuted: color.sobreNocheSuave,

  accent: color.violeta600,
  accentContrast: color.cremaPaper,
  highlight: color.ambar500,
  highlightInk: color.noche900,
  success: color.verde600,
  warning: color.ambar700,
  danger: color.coral500,
  babyA: color.violeta600,
  babyB: color.terracota500,

  link: color.violeta600,
  linkHover: color.noche900,
};

export const font = {
  display: '"Bodoni Moda", Georgia, serif',        // marca y titulares de marca
  ui: '"Onest", system-ui, sans-serif',            // interfaz de marca / web
  mono: '"DM Mono", ui-monospace, monospace',      // horas, cifras, etiquetas
  displayApp: '"Instrument Serif", Georgia, serif',// titulares dentro del producto
  uiApp: '"DM Sans", system-ui, sans-serif',       // cuerpo dentro del producto
};

export const fontSize = {
  '2xs': 10, xs: 11, sm: 12.5, base: 14, md: 15, lg: 17, xl: 19,
  'display-sm': 22, 'display-md': 27, 'display-lg': 34, 'display-xl': 54, 'display-2xl': 74,
};

export const lineHeight = { tight: 1.1, snug: 1.3, normal: 1.45, relaxed: 1.55 };
export const fontWeight = { light: 300, regular: 400, medium: 500, semibold: 600, bold: 700 };

/** Etiqueta mono en versalitas: el recurso tipográfico de la marca. */
export const eyebrow = { size: 11, tracking: 0.1, trackingWide: 0.18 };

export const space = { 1: 2, 2: 4, 3: 6, 4: 8, 5: 10, 6: 12, 7: 14, 8: 16, 9: 20, 10: 22, 11: 26, 12: 32, 13: 40, 14: 44 };

export const radius = {
  xs: 8, sm: 10, md: 12, lg: 14, xl: 16, '2xl': 18, '3xl': 22, pill: 99,
  appIcon: 29,  // squircle del icono a 124px
  phone: 44,    // marco del teléfono
};

/** Radio compuesto de la hoja inferior (web: string CSS; RN: usa sheetNative). */
export const sheetRadius = '24px 24px 34px 34px';
export const sheetRadiusNative = { borderTopLeftRadius: 24, borderTopRightRadius: 24 };

export const shadow = {
  card: '0 12px 30px -22px rgba(22, 22, 43, .55)',
  raised: '0 24px 60px -30px rgba(22, 22, 43, .4)',
  phone: '0 34px 70px -24px rgba(22, 22, 43, .5)',
  toast: '0 16px 34px -14px rgba(22, 22, 43, .6)',
  accent: '0 8px 22px -14px rgba(107, 93, 211, .5)',
  focusRing: '0 0 0 3px rgba(107, 93, 211, .28)',
};

export const motion = {
  durFast: 200, durBase: 300, durSlow: 450, durChart: 900,
  easeStandard: 'ease',
  easeOutSoft: 'cubic-bezier(.2, .8, .2, 1)',
};

/** Alturas mínimas de toque. Nunca por debajo de 44. */
export const hit = { min: 44, comfortable: 50, large: 52 };

export const tokens = { color, semantic, font, fontSize, lineHeight, fontWeight, eyebrow, space, radius, shadow, motion, hit };
export default tokens;
