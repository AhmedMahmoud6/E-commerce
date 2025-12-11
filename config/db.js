const mongoose = require("mongoose");

// Cache the connection so serverless containers reuse it across invocations
let cachedConnection = null;

async function connectDB({ retries = 3, retryDelay = 1000 } = {}) {
  if (cachedConnection && mongoose.connection.readyState === 1) {
    return mongoose;
  }

  const mongoUrl = process.env.MONGO_URL;
  if (!mongoUrl) {
    throw new Error("MONGO_URL environment variable is not set");
  }

  // Recommended options
  const opts = {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    serverSelectionTimeoutMS: 5000,
    socketTimeoutMS: 45000,
  };

  let attempt = 0;
  while (attempt < retries) {
    try {
      await mongoose.connect(mongoUrl, opts);
      console.log("Connected to MongoDB");
      cachedConnection = mongoose;

      mongoose.connection.on("error", (err) => {
        console.error("MongoDB connection error:", err);
      });

      mongoose.connection.on("disconnected", () => {
        console.warn("MongoDB disconnected");
      });

      return mongoose;
    } catch (err) {
      attempt++;
      console.error(
        `MongoDB connect attempt ${attempt} failed:`,
        err.message || err
      );
      if (attempt >= retries) {
        console.error("All MongoDB connection attempts failed");
        throw err;
      }
      // exponential backoff
      const wait = retryDelay * Math.pow(2, attempt - 1);
      // eslint-disable-next-line no-await-in-loop
      await new Promise((resolve) => setTimeout(resolve, wait));
    }
  }
}

function getConnectionState() {
  // 0 = disconnected, 1 = connected, 2 = connecting, 3 = disconnecting
  return mongoose.connection.readyState;
}

module.exports = { connectDB, mongoose, getConnectionState };
