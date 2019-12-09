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
    return 'http://$_host:$_port/api/admin/apps';
  }

  String get endPointQueryApps {
    return 'http://$_host:$_port/api/apps';
  }

  String get endPointLogin {
    return 'http://$_host:$_port/api/tokens';
  }

  String get endPointDownloads {
    return 'http://$_host:$_port/api/resource/app/downloads';
  }

  String get endPointOperateApp {
    return 'http://$_host:$_port/api/admin/app';
  }
}
