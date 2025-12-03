class SingleJSONResponse {
  constructor(item, message) {
    this.item = item;
    this.message = message;
  }

  returnItem() {
    return {
      item: this.item,
      message: this.message,
    };
  }
}

class JSONResponse {
  constructor(items, message) {
    this.items = items;
    this.message = message;
  }

  returnItems() {
    return {
      items: this.items,
      totalItems: this.totalItems,
      message: this.message,
    };
  }
}

class PaginatedResponse extends JSONResponse {
  constructor(items, totalItems, totalPages, currentPage, message) {
    super(items, message);
    this.totalItems = totalItems;
    this.totalPages = totalPages;
    this.currentPage = currentPage;
  }

  returnItems() {
    return {
      items: this.items,
      totalItems: this.totalItems,
      totalPages: this.totalPages,
      currentPage: this.currentPage,
      message: this.message,
    };
  }
}

const handleJSON = (res, statusCode, items, message) => {
  const newJson = new JSONResponse(items, message);
  return res.status(statusCode).json(newJson.returnItems());
};

const handleSingleJSON = (res, statusCode, item, message) => {
  const newJson = new SingleJSONResponse(item, message);
  return res.status(statusCode).json(newJson.returnItem());
};

const handlePaginated = (
  res,
  statusCode,
  items,
  totalItems,
  totalPages,
  currentPage,
  message
) => {
  const newPaginatedJson = new PaginatedResponse(
    items,
    totalItems,
    totalPages,
    currentPage,
    message
  );
  return res.status(statusCode).json(newPaginatedJson.returnItems());
};

module.exports = { handleJSON, handlePaginated, handleSingleJSON };
