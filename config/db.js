const mongoose = require("mongoose");

const options = {
  // how long to try selecting a server before failing (ms)
  serverSelectionTimeoutMS: 10000,
  // socket inactivity timeout
  socketTimeoutMS: 45000,
};

mongoose
  .connect(process.env.MONGO_URL, options)
  .then(() => {
    console.log("Connected to MongoDB Atlas");
  })
  .catch((err) => {
    console.error("Error connecting to MongoDB Atlas", err);
  });

module.exports = mongoose;
