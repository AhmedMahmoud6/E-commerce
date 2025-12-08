const express = require("express");
const {
  addProduct,
  getProducts,
  getSelectedProduct,
  updateProduct,
  deleteProduct,
  getMyProducts,
} = require("../controllers/products-controller");
const auth = require("../middleware/auth");
const router = express.Router();

router.post("/", auth, addProduct);
router.get("/", getProducts);
router.get("/me", auth, getMyProducts);
router.get("/:id", getSelectedProduct);
router.put("/:id", auth, updateProduct);
router.delete("/:id", auth, deleteProduct);

module.exports = router;
