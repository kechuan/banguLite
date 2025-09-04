
enum BangumiResponseStatusCode {
  //Request Error
  badRequest(400,"请求格式错误"),
  unauthorized(401,"账号未验证身份"),
  connectRefused(403,"拒绝操作"),
  notFound(404,"内容未找到"),
  tooManyRequest(429,"触发频率限制"),

  //Server Error
  internalServerError(500,"服务器接口故障"),

  unknown(0,"未知")
  ;

  final int code;
  final String description;

  const BangumiResponseStatusCode(this.code,this.description);
}

