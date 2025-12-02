const express = require("express");
const {
  addProduct,
  getProducts,
} = require("../controllers/products-controller");
const router = express.Router();

router.post("/", addProduct);
router.get("/", getProducts);

module.exports = router;
