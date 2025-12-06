const mongoose = require("mongoose");

const cartSchema = new mongoose.Schema(
  {
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
    product_id: {
      type: [mongoose.Schema.Types.ObjectId],
      ref: "Product",
      defalut: [],
    },
    quantity: {
      type: [Number],
      default: [],
    },
    created_at: {
      type: Date,
      default: Date.now,
    },
  },
  { versionKey: false }
);

const Cart = mongoose.model("Cart", cartSchema);

module.exports = Cart;
