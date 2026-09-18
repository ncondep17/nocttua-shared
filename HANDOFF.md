# Notas de implementación

## Componentes compartidos entre las dos apps

Estos tienen el **mismo nombre y las mismas props** en Nocttua App y Nocttua Coach. Si cambia uno, cambian los dos:

`Logo` · `Eyebrow` · `Button` · `Card` · `Badge` · `Chip` · `StatCard` · `ListRow` · `Avatar` · `Toggle` · `Stepper` · `TextField` · `TextArea` · `SegmentedControl` · `MetricBar` · `BarChart` · `KpiRow` · `TimelineEvent` · `Toast` · `EmptyState`

Exclusivos de móvil: `TabBar` · `Sheet` · `PhoneFrame` · `ScreenScroll` · `ScreenHeader`
Exclusivos de escritorio: `SideNav` · `Modal` · `SidePanel` · `DesktopShell` · `PageHeader`

## Datos

`src/apps/*/data/mock.js` es el contrato de datos que espera cada pantalla. Al conectar la API real, mantené la forma de esos objetos o ajustá las pantallas en consecuencia. Ningún componente de `components/` importa datos.

## Estado que falta

Los routers de ejemplo cubren navegación y overlays. Lo que un backend real tiene que resolver:

- Sesión y cuenta compartida entre cuidadores (varios dispositivos, un mismo registro).
- Sincronización offline: la app se usa de madrugada y sin conexión fiable.
- Cálculo de la ventana por edad — hoy es un dato fijo en `mock.js`.
- Permisos por miembro del equipo (`TeamScreen` y `AccessManagementPanel` son las dos caras del mismo modelo).
- Publicación de versiones del plan: Coach escribe, App lee.

## Accesibilidad

- Todo control interactivo llega a 44px de alto mínimo.
- `Toggle` usa `role="switch"` + `aria-checked`; `Chip` usa `aria-pressed`.
- El foco visible es `shadow-ring` (violeta al 28%), no el outline del navegador.
- Contraste: el texto sobre noche usa `crema-paper` o `noite-suave`, nunca `noite-tenue` para cuerpo.
