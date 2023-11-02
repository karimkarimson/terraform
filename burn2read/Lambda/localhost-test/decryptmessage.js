const fs = require('fs');
const crypto = require('crypto');

const privkeybuffer = fs.readFileSync('./privkey', (err, data) => {
    if (err) throw err;
    return data;
});

const encryptedmessage = fs.readFileSync('./message', (err, data) => {
    if (err) throw err;
    return data;
});
// const encryptedmessage = Buffer.from(b64uEncryptedmessage, 'base64url');
// console.log("encrypted message " + encryptedmessage);

const key = {
    key: privkeybuffer,
    oaepHash: 'sha256',
    passphrase: '',
};

// console.table(encryptedmessage);
const decryptedmessage = crypto.privateDecrypt(key, encryptedmessage);
console.log("decrypted message " + decryptedmessage);
