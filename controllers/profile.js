const User = require("../model/users");
const jwt = require("jsonwebtoken");

const getProfile = async (req, res) => {
  try {
    const authHeader = req.headers["authorization"];

    if (!authHeader) {
      return res
        .status(401)
        .json({ message: "Authorization token is missing" });
    }

    const decoded = jwt.verify(authHeader, process.env.JWT_SECRET);
    const profileId = decoded.userId;

    const profile = await User.findById(profileId);
    console.log("Profile: ", profile);

    if (!profile) {
      return res.status(404).json({ message: "Profile not found" });
    }
    const { username, email, address, role, created_at } = profile;

    return res.status(200).json({
      username,
      email,
      address,
      role,
      created_at,
    });
  } catch (err) {
    console.error("Failed to load profile:", err);
    return res.status(500).json({
      message: "Failed to load profile",
      error: err.message || err.toString(),
    });
  }
};

const getUserProfile = async (req, res) => {
  try {
    const userId = req.params.id;
    const profile = await User.findById(userId);

    if (!profile) {
      return res.status(404).json({ message: "Profile not found" });
    }

    const { username, email, address, role, created_at } = profile;

    return res.status(200).json({
      username,
      email,
      address,
      role,
      created_at,
    });
  } catch (err) {
    console.error("Failed to load profile:", err);
    return res.status(500).json({
      message: "Failed to load profile",
      error: err.message || err.toString(),
    });
  }
};

module.exports = { getProfile, getUserProfile };
