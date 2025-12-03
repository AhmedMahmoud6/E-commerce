const User = require("../model/users");
const jwt = require("jsonwebtoken");

const getProfile = async (req, res) => {
  try {
    const authHeader = req.headers["authorization"];
    const decoded = jwt.decode(authHeader);
    const profileId = decoded.userId;

    const profile = await User.findById(profileId);
    console.log("Profile: ", profile);
    const { username, email, address, role, created_at } = profile;

    if (!profile) {
      return res.status(404).json({ message: "Profile not found" });
    }

    return res.status(200).json({
      username,
      email,
      address,
      role,
      created_at,
    });
  } catch (err) {
    console.error("Failed to load profile:", err);
    return res
      .status(500)
      .json({ message: "Failed to load profile", error: err });
  }
};

module.exports = { getProfile };
