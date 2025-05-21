
enum BangumiResponseStatusCode {
  //Request Error
  badRequest(400),
  unauthorized(401),
  notFound(404),
  tooManyRequest(429),

  //Server Error
  internalServerError(500)
  ;

  final int code;

  const BangumiResponseStatusCode(this.code);
}

