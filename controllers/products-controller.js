const Product = require("../model/products");
const User = require("../model/users");
const jwt = require("jsonwebtoken");
const { handleError } = require("../responses/errors");
const { handlePaginated, handleSingleJSON } = require("../responses/success");

const addProduct = async (req, res) => {
  try {
    const { name, description, image_url, price, category, stock } = req.body;

    const existingProduct = await Product.findOne({ name });

    const authHeader = req.headers["authorization"];

    if (!authHeader)
      return handleError(res, 401, "Authorization token is missing");

    const decoded = jwt.verify(authHeader, process.env.JWT_SECRET);
    const currentMerchantId = decoded.userId;

    const user = await User.findById(currentMerchantId);
    console.log("Found user:", user);

    if (!user) {
      return handleError(res, 404, "Merchant not found");
    }

    if (user.role === "member") {
      return handleError(res, 400, "User is not a merchant");
    }

    if (existingProduct) return handleError(res, 400, "Product name is taken");

    const newProduct = await Product.create({
      name,
      description,
      image_url,
      price,
      category,
      stock,
      merchant_id: currentMerchantId,
    });

    return handleSingleJSON(res, 200, newProduct, "Product added successfully");
  } catch (err) {
    console.error("Error adding product:", err);
    return handleError(res, 500, "Error adding product");
  }
};

const getProducts = async (req, res) => {
  try {
    const { search, limit, page } = req.query;

    const limitResults = Math.abs(parseInt(limit)) || 10;
    const pageNumber = Math.abs(parseInt(page)) || 1;

    const skip = (pageNumber - 1) * limitResults;

    const searchQuery = search
      ? { name: { $regex: `^${search}`, $options: "i" } }
      : {};

    const products = await Product.find(searchQuery)
      .skip(skip)
      .limit(limitResults);

    const totalProducts = await Product.countDocuments(searchQuery);

    const totalPages = Math.ceil(totalProducts / limitResults);

    console.log(pageNumber);

    if (products.length === 0) return handleError(res, 404, "No results found");

    if (pageNumber < 1 || pageNumber > totalPages)
      return handleError(
        res,
        400,
        `Page ${pageNumber} is out of range. Please select a valid page between 1 and ${totalPages}.`
      );

    return handlePaginated(
      res,
      200,
      products,
      totalProducts,
      totalPages,
      pageNumber,
      "items loaded"
    );
  } catch (err) {
    console.error("Error fetching products:", err);
    return handleError(res, 500, "Error fetching products");
  }
};

const getSelectedProduct = async (req, res) => {
  try {
    const productId = req.params.id;
    const product = await Product.findById(productId);

    const productMerchant = await User.findById(product.merchant_id);

    if (!product) return handleError(res, 404, "Product not found");
    if (!productMerchant)
      return handleError(res, 404, "Product merchant not found");

    const { username, email, address, role, profile_url, created_at } =
      productMerchant;

    return handleSingleJSON(
      res,
      200,
      {
        product,
        merchantInfo: {
          username,
          email,
          address,
          role,
          profile_url,
          created_at,
        },
      },
      "product loaded"
    );
  } catch (err) {
    console.error("Failed to load product:", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

const updateProduct = async (req, res) => {
  try {
    const authHeader = req.headers["authorization"];

    if (!authHeader)
      return handleError(res, 401, "Authorization token is missing");

    const decoded = jwt.verify(authHeader, process.env.JWT_SECRET);
    const currUserId = decoded.userId;

    const productId = req.params.id;

    if (!productId) return handleError(res, 401, "Product id missing");

    const { name, description, image_url, price, category, status, stock } =
      req.body;

    const product = await Product.findById(productId);

    if (!product) return handleError(res, 404, "Product not found");

    if (product.merchant_id.toString() !== currUserId)
      return handleError(
        res,
        403,
        "Access Denied: You do not have permission to perform this action"
      );

    const updatedData = {
      name: name || product.name,
      description: description || product.description,
      image_url: image_url || product.image_url,
      price: price || product.price,
      category: category || product.category,
      status: status || product.status,
      stock: stock || product.stock,
      updated_at: Date.now(),
    };

    const updatedProduct = await Product.findByIdAndUpdate(
      productId,
      updatedData
    );

    if (!updatedProduct) return handleError(res, 404, "Product not found");

    return handleSingleJSON(
      res,
      200,
      updateProduct,
      "Product updated successfully"
    );
  } catch (err) {
    console.error("Error updating product:", err);
    return handleError(res, 500, "Internal server error");
  }
};

const deleteProduct = async (req, res) => {
  try {
    const authHeader = req.headers["authorization"];

    if (!authHeader)
      return handleError(res, 401, "Authorization token is missing");

    const decoded = jwt.verify(authHeader, process.env.JWT_SECRET);
    const currUserId = decoded.userId;

    const currUser = await User.findById(currUserId);

    const productId = req.params.id;

    if (!productId) return handleError(res, 401, "Product id missing");

    const product = await Product.findById(productId);

    if (!product) return handleError(res, 404, "Product is not found");

    if (
      currUser.role !== "admin" &&
      currUserId !== product.merchant_id.toString()
    )
      return handleError(
        res,
        403,
        "Access Denied: You do not have permission to perform this action"
      );

    const deletedProduct = await Product.findByIdAndDelete(productId);

    if (!deletedProduct) return handleError(res, 404, "Product not found");

    return handleSingleJSON(
      res,
      200,
      deletedProduct,
      "Product deleted successfully"
    );
  } catch (err) {
    console.error("Error deleting product", err);
    return handleError(res, 500, "Internal server error");
  }
};

module.exports = {
  addProduct,
  getProducts,
  getSelectedProduct,
  updateProduct,
  deleteProduct,
};
