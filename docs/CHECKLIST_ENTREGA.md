# Checklist de Entrega Final - Bolsillo Claro (v1.0.0)

Este documento detalla el estado de cumplimiento de los requisitos técnicos, arquitectónicos, de calidad y de entrega del proyecto **Bolsillo Claro**, distinguiendo entre lo verificado automáticamente y las comprobaciones manuales pendientes a cargo del evaluador/estudiante.

---

## 1. Casillas de Verificación de Entrega (15 Puntos Clave)

A continuación se listan las casillas correspondientes a los 15 aspectos solicitados para la entrega final:

- [ ] **1. 20 registros:** Registro de exactamente 20 gastos demostrativos mediante la API pública con montos realistas en USD para Ecuador. El script [`scripts/cargar_datos_demo.ps1`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/scripts/cargar_datos_demo.ps1) está creado y validado, pero **su ejecución interactiva real en el backend permanece pendiente como comprobación manual**.
- [x] **2. Autenticación:** Registro de usuario (`/usuarios/`), login por formulario (`/usuarios/token`), almacenamiento de token JWT en `flutter_secure_storage`, restauración de sesión (`/usuarios/me`) y cierre de sesión. Verificado con pruebas unitarias y de widgets.
- [x] **3. CRUD:** Creación, listado paginado, edición y eliminación de gastos (`/gastos/`) con confirmación de borrado y validación de montos/descripciones.
- [x] **4. Filtro:** Filtrado por categoría con opción dinámica *"Todos"* y obtención de categorías vigentes del backend (`/gastos/categorias`).
- [x] **5. Resumen:** Obtención del total general y distribución por categoría usando el endpoint oficial `/gastos/resumen` del backend (sin calcular totales sobre páginas parciales).
- [x] **6. Caché:** Persistencia Hive aislada por ID de usuario (`gastos_user_<id>`), indicador visible de última sincronización, fallback ante desconexión o 5xx, limpieza al cerrar sesión e inmutabilidad (sin simulación de escrituras offline).
- [x] **7. Tema:** Preferencia de tema Claro / Oscuro con persistencia en Hive que sobrevive al reinicio de la aplicación.
- [ ] **8. Asistente real:** Interfaz con preguntas sugeridas, advertencia de IA y prevención de doble consulta lista y testeada con mocks; **la consulta con IA real mediante una clave propia de Google Gemini en el proxy permanece pendiente como comprobación manual**.
- [x] **9. Errores:** Manejo integral y mensajes comprensibles para errores de red, timeouts, códigos 400, 401, 422 y 5xx, sin registrar contraseñas ni tokens en consola.
- [x] **10. Pruebas:** Cobertura exhaustiva de pruebas unitarias y de widgets sin dependencias externas (78 pruebas Flutter pasadas + 7 pruebas Node.js del proxy pasadas).
- [x] **11. CI:** Pipeline de GitHub Actions en [`.github/workflows/ci.yml`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/.github/workflows/ci.yml) configurado para `push` y `pull_request` en `main`, verificando Java 17, Flutter estable, formato, análisis, pruebas y empaquetado del APK.
- [x] **12. APK:** Compilación local exitosa del archivo ejecutable Release (`app-release.apk`, 51.6 MB) y configuración de empaquetado en CI (`bolsillo-claro-apk`).
- [ ] **13. Capturas:** Capturas de pantalla reales del emulador Android para documentar la entrega (pendientes de ser tomadas por el estudiante durante la prueba en vivo).
- [x] **14. README:** Documentación exhaustiva en español ([`README.md`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/README.md)) con arquitectura, configuración segura de variables, comandos PowerShell, limitaciones (`10.0.2.2`), advertencias de seguridad y guía de evidencias.
- [ ] **15. Release:** Workflow preparado en GitHub Actions para publicar el release y adjuntar el APK al recibir una etiqueta `v*`; **la creación y envío de la etiqueta `v1.0.0` mediante `git push origin v1.0.0` permanece pendiente a decisión del estudiante/evaluador**.

---

## 2. Resultados Exactos de Análisis, Pruebas y Compilación Local

| Verificación / Herramienta | Comando Exacto Ejecutado | Resultado Obtenido | Estado |
| :--- | :--- | :--- | :--- |
| **Dart Format** | `dart format --output=none --set-exit-if-changed lib test` | 50 archivos analizados, 0 cambios requeridos | **APROBADO** |
| **Flutter Analyze** | `flutter analyze` | `No issues found! (ran in 7.0s)` | **APROBADO** (0 errores, 0 advertencias) |
| **Pruebas Flutter** | `flutter test` | `00:08 +78: All tests passed!` | **APROBADO** (78/78 pruebas pasadas) |
| **Pruebas Proxy Node.js** | `node --test server/test/proxy_test.js` | `pass 7, fail 0 (duration: 379ms)` | **APROBADO** (7/7 pruebas pasadas) |
| **Compilación Local APK** | `flutter build apk --release --dart-define=API_BASE_URL=...` | `√ Built build\app\outputs\flutter-apk\app-release.apk (51.6MB)` | **APROBADO** |

