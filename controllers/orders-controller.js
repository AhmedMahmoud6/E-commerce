const Product = require("../model/products");
const User = require("../model/users");
const Order = require("../model/orders");
const { handleError } = require("../responses/errors");
const { verifyJWT } = require("../utils/repeated-functions");
const {
  handleSingleJSON,
  handleJSON,
  handlePaginated,
} = require("../responses/success");

const getProductsByIds = async (productsIds) => {
  try {
    const products = await Product.find({ _id: { $in: productsIds } });
    if (!products || products.length === 0) {
      console.log("No products found");
      return [];
    }

    return products;
  } catch (err) {
    console.error("Error fetching products:", err);
    throw err;
  }
};

const addOrder = async (req, res) => {
  const { product_id, quantity } = req.body;

  const user_id = req.userId || verifyJWT(req, res);
  if (!user_id) return;
  const user = await User.findById(user_id);

  if (!user) return handleError(res, 404, "User not found");

  if (user.role !== "member")
    return handleError(res, 403, "User is not a member to order");

  if (!product_id || product_id.length === 0)
    return handleError(res, 400, "No product IDs provided");

  if (!quantity || quantity.length === 0)
    return handleError(res, 400, "No quantities provided");

  try {
    const products = await getProductsByIds(product_id);
    let isError = false;
    let errorMsg = "";

    if (products.length !== product_id.length)
      return handleError(res, 404, "Some products not found");

    // check if there's a stock
    products.forEach((product) => {
      if (product.stock === 0) {
        errorMsg = `Product out of stock: ${product.name}`;
        isError = true;
      }
    });

    if (isError) return handleError(res, 400, errorMsg);

    // update stock (sequentially to ensure saves complete)
    for (let index = 0; index < products.length; index++) {
      const product = products[index];
      if (product.stock >= quantity[index]) {
        product.stock -= quantity[index];
        try {
          await product.save();
        } catch (err) {
          console.error("Error updating product stock:", err);
        }
      } else {
        errorMsg = `Insufficient stock for product: ${product.name}`;
        isError = true;
      }
    }

    if (isError) return handleError(res, 400, errorMsg);

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

const getAllOrders = async (req, res) => {
  try {
    const user_id = req.userId || verifyJWT(req, res);
    if (!user_id) return;
    const user = await User.findById(user_id);

    if (user.role !== "member")
      return handleError(
        res,
        403,
        "Access Denied: You do not have permission to perform this action"
      );

    const allOrders = await Order.find({
      user_id: user_id,
    });

    if (!allOrders)
      return handleError(res, 200, "You have not placed any orders yet.");

    return handleJSON(res, 200, allOrders, "Orders found");
  } catch (err) {
    console.error("Failed to fetch orders", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

const getAllOrdersAdmin = async (req, res) => {
  try {
    const user_id = req.userId || verifyJWT(req, res);
    if (!user_id) return;
    const user = await User.findById(user_id);

    if (user.role !== "admin")
      return handleError(
        res,
        403,
        "Access Denied: You do not have permission to perform this action"
      );

    const { search, limit, page } = req.query;

    const limitResults = Math.abs(parseInt(limit)) || 10;
    const pageNumber = Math.abs(parseInt(page)) || 1;

    const skip = (pageNumber - 1) * limitResults;

    const products = await Product.find({
      name: { $regex: search ? search.toString() : "", $options: "i" },
    }).select("_id");

    if (products.length === 0) {
      return handleError(res, 404, "No products found matching the search");
    }

    const productIds = products.map((product) => product._id);

    const searchQuery = search ? { product_id: { $in: productIds } } : {};

    const orders = await Order.find(searchQuery)
      .populate("product_id")
      .skip(skip)
      .limit(limitResults);

    const totalOrders = await Order.countDocuments(searchQuery);

    const totalPages = Math.ceil(totalOrders / limitResults);

    console.log(pageNumber);

    if (orders.length === 0) return handleError(res, 404, "No results found");

    if (pageNumber < 1 || pageNumber > totalPages)
      return handleError(
        res,
        400,
        `Page ${pageNumber} is out of range. Please select a valid page between 1 and ${totalPages}.`
      );

    if (!orders) return handleError(res, 200, "No orders found.");

    return handlePaginated(
      res,
      200,
      orders,
      totalOrders,
      totalPages,
      pageNumber,
      "Orders found."
    );
  } catch (err) {
    console.error("Failed to fetch orders", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

const getOrdersByMerchant = async (req, res) => {
  try {
    const user_id = req.userId || verifyJWT(req, res);
    if (!user_id) return;
    const user = await User.findById(user_id);

    const merchantId = req.params.merchantId;
    if (!merchantId) return handleError(res, 400, "merchant id is missing");

    // Only allow admin or the merchant themself to fetch merchant orders
    if (user.role !== "admin" && user._id.toString() !== merchantId)
      return handleError(
        res,
        403,
        "Access Denied: cannot view other merchant orders"
      );

    // Find products that belong to this merchant
    const products = await Product.find({ merchant_id: merchantId }).select(
      "_id"
    );
    if (!products || products.length === 0) {
      return handleJSON(res, 200, [], "No orders for this merchant");
    }
    const productIds = products.map((p) => p._id);

    // Find orders that reference any of these product ids
    const orders = await Order.find({
      product_id: { $in: productIds },
    }).populate("product_id");

    if (!orders || orders.length === 0) {
      return handleJSON(res, 200, [], "No orders for this merchant");
    }

    return handleJSON(res, 200, orders, "Merchant orders found");
  } catch (err) {
    console.error("Failed to fetch merchant orders", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

module.exports = {
  addOrder,
  getOrder,
  getAllOrders,
  getAllOrdersAdmin,
  getOrdersByMerchant,
};
