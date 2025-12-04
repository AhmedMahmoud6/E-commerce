const express = require("express");
const {
  getProfile,
  getUserProfile,
  getAllUsersProfile,
  deleteUser,
} = require("../controllers/profile");
const router = express.Router();

router.get("/", getProfile);
router.get("/admin", getAllUsersProfile);
router.get("/:id", getUserProfile);
router.delete("/:id/admin", deleteUser);

module.exports = router;
