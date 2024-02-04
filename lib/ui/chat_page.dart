import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:testvalleyflutter/constants/app_constants.dart';
import 'package:testvalleyflutter/ui/widget/current_chat.dart';
import 'package:testvalleyflutter/ui/widget/group_chat.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  OpenChannel? _channel;
  List<BaseMessage> _messages = [];
  TextEditingController messageController = TextEditingController();
  bool hasText = false;
  bool isLoading = false;
  User? user;

  @override
  void initState() {
    super.initState();
    // _initSendbird();
    loadSendbird();
  }

  @override
  dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<User?> connectWithSendbird() async {
    try {
      final sendbird = SendbirdSdk(appId:AppConstants.appId, apiToken:AppConstants. apiToken);
      final user = await sendbird.connect(AppConstants.userId);
      return user;
    } catch (e) {
      throw e;
    }
  }

  void loadSendbird() async {
    isLoading = true;
    setState(() {});
    try {
      user = await connectWithSendbird();
      setState(() {});
      _channel = await OpenChannel.getChannel(AppConstants.channelUrl);
      _channel?.enter();
      setState(() {});

      // Retrieve any existing messages from the GroupChannel
      final messages = await _channel?.getMessagesByTimestamp(
        DateTime.now().millisecondsSinceEpoch * 1000,
        MessageListParams(),
      );

      // Update & prompt the UI to rebuild
      setState(() {
        _messages = messages!;
      });

      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
    }
  }

  _sendMessage(String text, OpenChannel channel) async {
    try {
      setState(() {
        isLoading = true;
      });
      final params = UserMessageParams(
        message: text,
      );
      final message = channel.sendUserMessage(params);

      channel.sendUserMessage(params, onCompleted: (message, error) async {
        if (error != null) {
          setState(() {
            isLoading = false;
          });
        } else {
          await connectWithSendbird();
          messageController = TextEditingController();

          setState(() {
            isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0E0D0D),
      endDrawer: Drawer(
        backgroundColor: Color(0xff0E0D0D),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xffF5F5F5), size: 24),
        centerTitle: true,
        leading: Icon(
          Icons.arrow_back_ios,
          color: Color(0xffF5F5F5),
        ),
        backgroundColor: Colors.transparent,
        title: Text(
          '강남스팟',
          style: TextStyle(
              color: Color(0xffF5F5F5),
              fontSize: 15,
              fontWeight: FontWeight.w500),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(
                  0xffFF006B,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return AppConstants.userId == _messages[index].sender!.userId
                          ? CurrentUserChat(
                              baseMessage: _messages[index],
                            )
                          : GroupChatItem(
                              baseMessage: _messages[index],
                            );
                    },
                  ),
                ),
                Container(
                  color: Color(131313),
                  padding:
                      const EdgeInsets.symmetric(vertical: 36, horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          size: 24,
                          color: Color(0xffF5F5F5),
                        ),
                        onPressed: () {},
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: messageController,
                          style:
                              TextStyle(color: Color(0xffFCFCFC), fontSize: 14),
                          onChanged: (val) {
                            setState(() {
                              hasText = val.isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                              hintText: "메세지 보내기",
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 20,
                              ),
                              hintStyle: TextStyle(
                                  color: Color(0xff666666), fontSize: 14),
                              prefixIconConstraints:
                                  BoxConstraints(maxWidth: 10),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xff323232)),
                                  borderRadius: BorderRadius.circular(48)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xff323232)),
                                  borderRadius: BorderRadius.circular(48)),
                              suffixIcon: InkWell(
                                onTap: () {
                                  _sendMessage(
                                      messageController.text, _channel!);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 12),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Color(
                                      hasText ? 0xffFF006A : 0xff3A3A3A,
                                    ),
                                    child: Icon(
                                      Icons.arrow_upward,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              )),
                          onFieldSubmitted: (text) {
                            _sendMessage(text, _channel!);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

