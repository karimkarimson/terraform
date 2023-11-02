/*
* Key-Pair generation
*/

const crypto = require('crypto');
const fs = require('fs');


function generateKeyFiles() {
    console.log("generating keys");
    const keyPair = crypto.generateKeyPairSync('rsa', {
        modulusLength: 4096,
        publicKeyEncoding: {
            type: 'pkcs1',
            format: 'pem'
        },
        privateKeyEncoding: {
        type: 'pkcs1',
        format: 'pem',
        cipher: 'aes-256-cbc',
        passphrase: ''
        }
    });
       
    // Creating public key file 
    return keyPair;
}

// generate & assign keys
const keys = generateKeyFiles();
const pubKey = keys.publicKey;
const privKey = keys.privateKey;

fs.writeFileSync('./pubkey', pubKey);
fs.writeFileSync('./privkey', privKey);
/*
exports.auth_encrypt_token = asyncHandler(async (req, res, next) => {
    const token = Buffer.from(req.query.token);
    console.log("token-buffer: " + token);
    const encryptedToken = crypto.publicEncrypt(pubKey, token);
    console.log("encryptedToken " + encryptedToken.toString('base64url'));
    const jsonToken = { batToken: `${encryptedToken.toString('base64url')}` };
    res.status(200);
    res.send(JSON.stringify(jsonToken));
    next();
})

exports.auth_decrypt_token = asyncHandler(async (req, res, next) => {
    console.log("received this encrypted token: " + req.query.token);
    const token = Buffer.from(req.query.token, 'base64url');
    const decryptedToken = crypto.privateDecrypt( privKey, token);
    console.log("decryptedToken: " + decryptedToken.toString('utf8'));

    if(decryptedToken.batToken) {
        const token = validateUser(decryptedToken['batToken']);
        // send decrypted batToken
        if (token) {
            token.token = decryptedToken['batToken'];
            res.status(200);
            res.send(token);
        } else {
            res.status(401);
            res.send("Token not valid");
        };
    } else {
        res.status(401);
        res.send("couldnt find Token in data");
    };
    next();
})
*/