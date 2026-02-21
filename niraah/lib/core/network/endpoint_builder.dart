class EndpointBuilder {
  const EndpointBuilder._();

  static String withPathParams(String path, Map<String, String> params) {
    String output = path;
    for (final MapEntry<String, String> entry in params.entries) {
      output = output.replaceAll('{${entry.key}}', entry.value);
    }
    return output;
  }
}
