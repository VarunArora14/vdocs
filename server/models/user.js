const mongoose = require("mongoose");

// schema of the user model in the database
const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
  },
  profilePic: {
    type: String,
    required: true,
  },
});

// create model based on schema, model name is User
const User = mongoose.model("User", userSchema);
module.exports = User; // export this to auth js file
