import 'dart:developer';

import 'package:chat_gpt_bot/utils/AppColors.dart';
import 'package:chat_gpt_bot/utils/AppConstant.dart';
import 'package:chat_gpt_bot/models/ChatModels.dart';
import 'package:chat_gpt_bot/utils/ImageUtils.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final openAI = ChatGPT.instance.builder(AppConstant.CHAT_GPT_TOKEN,
      baseOption: HttpSetup(receiveTimeout: 6000));
  TextEditingController controller = new TextEditingController();
  List<ChatModels> chats = [];
  bool isListen = true;
  bool isBotTyping = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // _callGetChats();
    super.initState();
  }

  _scrollToBottom() {
    if (scrollController.hasClients)
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  void addMyMessage() {
    if (controller.text.isNotEmpty) {
      chats.add(ChatModels(
          text: controller.text,
          owner: AppConstant.YOU,
          dateTime: DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now())));
      
      askQuestionToBot(controller.text);
      controller.clear();
      changeStatus(true);
    }
  }

  void addBotMessage(String reply) {
    if (isListen == true) {
      chats.add(ChatModels(
          text: reply,
          owner: AppConstant.BOT,
          dateTime: DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now())));

      setState(() {
        isBotTyping = false;
      });
      changeStatus(false);
    }
  }

  void changeStatus(bool val) {
    setState(() {
      isListen = val;
    });
    _scrollToBottom();
  }

  void askQuestionToBot(String question) {
    // debugger();

    setState(() {
      isBotTyping = true;
    });
    final request = CompleteReq(
        prompt: question, model: kTranslateModelV3, max_tokens: 200);

    openAI.onCompleteStream(request: request).listen((response) {
      addBotMessage(response!.choices.last.text.trimLeft());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.mainColor,
          centerTitle: true,
          title: const Text(
            "Chat With Me",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        body: Stack(children: [
          chats.length == 0
              ? Center(
                  child: Image.asset(
                    ImageUtils.EMPTY_CHAT_LOADER,
                    height: 200,
                    width: 200,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: chats.length + 1,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    // physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return index == chats.length
                          ? isBotTyping == false
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(
                                      left: 14, right: 14, top: 10, bottom: 10),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.all(16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              ImageUtils.BOT_TYPING_GIT,
                                              height: 40,
                                              fit: BoxFit.fill,
                                              width: 100,
                                            ),
                                          ],
                                        )),
                                  ),
                                )
                          : Container(
                              padding: EdgeInsets.only(
                                  left: 14, right: 14, top: 10, bottom: 10),
                              child: Align(
                                alignment:
                                    (chats[index].owner == AppConstant.BOT
                                        ? Alignment.topLeft
                                        : Alignment.topRight),
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        (chats[index].owner == AppConstant.BOT
                                            ? Colors.grey.shade200
                                            : Colors.blue[200]),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    chats[index].text,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            );
                    },
                  ),
                ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue[100],
                ),
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                            hintText: "Write message...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        addMyMessage();
                        // _scrollToBottom();
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      // focusColor: Colors.red,
                      backgroundColor: AppColors.mainColor,
                      elevation: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]));
  }
}
