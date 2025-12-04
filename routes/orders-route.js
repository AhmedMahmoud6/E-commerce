const express = require("express");
const {
  addOrder,
  getOrder,
  getAllOrders,
  getAllOrdersAdmin,
} = require("../controllers/orders-controller");
const router = express.Router();

router.post("/", addOrder);
router.get("/", getAllOrders);
router.get("/admin", getAllOrdersAdmin);
router.get("/:id", getOrder);

module.exports = router;
