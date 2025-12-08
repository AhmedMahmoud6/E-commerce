const { handleError } = require("../responses/errors");
const { handleSingleJSON } = require("../responses/success");
const { verifyJWT } = require("../utils/repeated-functions");
const Wishlist = require("../model/wishlist");

const addToWishlist = async (req, res) => {
  try {
    const user_id = req.userId || verifyJWT(req, res);
    if (!user_id) return;

    const { product_id } = req.body;

    if (!product_id) return handleError(res, 400, "Product id is missing");

    let userWishlist = await Wishlist.findOne({ user_id });
    if (!userWishlist) {
      userWishlist = await Wishlist.create({ user_id, product_id: [] });
    }

    const productIndex = userWishlist.product_id.findIndex(
      (p) => p.toString() === product_id
    );
    let message = "";

    if (productIndex !== -1) {
      message = "Product is already in wishlist";
    } else {
      userWishlist.product_id.push(product_id);
      message = "Product added to wishlist successfully";
    }

    await userWishlist.save();

    return handleSingleJSON(res, 201, userWishlist, message);
  } catch (err) {
    console.error("Failed to add product to wishlist", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

const getWishlist = async (req, res) => {
  try {
    const user_id = req.userId || verifyJWT(req, res);
    if (!user_id) return;

    const userWishlist = await Wishlist.findOne({ user_id }).populate(
      "product_id"
    );

    if (!userWishlist) {
      return handleError(res, 404, "Wishlist not found");
    }

    return handleSingleJSON(
      res,
      200,
      userWishlist,
      "Wishlist fetched successfully"
    );
  } catch (err) {
    console.error("Failed to get wishlist", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

const deleteWishlistProduct = async (req, res) => {
  try {
    const productId = req.params.id;

    if (!productId) return handleError(res, 400, "Product id is missing");

    const user_id = req.userId || verifyJWT(req, res);
    if (!user_id) return;

    const userWishlist = await Wishlist.findOne({ user_id }).populate(
      "product_id"
    );

    if (!userWishlist)
      return handleError(res, 404, "Wishlist not found for current user");

    const productIndex = userWishlist.product_id.findIndex(
      (product) => product._id.toString() === productId
    );

    if (productIndex === -1)
      return handleError(
        res,
        404,
        "Cannot delete product, product is not in wishlist"
      );

    const deletedProduct = userWishlist.product_id.splice(productIndex, 1)[0];

    await userWishlist.save();

    return handleSingleJSON(
      res,
      200,
      deletedProduct,
      `${deletedProduct.name} deleted successfully`
    );
  } catch (err) {
    console.error("Failed to delete Wishlist", err);
    return handleError(res, 500, "Internal Server Error");
  }
};

module.exports = { addToWishlist, getWishlist, deleteWishlistProduct };
