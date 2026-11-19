# Medellín en doce latidos

Sitio web público y participativo de investigación-creación. Incluye 12 puntos iniciales, textos literarios del documento del equipo, mapa OpenStreetMap, formulario con foto y geolocalización, almacenamiento privado y panel editorial.

## 1. Ejecutar en tu computador

Requisitos: Node.js 20.19+ o 22.12+.

```bash
npm install
npm run dev
```

Abrir la dirección local que aparece en la terminal. Sin Supabase, funcionan el mapa, los textos y el diseño; **no se reciben aportes ni se pueden moderar**.

## 2. Activar contribuciones reales

1. Crear un proyecto en https://supabase.com.
2. En **SQL Editor**, ejecutar `supabase/schema.sql` sobre un proyecto nuevo.
3. En **Authentication > Providers**, habilitar Email. Para un panel editorial cerrado, deshabilitar el registro público de cuentas y crear los usuarios del equipo manualmente en **Authentication > Users**.
4. Copiar `.env.example` a `.env` y reemplazar `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY` por los valores **públicos** del proyecto (Project URL y anon/publishable key). **Nunca** colocar `service_role` ni claves secretas en variables `VITE_`.
5. En SQL Editor, ejecutar `insert into public.admins (user_id) values ('UUID-DEL-USUARIO');` por cada usuario autorizado, usando su UUID de Authentication > Users.
6. Reiniciar `npm run dev`.
7. Enviar una contribución de prueba y abrir **Equipo editorial** en el pie de página para aprobarla. Una vez aprobada, aparecerá en el mapa público.

## 3. Publicar en Internet

1. Subir el proyecto a un repositorio GitHub **sin** el archivo `.env`.
2. Importar el repositorio en Vercel o Netlify como proyecto Vite. Comando de compilación `npm run build`, carpeta de salida `dist`.
3. Añadir las dos variables `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY` en los ajustes del alojamiento.
4. Desplegar. El alojamiento proporciona una URL pública. Opcionalmente, conectar un dominio propio.
5. Probar desde otro dispositivo: leer textos, enviar foto, aprobar, comprobar publicación, rechazar y verificar que lo rechazado no aparezca.

## 4. Contenido inicial y revisión editorial

- Los textos iniciales se extrajeron del documento `Guia trabajo final Práctica VIII (1).docx`, sección 5, sin reemplazarlos por otros textos.
- **Metro de Medellín** y **Plaza Botero** no tenían contenido literario en el documento; aparecen como pendientes. Completar `text` en `src/originales.json` antes de publicar.
- Las coordenadas de los 12 puntos iniciales son **aproximadas**; revisarlas en `src/originales.json` antes de lanzar la web.
- Las fotos de los 12 puntos originales no están incluidas porque el documento no aporta archivos fotográficos con autorización de uso. Las contribuciones ciudadanas sí permiten adjuntar una foto.
- El título y la descripción de la plataforma son propuestas editoriales; pueden modificarse.

## 5. Seguridad y límites de esta primera versión

- Las contribuciones se guardan como `pending`; solo los editores autorizados pueden aprobar/rechazar.
- El almacenamiento de fotos es privado y se ofrecen enlaces firmados temporalmente para fotos aprobadas.
- Se aplican validaciones de tamaño de foto (5 MB), tipo MIME y longitud del texto; la base de datos valida campos y coordenadas.
- El formulario es público y puede recibir spam. **Antes de difundir masivamente**, añadir protección anti-bots (Turnstile o CAPTCHA validado en servidor/Edge Function), límites de solicitudes, procedimiento de eliminación, política de privacidad y tratamiento de datos personales acorde con la legislación aplicable en Colombia.
- Una revisión editorial humana sigue siendo necesaria para derechos de autor, fotografías de personas y contenido sensible.
- Las imágenes subidas que no se conviertan en publicaciones aprobadas permanecen almacenadas; establecer una rutina de eliminación para aportes rechazados/huérfanos.
- El mapa de selección permite ubicar puntos dentro de un área geográfica aproximada de Medellín; ajustar el alcance si se quiere incluir el área metropolitana.

## 6. Organización

- `src/App.jsx`: portada, mapa, lecturas, formulario y moderación.
- `src/originales.json`: 12 lugares y sus textos originales.
- `src/style.css`: diseño responsive.
- `src/supabase.js`: conexión con backend.
- `supabase/schema.sql`: tablas, reglas de acceso y almacenamiento.

## 7. Licencias y atribución

Mapa © colaboradores de OpenStreetMap. Textos originales: equipo autor del proyecto; conservar los créditos que el equipo decida antes de publicar. Las contribuciones de terceros requieren consentimiento expreso de publicación.
