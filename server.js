const express = require("express");
const app = express();
const productRoutes = require("./routes/products-route");
const registerRoutes = require("./routes/register-route");
const loginRoutes = require("./routes/login-route");
const profileRoutes = require("./routes/profile-route");
const orderRoutes = require("./routes/orders-route");
const cartRoutes = require("./routes/cart-route");
const wishlistRoutes = require("./routes/wishlist-route");

app.use(express.json());
require("dotenv").config();
const { connectDB } = require("./config/db");

app.use("/api/products", productRoutes);
app.use("/api/register", registerRoutes);
app.use("/api/login", loginRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/wishlist", wishlistRoutes);

const PORT = process.env.PORT || 5000;

(async () => {
  try {
    await connectDB();
    app.listen(PORT, () => {
      console.log(`Server listening on port ${PORT}`);
    });
  } catch (err) {
    console.error("Failed to start server due to DB connection error:", err);
    process.exit(1);
  }
})();
