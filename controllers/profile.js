const { handleError } = require("../responses/errors");
const { handleJSON } = require("../responses/success");
const User = require("../model/users");
const jwt = require("jsonwebtoken");

const getProfile = async (req, res) => {
  try {
    const authHeader = req.headers["authorization"];

    if (!authHeader)
      return handleError(res, 401, "Authorization token is missing");

    const decoded = jwt.verify(authHeader, process.env.JWT_SECRET);
    const profileId = decoded.userId;

    const profile = await User.findById(profileId);
    console.log("Profile: ", profile);

    if (!profile) {
      return handleError(res, 404, "Profile not found");
    }
    const { username, email, address, role, profile_url, created_at } = profile;

    return handleJSON(
      res,
      200,
      { username, email, address, role, profile_url, created_at },
      "profile loaded"
    );
  } catch (err) {
    console.error("Failed to load profile:", err);
    return handleError(res, 500, "Failed to load profile");
  }
};

const getUserProfile = async (req, res) => {
  try {
    const userId = req.params.id;
    const profile = await User.findById(userId);

    if (!profile) return handleError(res, 404, "Profile not found");

    const { username, email, address, role, profile_url, created_at } = profile;

    return handleJSON(
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

module.exports = { getProfile, getUserProfile };
