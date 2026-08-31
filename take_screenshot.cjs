const puppeteer = require('puppeteer');
const http = require('http');
const fs = require('fs');
const path = require('path');

// Simple static file server with cache-control headers disabled
const server = http.createServer((req, res) => {
  let filePath = path.join(__dirname, 'build', 'web', req.url === '/' ? 'index.html' : req.url);
  
  // Clean query strings/fragments
  filePath = filePath.split('?')[0].split('#')[0];

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end('Not Found');
      return;
    }
    
    // Set content type
    let ext = path.extname(filePath);
    let contentType = 'text/html';
    if (ext === '.js') contentType = 'application/javascript';
    else if (ext === '.css') contentType = 'text/css';
    else if (ext === '.json') contentType = 'application/json';
    else if (ext === '.png') contentType = 'image/png';
    else if (ext === '.jpg') contentType = 'image/jpeg';
    else if (ext === '.wasm') contentType = 'application/wasm';

    res.writeHead(200, { 
      'Content-Type': contentType,
      'Cache-Control': 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0'
    });
    res.end(data);
  });
});

const PORT = 8080;
server.listen(PORT, async () => {
  console.log(`Server running at http://localhost:${PORT}`);
  
  try {
    const browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();
    
    // Disable cache at browser level
    await page.setCacheEnabled(false);
    
    // Set viewport to mobile size (e.g. 390x844 for iPhone 13/14)
    await page.setViewport({ width: 390, height: 844, deviceScaleFactor: 2 });
    
    await page.goto(`http://localhost:${PORT}`, { waitUntil: 'networkidle0' });
    
    // Wait for the app to render completely
    await new Promise(r => setTimeout(r, 7000));
    
    const screenshotName = process.argv[2] || 'screenshot.png';
    const screenshotPath = path.join(__dirname, 'assets', 'screenshots', screenshotName);
    
    // Make sure dir exists
    const dir = path.dirname(screenshotPath);
    if (!fs.existsSync(dir)){
      fs.mkdirSync(dir, { recursive: true });
    }
    
    await page.screenshot({ path: screenshotPath });
    console.log(`Screenshot saved to ${screenshotPath}`);
    
    await browser.close();
  } catch (e) {
    console.error('Error taking screenshot:', e);
  } finally {
    server.close();
    process.exit(0);
  }
});
