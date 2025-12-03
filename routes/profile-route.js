const express = require("express");
const { getProfile, getUserProfile } = require("../controllers/profile");
const router = express.Router();

router.get("/", getProfile);
router.get("/:id", getUserProfile);

module.exports = router;
