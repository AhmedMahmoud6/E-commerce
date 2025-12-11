const express = require("express");
const cors = require("cors");
require("dotenv").config();
const { connectDB, getConnectionState } = require("./config/db");

const productRoutes = require("./routes/products-route");
const registerRoutes = require("./routes/register-route");
const loginRoutes = require("./routes/login-route");
const profileRoutes = require("./routes/profile-route");
const orderRoutes = require("./routes/orders-route");
const cartRoutes = require("./routes/cart-route");
const wishlistRoutes = require("./routes/wishlist-route");

const app = express();

// Use permissive CORS for development: echo the request origin and allow credentials.
// Replace with a strict allowlist in production.
app.use(
  cors({
    origin: true,
    credentials: true,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: [
      "Content-Type",
      "Authorization",
      "X-Requested-With",
      "Accept",
    ],
  })
);

app.use(express.json());

// Routes
app.use("/api/products", productRoutes);
app.use("/api/register", registerRoutes);
app.use("/api/login", loginRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/wishlist", wishlistRoutes);

// Health check
app.get("/health", (req, res) => {
  const state = getConnectionState();
  res.json({ ok: true, mongoState: state });
});

const PORT = process.env.PORT || 5000;

// Serverless environment (e.g., Vercel) should export a handler instead of listening.
if (process.env.VERCEL) {
  module.exports = async function (req, res) {
    try {
      await connectDB();
    } catch (err) {
      console.error("DB connection failed in serverless invocation:", err);
      res.statusCode = 500;
      res.end("Database connection error");
      return;
    }
    // Forward the request to the Express app
    return app(req, res);
  };
} else {
  // Normal server start for local/dev
  (async () => {
    try {
      await connectDB();
      app.listen(PORT, () => {
        console.log(`Server listening on port ${PORT}`);
      });
    } catch (err) {
      console.error("Failed to start server:", err);
      process.exit(1);
    }
  })();
}
