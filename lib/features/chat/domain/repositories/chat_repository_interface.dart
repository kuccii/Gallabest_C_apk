import 'package:GalaBest/api/api_client.dart';
import 'package:GalaBest/interfaces/repository_interface.dart';

abstract class ChatRepositoryInterface extends RepositoryInterface {
  @override
  Future getList({int? offset, bool conversationList = false, String? type, bool searchConversationalList = false, String? name});
  Future<dynamic> getMessages(int offset, int? userID, String userType, int? conversationID);
  Future<dynamic> sendMessage(String message, String orderId, List<MultipartBody> images, int? userID, String userType, int? conversationID);
}