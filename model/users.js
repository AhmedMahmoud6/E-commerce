const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^\w+([.-]?\w+)@\w+([.-]?\w+)(.\w{2,3})+$/, "Invalid email"],
    },
    password: {
      type: String,
      required: true,
      minlength: [8, "Password must be at least 8 characters"],
      match: [
        /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$/,
        "Password must contain at least 1 uppercase, 1 lowercase, 1 number, and 1 special character",
      ],
    },
    profile_url: {
      type: String,
      required: false,
    },
    address: {
      type: String,
      required: true,
    },
    role: {
      type: String,
      required: true,
      enum: ["member", "merchant", "admin"],
      default: "member",
    },
    created_at: {
      type: Date,
      default: Date.now,
    },
  },
  { versionKey: false }
);

const User = mongoose.model("User", userSchema);

module.exports = User;
