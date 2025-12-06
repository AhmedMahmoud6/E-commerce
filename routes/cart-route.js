const express = require("express");
const {
  addToCart,
  deleteCartProduct,
  getCart,
} = require("../controllers/carts-controller");
const router = express.Router();

router.post("/", addToCart);
router.get("/", getCart);
router.delete("/:id", deleteCartProduct);

module.exports = router;
