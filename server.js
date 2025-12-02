const express = require("express");
const app = express();
const productRoutes = require("./routes/products-route");
const registerRoutes = require("./routes/register-route");
const loginRoutes = require("./routes/login-route");

app.use(express.json());
require("dotenv").config();
require("./config/db");

app.use("/api/products", productRoutes);
app.use("/api/register", registerRoutes);
app.use("/api/login", loginRoutes);

app.listen(process.env.PORT, () => {
  console.log("Server Listened");
});
