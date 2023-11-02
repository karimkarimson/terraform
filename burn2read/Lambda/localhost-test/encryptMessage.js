const crypto = require('crypto');
const fs = require('fs');

var pubkeybuffer = fs.readFileSync('./pubkey', (err, data) => {
    if (err) throw err;
    return data;
});

const key = {
    key: pubkeybuffer,
    oaepHash: 'sha256',
    enconding: 'base64'
};

const message = "some the other side blas difadf bjerli blub blub dklkjkeee";

const encryptedmessage = crypto.publicEncrypt(key, message);
const b64uMessage = encryptedmessage;
// .toString('base64url');

// console.log("encrypted message " + encryptedmessage.toString('base64url'));

fs.writeFileSync('./message', b64uMessage);