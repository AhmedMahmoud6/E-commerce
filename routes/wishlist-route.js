const express = require("express");
const {
  addToWishlist,
  deleteWishlistProduct,
  getWishlist,
} = require("../controllers/wishlist-controller");
const auth = require("../middleware/auth");
const router = express.Router();

// All wishlist routes require authentication
router.use(auth);

router.post("/", addToWishlist);
router.get("/", getWishlist);
router.delete("/:id", deleteWishlistProduct);

module.exports = router;
