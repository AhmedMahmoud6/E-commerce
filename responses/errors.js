class ServerErrorResponse {
  constructor(message, error) {
    this.message = message;
    this.error = error;
  }

  formatError(statusCode) {
    return {
      statusCode,
      message: this.message,
    };
  }
}

const handleError = (res, statusCode, message, errorDetails = null) => {
  const error = new ServerErrorResponse(message, errorDetails);
  return res.status(statusCode).json(error.formatError(statusCode));
};

module.exports = { handleError };
