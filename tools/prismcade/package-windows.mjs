#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, statSync, writeFileSync, copyFileSync } from "node:fs";
import path from "node:path";

const root = process.cwd();
const registryPath = path.join(root, "data/prismcade/game-manifests.json");
const outRoot = path.join(root, "dist/prismcade-windows");
const packageRoot = path.join(outRoot, "Prismcade");
const wwwRoot = path.join(packageRoot, "www");
const zipPath = path.join(outRoot, "Prismcade-Windows.zip");

const excludeNames = new Set([
  ".git",
  ".DS_Store",
  "node_modules",
  "dist",
  "artifacts",
  "coverage",
  ".turbo"
]);

const excludeRepoPaths = new Set([
  "games/pixel-fruit-arena/assets/reference"
]);

function rel(value) {
  return path.relative(root, value).split(path.sep).join("/");
}

function readJson(file) {
  return JSON.parse(readFileSync(file, "utf8"));
}

function ensureDir(dir) {
  mkdirSync(dir, { recursive: true });
}

function copyTree(src, dest) {
  if (!existsSync(src)) throw new Error(`Missing source path: ${rel(src)}`);
  const sourceStat = statSync(src);
  if (sourceStat.isDirectory()) {
    const repoPath = rel(src);
    if (excludeNames.has(path.basename(src)) || excludeRepoPaths.has(repoPath)) return;
    ensureDir(dest);
    for (const entry of readdirSync(src)) {
      copyTree(path.join(src, entry), path.join(dest, entry));
    }
    return;
  }
  if (sourceStat.isFile()) {
    ensureDir(path.dirname(dest));
    copyFileSync(src, dest);
  }
}

function writeText(file, content) {
  ensureDir(path.dirname(file));
  writeFileSync(file, content, "utf8");
}

function unique(values) {
  return [...new Set(values.filter(Boolean))];
}

function run(command, args, options = {}) {
  const result = spawnSync(command, args, { stdio: "inherit", shell: false, ...options });
  return result.status ?? 1;
}

function runCapture(command, args, options = {}) {
  return spawnSync(command, args, { encoding: "utf8", shell: false, ...options });
}

function shellEscapePowerShell(value) {
  return `'${String(value).replaceAll("'", "''")}'`;
}

