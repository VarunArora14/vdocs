const express = require("express");
const { default: mongoose } = require("mongoose");
const authRouter = require("./routes/router");
const dbUrl = require("./db_url");
const cors = require("cors"); // xml http request error without this line
// const mongoose = require("mongoose");

// initialise express and store in app variable
const app = express();

app.use(cors()); // use cors() not cors otherwise same error
app.use(express.json()); // parse json data from the body of the request, otherwise we cannot get userName and others from the body of the request, initialize it before the routes
app.use(authRouter); // add this to the app otherwise the API wouldnt work as it needs to know where to look for the API
const PORT = process.env.PORT || 5000; // our server running on port 3000 so we run 5000 here

mongoose
  .connect(dbUrl) // use private and gitignore dbUrl and once connected, we use .then() to decide what to do when the connection is set
  .then(() => console.log("database connection successful"))
  .catch((err) => console.log(err));
// here connect() is like a promise it will connect like async and await for Future in dart to resolve it
// or if u are outside the function then we use .then((data) => print(data)) to resolve it with data as a parameter

// here "0.0.0.0" means it can be accessed from any device on the network
app.listen(PORT, "0.0.0.0", () => console.log(`server has started on port ${PORT}`));

// unless you start the server, the app will not run as it has to find the user from the database
// mongoDB, otherwise you will get XMLhttprequest error
