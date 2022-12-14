const express = require("express");
const { default: mongoose } = require("mongoose");
const Document = require("../server/models/document");
const authRouter = require("./routes/router");
const http = require("http"); // http for connecting to server for scoket later
const dbUrl = require("./hidden/db_url");
const cors = require("cors"); // xml http request error without this line
const documentRouter = require("./routes/document");
// const mongoose = require("mongoose");

// initialise express and store in app variable
const app = express();
var server = http.createServer(app); // create a server using http and express
var socket = require("socket.io"); // now do socket connection and call function for io
var io = socket(server); // pass the server to socket

app.use(cors()); // use cors() not cors otherwise same error
app.use(express.json()); // parse json data from the body of the request, otherwise we cannot get userName and others from the body of the request, initialize it before the routes
app.use(authRouter); // add this to the app otherwise the API wouldnt work as it needs to know where to look for the API
app.use(documentRouter); // router for documents
const PORT = process.env.PORT || 5000; // our server running on port 3000 so we run 5000 here

mongoose
  .connect(dbUrl) // use private and gitignore dbUrl and once connected, we use .then() to decide what to do when the connection is set
  .then(() => console.log("database connection successful"))
  .catch((err) => console.log(err));
// here connect() is like a promise it will connect like async and await for Future in dart to resolve it
// or if u are outside the function then we use .then((data) => print(data)) to resolve it with data as a parameter

io.on("connection", (s) => {
  s.on("join", (documentId) => {
    s.join(documentId); // join the room
    console.log("joined room " + documentId);
  });
  // console.log("connected to socket" + s.id); // s is the socket passed to the function

  s.on("typing", (data) => {
    // we want to send the data to all the users in same room except the current user making changes to it
    s.broadcast.to(data.room).emit("changes", data); // broadcast to all the users in the room
    // here we send data from server to client side
  });

  s.on("save", (data) => {
    saveData(data); // method to async save new document content to the database
    // use broadcast to send to all the users in the room except current. io.to() to send to all the users in the room
    // s.to() to send changes to current user only
  });
});

// creating outside the "save" to make it look cleaner
const saveData = async (data) => {
  let document = await Document.findById(data.room); // get document by id as room and match value with map names of autoSave()
  document.content = data.delta; // save the content of document as delta
  document = await document.save();
};

// here "0.0.0.0" means it can be accessed from any device on the network
server.listen(PORT, "0.0.0.0", () => console.log(`server has started on port ${PORT}`));
// listen on this server for socket connection

// unless you start the server, the app will not run as it has to find the user from the database
// mongoDB, otherwise you will get XMLhttprequest error
