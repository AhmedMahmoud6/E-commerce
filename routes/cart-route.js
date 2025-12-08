const express = require("express");
const {
  addToCart,
  deleteCartProduct,
  getCart,
} = require("../controllers/carts-controller");
const auth = require("../middleware/auth");
const router = express.Router();

// All cart routes require authentication
router.use(auth);

router.post("/", addToCart);
router.get("/", getCart);
router.delete("/:id", deleteCartProduct);

module.exports = router;
