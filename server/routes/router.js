const express = require("express");
const User = require("../models/user");
const jwt = require("jsonwebtoken");
const authRouter = express.Router();
const auth = require("../middleware/auth");

// instead of app we use authRouter for get, post, put, delete

// api using express, since we initialized it using app=express(), we use app for API calls

// this is a post request, we are sending data to the server, has to be async
authRouter.post("/api/signup", async (req, res) => {
  try {
    // here we use the body of the request, not headers as they are mainly for the tokens
    // get the name, email, profilePic from the body of the request
    console.log(req.body);
    const { username, email, profilePicUrl } = req.body;

    // check if email exists in the database
    let currUser = await User.findOne({ email: email }); // email database matches the email in req.body, returns a promise
    if (currUser == null) {
      // user does not exists, create a new user
      currUser = new User({ name: username, email: email, profilePic: profilePicUrl });
      currUser = await currUser.save(); // save the user to the database and return the promise in currUser
      // it also generates a id for the user(hover and see the last description of the variable)
    }

    // consider jwt like wrapper around info
    const token = jwt.sign({ id: currUser._id }, "passwordKey"); // sign the id and use this token to authenticate the user

    // if user exists, return the user as json object
    res.json({ user: currUser, token: token }); // send token as well in object as json
  } catch (e) {
    console.log(e);
    res.status(500).json({ error: e.message }); // cant send res.json() as it has default code 200
  }
});

authRouter.get("/", auth, async (req, res) => {
  const user = await User.findById(req.user); // middleare stores id of user in req.user
  res.json({ user, token: req.token });
});

module.exports = authRouter;

// with req u can access header, body, params, query of the request from the client side
// with res u can send response to the client side
