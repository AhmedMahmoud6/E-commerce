const { handleError } = require("../responses/errors");
const User = require("../model/users");
const bcrypt = require("bcryptjs");

const registerUser = async (req, res) => {
  const { username, email, address, password, role } = req.body;

  try {
    const userExists = await User.findOne({ email });

    if (userExists) return handleError(res, 400, "User already exists");

    const hashedPassword = await bcrypt.hash(password, 10);

    await User.create({
      username,
      email,
      address,
      password: hashedPassword,
      role,
    });

    res.status(201).json({
      message: "User registered successfully",
    });
  } catch (err) {
    return handleError(res, 500, "Server Error");
  }
};

module.exports = registerUser;
