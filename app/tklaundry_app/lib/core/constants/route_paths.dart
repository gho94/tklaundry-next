abstract final class RoutePaths {
  static const login = '/login';
  static const register = '/register';
  static const orders = '/orders';
  static const orderDetail = '/orders/:orderNo';
  static const settings = '/settings';
  static const settingsCodes = '/settings/codes';
  static const settingsMembers = '/settings/members';

  static const publicPaths = [login, register];
}