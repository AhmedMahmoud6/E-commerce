const User = require("../model/users");
const Cart = require("../model/carts");
const Wishlist = require("../model/wishlist");
const { handleSingleJSON } = require("../responses/success");
const bcrypt = require("bcryptjs");
const { handleError } = require("../responses/errors");

const registerUser = async (req, res) => {
  try {
    const userCredentials = req.body;
    const userExists = await User.findOne({ email: userCredentials.email });

    if (userExists) return handleError(res, 400, "User already exists");

    const hashedPassword = await bcrypt.hash(userCredentials.password, 10);

    userCredentials.password = hashedPassword;

    const newUser = await User.create(userCredentials);

    const newUserId = newUser._id.toString();

    if (userCredentials.role === "member") {
      await Cart.create({
        user_id: newUserId,
      });

      await Wishlist.create({
        user_id: newUserId,
      });
    }

    return handleSingleJSON(res, 201, newUser, "User registered successfully");
  } catch (err) {
    console.error("Failed to register user", err);
    return handleError(res, 500, "Server Error");
  }
};

module.exports = registerUser;
