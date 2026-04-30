String convertDriveUrl(String url) {
  try {
    final uri = Uri.parse(url);
    final id = uri.pathSegments[2];
    return 'https://drive.google.com/uc?export=view&id=$id';
  } catch (e) {
    return url;
  }
}