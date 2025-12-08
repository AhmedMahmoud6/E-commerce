const { handleError } = require("../responses/errors");
const { handleSingleJSON } = require("../responses/success");
const { verifyJWT } = require("../utils/repeated-functions");
const Cart = require("../model/carts");

const addToCart = async (req, res) => {
  try {
    const user_id = req.userId || verifyJWT(req, res);
    if (!user_id) return;

    const { product_id, quantity } = req.body;

    if (!product_id || product_id.length === 0)
      return handleError(res, 400, "Products array is empty");
    if (!quantity) return handleError(res, 400, "Quantity array is empty");

    let userCart = await Cart.findOne({ user_id });
    if (!userCart) {
      userCart = await Cart.create({ user_id, product_id: [], quantity: [] });
    }

    const productIndex = userCart.product_id.findIndex(
      (p) => p.toString() === product_id
    );
    let message = "";

    if (productIndex !== -1) {
      userCart.quantity[productIndex] =
        (userCart.quantity[productIndex] || 0) + quantity;
      message = "Updated product quantity successfully";
    } else {
      userCart.product_id.push(product_id);
      userCart.quantity.push(quantity);
      message = "Product added to cart successfully";
    }

    await userCart.save();

    return handleSingleJSON(res, 201, userCart, message);
  } catch (err) {
    console.error("Failed to add product to cart", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

const getCart = async (req, res) => {
  try {
    const user_id = req.userId || verifyJWT(req, res);
    if (!user_id) return;

    const userCart = await Cart.findOne({ user_id }).populate("product_id");

    if (!userCart) {
      return handleError(res, 404, "Cart not found");
    }

    return handleSingleJSON(res, 200, userCart, "Cart fetched successfully");
  } catch (err) {
    console.error("Failed to get cart", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

const deleteCartProduct = async (req, res) => {
  try {
    const productId = req.params.id;

    if (!productId) return handleError(res, 400, "Product id is missing");

    const user_id = req.userId || verifyJWT(req, res);
    if (!user_id) return;

    const userCart = await Cart.findOne({ user_id }).populate("product_id");

    if (!userCart)
      return handleError(res, 404, "Cart not found for current user");

    const productIndex = userCart.product_id.findIndex(
      (product) => product._id.toString() === productId
    );

    if (productIndex === -1)
      return handleError(
        res,
        404,
        "Cannot delete product, product is not in cart"
      );

    const deletedProduct = userCart.product_id.splice(productIndex, 1)[0];
    userCart.quantity.splice(productIndex, 1)[0];

    await userCart.save();

    return handleSingleJSON(
      res,
      200,
      deletedProduct,
      `${deletedProduct.name} deleted successfully`
    );
  } catch (err) {
    console.error("Failed to delete product", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

module.exports = { addToCart, getCart, deleteCartProduct };
