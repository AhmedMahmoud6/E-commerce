const jwt = require("jsonwebtoken");
const { handleError } = require("../responses/errors");

const verifyJWT = (req, res) => {
  const authHeader = req.headers["authorization"];
  if (!authHeader) {
    handleError(res, 401, "Authorization token is missing");
    return null;
  }

  try {
    const decoded = jwt.verify(authHeader, process.env.JWT_SECRET);
    if (!decoded || !decoded.userId) {
      handleError(res, 401, "Invalid authorization token");
      return null;
    }

    return decoded.userId;
  } catch (err) {
    console.error("JWT verification failed:", err);
    handleError(res, 401, "Invalid or expired authorization token");
    return null;
  }
};

module.exports = { verifyJWT };
