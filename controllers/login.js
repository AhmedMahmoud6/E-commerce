const User = require("../model/users");
const { handleError } = require("../responses/errors");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");

const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email) return handleError(res, 422, "Email is missing");
    if (!password) return handleError(res, 422, "Password is missing");

    const emailRegex = /^\w+([.-]?\w+)@\w+([.-]?\w+)(.\w{2,3})+$/;
    if (!emailRegex.test(email)) {
      return handleError(res, 422, "Invalid email format");
    }

    const passwordRegex =
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$/;
    if (!passwordRegex.test(password)) {
      return handleError(
        res,
        422,
        "Password must contain at least 1 uppercase, 1 lowercase, 1 number, and 1 special character"
      );
    }

    const userExists = await User.findOne({ email });

    if (!userExists) return handleError(res, 404, "User not found");

    const isMatch = await bcrypt.compare(password, userExists.password);

    if (!isMatch) return handleError(res, 400, "Invalid credentials");

    const token = jwt.sign({ userId: userExists._id }, process.env.JWT_SECRET);

    return res.status(200).json({ message: "Login successful", token });
  } catch (err) {
    console.error("Error logging in:", err);
    return handleError(res, 500, "Server Error");
  }
};

module.exports = loginUser;
