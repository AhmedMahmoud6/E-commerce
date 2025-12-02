const User = require("../model/users");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");

const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    const userExists = await User.findOne({ email });

    if (!userExists) return res.status(404).json({ message: "User not found" });

    const token = jwt.sign({ userId: userExists._id }, process.env.JWT_SECRET);

    const isMatch = await bcrypt.compare(password, userExists.password);

    if (!isMatch)
      return res.status(400).json({ message: "Invalid credentials" });

    return res.status(200).json({
      message: "Login successful",
      token,
    });
  } catch (err) {
    console.error("Error logging in:", err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = loginUser;
