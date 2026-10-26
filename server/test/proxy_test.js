const { test, describe, before, after } = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');

describe('Bolsillo Claro AI Proxy - Suite de Pruebas', () => {
  let mockGeminiServer;
  let mockGeminiPort;
  let proxyServer;
  let proxyPort;

  let geminiResponseStatus = 200;
  let geminiResponseBody = {};
  let geminiResponseDelayMs = 0;

  before(async () => {
    // 1. Iniciar un servidor simulado de Gemini API
    mockGeminiServer = http.createServer((req, res) => {
      setTimeout(() => {
        res.writeHead(geminiResponseStatus, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(geminiResponseBody));
      }, geminiResponseDelayMs);
    });

    await new Promise((resolve) => {
      mockGeminiServer.listen(0, () => {
        mockGeminiPort = mockGeminiServer.address().port;
        resolve();
      });
    });

    // 2. Configurar variables para apuntar al servidor simulado
    process.env.GEMINI_BASE_URL = `http://localhost:${mockGeminiPort}`;
    process.env.GEMINI_API_KEY = 'clave_de_prueba_123';
    process.env.GEMINI_MODEL = 'gemini-3.5-flash-lite';
    process.env.PORT = '0';

    // 3. Iniciar el servidor proxy
    const { crearServidor } = require('../server');
    proxyServer = crearServidor();
    await new Promise((resolve) => {
      proxyServer.listen(0, () => {
        proxyPort = proxyServer.address().port;
        resolve();
      });
    });
  });

  after(async () => {
    await new Promise((resolve) => proxyServer.close(resolve));
    await new Promise((resolve) => mockGeminiServer.close(resolve));
  });

  test('GET /health responde estado OK con puerto y modelo', async () => {
    const res = await fetch(`http://localhost:${proxyPort}/health`);
    assert.equal(res.status, 200);
    const data = await res.json();
    assert.equal(data.status, 'ok');
    assert.equal(data.modelo, 'gemini-3.5-flash-lite');
    assert.equal(data.tieneClave, true);
  });

  test('POST /asistente con cuerpo vacío o sin consulta responde 422', async () => {
    const res = await fetch(`http://localhost:${proxyPort}/asistente`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({}),
    });
    assert.equal(res.status, 422);
    const data = await res.json();
    assert.match(data.detail, /consulta es requerida/i);
  });

  test('POST /asistente con consulta que supera 500 caracteres responde 422', async () => {
    const res = await fetch(`http://localhost:${proxyPort}/asistente`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        consulta: 'a'.repeat(501),
      }),
    });
    assert.equal(res.status, 422);
    const data = await res.json();
    assert.match(data.detail, /máximo 500 caracteres/i);
  });

  test('POST /asistente exitoso con respuesta estructurada del proveedor', async () => {
    geminiResponseStatus = 200;
    geminiResponseDelayMs = 0;
    geminiResponseBody = {
      candidates: [
        {
          content: {
            parts: [
              {
                text: JSON.stringify({
                  respuesta: 'Has gastado más en comida este mes. Te recomiendo planificar tus comidas semanales para ahorrar.',
                }),
              },
            ],
          },
        },
      ],
    };

    const res = await fetch(`http://localhost:${proxyPort}/asistente`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        consulta: '¿En qué categoría gasto más?',
        resumen: {
          total_general: 100.0,
          categorias: [
            { categoria: 'comida', total: 70.0, cantidad: 3, disponible: 430.0 },
          ],
        },
      }),
    });

    assert.equal(res.status, 200);
    const data = await res.json();
    assert.equal(
      data.respuesta,
      'Has gastado más en comida este mes. Te recomiendo planificar tus comidas semanales para ahorrar.',
    );
  });

  test('POST /asistente traduce código 429 de cuota agotada del proveedor', async () => {
    geminiResponseStatus = 429;
    geminiResponseBody = { error: { message: 'Quota exceeded' } };

    const res = await fetch(`http://localhost:${proxyPort}/asistente`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        consulta: '¿Cómo puedo ahorrar?',
      }),
    });

    assert.equal(res.status, 429);
    const data = await res.json();
    assert.match(data.detail, /cuota de consultas/i);
  });

  test('POST /asistente traduce clave inválida (401/403) a error legible 502', async () => {
    geminiResponseStatus = 403;
    geminiResponseBody = { error: { message: 'API key not valid' } };

    const res = await fetch(`http://localhost:${proxyPort}/asistente`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        consulta: '¿Cómo puedo ahorrar?',
      }),
    });

    assert.equal(res.status, 502);
    const data = await res.json();
    assert.match(data.detail, /clave GEMINI_API_KEY no es válida/i);
  });

  test('POST /asistente traduce respuesta malformada del proveedor a 502', async () => {
    geminiResponseStatus = 200;
    geminiResponseBody = {
      candidates: [
        {
          content: {
            parts: [{ text: 'Respuesta no JSON plana' }],
          },
        },
      ],
    };

    const res = await fetch(`http://localhost:${proxyPort}/asistente`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        consulta: '¿Cómo puedo ahorrar?',
      }),
    });

    assert.equal(res.status, 502);
    const data = await res.json();
    assert.match(data.detail, /proveedor de IA/i);
  });
});
