const express = require("express");
const {
  getProfile,
  getUserProfile,
  getAllUsersProfile,
  deleteUser,
} = require("../controllers/profile");
const router = express.Router();

router.get("/", getProfile);
router.get("/:id", getUserProfile);
router.get("/admin", getAllUsersProfile);
router.delete("/:id/admin", deleteUser);

module.exports = router;