---

## 3. Inventario Completo de Archivos Creados y Modificados

### Archivos Creados
1. [`scripts/cargar_datos_demo.ps1`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/scripts/cargar_datos_demo.ps1): Script interactivo en PowerShell para el registro de 20 gastos demostrativos con montos ecuatorianos (USD).
2. [`.github/workflows/ci.yml`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/.github/workflows/ci.yml): Flujo de trabajo unificado de CI/CD para pruebas, análisis estático, compilación de APK y creación de GitHub Release en tags `v*`.
3. [`docs/CHECKLIST_ENTREGA.md`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/docs/CHECKLIST_ENTREGA.md): Este documento de auditoría y entrega final.
4. [`server/package.json`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/server/package.json): Configuración del proyecto Node.js nativo para el proxy.
5. [`server/.env.example`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/server/.env.example): Plantilla de variables de entorno sin secretos (`GEMINI_API_KEY`, `GEMINI_MODEL`, `PORT`).
6. [`server/server.js`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/server/server.js): Servidor proxy HTTP nativo para intermediar con Google Gemini (`GET /health`, `POST /asistente`).
7. [`server/README.md`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/server/README.md): Documentación de puesta en marcha del proxy en PowerShell.
8. [`server/test/proxy_test.js`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/server/test/proxy_test.js): Pruebas automatizadas del proxy con simulación del proveedor.
9. [`lib/controllers/assistant_controller.dart`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/lib/controllers/assistant_controller.dart): Controlador GetX del Asistente de IA.
10. [`lib/data/services/assistant_service.dart`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/lib/data/services/assistant_service.dart): Servicio de red para comunicación con el proxy de IA.
11. [`lib/views/assistant/assistant_view.dart`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/lib/views/assistant/assistant_view.dart): Vista de usuario del Asistente con advertencia y sugerencias.
12. [`test/mocks/mock_assistant_dependencies.dart`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/test/mocks/mock_assistant_dependencies.dart): Mocks para pruebas aisladas del asistente.
13. [`test/unit/assistant_controller_test.dart`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/test/unit/assistant_controller_test.dart): Pruebas unitarias de lógica y validación del asistente.
14. [`test/unit/assistant_service_test.dart`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/test/unit/assistant_service_test.dart): Pruebas unitarias del servicio de red del asistente.
15. [`test/widget/assistant_view_test.dart`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/test/widget/assistant_view_test.dart): Pruebas de renderizado y estados de la vista del asistente.

### Archivos Modificados
1. [`.gitignore`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/.gitignore): Exclusión de `.env`, `.env.local`, `server/.env`, `node_modules/` y directorios de compilación.
2. [`README.md`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/README.md): Documentación completa y reescrita en español.
3. [`android/app/src/main/AndroidManifest.xml`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/android/app/src/main/AndroidManifest.xml): Etiqueta de la aplicación corregida a `"Bolsillo Claro"`.
4. [`lib/core/config/api_config.dart`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/lib/core/config/api_config.dart): Incorporación de `ASSISTANT_BASE_URL` y endpoints.
5. [`lib/views/home/home_screen.dart`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/lib/views/home/home_screen.dart): Barra de navegación inferior con acceso a Gastos y Asistente.
6. [`lib/main.dart`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/lib/main.dart): Inyección de dependencias GetX para `AssistantService` y `AssistantController`.
7. [`test/widget/home_screen_gastos_test.dart`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/test/widget/home_screen_gastos_test.dart): Adaptación a la barra de navegación del asistente.
8. [`test/widget/auth_screens_test.dart`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/test/widget/auth_screens_test.dart): Adaptación a la barra de navegación del asistente.
9. Archivos Dart formateados con `dart format` en `lib/` y `test/`.

---

## 4. Requisitos y Verificaciones Pendientes

Los siguientes 4 puntos deben ser completados de forma manual por el estudiante o evaluador:

1. **Ejecución del Script de 20 Gastos:**
   - Iniciar el backend (`uvicorn app.main:app --port 8000`).
   - Correr `powershell -ExecutionPolicy Bypass -File scripts/cargar_datos_demo.ps1` e ingresar credenciales válidas.
2. **Consulta en Vivo con IA:**
   - Iniciar el proxy con clave propia (`$env:GEMINI_API_KEY = "..." ; node server/server.js`).
   - Realizar una consulta desde la pestaña del Asistente en el emulador Android.
3. **Captura de Pantallas (Evidencias):**
   - Tomar las 10 capturas de pantalla descritas en la sección 11 del [`README.md`](file:///D:/PracticasCursos/Modulo3/exploraec-curso/bolsillo_claro/README.md).
4. **Publicación del Release v1.0.0:**
   - Cuando se desee publicar formalmente en GitHub, ejecutar en PowerShell:
     ```powershell
     git tag -a v1.0.0 -m "Release v1.0.0: Bolsillo Claro"
     git push origin v1.0.0
     ```
