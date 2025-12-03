const Product = require("../model/products");
const User = require("../model/users");
const jwt = require("jsonwebtoken");

const addProduct = async (req, res) => {
  try {
    const { name, description, image_url, price, category, stock } = req.body;

    const existingProduct = await Product.findOne({ name });

    const authHeader = req.headers["authorization"];

    if (!authHeader) {
      return res
        .status(401)
        .json({ message: "Authorization token is missing" });
    }

    const decoded = jwt.verify(authHeader, process.env.JWT_SECRET);
    const currentMerchantId = decoded.userId;

    const user = await User.findById(currentMerchantId);
    console.log("Found user:", user);

    if (!user) {
      return res.status(404).json({ message: "Merchant not found" });
    }

    if (user.role !== "merchant") {
      return res.status(400).json({ message: "User is not a merchant" });
    }

    if (existingProduct)
      return res.status(400).json({ message: "Product name is taken" });

    const newProduct = await Product.create({
      name,
      description,
      image_url,
      price,
      category,
      stock,
      merchant_id: currentMerchantId,
    });

    return res
      .status(200)
      .json({ message: "Product added successfully", product: newProduct });
  } catch (err) {
    console.error("Error adding product:", err);
    res.status(500).json({ message: "Error adding product", error: err });
  }
};

const getProducts = async (req, res) => {
  try {
    const products = await Product.find();

    return res.status(200).json(products);
  } catch (err) {
    console.error("Error fetching products:", err);
    res.status(500).json({ message: "Error fetching products", error: err });
  }
};

module.exports = { addProduct, getProducts };
