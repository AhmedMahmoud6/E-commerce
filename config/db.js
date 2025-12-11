const mongoose = require("mongoose");

async function connectDB() {
  const mongoUrl = process.env.MONGO_URL;
  if (!mongoUrl) {
    throw new Error("MONGO_URL environment variable is not set");
  }

  // Use recommended options and disable buffering if desired
  const opts = {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    // socketTimeoutMS: 30000,
    // serverSelectionTimeoutMS: 10000,
  };

  try {
    await mongoose.connect(mongoUrl, opts);
    console.log("Connected to MongoDB");
  } catch (err) {
    console.error("Error connecting to MongoDB", err);
    throw err;
  }

  mongoose.connection.on("error", (err) => {
    console.error("MongoDB connection error:", err);
  });

  mongoose.connection.on("disconnected", () => {
    console.warn("MongoDB disconnected");
  });

  return mongoose;
}

module.exports = { connectDB, mongoose };