function buildLauncherSource() {
  return String.raw`using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;

class PrismcadeLauncher
{
    static string Root = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "www");

    static int Main(string[] args)
    {
        if (!Directory.Exists(Root))
        {
            Console.Error.WriteLine("Missing www folder next to Prismcade.exe.");
            Console.Error.WriteLine("Extract the full Prismcade ZIP before running.");
            Console.WriteLine("Press Enter to close.");
            Console.ReadLine();
            return 1;
        }

        int port = FindOpenPort(4173);
        TcpListener listener = new TcpListener(IPAddress.Loopback, port);
        listener.Start();

        string url = "http://127.0.0.1:" + port + "/apps/prismcade/";
        Console.Title = "Prismcade";
        Console.WriteLine("Prismcade is running.");
        Console.WriteLine("Open: " + url);
        Console.WriteLine("Close this window to stop the local launcher.");
        OpenBrowser(url);

        while (true)
        {
            TcpClient client = listener.AcceptTcpClient();
            ThreadPool.QueueUserWorkItem(_ => HandleClient(client));
        }
    }

    static int FindOpenPort(int start)
    {
        for (int port = start; port < start + 100; port++)
        {
            try
            {
                TcpListener probe = new TcpListener(IPAddress.Loopback, port);
                probe.Start();
                probe.Stop();
                return port;
            }
            catch { }
        }
        throw new Exception("No open local port found.");
    }

    static void OpenBrowser(string url)
    {
        try
        {
            ProcessStartInfo psi = new ProcessStartInfo(url);
            psi.UseShellExecute = true;
            Process.Start(psi);
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine("Could not open browser automatically: " + ex.Message);
        }
    }

    static void HandleClient(TcpClient client)
    {
        using (client)
        using (NetworkStream stream = client.GetStream())
        using (StreamReader reader = new StreamReader(stream, Encoding.ASCII, false, 8192, true))
        {
            string requestLine = reader.ReadLine();
            if (string.IsNullOrWhiteSpace(requestLine)) return;

            string[] parts = requestLine.Split(' ');
            if (parts.Length < 2)
            {
                WriteResponse(stream, 400, "text/plain; charset=utf-8", Encoding.UTF8.GetBytes("Bad Request"));
                return;
            }

            string urlPath = parts[1];
            while (!string.IsNullOrEmpty(reader.ReadLine())) { }

            if (urlPath == "/")
            {
                WriteRedirect(stream, "/apps/prismcade/");
                return;
            }

            ServePath(stream, urlPath);
        }
    }

    static void ServePath(NetworkStream stream, string urlPath)
    {
        string cleanPath = urlPath.Split('?')[0].Split('#')[0];
        cleanPath = Uri.UnescapeDataString(cleanPath).Replace('/', Path.DirectorySeparatorChar).TrimStart(Path.DirectorySeparatorChar);
        string fullPath = Path.GetFullPath(Path.Combine(Root, cleanPath));
        string fullRoot = Path.GetFullPath(Root) + Path.DirectorySeparatorChar;

        if (!fullPath.StartsWith(fullRoot, StringComparison.OrdinalIgnoreCase))
        {
            WriteResponse(stream, 403, "text/plain; charset=utf-8", Encoding.UTF8.GetBytes("Forbidden"));
            return;
        }

        if (Directory.Exists(fullPath)) fullPath = Path.Combine(fullPath, "index.html");
        if (!File.Exists(fullPath))
        {
            WriteResponse(stream, 404, "text/plain; charset=utf-8", Encoding.UTF8.GetBytes("Not Found"));
            return;
        }

        byte[] body = File.ReadAllBytes(fullPath);
        WriteResponse(stream, 200, MimeType(fullPath), body);
    }

    static void WriteRedirect(NetworkStream stream, string location)
    {
        string header = "HTTP/1.1 302 Found\r\nLocation: " + location + "\r\nContent-Length: 0\r\nConnection: close\r\n\r\n";
        byte[] bytes = Encoding.ASCII.GetBytes(header);
        stream.Write(bytes, 0, bytes.Length);
    }

    static void WriteResponse(NetworkStream stream, int status, string mime, byte[] body)
    {
        string reason = status == 200 ? "OK" : status == 400 ? "Bad Request" : status == 403 ? "Forbidden" : status == 404 ? "Not Found" : "Error";
        string header = "HTTP/1.1 " + status + " " + reason + "\r\n" +
            "Content-Type: " + mime + "\r\n" +
            "Content-Length: " + body.Length + "\r\n" +
            "Cache-Control: no-store\r\n" +
            "Connection: close\r\n\r\n";
        byte[] headerBytes = Encoding.ASCII.GetBytes(header);
        stream.Write(headerBytes, 0, headerBytes.Length);
        stream.Write(body, 0, body.Length);
    }

    static string MimeType(string file)
    {
        string ext = Path.GetExtension(file).ToLowerInvariant();
        switch (ext)
        {
            case ".html": return "text/html; charset=utf-8";
            case ".js": return "text/javascript; charset=utf-8";
            case ".mjs": return "text/javascript; charset=utf-8";
            case ".css": return "text/css; charset=utf-8";
            case ".json": return "application/json; charset=utf-8";
            case ".svg": return "image/svg+xml";
            case ".png": return "image/png";
            case ".jpg": return "image/jpeg";
            case ".jpeg": return "image/jpeg";
            case ".webp": return "image/webp";
            case ".ico": return "image/x-icon";
            case ".wasm": return "application/wasm";
            case ".md": return "text/plain; charset=utf-8";
            default: return "application/octet-stream";
        }
    }
}
`;
}

function writeLauncherFiles() {
  const sourcePath = path.join(packageRoot, "PrismcadeLauncher.cs");
  writeText(sourcePath, buildLauncherSource());

  writeText(path.join(packageRoot, "Prismcade.cmd"), `@echo off\r\nsetlocal\r\ncd /d "%~dp0"\r\nif exist Prismcade.exe (\r\n  start "" "%~dp0Prismcade.exe"\r\n) else (\r\n  echo Prismcade.exe was not built.\r\n  echo Trying Python fallback at http://127.0.0.1:4173/apps/prismcade/\r\n  start "" http://127.0.0.1:4173/apps/prismcade/\r\n  python -m http.server 4173 -d www\r\n)\r\n`);

  writeText(path.join(packageRoot, "README.txt"), `Prismcade Windows Package\r\n\r\n1. Extract the full ZIP.\r\n2. Double-click Prismcade.exe.\r\n3. Pick a game in the Prismcade catalog.\r\n\r\nIf Prismcade.exe is missing, double-click Prismcade.cmd.\r\nThe launcher starts a local-only server on 127.0.0.1 and opens the catalog in your browser.\r\nClose the Prismcade console window to stop it.\r\n`);
}

