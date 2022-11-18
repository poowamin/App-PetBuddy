import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/cloudfirestore_api.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/widget/messages_widget.dart';
import 'package:pet_buddy/widget/new_message_widget.dart';


class ChatPage extends StatefulWidget {
  final UserModel user, my_account;

  const ChatPage({
    required this.user,
    required this.my_account,
    Key? key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var chatLinkId = '';

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    final id = (await CloudFirestoreApi.addChatLink(
        widget.user.user_id, widget.my_account.user_id))!;
    setState(() {
      chatLinkId = id;

      if (chatLinkId != '') {
        CloudFirestoreApi.updateAllseen(chatLinkId, widget.user.user_id);
        CloudFirestoreApi.updateUserStay(widget.my_account.user_id, chatLinkId);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    CloudFirestoreApi.updateUserStay(widget.my_account.user_id, '');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.blue,
        body: Scaffold(
          appBar: AppBar(
              title: Text(
            widget.user.name,
            style: GoogleFonts.kanit(),
          )),
          body: Column(
            children: [
              //ProfileHeaderWidget(name: widget.user.name),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        // topLeft: Radius.circular(25),
                        // topRight: Radius.circular(25),
                        ),
                  ),
                  child: chatLinkId != ''
                      ? MessagesWidget(
                          user_id: widget.user.user_id,
                          chatLinkId: chatLinkId,
                          my_account: widget.my_account)
                      : Container(),
                ),
              ),
              NewMessageWidget(
                  user_id: widget.user.user_id, my_account: widget.my_account)
            ],
          ),
        ),
      );
}
