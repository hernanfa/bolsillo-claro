# Bolsillo Claro 💰

Aplicación móvil moderna y segura desarrollada en **Flutter** para el registro, control financiero y análisis inteligente de gastos personales, orientada a la realidad económica de Ecuador (USD). Incorpora arquitectura limpia por capas, persistencia segura de credenciales, almacenamiento local y soporte offline con **Hive**, y un **Asistente Financiero con IA** conectado de forma privada a **Google Gemini** mediante un proxy HTTP propio.

---

## 1. Características Principales

- **Autenticación y Sesión Segura:**
  - Registro de usuarios y login por formulario (`application/x-www-form-urlencoded`).
  - Almacenamiento cifrado de tokens JWT mediante `flutter_secure_storage`.
  - Restauración automática de sesión al abrir la app (`/usuarios/me`).
  - Cierre de sesión con purga completa de datos locales y credenciales.
- **Gestión Integral de Gastos (CRUD):**
  - Listado de transacciones con soporte de paginación (`skip`, `limit`) y recarga por deslizamiento (*pull-to-refresh*).
  - Creación y edición de gastos con validaciones en tiempo real (monto mayor a cero, máximo dos decimales, descripción obligatoria).
  - Eliminación segura con confirmación previa del usuario.
  - Prevención de doble envío durante las operaciones de guardado.
- **Filtro y Resumen Financiero:**
  - Filtrado dinámico por categorías obtenidas directamente del servidor (`comida`, `transporte`, `entretenimiento`, `otros`) y opción *"Todos"*.
  - Indicadores en tiempo real de gasto total y disponibilidad por categoría calculados por el endpoint oficial `/gastos/resumen` del backend.
- **Persistencia Local y Modo Offline (Hive):**
  - Almacenamiento local en cajas aisladas por ID de usuario (`gastos_user_<id>`), garantizando estricta separación multiusuario.
  - Disponibilidad de datos y banner informativo con la última hora de sincronización ante caídas de red, timeouts o errores 5xx del servidor.
  - No simula escrituras sin conexión para evitar desincronizaciones de datos.
- **Tema Personalizable:**
  - Selector de tema **Claro** y **Oscuro** con persistencia en Hive que sobrevive al reinicio de la aplicación.
  - Paleta visual corporativa propia basada en **Azul Oscuro** (`#0F2942`) y **Verde Esmeralda** (`#10B981`).
- **Asistente de IA Financiero:**
  - Interfaz conversacional con chips de preguntas sugeridas sobre ahorro y distribución del gasto.
  - Privacidad estricta: únicamente se envían al proxy la consulta del usuario y los totales agrupados por categoría. **Nunca se transmiten correos, contraseñas, tokens ni descripciones individuales de gastos**.
  - Servidor proxy HTTP Node.js dedicado que resguarda la clave `GEMINI_API_KEY` fuera del cliente móvil.

---

## 2. Arquitectura de la Aplicación

El proyecto sigue una arquitectura en capas desacoplada y mantenible:

$$\text{Vistas (Views/Pages)} \longrightarrow \text{Controladores (GetX)} \longrightarrow \text{Repositorios / Servicios} \longrightarrow \text{Clientes HTTP / Almacenamiento}$$

```
bolsillo_claro/
├── android/                   # Configuración nativa de Android (package: ec.hernanfa.bolsillo_claro)
├── lib/
│   ├── controllers/           # Controladores GetX (Auth, Gastos, Assistant)
│   ├── core/
│   │   ├── config/            # Endpoints y configuración de entorno (ApiConfig)
│   │   ├── errors/            # Excepciones de dominio y parseo de errores Dio
│   │   ├── network/           # Cliente ApiClient con interceptor Bearer y timeouts
│   │   ├── storage/           # Servicios de almacenamiento (SecureStorage, HiveCache, Settings)
│   │   └── theme/             # Colores, estilos y ThemeController
│   ├── data/
│   │   ├── models/            # Modelos JSON y DTOs (User, Token, Gasto, Resumen, Categorias)
│   │   ├── repositories/      # Repositorios de datos (AuthRepository, GastosRepository)
│   │   └── services/          # Clientes de servicios externos (AssistantService)
│   ├── routes/                # Enrutamiento GetPages y rutas nombradas
│   ├── views/                 # Pantallas (Auth, Home/Gastos, Assistant, Splash)
│   └── main.dart              # Inicialización de Flutter, Hive e inyección de dependencias GetX
├── server/                    # Servidor Proxy Node.js para Google Gemini
│   ├── package.json           # Configuración del paquete y scripts
│   ├── server.js              # Proxy HTTP con endpoints /health y /asistente
│   ├── .env.example           # Plantilla de variables de entorno sin secretos
│   └── test/                  # Suite de pruebas automatizadas del proxy
├── scripts/
│   └── cargar_datos_demo.ps1  # Script PowerShell para registrar 20 gastos de prueba
├── docs/
│   └── CHECKLIST_ENTREGA.md   # Control de requisitos y verificaciones de entrega
└── test/                      # Suite de pruebas unitarias y de widgets con mocks
```

