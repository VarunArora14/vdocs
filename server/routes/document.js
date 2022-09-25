const express = require("express");
const Document = require("../models/document");
const documentRouter = express.Router();
const auth = require("../middleware/auth");

documentRouter.post("/doc/create", auth, async (req, res) => {
  try {
    const { createdAt } = req.body;
    // create a new deocument object
    let document = new Document({
      uid: req.user, // passed from auth
      title: "Untitled document", // initial name
      createdAt, // passed on from req body based on current time
      // content: "", // emptydoc at start
    });
    // save the document to the database
    document = await document.save();
    res.json(document);
    console.log(document);
  } catch (e) {
    res.status(500).json({ error: e.message });
    console.log(e.message);
  }
});

documentRouter.get("/docs/me", auth, async (req, res) => {
  try {
    let documents = await Document.find({ uid: req.user }); // find all documents created by me
    res.json(documents); // sends the list of documents of current user
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = documentRouter;
