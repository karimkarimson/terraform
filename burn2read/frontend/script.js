const messageInput = document.getElementById('message');
const recipientInput = document.getElementById('recipient');
const senderInput = document.getElementById('sender');
const passwordInput = document.getElementById('password');
const uuidInput = document.getElementById('uuid');

const sendButton = document.getElementById('sendmessage');
const showButton = document.getElementById('showallmessages');
const getButton = document.getElementById('getmessage');

const outputs = document.getElementById('outputs');

const baseUrl = "https://v9q4cj087h.execute-api.eu-central-1.amazonaws.com";



// Input-Validation
function handleErr(text) {
    // console.log("handling error");
    outputs.innerText= `Please enter a ${text.id}!`;
}
function validate(testvalues) {
    var validation = true;
    testvalues.forEach(element => {
        // console.log("validation element");
        // console.log(element.id);
        // console.log(element.value);
        if (element.value === "") {
            handleErr(element);
            validation = false;
        };
    });
    return validation;
}


// Fetch-Logic
async function sendMessage() {
    console.log("Sending message entrypoint");
    const sendUrl = `${baseUrl}/putmessage`;
    var validation = validate([senderInput, recipientInput, passwordInput, messageInput]);
    if (validation === false) { 
        console.log("validation failed");
        return;
    } else {
        // console.log("validation passed");
    };

    const senddata = {
        sender: senderInput.value,
        recipient: recipientInput.value,
        password: passwordInput.value,
        message: messageInput.value
    };
    try {
        console.log("sending put to dynamodb");
        const response = await fetch(sendUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(senddata)
        });
        const data = await response.json();
        // console.log(data);
        outputs.innerHTML = "";
        outputs.innerHTML = `<p>Your message was encrypted and then stored in the Letterbox</p>`;
    } catch (err) {
        handleErr(err);
        console.log(err);
    }
    console.log("handled sendmessage");
    return;
}

async function getMessage() {
    console.log("Getting message entrypoint");
    let validation = validate([uuidInput, recipientInput, passwordInput]);
    if (validation === false) {
        console.log("validation failed");
        return;
    } else {
        console.log("validation passed");
    };

    const uuidParam = uuidInput.value;
    const recipientParam = recipientInput.value;
    const passwordParam = passwordInput.value;

    const getoneUrl= `${baseUrl}/getone/?uuid=${uuidParam}&recipient=${recipientParam}&password=${passwordParam}`;
    try {
        const response = await fetch(getoneUrl, {
            method: 'GET',
        });
        outputs.innerHTML = "";
        const data = await response.json();
        // console.log(data.response.body);
        outputs.innerHTML= `<div class="mp" id="secretmessage">The Message: ${data.response.body}</div>`;
    } catch (err) {
        console.log(err);
    }
    console.log("handled getone");
    return;
}

async function showMessages() {
    console.log("showing all messages entrypoint");
    const getallUrl = `${baseUrl}/getall`;
    try{
        const response = await fetch(getallUrl, {
            method: 'GET',
        });
        const data = await response.json();
        console.log(Object.values(data));
        outputs.innerHTML = "";
        Object.values(data).forEach(element => {
            outputs.innerHTML += `<div class="messageelement mp" id=${element.UUID}></div>`;
            const retmessage = document.getElementById(element.UUID);
            retmessage.innerHTML += `<p>${element.UUID}</p>`;
            retmessage.innerHTML += `<p>Received on ${element.date}</p>`;
            retmessage.innerHTML += `<p>Recipient: ${element.Recipient}</p>`;
            retmessage.innerHTML += `<p>Sender: ${element.Sender}</p>`;
        });
    } catch (err) {
        console.log(err);
    }
    console.log("handled all messages");
    return;
}

// Event Listeners
sendButton.addEventListener('click', (event) => {
    event.preventDefault();
    (async () => await sendMessage())();
});
showButton.addEventListener('click', (event) => {
    event.preventDefault();
    (async () => await showMessages())();
});
getButton.addEventListener('click', (event) => {
    event.preventDefault();
    (async () => getMessage())();
});