# nocttua-shared

Código y esquema compartidos entre [nocttua-mobile](https://github.com/ncondep17/nocttua-mobile) y [nocttua-coach](https://github.com/ncondep17/nocttua-coach).

## `theme/`

Paquete `@nocttua/theme` — la fuente única de verdad de colores, tipografía, espaciado y radios. Cada app lo consume como dependencia local (`file:./shared/theme`), donde `shared/` es este repo montado como git submodule.

- `theme/src/tokens.core.js` — tokens para web (Coach).
- `theme/src/tokens.native.js` — mismos tokens para React Native (mobile).

## `supabase/migrations/`

Historial de migraciones SQL del proyecto Supabase que usan ambas apps (una sola base de datos, un solo backend). Se aplican vía Dashboard SQL — no hay acceso directo por CLI configurado.

## `HANDOFF.md`

Convención de componentes de UI que deben mantenerse alineados en nombre y props entre las dos apps.

## Actualizar el theme en las apps que lo consumen

Después de un cambio acá:

```bash
cd ../nocttua-mobile/shared && git pull origin main   # o nocttua-coach
cd .. && git add shared && git commit -m "bump shared"
```