function compileLauncher() {
  if (process.platform !== "win32") {
    console.warn("Skipping Prismcade.exe compile: this script is not running on Windows.");
    return false;
  }

  const sourcePath = path.join(packageRoot, "PrismcadeLauncher.cs");
  const exePath = path.join(packageRoot, "Prismcade.exe");
  const ps = `$csc = (Get-Command csc.exe -ErrorAction SilentlyContinue).Source\nif (-not $csc) {\n  $candidate = Join-Path $env:WINDIR 'Microsoft.NET\\Framework64\\v4.0.30319\\csc.exe'\n  if (Test-Path $candidate) { $csc = $candidate }\n}\nif (-not $csc) { Write-Error 'csc.exe not found'; exit 2 }\n& $csc /nologo /target:exe /out:${shellEscapePowerShell(exePath)} ${shellEscapePowerShell(sourcePath)}\nexit $LASTEXITCODE`;
  const status = run("powershell.exe", ["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", ps]);
  if (status !== 0) throw new Error("Failed to compile Prismcade.exe");
  return existsSync(exePath);
}

function createZip() {
  rmSync(zipPath, { force: true });
  if (process.platform === "win32") {
    const ps = `Compress-Archive -Path ${shellEscapePowerShell(path.join(packageRoot, "*"))} -DestinationPath ${shellEscapePowerShell(zipPath)} -Force`;
    const status = run("powershell.exe", ["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", ps]);
    if (status !== 0) throw new Error("Failed to create Windows ZIP with Compress-Archive");
    return true;
  }

  const py = runCapture("python", ["-c", "import sys"]);
  if (py.status === 0) {
    const script = `import os, zipfile\nroot=${JSON.stringify(packageRoot)}\nout=${JSON.stringify(zipPath)}\nos.makedirs(os.path.dirname(out), exist_ok=True)\nwith zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:\n    for base, dirs, files in os.walk(root):\n        for f in files:\n            p=os.path.join(base,f)\n            z.write(p, os.path.relpath(p, root))\n`;
    const status = run("python", ["-c", script]);
    if (status !== 0) throw new Error("Failed to create ZIP with Python");
    return true;
  }

  console.warn("Skipping ZIP creation: neither Windows PowerShell nor Python zipfile path is available.");
  return false;
}

function main() {
  if (!existsSync(registryPath)) throw new Error("Missing data/prismcade/game-manifests.json");
  const registry = readJson(registryPath);
  const games = registry.games || [];
  if (!games.length) throw new Error("No Prismcade games found in manifest registry.");

  rmSync(outRoot, { recursive: true, force: true });
  ensureDir(wwwRoot);

  const requiredPaths = unique([
    "apps/prismcade",
    "apps/prismcade-creator",
    "data/prismcade",
    "docs/prismcade",
    "games/_shared",
    "packages/game-assets/manifests",
    ...games.map((game) => game.path)
  ]);

  for (const repoPath of requiredPaths) {
    copyTree(path.join(root, repoPath), path.join(wwwRoot, repoPath));
  }

  writeLauncherFiles();
  const exeBuilt = compileLauncher();
  const zipBuilt = createZip();

  for (const game of games) {
    const entry = path.join(wwwRoot, game.entrypoint);
    if (!existsSync(entry)) throw new Error(`Packaged game entrypoint missing: ${game.entrypoint}`);
  }
  if (!existsSync(path.join(wwwRoot, "apps/prismcade/index.html"))) throw new Error("Packaged Prismcade catalog missing.");
  if (!existsSync(path.join(packageRoot, "Prismcade.cmd"))) throw new Error("Fallback launcher missing.");

  console.log("Prismcade Windows package staged:", packageRoot);
  console.log("Prismcade.exe:", exeBuilt ? "built" : "not built on this platform");
  console.log("ZIP:", zipBuilt ? zipPath : "not created");
}

main();
