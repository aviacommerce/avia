export const fetchGet = (url) => {
  const request = {
    credentials: 'include',
    method: 'GET',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
  };
  return fetch(url, request);
};

export const fetchPost = (url, data) => {
  const request = {
    credentials: 'include',
    method: 'POST',
    body: JSON.stringify(data),
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
  };
  return fetch(url, request);
};

export const fetchPut = (url, data) => {
  const request = {
    credentials: 'include',
    method: 'PUT',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data),
  };
  return fetch(url, request);
};

export const fetchProducts = () => {
  const productsList = {
    products: [
      {
        category: 'shoes',
        id: 1,
      },
      {
        category: 'tshirts',
        id: 2,
      },
      {
        category: 'watches',
        id: 3,
      },
    ],
  };

  return new Promise((resolve) => {
    setTimeout(() => resolve(productsList), 300);
  });
};
