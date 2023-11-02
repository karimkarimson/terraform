import { readFileSync } from 'node:fs';
import { privateDecrypt } from 'node:crypto';
import { DynamoDBClient, GetItemCommand, ScanCommand, DeleteItemCommand } from "@aws-sdk/client-dynamodb"; // ES Modules import
const client = new DynamoDBClient();

const privkeybuffer = readFileSync('./privkey', (err, data) => {
    if (err) throw err;
    return data;
});

const key = {
    key: privkeybuffer,
    oaepHash: 'sha256',
    passphrase: '',
};

export const handler = async (event) => {
  const qsparam = event.queryStringParameters;
  if(!qsparam) {
    console.log("############    getting all messages       #############");
    const scanparams = {
      TableName: "burn2read",
      Select: "ALL_ATTRIBUTES",
    };
    const scancommand = new ScanCommand(scanparams);
    const scanresponse = await client.send(scancommand);
    // console.log(scanresponse);
    var allmessages = {};
    for(let i=0; i < scanresponse.Items.length; i++) {
      var item = scanresponse.Items[i];
      var element = {};
      element['UUID'] = item.UUID.S;
      element['Sender'] = item.Sender.S;
      element['Recipient'] = item.Recipient.S;
      element['date'] = item.date.S;
      // console.log(element);
      allmessages[`${i}`] = element;
    }
    //console.log(allmessages);
    return JSON.stringify(allmessages);
  }
  console.log("########### Getting one Message:  #############");
  console.log(qsparam);
  
  const readmessage = {
    TableName: "burn2read",
    Key: { 
      "UUID": {"S": qsparam.uuid},
      "Recipient": {"S": qsparam.recipient}
    },
  };
  const getcommand = new GetItemCommand(readmessage);
  
  try {
    const dbresponse = await client.send(getcommand);
    // console.log(dbresponse);
    if(!dbresponse.Item) { return {body: JSON.stringify("Message not Found")}; }

    const password = dbresponse.Item.Password.S;
    if(password !== qsparam.password) { return {body: JSON.stringify("Wrong Password")}; }
    
    const encryptedmessage = Buffer.from(JSON.parse(dbresponse.Item.message.S));
    //console.log(typeof encryptedmessage);
    // console.log(dbresponse);
    // console.log(encryptedmessage);
    
    const decryptedmessage = privateDecrypt(key, encryptedmessage);
    console.log("decrypted message " + decryptedmessage);
    //console.log(typeof decryptedmessage);
    
    //console.log("############### deleting message #################");
    
    const delcommand = new DeleteItemCommand(readmessage);
    try {
      const response = await client.send(delcommand);
      // console.log(response);
    } catch(err) {
      return {body: JSON.stringify(err)};
    }
    const response = {
    statusCode: 200,
    body: JSON.stringify(decryptedmessage.toString()),
    };
    return {response};
    // return;
  } catch (err) {
    console.log(err);
    return err;
  }
};