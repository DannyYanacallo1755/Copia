

enum Language { 
  SPANISH('es'),
  ENGLISH('en'), 
  CHINESE('zh');
  final String value;
  const Language(this.value);
}

enum CardType{
  VISA,
  MASTERCARD,
  UNKNOWN
}

enum AdminOptions{
  MY_COMPANY,
  ORDERS,
  PRODUCTS,
  COMMUNICATION,
}

enum FloatingActionButtonType{
  ADD,
  EDIT,
  DELETE,
  CART,
  UNKNOWN
}