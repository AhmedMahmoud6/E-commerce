const { verifyJWT } = require("../utils/repeated-functions");

// Express middleware to attach userId to `req.userId`.
// If token is missing/invalid, `verifyJWT` will send the response and return null.
const auth = (req, res, next) => {
  const userId = req.userId || verifyJWT(req, res);
  if (!userId) return; // verifyJWT already handled the response
  req.userId = userId;
  next();
};

module.exports = auth;
