# Servidor Proxy del Asistente de IA — Bolsillo Claro

Servidor proxy ligero en Node.js que conecta de forma segura la aplicación móvil **Bolsillo Claro** con la API de Google Gemini para el análisis de finanzas personales y sugerencias de ahorro.

---

## 1. Seguridad y Privacidad

- **La clave nunca viaja a la app:** `GEMINI_API_KEY` reside exclusivamente en el entorno del servidor proxy.
- **Datos mínimos:** La app solo envía la pregunta y los totales consolidados por categoría (`total_general` y `categorias: [{ categoria, total, cantidad, disponible }]`). Nunca se envían descripciones de gastos, contraseñas, correos ni tokens.
- **Sin registros sensibles:** El servidor nunca imprime en logs ni almacena preguntas, respuestas, claves de API ni credenciales.
- **Sin simulación engañosa:** Si no hay clave configurada en el entorno, el proxy responde con un error claro de configuración (código `503`).

---

## 2. Configuración y Modelo de Gemini

El proxy utiliza por defecto el modelo **`gemini-3.5-flash-lite`** de Google AI Studio, verificable y configurable a través de la variable de entorno `GEMINI_MODEL`:

- `GEMINI_API_KEY`: Tu clave de API personal (obtenida gratis en [Google AI Studio](https://aistudio.google.com/apikey)).
- `GEMINI_MODEL`: Identificador del modelo (por defecto `gemini-3.5-flash-lite`).
- `PORT`: Puerto de escucha local (por defecto `3000`).

---

## 3. Instrucciones de Inicio en Windows (PowerShell)

1. Abre una terminal de PowerShell y navega al directorio del servidor:
   ```powershell
   cd server
   ```

2. Configura tu clave de Gemini e inicia el proxy:
   ```powershell
   $env:GEMINI_API_KEY = "tu_clave_de_gemini_aqui"
   node server.js
   ```

3. (Opcional) Si deseas especificar un modelo alternativo:
   ```powershell
   $env:GEMINI_MODEL = "gemini-3.5-flash-lite"
   node server.js
   ```

4. Para verificar que el proxy esté activo y saludable:
   ```powershell
   Invoke-RestMethod -Uri "http://localhost:3000/health"
   ```
   Respuesta esperada:
   ```json
   {
     "status": "ok",
     "puerto": 3000,
     "modelo": "gemini-3.5-flash-lite",
     "tieneClave": true
   }
   ```

Desde el emulador de Android, la app se conectará automáticamente a:
```text
http://10.0.2.2:3000
```

---

## 4. Ejecución de Pruebas del Proxy

El servidor cuenta con pruebas automatizadas que emplean un servidor simulado de Gemini para verificar validaciones, timeouts y códigos de error sin consumir cuota real:

```powershell
npm test
```
o bien:
```powershell
node --test test/proxy_test.js
```
