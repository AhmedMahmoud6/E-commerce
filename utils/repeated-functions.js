const jwt = require("jsonwebtoken");
const { handleError } = require("../responses/errors");

const verifyJWT = (req, res) => {
  const authHeader = req.headers["authorization"];
  if (!authHeader)
    return handleError(res, 401, "Authorization token is missing");

  const decoded = jwt.verify(authHeader, process.env.JWT_SECRET);
  const user_id = decoded.userId;

  return user_id;
};

module.exports = { verifyJWT };
