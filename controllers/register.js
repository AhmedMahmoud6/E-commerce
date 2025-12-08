const User = require("../model/users");
const Cart = require("../model/carts");
const Wishlist = require("../model/wishlist");
const { handleSingleJSON } = require("../responses/success");
const bcrypt = require("bcryptjs");
const { handleError } = require("../responses/errors");

const registerUser = async (req, res) => {
  try {
    const userCredentials = req.body;

    if (!userCredentials.email)
      return handleError(res, 422, "Email is missing");
    if (!userCredentials.username)
      return handleError(res, 422, "Username is missing");
    if (!userCredentials.password)
      return handleError(res, 422, "Password is missing");
    if (!userCredentials.address)
      return handleError(res, 422, "Address is missing");
    if (!userCredentials.role) return handleError(res, 422, "Role is missing");

    const userExists = await User.findOne({ email: userCredentials.email });

    if (userExists) return handleError(res, 409, "User already exists");

    const emailRegex = /^\w+([.-]?\w+)@\w+([.-]?\w+)(.\w{2,3})+$/;
    if (!emailRegex.test(userCredentials.email)) {
      return handleError(res, 422, "Invalid email format");
    }

    const passwordRegex =
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$/;
    if (!passwordRegex.test(userCredentials.password)) {
      return handleError(
        res,
        422,
        "Password must contain at least 1 uppercase, 1 lowercase, 1 number, and 1 special character"
      );
    }

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
