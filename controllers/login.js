const User = require("../model/users");
const { handleError } = require("../responses/errors");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");

const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    const userExists = await User.findOne({ email });

    if (!userExists) return handleError(res, 404, "User not found");

    const token = jwt.sign({ userId: userExists._id }, process.env.JWT_SECRET);

    const isMatch = await bcrypt.compare(password, userExists.password);

    if (!isMatch) return handleError(res, 400, "Invalid credentials");

    return res.status(200).json({
      message: "Login successful",
      token,
    });
  } catch (err) {
    console.error("Error logging in:", err);
    return handleError(res, 500, "Server Error");
  }
};

module.exports = loginUser;
