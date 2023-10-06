import 'dart:async';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layout/social_app/cubit/cubit.dart';
import 'package:social_app/layout/social_app/cubit/states.dart';
import 'package:social_app/models/social_app/message_model.dart';
import 'package:social_app/models/social_app/social_user_model.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/functions.dart';
import 'package:social_app/shared/styles/colors.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

class ChatDetailsScreen extends StatelessWidget {
  SocialUserModel receiveUserModel;

  ChatDetailsScreen({
    super.key,
    required this.receiveUserModel,
  });

  var messageController = TextEditingController();
  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    var myUserModel = SocialCubit.get(context).userModel;
    return Builder(
      builder: (BuildContext context) {
        SocialCubit.get(context).getMessages(receiverId: receiveUserModel.uId!);
        return BlocConsumer<SocialCubit, SocialStates>(
          listener: (context, state) {},
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                titleSpacing: 0.0,
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.0,
                      backgroundImage: NetworkImage(receiveUserModel.image!),
                    ),
                    const SizedBox(width: 15.0),
                    Text(receiveUserModel.name!),
                  ],
                ),
              ),
              body: ConditionalBuilder(
                condition: SocialCubit.get(context).messages.isNotEmpty,
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            var message =
                                SocialCubit.get(context).messages[index];

                            return Dismissible(
                              confirmDismiss:
                                  (DismissDirection direction) async {
                                await (showCustomAlert
                                  context,
                                  title: 'Remove',
                                  content:
                                      'Are you sure you want to delete this message? 🐼',
                                  confirmActionText: 'Delete',
                                  cancelActionText: 'Cancel',
                                  confirmActionPressed: () {
                                    //to do
                                  },
                                );
                              },
                              onDismissed: (direction) {
                                if (direction == DismissDirection.startToEnd) {
                                  showToast(
                                      text: 'delete it?',
                                      state: ToastStates.WARNING);
                                }
                              },
                              key: Key('${'d $index'}'),
                              child: SocialCubit.get(context).userModel.uId ==
                                      message.senderId
                                  ? buildMyMessage(
                                      message, myUserModel, context, index)
                                  : buildMessage(message),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 15.0),
                          itemCount: SocialCubit.get(context).messages.length,
                        ),
                      ),
                      if (SocialCubit.get(context).messageImage != null)
                        buildImageTemp(context),
                      const SizedBox(height: 10),
                      buildButtonSend(context),
                    ],
                  ),
                ),
                fallback: (context) => Column(
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          'There are no messages yet\n start chatting now',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    buildButtonSend(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Stack buildImageTemp(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        Container(
          height: 140.0,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            image: DecorationImage(
              image: FileImage(SocialCubit.get(context).messageImage!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        IconButton(
          icon: const CircleAvatar(
            radius: 20.0,
            child: Icon(
              Icons.close,
              size: 16.0,
            ),
          ),
          onPressed: () {
            SocialCubit.get(context).removeMessageImage();
          },
        ),
      ],
    );
  }

  Widget buildMessage(MessageModel receiveMessageModel) => Align(
        alignment: AlignmentDirectional.topStart,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadiusDirectional.only(
                    bottomEnd: Radius.circular(10.0),
                    topStart: Radius.circular(10.0),
                    topEnd: Radius.circular(10.0),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(
                        receiveUserModel.name!,
                        style: const TextStyle(
                            color: Colors.deepPurpleAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ),
                    if (receiveMessageModel.image != null &&
                        receiveMessageModel.image == '')
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(15)),
                        child: Image.network(
                          receiveMessageModel.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    Align(
                        alignment:
                            MyFunctions.isArabic(receiveMessageModel.text!)
                                ? AlignmentDirectional.centerEnd
                                : AlignmentDirectional.centerStart,
                        child: Text(receiveMessageModel.text!)),
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Text(
                          receiveMessageModel.dateTime!.substring(10, 16),
                          style: const TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
            CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(receiveUserModel.image!),
            ),
          ],
        ),
      );

  Widget buildMyMessage(MessageModel myMessageModel,
          SocialUserModel myUserModel, BuildContext context, int index) =>
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // SocialCubit.get(context).messages[index].senderId ==
            //         SocialCubit.get(context).messages[index - 1].senderId
            (index + 1).toString() == (index).toString()
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: Text('${index}'),
                  )
                : CircleAvatar(
                    radius: 20.0,
                    backgroundImage: NetworkImage(myUserModel.image!),
                  ),
            const SizedBox(width: 5),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: defaultColor.shade200,
                  borderRadius: const BorderRadiusDirectional.only(
                    bottomStart: Radius.circular(10.0),
                    topStart: Radius.circular(10.0),
                    topEnd: Radius.circular(10.0),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: Column(
                  children: [
                    // Align(
                    //     alignment: AlignmentDirectional.topStart,
                    //     child: Text(
                    //       myUserModel.name!,
                    //       style: const TextStyle(
                    //           color: Colors.deepOrangeAccent,
                    //           fontWeight: FontWeight.bold,
                    //           letterSpacing: 1),
                    //     )),
                    if (myMessageModel.image != null &&
                        myMessageModel.image != '')
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(15)),
                        child: Image.network(
                          myMessageModel.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    Align(
                      alignment: MyFunctions.isArabic(myMessageModel.text!)
                          ? AlignmentDirectional.centerEnd
                          : AlignmentDirectional.centerStart,
                      child: Text(myMessageModel.text!),
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Text(
                        myMessageModel.dateTime!.substring(10, 16),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildButtonSend(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(
          15.0,
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Row(
        children: [
          Expanded(
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                ),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'message must not be empty';
                    }
                    return null;
                  },
                  controller: messageController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'type your message here ...',
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 50.0,
            color: defaultColor,
            child: Row(
              children: [
                buildCameraButton(context, receiveUserModel.uId.toString()),
                const VerticalDivider(
                  color: Colors.white,
                  width: 1,
                ),
                BlocBuilder<SocialCubit, SocialStates>(
                  builder: (context, state) => state
                          is SocialSendMessageLoadingState
                      ? const CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.white)
                      : MaterialButton(
                          onPressed: () {
                            if (formKey.currentState!.validate() ||
                                SocialCubit.get(context).messageImage != null) {
                              SocialCubit.get(context).sendMessage(
                                receiverId: receiveUserModel.uId!,
                                dateTime: DateTime.now().toString(),
                                text: messageController.text,
                                image: SocialCubit.get(context).messageImage,
                              );
                              _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent);

                              //clear textformfield
                              messageController.text = '';
                            }
                          },
                          minWidth: 1.0,
                          child: const Icon(
                            IconBroken.Send,
                            size: 16.0,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container buildCameraButton(
      BuildContext context, String receiveUserModelUid) {
    return Container(
      height: double.infinity,
      color: Colors.grey[100],
      child: MaterialButton(
        onPressed: () {
          SocialCubit.get(context).getMessagetImage();
        },
        minWidth: 1.0,
        child: const Icon(
          IconBroken.Camera,
          size: 16.0,
          color: Colors.black,
        ),
      ),
    );
  }
}
