const Product = require("../model/products");
const User = require("../model/users");
const Order = require("../model/orders");
const { handleError } = require("../responses/errors");
const jwt = require("jsonwebtoken");
const { handleSingleJSON } = require("../responses/success");

const getProductsByIds = async (productsIds) => {
  try {
    const products = Product.find({
      _id: { $in: productsIds },
    });

    if (products.length === 0) {
      console.log("No products found");
      return [];
    }

    return products;
  } catch (err) {
    console.error("Error fetching products:", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

const addOrder = async (req, res) => {
  const { product_id, quantity } = req.body;

  const authHeader = req.headers["authorization"];

  if (!authHeader)
    return handleError(res, 401, "Authorization token is missing");

  const decoded = jwt.verify(authHeader, process.env.JWT_SECRET);
  const user_id = decoded.userId;

  if (!product_id || product_id.length === 0)
    return handleError(res, 400, "No product IDs provided");

  if (!quantity || quantity.length === 0)
    return handleError(res, 400, "No quantities provided");

  if (!user_id) return handleError(res, 400, "No user id provided");

  try {
    const products = await getProductsByIds(product_id);

    if (products.length !== product_id.length)
      return handleError(res, 404, "Some products not found");

    // update stock
    products.forEach(async (product, index) => {
      if (product.stock >= quantity[index]) {
        product.stock -= quantity[index];

        try {
          await product.save();
        } catch (err) {
          console.error("Error updating product stock:", err);
        }
      } else throw new Error(`Insufficient stock for product: ${product.name}`);
    });

    // update total price
    let totalPrice = 0;
    products.forEach((product, index) => {
      totalPrice += product.price * quantity[index];
    });

    const newOrder = await Order.create({
      user_id,
      product_id,
      quantity,
      total_price: totalPrice,
    });

    return handleSingleJSON(res, 201, newOrder, "Order created successfully");
  } catch (err) {
    console.error("Error creating order", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

const getOrder = async (req, res) => {
  try {
    const orderId = req.params.id;

    if (!orderId) return handleError(res, 404, "Order id is missing");

    const order = await Order.findById(orderId).populate("product_id").exec();

    if (!order) return handleError(res, 404, "Order not found");
    console.log("curr order", order);

    return handleSingleJSON(res, 200, order, "Order fetched successfully");
  } catch (err) {
    console.error("Error fetching order:", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

module.exports = { addOrder, getOrder };
