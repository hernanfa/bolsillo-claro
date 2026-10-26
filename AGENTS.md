# Reglas y Estándares de Bolsillo Claro

Este documento define las directrices y normas de desarrollo para agentes y desarrolladores que trabajen en el proyecto **Bolsillo Claro**.

---

## 1. Arquitectura y Separación de Responsabilidades

El proyecto sigue estrictamente el patrón por capas:
$$\text{Pantalla (View)} \longrightarrow \text{Controlador (GetX)} \longrightarrow \text{Repositorio / Servicio} \longrightarrow \text{Cliente API / Almacenamiento}$$

- **Pantallas (Views/Pages):**
  - Responsabilidad exclusiva de construir la interfaz gráfica y reaccionar a los estados expuestos por el controlador GetX.
  - **PROHIBIDO:** Ninguna pantalla debe realizar llamadas HTTP, interactuar directamente con Dio o acceder a `flutter_secure_storage`.
  - Las acciones del usuario (taps, envíos de formulario) deben delegarse invocando métodos en su respectivo `GetxController`.

- **Controladores (GetX Controllers):**
  - Gestionan el estado reactivo (`Rx`, `Obx`, `GetxController`).
  - Orquestan la lógica de negocio y llaman a repositorios o servicios.
  - Manejan las banderas de carga (`isLoading`), mensajes de error legibles y navegación.

- **Repositorios y Servicios:**
  - Los **repositorios** abstraen el origen de los datos y transforman respuestas HTTP o almacenamiento local a entidades de dominio/modelos Dart.
  - Los **servicios** (como `ApiClient` y `StorageService`) encapsulan utilidades transversales (cliente HTTP Dio, almacenamiento seguro, interceptores).

---

## 2. Seguridad y Privacidad

- **PROHIBIDO registrar datos sensibles:** Nunca escribir en logs (`print`, `debugPrint`, `logger`) claves, contraseñas, tokens de autenticación (JWT) ni información personal identificable.
- Todos los tokens de autenticación deben persistirse exclusivamente en almacenamiento seguro (`flutter_secure_storage`), nunca en texto plano ni almacenamiento inseguro.
- La configuración de variables sensibles o URLs base se inyecta en tiempo de compilación mediante `--dart-define` (`API_BASE_URL`).

---

## 3. Control de Versiones

- **PROHIBIDO:** No ejecutar comandos que modifiquen el historial remoto o creen commits/etiquetas de manera no autorizada (`git commit`, `git push`, `git tag`).
- Mantener los cambios limpios y ordenados en el área de trabajo local.

---

## 4. Calidad de Código y Pruebas

- Antes de dar por finalizada cualquier tarea o etapa, es obligatorio verificar y asegurar que no existan errores ni advertencias:
  ```bash
  flutter analyze
  flutter test
  ```
- Todas las capas de lógica (validaciones, repositorios, controladores) deben estar respaldadas por pruebas unitarias y de widgets con dependencias simuladas (mocks/fakes), sin depender del backend en ejecución.
- Mantener consistencia en tipografía, espaciado y paleta de colores corporativa (azul oscuro y verde).
