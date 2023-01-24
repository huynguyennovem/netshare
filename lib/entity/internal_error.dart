enum InternalError {
  getAndroidDownloadPathFailed('Failed to get Android Downloads path'),
  downloadDestNotExist('Download destination does not exist');

  const InternalError(this.message);

  final String message;
}
