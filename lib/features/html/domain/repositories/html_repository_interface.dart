import 'package:GalaBest/interfaces/repository_interface.dart';
import 'package:GalaBest/util/html_type.dart';

abstract class HtmlRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getHtmlText(HtmlType htmlType);
}