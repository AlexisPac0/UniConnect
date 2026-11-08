import '../../domain/entities/welcome_item.dart';

class HomeRepository {
  const HomeRepository();

  List<WelcomeItem> getWelcomeItems() {
    return const [
      WelcomeItem(
        title: 'Stay informed',
        description: 'Keep university information in one place.',
      ),
      WelcomeItem(
        title: 'Connect with your community',
        description: 'Make everyday student life easier to organise.',
      ),
    ];
  }
}
