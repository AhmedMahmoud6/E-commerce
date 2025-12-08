const express = require("express");
const {
  addOrder,
  getOrder,
  getAllOrders,
  getAllOrdersAdmin,
} = require("../controllers/orders-controller");
const auth = require("../middleware/auth");
const router = express.Router();

router.post("/", auth, addOrder);
router.get("/", auth, getAllOrders);
router.get("/admin", auth, getAllOrdersAdmin);
router.get("/:id", getOrder);

module.exports = router;
