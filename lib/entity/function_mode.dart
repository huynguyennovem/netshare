enum FunctionMode {
  none(''),
  client('Client'),
  server('Server');

  const FunctionMode(this.name);

  final String name;
}
