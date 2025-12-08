const express = require("express");
const {
  getProfile,
  getUserProfile,
  getAllUsersProfile,
  deleteUser,
} = require("../controllers/profile");
const auth = require("../middleware/auth");
const router = express.Router();

router.get("/", auth, getProfile);
router.get("/admin", auth, getAllUsersProfile);
router.get("/:id", getUserProfile);
router.delete("/:id/admin", auth, deleteUser);

module.exports = router;
