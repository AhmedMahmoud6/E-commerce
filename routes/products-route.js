const express = require("express");
const {
  addProduct,
  getProducts,
  getSelectedProduct,
  updateProduct,
  deleteProduct,
  getMyProducts,
} = require("../controllers/products-controller");
const router = express.Router();

router.post("/", addProduct);
router.get("/", getProducts);
router.get("/me", getMyProducts);
router.get("/:id", getSelectedProduct);
router.put("/:id", updateProduct);
router.delete("/:id", deleteProduct);

module.exports = router;
