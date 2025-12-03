const express = require("express");
const {
  addProduct,
  getProducts,
  getSelectedProduct,
  updateProduct,
  deleteProduct,
} = require("../controllers/products-controller");
const router = express.Router();

router.post("/", addProduct);
router.get("/", getProducts);
router.get("/:id", getSelectedProduct);
router.put("/:id", updateProduct);
router.delete("/:id", deleteProduct);

module.exports = router;
