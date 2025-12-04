const express = require("express");
const { addOrder, getOrder } = require("../controllers/orders-controller");
const router = express.Router();

router.post("/", addOrder);
router.get("/:id", getOrder);

module.exports = router;
