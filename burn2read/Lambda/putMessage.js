import { publicEncrypt, randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient();

// Import Key
// const pubkeybuffer = process.env.PUBKEY;
// console.log("#########   PUBKEY #########  ");
const pubkeybuffer = readFileSync('./pubkey', (err, data) => {
  if (err) throw err;
  return data;
});

// create Key-Object for crypto.publicEncrypt(key, buffer)
const key = {
    key: pubkeybuffer,
    oaepHash: 'sha256',
    enconding: 'base64'
};

export const handler = async (event) => {
  console.log("##############    importing data from body   ###########");
  // console.log(event);
  const body = JSON.parse(event.body);
  const sender = body.sender;
  const recipient = body.recipient;
  const password = body.password;
  const message = body.message;
  
  const encryptedmessage = publicEncrypt(key, message);
  
  const dbinput = {
  TableName: 'burn2read',
    Item: {
      'UUID': {"S": randomUUID()},
      'Recipient' : {"S": recipient},
      'Sender': {"S": sender},
      'Password': {"S": password},
      'message' : {"S": JSON.stringify(encryptedmessage.toJSON())},
      'date' : {"S": new Date().toString() }
    }
  };
  const command = new PutItemCommand(dbinput);
    try {
      const dbresponse = await client.send(command);
      console.log("###############  response from dynamodb: #################");
      console.log(dbresponse);
      const response = {
        statusCode: 200,
        body: JSON.stringify(dbresponse),
      };
      return response;
      
    } catch (err) {
      console.log(err);
      return { error: err };
    }
};
