class Config {
  static Config _instance;
  String _host = '192.168.21.41';
  int _port = 8080;
  String _uuid = '123';

  factory Config() => getInstance();

  Config._internal() {}

  static Config getInstance() {
    if (_instance == null) {
      _instance = Config._internal();
    }
    return _instance;
  }

  String get endPointManageApp {
    return 'https://$_host:$_port/api/admin/apps';
  }

    String get endPointUserInfo {
    return 'https://$_host:$_port/api/user';
  }

  String get endPointQueryApps {
    return 'https://$_host:$_port/api/apps';
  }

  String get endPointLogin {
    return 'https://$_host:$_port/api/tokens';
  }

  String get endPointDownloads {
    return 'https://$_host:$_port/api/resource/app/downloads';
  }

  String get endPointOperateApp {
    return 'https://$_host:$_port/api/admin/app';
  }

    String get endPointAppInfo {
    return 'https://$_host:$_port/api/app/detail';
  }
}
