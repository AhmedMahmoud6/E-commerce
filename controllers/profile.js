const { handleError } = require("../responses/errors");
const {
  handleJSON,
  handleSingleJSON,
  handlePaginated,
} = require("../responses/success");
const User = require("../model/users");
const { verifyJWT } = require("../utils/repeated-functions");
const mongoose = require("mongoose");
const Product = require("../model/products");
const Order = require("../model/orders");
const Cart = require("../model/carts");
const Wishlist = require("../model/wishlist");

const getProfile = async (req, res) => {
  try {
    const profileId = req.userId || verifyJWT(req, res);
    if (!profileId) return;

    const profile = await User.findById(profileId);
    console.log("Profile: ", profile);

    if (!profile) {
      return handleError(res, 404, "Profile not found");
    }

    return handleSingleJSON(res, 200, profile, "profile loaded");
  } catch (err) {
    console.error("Failed to load profile:", err);
    return handleError(res, 500, "Failed to load profile");
  }
};

const getUserProfile = async (req, res) => {
  try {
    const userId = req.params.id;

    if (!userId) return handleError(res, 422, "User id is missing");

    const profile = await User.findById(userId);

    if (!profile) return handleError(res, 404, "Profile not found");

    const { username, email, address, role, profile_url, created_at } = profile;

    return handleSingleJSON(
      res,
      200,
      {
        username,
        email,
        address,
        role,
        profile_url,
        created_at,
      },
      "profile loaded"
    );
  } catch (err) {
    console.error("Failed to load profile:", err);
    return handleError(res, 500, "Failed to load profile");
  }
};

const getAllUsersProfile = async (req, res) => {
  try {
    const user_id = req.userId || verifyJWT(req, res);
    if (!user_id) return;

    const user = await User.findById(user_id);

    if (user.role !== "admin")
      return handleError(
        res,
        403,
        "Access Denied: You do not have permission to perform this action"
      );

    const { search, limit, page } = req.query;

    const limitResults = Math.abs(parseInt(limit)) || 10;
    const pageNumber = Math.abs(parseInt(page)) || 1;

    const skip = (pageNumber - 1) * limitResults;

    const searchQuery = search
      ? { username: { $regex: `^${search}`, $options: "i" } }
      : {};

    const allUsers = await User.find(searchQuery)
      .skip(skip)
      .limit(limitResults);

    const totalUsers = await User.countDocuments(searchQuery);

    const totalPages = Math.ceil(totalUsers / limitResults);

    console.log(pageNumber);

    if (allUsers.length === 0) return handleError(res, 404, "No results found");

    if (pageNumber < 1 || pageNumber > totalPages)
      return handleError(
        res,
        400,
        `Page ${pageNumber} is out of range. Please select a valid page between 1 and ${totalPages}.`
      );

    if (!allUsers) return handleError(res, 200, "Users not found.");

    return handlePaginated(
      res,
      200,
      allUsers,
      totalUsers,
      totalPages,
      pageNumber,
      "Users fetched"
    );
  } catch (err) {
    console.error("Error fetching users", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

const deleteUser = async (req, res) => {
  // Try transactional delete first. If the Mongo deployment does not support
  // transactions (e.g., standalone server), fall back to non-transactional
  // sequential deletes so the admin action still succeeds.
  let session;
  try {
    session = await mongoose.startSession();
    session.startTransaction();

    const user_id = req.userId || verifyJWT(req, res);
    if (!user_id) return;

    const user = await User.findById(user_id);

    if (user.role !== "admin")
      return handleError(
        res,
        403,
        "Access Denied: You do not have permission to perform this action"
      );

    const selectedUserId = req.params.id;

    if (!selectedUserId) return handleError(res, 400, "User id is missing");

    // Load the selected user within the same session so we can decide what to delete
    const selectedUser = await User.findById(selectedUserId).session(session);
    if (!selectedUser) return handleError(res, 404, "User not found.");

    // If the selected user is a merchant, delete their products
    if (selectedUser.role === "merchant") {
      await Product.deleteMany({ merchant_id: selectedUserId }).session(
        session
      );
    }

    // If the selected user is a member, delete their cart and wishlist
    if (selectedUser.role === "member") {
      await Cart.deleteMany({ user_id: selectedUserId }).session(session);
      await Wishlist.deleteMany({ user_id: selectedUserId }).session(session);
    }

    // Delete orders made by this user (applies to members and any other role that may have orders)
    await Order.deleteMany({ user_id: selectedUserId }).session(session);

    // Finally delete the user record
    await User.findByIdAndDelete(selectedUserId).session(session);

    await session.commitTransaction();
    session.endSession();

    return handleSingleJSON(
      res,
      200,
      selectedUser,
      "User and related data deleted successfully"
    );
  } catch (err) {
    // If transaction failed (e.g., transactions not supported), log and fall back
    console.error(
      "Transactional delete failed, falling back to non-transactional delete:",
      err
    );
    try {
      if (session) {
        try {
          await session.abortTransaction();
        } catch (_) {}
        session.endSession();
      }

      const user_id = req.userId || verifyJWT(req, res);
      if (!user_id) return;

      const user = await User.findById(user_id);

      if (user.role !== "admin")
        return handleError(
          res,
          403,
          "Access Denied: You do not have permission to perform this action"
        );

      const selectedUserId = req.params.id;
      if (!selectedUserId) return handleError(res, 400, "User id is missing");

      const selectedUser = await User.findById(selectedUserId);
      if (!selectedUser) return handleError(res, 404, "User not found.");

      // Non-transactional deletes (best-effort)
      if (selectedUser.role === "merchant") {
        await Product.deleteMany({ merchant_id: selectedUserId });
      }
      if (selectedUser.role === "member") {
        await Cart.deleteMany({ user_id: selectedUserId });
        await Wishlist.deleteMany({ user_id: selectedUserId });
      }
      await Order.deleteMany({ user_id: selectedUserId });
      await User.findByIdAndDelete(selectedUserId);

      return handleSingleJSON(
        res,
        200,
        selectedUser,
        "User and related data deleted successfully (non-transactional)"
      );
    } catch (err2) {
      console.error("Error Deleting User", err2);
      return handleError(res, 500, "Failed to delete user and related data");
    }
  }
};

module.exports = { getProfile, getUserProfile, getAllUsersProfile, deleteUser };
