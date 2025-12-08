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
  const payload = error.formatError(statusCode);
  if (errorDetails) payload.error = errorDetails;
  return res.status(statusCode).json(payload);
};

module.exports = { handleError };
