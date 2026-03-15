const http = require('node:http');
const fs = require('node:fs');
const net = require('node:net');
const path = require('node:path');

const PORT = parseInt(process.env.PORT || '18790', 10);
const GATEWAY_HOST = process.env.GATEWAY_HOST || '127.0.0.1';
const GATEWAY_PORT = parseInt(process.env.GATEWAY_PORT || '18789', 10);
const GATEWAY_TOKEN = process.env.GATEWAY_TOKEN || '';

const rawHtml = fs.readFileSync(path.join(__dirname, 'index.html'), 'utf8');
const html = rawHtml.replace('__GATEWAY_TOKEN__', GATEWAY_TOKEN);

const server = http.createServer((req, res) => {
  res.writeHead(200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'no-cache',
  });
  res.end(html);
});

server.on('upgrade', (req, clientSocket, head) => {
  if (req.url !== '/ws') {
    clientSocket.destroy();
    return;
  }

  const upstream = net.createConnection(GATEWAY_PORT, GATEWAY_HOST, () => {
    // Rebuild the upgrade request, rewriting Origin to gateway's own address
    // so it passes the allowedOrigins check
    const gatewayOrigin = `http://${GATEWAY_HOST}:${GATEWAY_PORT}`;
    let header = `GET / HTTP/${req.httpVersion}\r\n`;
    let hasOrigin = false;
    for (let i = 0; i < req.rawHeaders.length; i += 2) {
      const name = req.rawHeaders[i];
      if (name.toLowerCase() === 'origin') {
        header += `Origin: ${gatewayOrigin}\r\n`;
        hasOrigin = true;
      } else if (name.toLowerCase() === 'host') {
        header += `Host: ${GATEWAY_HOST}:${GATEWAY_PORT}\r\n`;
      } else {
        header += `${name}: ${req.rawHeaders[i + 1]}\r\n`;
      }
    }
    if (!hasOrigin) header += `Origin: ${gatewayOrigin}\r\n`;
    header += '\r\n';
    upstream.write(header);
    if (head.length) upstream.write(head);

    clientSocket.pipe(upstream);
    upstream.pipe(clientSocket);
  });

  upstream.on('error', () => clientSocket.destroy());
  clientSocket.on('error', () => upstream.destroy());
  clientSocket.on('close', () => upstream.destroy());
  upstream.on('close', () => clientSocket.destroy());
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`marcos.chat web → :${PORT}  (gateway ${GATEWAY_HOST}:${GATEWAY_PORT})`);
});
