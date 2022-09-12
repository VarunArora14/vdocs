const jwt = require("jsonwebtoken");

// verification middleware
const auth = async (req, res, next) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) {
      // there is no token
      return res.status(401).json({ msg: "no auth token, access denied." }); // unauthorized
    }

    const verified = jwt.verify(token, "passwordKey");
    if (!verified) return res.status(401).json({ msg: "Token verification failed, auth denied" });

    // if verified, we can get the user from the database
    req.user = verified.id;
    req.token = token;
    next(); // move to the next method which would be getting out of the middleware back to the function that called it
  } catch (e) {
    res.status(500).json({ err: e.message });
  }
};

module.exports = auth;