---

## 3. Requisitos Previos

- **Sistema Operativo:** Windows 10/11 con PowerShell 5.1 o PowerShell 7+.
- **Flutter SDK:** Versión 3.27+ o canal estable compatible con Dart 3.5+.
- **Java Development Kit (JDK):** Versión 17.
- **Android Studio:** Con emulador Android configurado y funcionando.
- **Node.js:** Versión 18.0.0 o superior (para ejecutar el proxy de IA).
- **Backend FastAPI:** Proyecto `proyecto-curso-spec-kit` ejecutándose en el puerto `8000`.

---

## 4. Configuración y Ejecución del Entorno

### Paso 1: Iniciar el Backend FastAPI
Asegúrate de tener en ejecución el backend oficial del curso en el puerto `8000`:
```powershell
# En la carpeta del backend (../proyecto-curso-spec-kit)
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
> [!NOTE]
> Puedes verificar que el backend responda accediendo a `http://localhost:8000/docs` o `http://localhost:8000/openapi.json`.

---

### Paso 2: Configurar y Arrancar el Proxy del Asistente (Node.js)
El proxy protege tu clave de Gemini y la mantiene exclusivamente en el entorno del servidor:

1. Dirígete a la carpeta `server/`:
   ```powershell
   cd server
   ```
2. Obtén una clave de API gratuita en [Google AI Studio](https://aistudio.google.com/apikey).
3. Asigna la variable de entorno en tu sesión de PowerShell y arranca el servidor:
   ```powershell
   $env:GEMINI_API_KEY = "tu_clave_de_gemini_aqui"
   # Opcional: $env:GEMINI_MODEL = "gemini-3.5-flash-lite"
   # Opcional: $env:PORT = "3000"
   node server.js
   ```
4. Comprueba la salud del proxy abriendo otra terminal de PowerShell:
   ```powershell
   Invoke-RestMethod http://localhost:3000/health
   ```
   *Debe responder un objeto JSON con `status: "OK"`.*

---

### Paso 3: Ejecutar la Aplicación Móvil en el Emulador Android
Desde la raíz del proyecto `bolsillo_claro/`:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000 --dart-define=ASSISTANT_BASE_URL=http://10.0.2.2:3000
```

> [!IMPORTANT]
> - La dirección IP `10.0.2.2` es el alias que utiliza el emulador de Android oficial para comunicarse con el `localhost` de tu máquina Windows anfitriona.
> - Si ejecutas la app en un dispositivo físico conectado por USB o Wi-Fi, reemplaza `10.0.2.2` por la dirección IP local de tu computadora en tu red LAN (por ejemplo, `http://192.168.1.50:8000`).

---

## 5. Carga de los 20 Registros Demostrativos

Para poblar rápidamente tu usuario de pruebas con datos realistas para Ecuador (con montos en USD distribuidos en comida, transporte, entretenimiento y otros):

1. Regístrate e inicia sesión desde la app o asegúrate de tener una cuenta creada en el backend.
2. Ejecuta el script interactivo desde PowerShell:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/cargar_datos_demo.ps1
   ```
3. El script solicitará tu correo y contraseña de manera interactiva sin guardar contraseñas ni tokens en disco ni mostrarlos en pantalla.
4. Tras registrar los 20 gastos en la API pública, desliza hacia abajo en la pantalla principal de la app para ver el listado y el nuevo resumen por categorías.

---

## 6. Pruebas Automatizadas y Calidad de Código

El proyecto cuenta con una cobertura completa de pruebas que no requieren backend, conexión a internet ni consumo de cuota de Gemini:

```powershell
# 1. Verificar formato del código Dart
dart format --output=none --set-exit-if-changed lib test

# 2. Análisis estático (cero errores y cero advertencias)
flutter analyze

# 3. Suite completa de pruebas unitarias y de widgets (78 pruebas)
flutter test

# 4. Pruebas del proxy Node.js (7 pruebas con simulación HTTP del proveedor)
node --test server/test/proxy_test.js
```

---

## 7. Compilación Manual del APK Release

Para generar el archivo ejecutable instalable en modo Release:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:8000 --dart-define=ASSISTANT_BASE_URL=http://10.0.2.2:3000
```

El APK resultante se encontrará en:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 8. Integración Continua (CI/CD) y Publicación de Releases

El archivo [`.github/workflows/ci.yml`](file:///.github/workflows/ci.yml) gestiona el ciclo completo de integración y despliegue continuo:
- **En cada `push` y `pull_request` a `main`:**
  - Ejecuta las pruebas del proxy sin consumir API Keys.
  - Verifica el formato de código con `dart format`.
  - Corre el linter con `flutter analyze`.
  - Ejecuta las 78 pruebas con `flutter test`.
  - Compila el APK Release y lo almacena como artefacto de GitHub Actions (`bolsillo-claro-apk`).
- **En etiquetas de versión (`v*`):**
  - Al recibir una etiqueta como `v1.0.0`, el workflow compila el APK y crea automáticamente un **GitHub Release** oficial adjuntando `app-release.apk`.

### Comandos de PowerShell para publicar la versión v1.0.0:
```powershell
# 1. Asegúrate de que todos los cambios estén limpios
git status

# 2. Crea la etiqueta anotada v1.0.0
git tag -a v1.0.0 -m "Release v1.0.0: Autenticacion, CRUD de gastos, cache offline Hive y Asistente IA"

# 3. Publica la etiqueta en GitHub (esto disparará el release automático)
git push origin v1.0.0
```

---

## 9. Seguridad y Manejo de Secretos

- **Prohibido incluir claves en el código:** Nunca se deben hardcodear tokens ni credenciales en archivos Dart.
- **Exclusión en Control de Versiones:** El archivo `.gitignore` excluye `.env`, `.env.local` y los módulos de dependencias (`node_modules/`).
- **Configuración mediante Entorno:** El proxy recibe su clave mediante variable de entorno de sistema o archivo `.env` local no versionado, mientras que la app móvil solo recibe URLs base mediante `--dart-define`.

---

## 10. Créditos y Referencias

- **Backend del Curso:** Proporcionado en `../proyecto-curso-spec-kit` (FastAPI + SQLite/PostgreSQL).
- **Referencia del Proxy:** Arquitectura de proxy inverso inspirada en la estructura modular de `../exploraec/mock-server`, adaptada con validaciones de carga, sanitización y el modelo verificado `gemini-3.5-flash-lite`.

---

## 11. Lista de Evidencias y Capturas de Pantalla (Pendientes para Entrega)

El estudiante debe tomar y adjuntar las siguientes capturas del emulador Android para documentar su entrega final:

1. **Pantalla de Registro e Inicio de Sesión:** Mostrando el diseño corporativo en azul oscuro y verde con los campos validados.
2. **Pantalla Principal con los 20 Gastos:** Visualización del listado completo tras ejecutar `cargar_datos_demo.ps1`.
3. **Tarjeta de Resumen Financiero:** Mostrando el total general y las barras de progreso/disponibilidad por categoría.
4. **Filtro de Gastos en Acción:** Demostración del filtro activo por categoría (ej. categoría *Comida* o *Transporte*).
5. **Formulario de Registro/Edición de Gasto:** Mostrando las validaciones de monto y descripción.
6. **Diálogo de Confirmación de Borrado:** Diálogo solicitando confirmación antes de eliminar un gasto.
7. **Asistente de IA en Funcionamiento:** Respuesta generada por la IA tras seleccionar una pregunta sugerida o consulta libre.
8. **Interfaz en Modo Oscuro:** Captura de la aplicación con el tema oscuro activado.
9. **Modo Sin Conexión (Caché Hive):** Aviso de datos guardados y fecha de sincronización tras detener el backend.
10. **GitHub Actions y Release:** Captura del pipeline de CI exitoso y la pestaña de Releases en GitHub con el APK `app-release.apk` disponible para descarga.
