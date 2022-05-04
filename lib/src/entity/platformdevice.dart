import 'package:universal_io' show Platform;

class Util {

  os getPlatform() {
    if (kIsWeb) {
      return os.Web;
    } else if (Platform.isIOS) {
      return os.IOS;
    } else if (Platform.isAndroid) {
      return os.Android;
    } else if (Platform.isFuchsia) {
      return os.Fuchsia;
    } else if (Platform.isLinux) {
      return os.Linux;
    } else if (Platform.isMacOS) {
      return os.MacOS;
    } else if (Platform.isWindows) {
      return os.Windows;
    }
    return os.Unknown;
  }

  bool isWeb() {
    return (getPlatform()==os.Web);
  }

  bool isMobile() {
    os platform = getPlatform();
    return (platform == os.Android || platform == os.IOS || platform== os.Fuchsia);
  }

  bool isComputer() {
    os platform = getPlatform();
    return (platform == os.Linux || platform == os.MacOS || platform== os.Windows);
  }

}

enum os { Unknown, Web, Android, Fuchsia, IOS, Linux, MacOS, Windows }
