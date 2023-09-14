const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
const suffixesB = ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB'];

String getFileSize(int size, {int fractionDigits = 2, bool base1024 = true}) {
  final suffix = base1024 ? suffixesB : suffixes;
  final base = base1024 ? 1024.0 : 1000.0;
  var n = size.toDouble();
  int ind = 0;
  while (n >= base && ind < suffix.length - 1) {
    n /= base;
    ind++;
  }
  return '${n.toStringAsFixed(fractionDigits)} ${suffix[ind]}';
}
