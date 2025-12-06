const express = require("express");
const {
  addToWishlist,
  deleteWishlistProduct,
  getWishlist,
} = require("../controllers/wishlist-controller");
const router = express.Router();

router.post("/", addToWishlist);
router.get("/", getWishlist);
router.delete("/:id", deleteWishlistProduct);

module.exports = router;
