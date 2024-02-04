import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String appId = "BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF";
  final String apiToken = "f93b05ff359245af400aa805bafd2a091a173064";
  final String channelUrl =
      "sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211";
  final String apiUrl =
      "https://api-BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF.sendbird.co";
  String userId = "WoynshetBilihatu";

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
      final sendbird = SendbirdSdk(appId: appId, apiToken: apiToken);
      final user = await sendbird.connect(userId);
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
      _channel = await OpenChannel.getChannel(channelUrl);
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
                      return userId == _messages[index].sender!.userId
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

class GroupChatItem extends StatelessWidget {
  final BaseMessage baseMessage;
  const GroupChatItem({super.key, required this.baseMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                child: CircleAvatar(
                  radius: 16,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(18),
                      ),
                      color: Color(
                        0xff1A1A1A,
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            baseMessage.sender!.nickname,
                            style: TextStyle(
                                color: Color(0xffADADAD), fontSize: 14),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(
                                0xff46F9F5,
                              ),
                              gradient: baseMessage.sender!.isActive!
                                  ? null
                                  : LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        Color(
                                          0xff101010,
                                        ),
                                        Color(0xff2F2F2F)
                                      ],
                                    ),
                            ),
                          )
                        ],
                      ),
                      Text(
                        baseMessage.message,
                        style:
                            TextStyle(color: Color(0xffFFFFFF), fontSize: 16),
                      ),
                    ],
                  )),
            ],
          ),
          SizedBox(
            width: 10,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              timeAgo(baseMessage.createdAt),
              style: TextStyle(fontSize: 12, color: Color(0xff9C9CA3)),
            ),
          )
        ],
      ),
    );
  }

  String timeAgo(createdAt) {
    timeago.setLocaleMessages('ko', timeago.KoMessages());
    DateTime sentAt = DateTime.fromMillisecondsSinceEpoch(createdAt);
    DateTime now = DateTime.now();
    Duration difference = now.difference(sentAt);
    String timeAgo = timeago.format(now.subtract(difference), locale: 'ko');
    return timeAgo;
  }
}

// ignore: must_be_immutable
class CurrentUserChat extends StatelessWidget {
  BaseMessage baseMessage;
  CurrentUserChat({super.key, required this.baseMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4),
                  topLeft: Radius.circular(18),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(18),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(
                      0xffFF006B,
                    ),
                    Color(0xffFF4593)
                  ],
                )),
            child: Text(
              baseMessage.message,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        ],
      ),
    );
  }
}
