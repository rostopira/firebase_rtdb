import 'consts.dart';

// Lint ignored, because this class will be extended later
// ignore: one_member_abstracts
abstract class WsMessageDelegate {

  void handleWsMsg(MSD msg);

}