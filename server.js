const express = require("express");
const app = express();
const productRoutes = require("./routes/products-route");
const registerRoutes = require("./routes/register-route");
const loginRoutes = require("./routes/login-route");

app.use(express.json());
require("dotenv").config();
require("./config/db");
app.use("/products", productRoutes);
app.use("/register", registerRoutes);
app.use("/login", loginRoutes);

app.listen(process.env.PORT, () => {
  console.log("Server Listened");
});
