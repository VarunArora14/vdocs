// Document model will contain the following fields:
// 1. id
// 2. title
// 3. content
// 4. created time

// create a new schema for our document data
const mongoose = require("mongoose");

const documentSchema = new mongoose.Schema({
  uid: {
    required: true,
    type: String,
  },
  created: {
    type: Number, // client passes in millisecondsSinceEpoch
    required: true,
  },
  title: {
    type: String,
    required: true,
    trim: true, // long ones can cause problems
  },
  content: {
    type: Array,
    default: [],
    // not required as empty at start so provide default
  },
});

// create document based on this
const Document = mongoose.model("Document", documentSchema); // Document is the name of the collection

module.exports = Document;
